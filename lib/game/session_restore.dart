import 'package:impostor_tn/game/game_engine.dart';
import 'package:impostor_tn/game/game_phase.dart';
import 'package:impostor_tn/game/game_rejection.dart';
import 'package:impostor_tn/game/game_session.dart';
import 'package:impostor_tn/game/player.dart';
import 'package:impostor_tn/game/secret_word.dart';

/// The facts a saved session consists of (PRD §11), as read from storage.
/// [toString] is redacted.
final class RecordedSession {
  const RecordedSession({
    required this.players,
    required this.impostor,
    required this.word,
    required this.phase,
    this.acknowledged = const {},
    this.firstBallotVotes = const {},
    this.runoffVotes = const {},
    this.finalGuess,
  });

  final List<Player> players;
  final PlayerId impostor;
  final SecretWord word;
  final GamePhaseKind phase;
  final Set<PlayerId> acknowledged;

  /// Voter → target.
  final Map<PlayerId, PlayerId> firstBallotVotes;
  final Map<PlayerId, PlayerId> runoffVotes;
  final String? finalGuess;

  @override
  String toString() => 'RecordedSession(${phase.name}, <redacted>)';
}

/// Why a saved session cannot be resumed. Carries no game data.
enum SessionCorruption {
  invalidRoster,
  impostorNotAPlayer,
  invalidWord,

  /// The facts cannot have been produced by the rules: a gap in the
  /// acknowledgements, a self-vote, a vote in a phase never reached, an id
  /// that is not a player.
  inconsistentFacts,

  /// The facts are valid but lead to a different phase than the one stored.
  phaseMismatch,
}

sealed class RestoreResult {
  const RestoreResult();
}

final class Restored extends RestoreResult {
  const Restored(this.session);

  final GameSession session;
}

final class Corrupt extends RestoreResult {
  const Corrupt(this.reason);

  final SessionCorruption reason;

  @override
  String toString() => 'Corrupt(${reason.name})';
}

/// Rebuilds a session by replaying the recorded facts through [GameEngine].
///
/// The rules are applied, never repaired: anything they refuse makes the
/// session [Corrupt], and the caller cancels it safely (PRD §11, ADR-0003).
/// The stored assignment is used as is; nothing is drawn again.
abstract final class SessionRestore {
  static RestoreResult restore(RecordedSession recorded) {
    if (GameEngine.validateRoster(recorded.players) != null) {
      return const Corrupt(SessionCorruption.invalidRoster);
    }
    final ids = [for (final player in recorded.players) player.id];
    if (!ids.contains(recorded.impostor)) {
      return const Corrupt(SessionCorruption.impostorNotAPlayer);
    }
    if (!GameEngine.isUsableWord(recorded.word)) {
      return const Corrupt(SessionCorruption.invalidWord);
    }
    final everyIdKnown = [
      ...recorded.acknowledged,
      ...recorded.firstBallotVotes.keys,
      ...recorded.firstBallotVotes.values,
      ...recorded.runoffVotes.keys,
      ...recorded.runoffVotes.values,
    ].every(ids.contains);
    if (!everyIdKnown) {
      return const Corrupt(SessionCorruption.inconsistentFacts);
    }

    // Facts are replayed in playing order, the only order the rules accept.
    final steps = <Transition Function(GameSession)>[
      for (final id in ids)
        if (recorded.acknowledged.contains(id))
          (s) => GameEngine.acknowledge(s, id),
      if (recorded.phase.index >= GamePhaseKind.firstBallot.index)
        GameEngine.openVoting,
      for (final id in ids)
        if (recorded.firstBallotVotes[id] case final target?)
          (s) => GameEngine.castVote(s, voter: id, target: target),
      for (final id in ids)
        if (recorded.runoffVotes[id] case final target?)
          (s) => GameEngine.castVote(s, voter: id, target: target),
      if (recorded.finalGuess case final guess?)
        (s) => GameEngine.submitFinalGuess(s, guess),
    ];

    var session = GameSession(
      players: recorded.players,
      impostor: recorded.impostor,
      word: recorded.word,
      phase: RevealPhase(),
    );
    for (final step in steps) {
      switch (step(session)) {
        case Accepted(session: final next):
          session = next;
        case Rejected():
          return const Corrupt(SessionCorruption.inconsistentFacts);
      }
    }
    if (session.phase.kind != recorded.phase) {
      return const Corrupt(SessionCorruption.phaseMismatch);
    }
    return Restored(session);
  }
}
