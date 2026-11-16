import 'dart:math';

import 'package:impostor_tn/features/game/application/active_game.dart';
import 'package:impostor_tn/features/game/application/checkpoint.dart';
import 'package:impostor_tn/features/game/application/game_steps.dart';
import 'package:impostor_tn/features/game/application/launch.dart';
import 'package:impostor_tn/features/setup/application/player_names.dart';
import 'package:impostor_tn/game/ballot.dart';
import 'package:impostor_tn/game/content/content_catalog.dart';
import 'package:impostor_tn/game/content/content_eligibility.dart';
import 'package:impostor_tn/game/cooldown/word_selection.dart';
import 'package:impostor_tn/game/game_engine.dart';
import 'package:impostor_tn/game/game_phase.dart';
import 'package:impostor_tn/game/game_rejection.dart';
import 'package:impostor_tn/game/game_rules.dart';
import 'package:impostor_tn/game/game_session.dart';
import 'package:impostor_tn/game/persistence/saved_state.dart';
import 'package:impostor_tn/game/persistence/session_snapshot.dart';
import 'package:impostor_tn/game/persistence/state_store.dart';
import 'package:impostor_tn/game/player.dart';
import 'package:impostor_tn/game/session_restore.dart';

/// The checkpoints C0–C9 of `UX_FLOWS.md` §3 (ADR-0003).
///
/// Each call runs alone, in call order: it re-reads the saved state, decides
/// through the engine, writes one document, and only then returns [Saved].
/// An action whose effect is already saved writes nothing and returns
/// [Saved] with the current game (UX_FLOWS §3.1 rule 1), so a retry, a
/// double tap or a restart can never apply it twice.
final class GameService {
  GameService({
    required this._store,
    required this._catalog,
    required this._channel,
    required this._random,
  });

  final StateStore _store;
  final ContentCatalog _catalog;
  final ContentChannel _channel;
  final Random _random;

  Future<void> _queue = Future.value();

  /// Set when launch could not read storage and told the group the game
  /// could not be restored. Whatever session is found later is then treated
  /// as cancelled, as announced, never resumed behind their back. Cleared by
  /// the next committed write, which no longer contains it.
  bool _sessionWithdrawn = false;

  /// F1: resume a valid game, or cancel a damaged one and go Home.
  Future<Launch> launch() => _serial(() async {
    final read = await _store.read();
    if (read is! StoreLoaded) {
      _sessionWithdrawn = true;
      return LaunchHome(roster: SavedRoster.empty, restoreFailed: true);
    }
    final state = read.state;
    final game = state.session == null ? null : _restore(state.session!);
    final sessionLost =
        read.discarded.contains(DiscardedPart.session) ||
        (state.session != null && game == null);
    if (sessionLost || read.discarded.isNotEmpty) {
      // Cancel safely: drop what cannot be trusted, keep the rest (ADR-0003).
      // If this write fails the damaged session is still never used.
      await _write(game == null ? state.withSession(null) : state);
    }
    if (game != null) return LaunchResume(game);
    return LaunchHome(roster: state.roster, restoreFailed: sessionLost);
  });

  /// C0: the roster and packs kept for the next game.
  Future<Checkpoint<SavedRoster>> saveRoster(SavedRoster roster) =>
      _serial(() async {
        final names = [for (final player in roster.players) player.name];
        if (roster.players.length > GameRules.maxPlayers ||
            !PlayerNames.allValid(names) ||
            roster.players.map((p) => p.id).toSet().length != names.length ||
            roster.packIds.toSet().length != roster.packIds.length) {
          return const Refused(RefusalReason.invalidRoster);
        }
        final normalized = SavedRoster(
          players: [
            for (final player in roster.players)
              Player(id: player.id, name: PlayerNames.normalize(player.name)),
          ],
          packIds: roster.packIds,
        );
        final state = await _read();
        if (state == null) return const SaveFailed();
        final next = SavedState(
          cooldown: state.cooldown,
          roster: normalized,
          session: state.session,
        );
        return switch (await _write(next)) {
          StoreWrite.committed => Saved(normalized),
          StoreWrite.failed => const SaveFailed(),
        };
      });

  /// C1: a new session from the saved roster. The word is chosen but not
  /// consumed (D-21). A second call while a game exists returns that game.
  Future<Checkpoint<ActiveGame>> startGame() => _serial(() async {
    final state = await _read();
    if (state == null) return const SaveFailed();
    if (state.session case final saved?) {
      if (_restore(saved) case final existing?) return Saved(existing);
    }
    return _createGame(state, state.roster.players, state.roster.packIds);
  });

  /// C2: the first "I am {name}" of the game records the word in the
  /// cooldown and marks it consumed, in one write (D-21).
  Future<Checkpoint<ActiveGame>> confirmIdentity(
    String sessionId,
    PlayerId player,
  ) => _advance(sessionId, (game) => GameSteps.confirmIdentity(game, player));

  /// C3.
  Future<Checkpoint<ActiveGame>> acknowledge(
    String sessionId,
    PlayerId player,
  ) => _advance(sessionId, (game) => GameSteps.acknowledge(game, player));

  /// C4.
  Future<Checkpoint<ActiveGame>> openVoting(String sessionId) =>
      _advance(sessionId, GameSteps.openVoting);

  /// C5 (first ballot) and C6 (runoff). [ballot] names the ballot the vote
  /// was cast in, so a retried first-ballot vote never lands in the runoff.
  Future<Checkpoint<ActiveGame>> castVote(
    String sessionId, {
    required BallotKind ballot,
    required PlayerId voter,
    required PlayerId target,
  }) => _advance(
    sessionId,
    (game) => GameSteps.castVote(game, ballot, voter: voter, target: target),
  );

  /// C7.
  Future<Checkpoint<ActiveGame>> submitFinalGuess(
    String sessionId,
    String rawGuess,
  ) => _advance(sessionId, (game) => GameSteps.finalGuess(game, rawGuess));

  /// C8: the session is deleted; roster, packs and cooldown are kept. A
  /// consumed word stays in the cooldown. Never deletes a different game:
  /// if one is saved (a replay committed first), the call is refused so the
  /// caller does not believe it left.
  Future<Checkpoint<SavedRoster>> endSession(String sessionId) =>
      _serial(() async {
        final state = await _read();
        if (state == null) return const SaveFailed();
        final saved = state.session;
        if (saved == null) return Saved(state.roster);
        final game = _restore(saved);
        if (game != null && game.sessionId != sessionId) {
          return const Refused(RefusalReason.staleSession);
        }
        return switch (await _write(state.withSession(null))) {
          StoreWrite.committed => Saved(state.roster),
          StoreWrite.failed => const SaveFailed(),
        };
      });

  /// C9: replaces a finished session with a new one for the same players and
  /// packs, in one write. On any failure the finished result stays.
  Future<Checkpoint<ActiveGame>> playAgain(String sessionId) =>
      _serial(() async {
        final state = await _read();
        if (state == null) return const SaveFailed();
        final game = state.session == null ? null : _restore(state.session!);
        if (game == null) return const Refused(RefusalReason.staleSession);
        // A retry after a committed replay finds the new game already there.
        if (game.sessionId != sessionId) return Saved(game);
        // PRD §9: only a finished game is replayed (as GameEngine.replay).
        if (game.session.phase is! ResultPhase) {
          return const Refused(
            RefusalReason.rule,
            rule: GameRejection.wrongPhase,
          );
        }
        return _createGame(state, game.session.players, game.packIds);
      });

  Future<Checkpoint<ActiveGame>> _createGame(
    SavedState state,
    List<Player> players,
    List<String> packIds,
  ) async {
    if (players.length < GameRules.minPlayers ||
        players.length > GameRules.maxPlayers ||
        !PlayerNames.allValid([for (final p in players) p.name])) {
      return const Refused(RefusalReason.invalidRoster);
    }
    if (packIds.isEmpty) return const Refused(RefusalReason.noPackSelected);

    final selection = WordSelector.select(
      candidates: ContentEligibility.candidates(_catalog, packIds, _channel),
      cooldown: state.cooldown,
      random: _random,
    );
    if (selection is! WordSelected) {
      return const Refused(RefusalReason.noEligibleWord);
    }
    final GameSession session;
    switch (GameEngine.start(
      players: players,
      word: selection.word.toSecretWord(),
      random: _random,
    )) {
      case Accepted(session: final started):
        session = started;
      case Rejected(:final reason):
        return Refused(RefusalReason.invalidRoster, rule: reason);
    }
    return _commit(
      state,
      ActiveGame(
        sessionId: _newSessionId(),
        session: session,
        packIds: packIds,
        wordConsumed: false,
        wordVersion: selection.word.version,
      ),
    );
  }

  Future<Checkpoint<ActiveGame>> _advance(
    String sessionId,
    StepOutcome Function(ActiveGame game) step,
  ) => _serial(() async {
    final state = await _read();
    if (state == null) return const SaveFailed();
    final game = state.session == null ? null : _restore(state.session!);
    if (game == null || game.sessionId != sessionId) {
      return const Refused(RefusalReason.staleSession);
    }
    return switch (step(game)) {
      AlreadyDone() => Saved(game),
      Refuse(:final reason, :final rule) => Refused(reason, rule: rule),
      Advance(:final next, :final consumeWord) => _commit(
        state,
        next,
        consumeWord: consumeWord,
      ),
    };
  });

  Future<Checkpoint<ActiveGame>> _commit(
    SavedState base,
    ActiveGame next, {
    bool consumeWord = false,
  }) async {
    final state = SavedState(
      cooldown: consumeWord
          ? base.cooldown.record(next.session.word.wordId)
          : base.cooldown,
      roster: base.roster,
      session: SessionSnapshot.save(
        sessionId: next.sessionId,
        packIds: next.packIds,
        wordConsumed: next.wordConsumed,
        wordVersion: next.wordVersion,
        session: next.session,
      ),
    );
    return switch (await _write(state)) {
      StoreWrite.committed => Saved(next),
      StoreWrite.failed => const SaveFailed(),
    };
  }

  /// The saved state as this service may use it, or null if storage failed.
  Future<SavedState?> _read() async {
    final read = await _store.read();
    if (read is! StoreLoaded) return null;
    return _sessionWithdrawn ? read.state.withSession(null) : read.state;
  }

  Future<StoreWrite> _write(SavedState state) async {
    final result = await _store.write(state);
    if (result == StoreWrite.committed) _sessionWithdrawn = false;
    return result;
  }

  /// A saved session as a game, or null if it must be cancelled. Beyond the
  /// rules (SessionSnapshot), the word must still be playable in this build
  /// (PRD §10: a word withdrawn by an update is never shown again) and the
  /// names must still satisfy D-15.
  ActiveGame? _restore(SavedSession saved) {
    final entry = _catalog.wordById(saved.word.id);
    if (entry == null || !ContentEligibility.isPlayable(entry, _channel)) {
      return null;
    }
    if (!PlayerNames.allValid([for (final p in saved.players) p.name])) {
      return null;
    }
    return switch (SessionSnapshot.restore(saved, _catalog)) {
      Restored(:final session) => ActiveGame(
        sessionId: saved.sessionId,
        session: session,
        packIds: saved.packIds,
        wordConsumed: saved.wordConsumed,
        wordVersion: saved.word.version,
      ),
      Corrupt() => null,
    };
  }

  String _newSessionId() => [
    for (var i = 0; i < 16; i++)
      _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ].join();

  Future<T> _serial<T>(Future<T> Function() action) {
    final result = _queue.then((_) => action());
    // Keeps the queue going after a failure; the caller still gets the error.
    _queue = result.then<void>((_) {}, onError: (Object _) {});
    return result;
  }
}
