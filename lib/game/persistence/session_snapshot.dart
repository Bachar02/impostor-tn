import 'package:impostor_tn/game/content/content_catalog.dart';
import 'package:impostor_tn/game/game_outcome.dart';
import 'package:impostor_tn/game/game_phase.dart';
import 'package:impostor_tn/game/game_session.dart';
import 'package:impostor_tn/game/persistence/saved_state.dart';
import 'package:impostor_tn/game/session_restore.dart';

/// Converts between a live [GameSession] and the facts that are saved.
abstract final class SessionSnapshot {
  /// The facts of [session] (PRD §11). The word is saved by reference only.
  static SavedSession save({
    required String sessionId,
    required List<String> packIds,
    required bool wordConsumed,
    required int wordVersion,
    required GameSession session,
  }) {
    final phase = session.phase;
    final (first, runoff) = switch (phase) {
      RevealPhase() || DiscussionPhase() => (null, null),
      FirstBallotPhase(:final ballot) => (ballot, null),
      RunoffPhase(:final firstBallot, :final runoff) => (firstBallot, runoff),
      FinalGuessPhase(:final ballots) || ResultPhase(:final ballots) => (
        ballots.first,
        ballots.length > 1 ? ballots[1] : null,
      ),
    };
    return SavedSession(
      sessionId: sessionId,
      players: session.players,
      packIds: packIds,
      impostor: session.impostor,
      word: WordReference(id: session.word.wordId, version: wordVersion),
      wordConsumed: wordConsumed,
      phase: phase.kind,
      acknowledged: switch (phase) {
        RevealPhase(:final acknowledged) => acknowledged,
        _ => [...session.playerIds],
      },
      firstBallotVotes: first?.votes ?? const {},
      runoffVotes: runoff?.votes ?? const {},
      finalGuess: switch (phase) {
        ResultPhase(outcome: ImpostorGuessed(:final rawGuess)) => rawGuess,
        _ => null,
      },
    );
  }

  /// Rebuilds the session from [saved] through the rules (ADR-0003).
  ///
  /// The word must still exist in [catalog] at the saved version; a word
  /// that changed or disappeared makes the session corrupt rather than
  /// replacing it. Every role shown requires the word to have been consumed
  /// first (D-21), so an acknowledgement without it is corrupt as well.
  static RestoreResult restore(SavedSession saved, ContentCatalog catalog) {
    final entry = catalog.wordById(saved.word.id);
    if (entry == null || entry.version != saved.word.version) {
      return const Corrupt(SessionCorruption.invalidWord);
    }
    if (!saved.wordConsumed &&
        (saved.acknowledged.isNotEmpty ||
            saved.phase != GamePhaseKind.reveal)) {
      return const Corrupt(SessionCorruption.inconsistentFacts);
    }
    if (saved.acknowledged.toSet().length != saved.acknowledged.length) {
      return const Corrupt(SessionCorruption.inconsistentFacts);
    }
    return SessionRestore.restore(
      RecordedSession(
        players: saved.players,
        impostor: saved.impostor,
        word: entry.toSecretWord(),
        phase: saved.phase,
        acknowledged: saved.acknowledged.toSet(),
        firstBallotVotes: saved.firstBallotVotes,
        runoffVotes: saved.runoffVotes,
        finalGuess: saved.finalGuess,
      ),
    );
  }
}
