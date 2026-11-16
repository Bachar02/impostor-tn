import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_tn/game/game_engine.dart';
import 'package:impostor_tn/game/game_outcome.dart';
import 'package:impostor_tn/game/game_phase.dart';
import 'package:impostor_tn/game/role_view.dart';

import 'game_fixtures.dart';

/// PRD §12: types that hold a secret never print it.
void main() {
  final finalGuess = castAll(votingSession(players: 4, impostor: 2), [
    2,
    2,
    0,
    2,
  ]);
  final finished = accepted(GameEngine.submitFinalGuess(finalGuess, 'alfa'));
  final result = finished.phase as ResultPhase;

  final secrets = [
    fixtureWord.canonical,
    ...fixtureWord.aliases,
    fixtureWord.category,
    fixtureWord.wordId,
    finished.impostor.value,
  ];

  for (final (label, value) in <(String, Object)>[
    ('secret word', fixtureWord),
    ('session', finished),
    ('result phase', result),
    ('ballot', result.ballots.single),
    ('outcome', result.outcome),
    (
      'civilian view',
      GameEngine.roleViewForPendingPlayer(revealSession(impostor: 1))!,
    ),
    ('impostor view', GameEngine.roleViewForPendingPlayer(revealSession())!),
    ('final-guess phase', finalGuess.phase),
    ('recorded session', recordedFrom(finished, finalGuess: 'alfa')),
  ]) {
    test('$label prints no secret', () {
      final text = value.toString();
      for (final secret in secrets) {
        expect(text, isNot(contains(secret)));
      }
    });
  }

  test('fixtures are what the redaction test assumes', () {
    expect(result.outcome, isA<ImpostorGuessed>());
    expect(
      GameEngine.roleViewForPendingPlayer(revealSession()),
      isA<ImpostorView>(),
    );
  });
}
