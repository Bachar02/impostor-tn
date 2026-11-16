import 'package:impostor_tn/game/game_session.dart';

/// Why the engine refused an action. Carries no game data, so it is safe in
/// any message (PRD §12).
enum GameRejection {
  tooFewPlayers,
  tooManyPlayers,
  duplicatePlayer,

  /// The selected word has an empty canonical form.
  invalidWord,

  /// The action does not belong to the current phase.
  wrongPhase,

  /// The player is not part of this session.
  unknownPlayer,

  /// Another player is next in playing order.
  notThisPlayersTurn,

  /// This player already acknowledged; a retry finds the work done.
  alreadyAcknowledged,

  /// This player already voted in this ballot (D-02: no change).
  alreadyVoted,

  selfVote,

  /// The target is not eligible in this ballot (runoff candidates only).
  notACandidate,

  /// The final guess is empty after D-01 normalization (D-16).
  emptyGuess,
}

/// The result of a transition: the next session, or why it was refused.
sealed class Transition {
  const Transition();
}

final class Accepted extends Transition {
  const Accepted(this.session);

  final GameSession session;
}

final class Rejected extends Transition {
  const Rejected(this.reason);

  final GameRejection reason;

  @override
  String toString() => 'Rejected(${reason.name})';
}
