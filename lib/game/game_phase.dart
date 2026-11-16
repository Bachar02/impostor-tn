import 'package:impostor_tn/game/ballot.dart';
import 'package:impostor_tn/game/game_outcome.dart';
import 'package:impostor_tn/game/player.dart';

/// Phase names as persisted and checked on restore (ADR-0003).
enum GamePhaseKind {
  reveal,
  discussion,
  firstBallot,
  runoff,
  finalGuess,
  result,
}

/// The phase of a session. Each subtype carries exactly the state that phase
/// needs. Ballots hold secrets, so every [toString] is redacted.
sealed class GamePhase {
  const GamePhase();

  GamePhaseKind get kind;

  @override
  String toString() => 'GamePhase(${kind.name})';
}

/// Players reveal and acknowledge their roles, in playing order.
final class RevealPhase extends GamePhase {
  RevealPhase({List<PlayerId> acknowledged = const []})
    : acknowledged = List.unmodifiable(acknowledged);

  /// Players who acknowledged, in order: always a prefix of the roster.
  final List<PlayerId> acknowledged;

  @override
  GamePhaseKind get kind => GamePhaseKind.reveal;
}

/// Spoken clues; nothing is recorded (PRD §6, D-03).
final class DiscussionPhase extends GamePhase {
  const DiscussionPhase();

  @override
  GamePhaseKind get kind => GamePhaseKind.discussion;
}

final class FirstBallotPhase extends GamePhase {
  const FirstBallotPhase(this.ballot);

  final Ballot ballot;

  @override
  GamePhaseKind get kind => GamePhaseKind.firstBallot;
}

/// The single runoff among the players tied at the top (PRD §7).
final class RunoffPhase extends GamePhase {
  const RunoffPhase({required this.firstBallot, required this.runoff});

  /// Complete and tied; kept for the result screen.
  final Ballot firstBallot;
  final Ballot runoff;

  @override
  GamePhaseKind get kind => GamePhaseKind.runoff;
}

/// The Impostor was nominated and has one guess (PRD §8).
final class FinalGuessPhase extends GamePhase {
  const FinalGuessPhase({required this.ballots, required this.nominee});

  /// The completed ballots: the first, and the runoff if there was one.
  final List<Ballot> ballots;
  final PlayerId nominee;

  @override
  GamePhaseKind get kind => GamePhaseKind.finalGuess;
}

final class ResultPhase extends GamePhase {
  const ResultPhase({required this.ballots, required this.outcome});

  final List<Ballot> ballots;
  final GameOutcome outcome;

  @override
  GamePhaseKind get kind => GamePhaseKind.result;
}
