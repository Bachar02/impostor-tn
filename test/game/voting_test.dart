import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_tn/game/ballot.dart';
import 'package:impostor_tn/game/game_engine.dart';
import 'package:impostor_tn/game/game_outcome.dart';
import 'package:impostor_tn/game/game_phase.dart';
import 'package:impostor_tn/game/game_rejection.dart';
import 'package:impostor_tn/game/game_session.dart';
import 'package:impostor_tn/game/player.dart';

import 'game_fixtures.dart';

// Four players p0…p3, Impostor p0 unless stated. A ballot is written as the
// target index chosen by each voter in playing order: [1, 0, 1, 1] means
// p0→p1, p1→p0, p2→p1, p3→p1.

void main() {
  group('first-ballot outcome (PRD §7)', () {
    test('a unique civilian leader ends the game: the Impostor wins', () {
      final session = castAll(votingSession(), [1, 0, 1, 1]);
      final phase = session.phase as ResultPhase;
      expect(phase.outcome, isA<CivilianNominated>());
      expect((phase.outcome as CivilianNominated).nominee, pid(1));
      expect(phase.outcome.winner, Winner.impostor);
      expect(phase.ballots, hasLength(1));
    });

    test('a unique Impostor leader leads to the final guess', () {
      final session = castAll(votingSession(), [1, 0, 0, 0]);
      final phase = session.phase as FinalGuessPhase;
      expect(phase.nominee, pid(0));
      expect(phase.ballots.single.kind, BallotKind.first);
      expect(GameEngine.pendingPlayer(session), pid(0));
    });

    for (final (label, players, targets, candidates) in [
      ('a two-way tie', 4, [1, 0, 0, 1], [0, 1]),
      ('a three-way tie (6 players)', 6, [1, 2, 0, 0, 1, 2], [0, 1, 2]),
      ('a tie between all players', 4, [1, 2, 3, 0], [0, 1, 2, 3]),
    ]) {
      test('$label opens one runoff among the tied players only', () {
        final session = castAll(votingSession(players: players), targets);
        final phase = session.phase as RunoffPhase;
        expect(phase.runoff.kind, BallotKind.runoff);
        expect(phase.runoff.candidates, candidates.map(pid));
        expect(phase.runoff.votes, isEmpty, reason: 'fresh ballot');
        expect(phase.firstBallot.votes, hasLength(players), reason: 'kept');
        expect(GameEngine.pendingPlayer(session), pid(0));
      });
    }

    test('records counts per candidate, zero included', () {
      final session = castAll(votingSession(), [1, 0, 1, 1]);
      final ballot = (session.phase as ResultPhase).ballots.single;
      expect(ballot.tally, {pid(0): 1, pid(1): 3, pid(2): 0, pid(3): 0});
    });

    // Three players, the minimum: every first-ballot shape. With three
    // voters and no self-vote, a tie can only be 1-1-1.
    group('at 3 players', () {
      for (final (label, targets, impostor, check) in [
        (
          'Impostor nominated → final guess',
          [1, 0, 0],
          0,
          (GameSession s) => expect(s.phase, isA<FinalGuessPhase>()),
        ),
        (
          'civilian nominated → Impostor wins',
          [2, 2, 1],
          0,
          (GameSession s) => expect(
            (s.phase as ResultPhase).outcome,
            isA<CivilianNominated>(),
          ),
        ),
        (
          'Impostor not first in order, nominated',
          [2, 2, 0],
          2,
          (GameSession s) =>
              expect((s.phase as FinalGuessPhase).nominee, pid(2)),
        ),
        (
          '1-1-1 → runoff among all three',
          [1, 2, 0],
          0,
          (GameSession s) => expect(
            (s.phase as RunoffPhase).runoff.candidates,
            [pid(0), pid(1), pid(2)],
          ),
        ),
      ]) {
        test(label, () {
          check(
            castAll(votingSession(players: 3, impostor: impostor), targets),
          );
        });
      }

      test('runoff 1-1-1 again is a draw without a final guess', () {
        final runoff = castAll(votingSession(players: 3), [1, 2, 0]);
        final phase = castAll(runoff, [2, 0, 1]).phase as ResultPhase;
        expect(phase.outcome, isA<RunoffDraw>());
        expect(phase.ballots, hasLength(2));
      });

      test('runoff with a unique Impostor leader → final guess', () {
        final runoff = castAll(votingSession(players: 3), [1, 2, 0]);
        expect(castAll(runoff, [1, 0, 0]).phase, isA<FinalGuessPhase>());
      });
    });

    test('works at 12 players', () {
      final session = castAll(votingSession(players: 12), [
        for (var voter = 0; voter < 12; voter++) voter == 11 ? 0 : 11,
      ]);
      final outcome = (session.phase as ResultPhase).outcome;
      expect((outcome as CivilianNominated).nominee, pid(11));
    });
  });

  group('runoff outcome (PRD §7, §8)', () {
    GameSession runoff() => castAll(votingSession(), [1, 0, 0, 1]);

    test('a unique Impostor leader leads to the final guess', () {
      final session = castAll(runoff(), [1, 0, 0, 0]);
      final phase = session.phase as FinalGuessPhase;
      expect(phase.nominee, pid(0));
      expect(phase.ballots.map((b) => b.kind), [
        BallotKind.first,
        BallotKind.runoff,
      ]);
    });

    test('a unique civilian leader ends the game: the Impostor wins', () {
      final session = castAll(runoff(), [1, 0, 1, 1]);
      final outcome = (session.phase as ResultPhase).outcome;
      expect((outcome as CivilianNominated).nominee, pid(1));
      expect(outcome.winner, Winner.impostor);
    });

    test('a tie is a draw without a final guess', () {
      final session = castAll(runoff(), [1, 0, 0, 1]);
      final phase = session.phase as ResultPhase;
      expect(phase.outcome, isA<RunoffDraw>());
      expect(phase.outcome.winner, Winner.draw);
      expect(phase.ballots, hasLength(2));
      expectRejected(
        GameEngine.submitFinalGuess(session, 'alpha'),
        GameRejection.wrongPhase,
      );
    });

    test('a tied candidate cannot vote for themselves', () {
      expectRejected(
        GameEngine.castVote(runoff(), voter: pid(0), target: pid(0)),
        GameRejection.selfVote,
      );
    });

    test('nobody can vote for a player who was not tied', () {
      final afterTwo = castAll(runoff(), [1, 0]);
      expectRejected(
        GameEngine.castVote(afterTwo, voter: pid(2), target: pid(3)),
        GameRejection.notACandidate,
      );
    });

    test('a player who was not tied votes for any tied candidate', () {
      final afterTwo = castAll(runoff(), [1, 0]);
      accepted(GameEngine.castVote(afterTwo, voter: pid(2), target: pid(0)));
      accepted(GameEngine.castVote(afterTwo, voter: pid(2), target: pid(1)));
    });
  });

  group('vote rejections', () {
    test('self-vote', () {
      expectRejected(
        GameEngine.castVote(votingSession(), voter: pid(0), target: pid(0)),
        GameRejection.selfVote,
      );
    });

    test('voting out of turn', () {
      expectRejected(
        GameEngine.castVote(votingSession(), voter: pid(1), target: pid(0)),
        GameRejection.notThisPlayersTurn,
      );
    });

    test(
      'a second vote by the same player leaves the first unchanged (D-02)',
      () {
        final session = castAll(votingSession(), [1]);
        expectRejected(
          GameEngine.castVote(session, voter: pid(0), target: pid(2)),
          GameRejection.alreadyVoted,
        );
        expect((session.phase as FirstBallotPhase).ballot.votes, {
          pid(0): pid(1),
        });
      },
    );

    for (final (label, voter, target) in [
      ('an unknown voter', const PlayerId('stranger'), pid(1)),
      ('an unknown target', pid(0), const PlayerId('stranger')),
    ]) {
      test(label, () {
        expectRejected(
          GameEngine.castVote(votingSession(), voter: voter, target: target),
          GameRejection.unknownPlayer,
        );
      });
    }

    for (final (label, session) in [
      ('reveal', revealSession()),
      ('discussion', acknowledgeAll(revealSession())),
      ('final guess', castAll(votingSession(), [1, 0, 0, 0])),
      ('result', castAll(votingSession(), [1, 0, 1, 1])),
    ]) {
      test('voting during $label', () {
        expectRejected(
          GameEngine.castVote(session, voter: pid(1), target: pid(2)),
          GameRejection.wrongPhase,
        );
      });
    }
  });
}
