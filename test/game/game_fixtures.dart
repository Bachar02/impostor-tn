import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_tn/game/game_engine.dart';
import 'package:impostor_tn/game/game_phase.dart';
import 'package:impostor_tn/game/game_rejection.dart';
import 'package:impostor_tn/game/game_session.dart';
import 'package:impostor_tn/game/player.dart';
import 'package:impostor_tn/game/secret_word.dart';
import 'package:impostor_tn/game/session_restore.dart';

// SYNTHETIC TEST FIXTURES. Not game content: no pack, no review status, never
// bundled. Player names and words are placeholders chosen for the tests.

const fixtureWord = SecretWord(
  wordId: 'fixture-word-1',
  category: 'fixture-category',
  canonical: 'alpha',
  aliases: ['alfa'],
);

const otherFixtureWord = SecretWord(
  wordId: 'fixture-word-2',
  category: 'fixture-category',
  canonical: 'beta',
);

PlayerId pid(int index) => PlayerId('p$index');

/// Players p0…p(count-1), in that playing order.
List<Player> roster(int count) => [
  for (var i = 0; i < count; i++) Player(id: pid(i), name: 'Player $i'),
];

/// A session in the reveal phase with a chosen Impostor, for rule tests that
/// must not depend on the random draw.
GameSession revealSession({int players = 4, int impostor = 0}) => GameSession(
  players: roster(players),
  impostor: pid(impostor),
  word: fixtureWord,
  phase: RevealPhase(),
);

/// The session of an accepted transition. Throws instead of using `expect`
/// so fixtures can also be built while test tables are declared.
GameSession accepted(Transition transition) => switch (transition) {
  Accepted(:final session) => session,
  Rejected(:final reason) => throw StateError(
    'Expected an accepted transition, got ${reason.name}',
  ),
};

void expectRejected(Transition transition, GameRejection reason) {
  expect(transition, isA<Rejected>());
  expect((transition as Rejected).reason, reason);
}

GameSession acknowledgeAll(GameSession session) {
  var current = session;
  while (current.phase is RevealPhase) {
    final player = GameEngine.pendingPlayer(current)!;
    current = accepted(GameEngine.acknowledge(current, player));
  }
  return current;
}

/// First ballot open, with a chosen Impostor.
GameSession votingSession({int players = 4, int impostor = 0}) => accepted(
  GameEngine.openVoting(
    acknowledgeAll(revealSession(players: players, impostor: impostor)),
  ),
);

/// Casts one vote per pending voter, in playing order: [targets][i] is the
/// index of the player that the i-th voter of this ballot votes for.
GameSession castAll(GameSession session, List<int> targets) {
  var current = session;
  for (final target in targets) {
    final voter = GameEngine.pendingPlayer(current)!;
    current = accepted(
      GameEngine.castVote(current, voter: voter, target: pid(target)),
    );
  }
  return current;
}

/// The facts a repository would store for [session] (ADR-0003 tables).
RecordedSession recordedFrom(GameSession session, {String? finalGuess}) {
  final phase = session.phase;
  final acknowledged = switch (phase) {
    RevealPhase(:final acknowledged) => acknowledged.toSet(),
    _ => session.playerIds.toSet(),
  };
  final (first, runoff) = switch (phase) {
    RevealPhase() || DiscussionPhase() => (null, null),
    FirstBallotPhase(:final ballot) => (ballot, null),
    RunoffPhase(:final firstBallot, :final runoff) => (firstBallot, runoff),
    FinalGuessPhase(:final ballots) || ResultPhase(:final ballots) => (
      ballots.first,
      ballots.length > 1 ? ballots.last : null,
    ),
  };
  return RecordedSession(
    players: session.players,
    impostor: session.impostor,
    word: session.word,
    phase: phase.kind,
    acknowledged: acknowledged,
    firstBallotVotes: first?.votes ?? const {},
    runoffVotes: runoff?.votes ?? const {},
    finalGuess: finalGuess,
  );
}
