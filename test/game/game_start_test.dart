import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_tn/game/game_engine.dart';
import 'package:impostor_tn/game/game_phase.dart';
import 'package:impostor_tn/game/game_rejection.dart';
import 'package:impostor_tn/game/game_rules.dart';
import 'package:impostor_tn/game/player.dart';
import 'package:impostor_tn/game/secret_word.dart';

import 'game_fixtures.dart';

void main() {
  group('player count (PRD §4)', () {
    for (final (count, rejection) in [
      (0, GameRejection.tooFewPlayers),
      (GameRules.minPlayers - 1, GameRejection.tooFewPlayers),
      (GameRules.minPlayers, null),
      (8, null),
      (GameRules.maxPlayers, null),
      (GameRules.maxPlayers + 1, GameRejection.tooManyPlayers),
    ]) {
      test('$count players → ${rejection?.name ?? 'accepted'}', () {
        final result = GameEngine.start(
          players: roster(count),
          word: fixtureWord,
          random: Random(1),
        );
        if (rejection == null) {
          accepted(result);
        } else {
          expectRejected(result, rejection);
        }
      });
    }
  });

  test('rejects two players with the same id', () {
    final players = [
      ...roster(4),
      const Player(id: PlayerId('p0'), name: 'Another name'),
    ];
    expectRejected(
      GameEngine.start(players: players, word: fixtureWord, random: Random(1)),
      GameRejection.duplicatePlayer,
    );
  });

  for (final (label, canonical) in [('empty', ''), ('spaces only', '   ')]) {
    test('rejects a word whose canonical form is $label', () {
      final word = SecretWord(
        wordId: 'fixture-empty',
        category: 'fixture-category',
        canonical: canonical,
      );
      expectRejected(
        GameEngine.start(players: roster(4), word: word, random: Random(1)),
        GameRejection.invalidWord,
      );
    });
  }

  test('a new session starts in the reveal phase with no acknowledgement', () {
    final session = accepted(
      GameEngine.start(
        players: roster(5),
        word: fixtureWord,
        random: Random(1),
      ),
    );
    expect(session.phase, isA<RevealPhase>());
    expect((session.phase as RevealPhase).acknowledged, isEmpty);
    expect(session.players, roster(5));
    expect(session.word, same(fixtureWord));
  });

  for (final count in [GameRules.minPlayers, GameRules.maxPlayers]) {
    test('exactly one Impostor, always a player, for $count players', () {
      for (var seed = 0; seed < 200; seed++) {
        final session = accepted(
          GameEngine.start(
            players: roster(count),
            word: fixtureWord,
            random: Random(seed),
          ),
        );
        expect(session.playerIds, contains(session.impostor));
      }
    });

    test('every position can be drawn as Impostor for $count players', () {
      final drawn = {
        for (var seed = 0; seed < 500; seed++)
          accepted(
            GameEngine.start(
              players: roster(count),
              word: fixtureWord,
              random: Random(seed),
            ),
          ).impostor,
      };
      expect(drawn, roster(count).map((p) => p.id).toSet());
    });
  }

  test('the same seed draws the same Impostor', () {
    PlayerId draw() => accepted(
      GameEngine.start(
        players: roster(8),
        word: fixtureWord,
        random: Random(42),
      ),
    ).impostor;
    expect(draw(), draw());
  });
}
