import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_tn/game/game_engine.dart';
import 'package:impostor_tn/game/game_outcome.dart';
import 'package:impostor_tn/game/game_phase.dart';
import 'package:impostor_tn/game/game_rejection.dart';

import 'game_fixtures.dart';

/// Impostor p0 nominated on the first ballot.
final _finalGuess = castAll(votingSession(), [1, 0, 0, 0]);

void main() {
  group('final guess (PRD §8)', () {
    for (final (label, guess, winner) in [
      ('the canonical word', 'alpha', Winner.impostor),
      ('an alias', 'alfa', Winner.impostor),
      ('the word with extra spaces', '  alpha  ', Winner.impostor),
      ('a wrong word', 'gamma', Winner.civilians),
      ('an empty guess (Q-02 pending)', '', Winner.civilians),
    ]) {
      test('$label → ${winner.name} win', () {
        final session = accepted(
          GameEngine.submitFinalGuess(_finalGuess, guess),
        );
        final outcome = (session.phase as ResultPhase).outcome;
        expect(outcome.winner, winner);
      });
    }

    test('stores the guess exactly as typed', () {
      final session = accepted(
        GameEngine.submitFinalGuess(_finalGuess, '  alpha  '),
      );
      final outcome = (session.phase as ResultPhase).outcome as ImpostorGuessed;
      expect(outcome.rawGuess, '  alpha  ');
    });

    test('keeps the ballots for the result screen', () {
      final session = accepted(
        GameEngine.submitFinalGuess(_finalGuess, 'gamma'),
      );
      expect((session.phase as ResultPhase).ballots, hasLength(1));
    });

    test('allows exactly one guess', () {
      final session = accepted(
        GameEngine.submitFinalGuess(_finalGuess, 'gamma'),
      );
      expectRejected(
        GameEngine.submitFinalGuess(session, 'alpha'),
        GameRejection.wrongPhase,
      );
    });

    for (final (label, session) in [
      ('reveal', revealSession()),
      ('discussion', acknowledgeAll(revealSession())),
      ('first ballot', votingSession()),
      (
        'result after a civilian nomination',
        castAll(votingSession(), [1, 0, 1, 1]),
      ),
    ]) {
      test('is rejected during $label', () {
        expectRejected(
          GameEngine.submitFinalGuess(session, 'alpha'),
          GameRejection.wrongPhase,
        );
      });
    }
  });

  group('replay (PRD §9)', () {
    final finished = accepted(
      GameEngine.submitFinalGuess(_finalGuess, 'gamma'),
    );

    test('starts a new session for the same roster', () {
      final next = accepted(
        GameEngine.replay(finished, word: otherFixtureWord, random: Random(7)),
      );
      expect(next.players, finished.players);
      expect(next.word, same(otherFixtureWord));
      expect(next.phase, isA<RevealPhase>());
      expect((next.phase as RevealPhase).acknowledged, isEmpty);
      expect(next.playerIds, contains(next.impostor));
    });

    test('draws the Impostor from the given random source', () {
      final a = accepted(
        GameEngine.replay(finished, word: otherFixtureWord, random: Random(9)),
      );
      final b = accepted(
        GameEngine.replay(finished, word: otherFixtureWord, random: Random(9)),
      );
      expect(a.impostor, b.impostor);
    });

    for (final (label, session) in [
      ('reveal', revealSession()),
      ('discussion', acknowledgeAll(revealSession())),
      ('first ballot', votingSession()),
      ('final guess', _finalGuess),
    ]) {
      test('is rejected before the game ended: $label', () {
        expectRejected(
          GameEngine.replay(session, word: otherFixtureWord, random: Random(1)),
          GameRejection.wrongPhase,
        );
      });
    }
  });
}
