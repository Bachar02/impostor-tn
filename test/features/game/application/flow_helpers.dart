import 'package:impostor_tn/features/game/application/active_game.dart';
import 'package:impostor_tn/features/game/application/checkpoint.dart';
import 'package:impostor_tn/features/game/application/game_service.dart';
import 'package:impostor_tn/game/ballot.dart';
import 'package:impostor_tn/game/game_engine.dart';
import 'package:impostor_tn/game/player.dart';

import 'service_fixtures.dart';

/// Chooses a target for each voter.
typedef Choose = PlayerId Function(ActiveGame game, PlayerId voter);

/// Casts every remaining vote of [ballot], one checkpoint each.
Future<ActiveGame> voteAll(
  GameService games,
  ActiveGame game,
  BallotKind ballot,
  Choose choose,
) async {
  var current = game;
  while (openBallotOf(current) == ballot) {
    final voter = GameEngine.pendingPlayer(current.session)!;
    current = savedValue(
      await games.castVote(
        current.sessionId,
        ballot: ballot,
        voter: voter,
        target: choose(current, voter),
      ),
    );
  }
  return current;
}

/// Everyone votes for the Impostor; the Impostor votes for the first other
/// player.
PlayerId accuseImpostor(ActiveGame game, PlayerId voter) {
  final impostor = game.session.impostor;
  if (voter != impostor) return impostor;
  return game.session.playerIds.firstWhere((id) => id != impostor);
}

/// The first two civilians, A and B.
(PlayerId, PlayerId) twoCivilians(ActiveGame game) {
  final civilians = game.session.playerIds
      .where((id) => id != game.session.impostor)
      .toList();
  return (civilians[0], civilians[1]);
}

/// A tie between civilians A and B on an even-sized table: A and B vote for
/// each other and the others split evenly. Also ties a runoff between them.
PlayerId tieTwoCivilians(ActiveGame game, PlayerId voter) {
  final (a, b) = twoCivilians(game);
  if (voter == a) return b;
  if (voter == b) return a;
  final others = game.session.playerIds.where((id) => id != a && id != b);
  return others.toList().indexOf(voter).isEven ? a : b;
}

/// Civilian B wins: everyone votes B, and B votes A.
PlayerId electCivilianB(ActiveGame game, PlayerId voter) {
  final (a, b) = twoCivilians(game);
  return voter == b ? a : b;
}

/// From a saved roster to the first ballot, through the service.
Future<ActiveGame> toFirstBallot(GameService games) async {
  final game = savedValue(await games.startGame());
  final discussing = await revealAll(games, game);
  return savedValue(await games.openVoting(discussing.sessionId));
}

/// The ballot accepting votes in [game], if any.
BallotKind? openBallotOf(ActiveGame game) =>
    switch (game.session.phase.kind.name) {
      'firstBallot' => BallotKind.first,
      'runoff' => BallotKind.runoff,
      _ => null,
    };

bool isSaved(Checkpoint<Object?> checkpoint) => checkpoint is Saved<Object?>;
