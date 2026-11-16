import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_tn/game/cooldown/word_cooldown.dart';
import 'package:impostor_tn/game/game_rules.dart';

List<String> ids(int from, int to) => [for (var i = from; i < to; i++) 'w-$i'];

void main() {
  test('records a word as the newest entry', () {
    final cooldown = WordCooldown.empty.record('w-1').record('w-2');

    expect(cooldown.oldestFirst, ['w-1', 'w-2']);
  });

  test('a repeated word moves to the newest position, never twice', () {
    final cooldown = WordCooldown(['w-1', 'w-2', 'w-3']).record('w-1');

    expect(cooldown.oldestFirst, ['w-2', 'w-3', 'w-1']);
  });

  test('keeps the ${GameRules.cooldownSize} most recent distinct ids', () {
    var cooldown = WordCooldown.empty;
    for (final id in ids(0, GameRules.cooldownSize + 5)) {
      cooldown = cooldown.record(id);
    }

    expect(cooldown.oldestFirst, ids(5, GameRules.cooldownSize + 5));
  });

  test('at exactly ${GameRules.cooldownSize} entries nothing is dropped', () {
    final cooldown = WordCooldown(ids(0, GameRules.cooldownSize));

    expect(cooldown.oldestFirst, hasLength(GameRules.cooldownSize));
    expect(cooldown.contains('w-0'), isTrue);
    expect(cooldown.record('w-new').contains('w-0'), isFalse);
  });

  test('re-recording when full drops nothing but reorders', () {
    final full = WordCooldown(ids(0, GameRules.cooldownSize));

    final next = full.record('w-0');

    expect(next.oldestFirst.first, 'w-1');
    expect(next.oldestFirst.last, 'w-0');
    expect(next.oldestFirst, hasLength(GameRules.cooldownSize));
  });

  test('construction keeps the newest occurrence of a duplicate', () {
    expect(WordCooldown(['w-1', 'w-2', 'w-1']).oldestFirst, ['w-2', 'w-1']);
  });

  test('is immutable', () {
    final cooldown = WordCooldown(['w-1']);

    expect(() => cooldown.oldestFirst.add('w-2'), throwsUnsupportedError);
  });

  test('toString does not print word ids', () {
    expect(WordCooldown(['w-secret']).toString(), isNot(contains('w-secret')));
  });
}
