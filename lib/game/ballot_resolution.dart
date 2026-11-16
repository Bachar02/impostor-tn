import 'package:impostor_tn/game/ballot.dart';
import 'package:impostor_tn/game/game_outcome.dart';
import 'package:impostor_tn/game/game_phase.dart';
import 'package:impostor_tn/game/game_session.dart';

/// The phase that follows a complete ballot (PRD §7, §8).
///
/// - Unique leader who is a civilian: result, the Impostor wins.
/// - Unique leader who is the Impostor: final guess.
/// - Tie on the first ballot: exactly one runoff among the tied players.
/// - Tie on the runoff: draw, no final guess.
///
/// Ties are never broken by chance or by playing order.
GamePhase resolveCompletedBallot(GameSession session, Ballot completed) {
  final ballots = [
    if (session.phase case RunoffPhase(:final firstBallot)) firstBallot,
    completed,
  ];
  final leaders = completed.leaders;

  if (leaders.length > 1) {
    return switch (completed.kind) {
      BallotKind.first => RunoffPhase(
        firstBallot: completed,
        runoff: Ballot(kind: BallotKind.runoff, candidates: leaders),
      ),
      BallotKind.runoff => ResultPhase(
        ballots: ballots,
        outcome: const RunoffDraw(),
      ),
    };
  }
  final nominee = leaders.single;
  return nominee == session.impostor
      ? FinalGuessPhase(ballots: ballots, nominee: nominee)
      : ResultPhase(ballots: ballots, outcome: CivilianNominated(nominee));
}
