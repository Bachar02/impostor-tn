import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_tn/game/content/word_entry.dart';
import 'package:impostor_tn/game/cooldown/word_cooldown.dart';
import 'package:impostor_tn/game/cooldown/word_selection.dart';
import 'package:impostor_tn/game/game_rules.dart';

// SYNTHETIC TEST FIXTURES: placeholder words, no real review.

WordEntry word(int i) => WordEntry(
  id: 'w-$i',
  version: 1,
  canonical: 'canonical $i',
  aliases: const [],
  category: 'fixture category',
  language: 'aeb-Arab',
  access: AccessStatus.free,
  status: EditorialStatus.published,
  reviews: const WordReviews(linguistic: 'fixture-a', editorial: 'fixture-b'),
);

List<WordEntry> words(int count) => [for (var i = 0; i < count; i++) word(i)];

String selectedId(WordSelection selection) =>
    (selection as WordSelected).word.id;

void main() {
  test('no candidates is a controlled failure, not an exception', () {
    final selection = WordSelector.select(
      candidates: const [],
      cooldown: WordCooldown(['w-1']),
      random: Random(1),
    );

    expect(selection, isA<NoEligibleWord>());
  });

  test('never selects a word in the cooldown while another is eligible', () {
    final cooldown = WordCooldown(['w-0', 'w-1', 'w-2']);
    for (var seed = 0; seed < 200; seed++) {
      final id = selectedId(
        WordSelector.select(
          candidates: words(4),
          cooldown: cooldown,
          random: Random(seed),
        ),
      );
      expect(id, 'w-3');
    }
  });

  test('the same seed gives the same word', () {
    String pick() => selectedId(
      WordSelector.select(
        candidates: words(50),
        cooldown: WordCooldown.empty,
        random: Random(42),
      ),
    );

    expect(pick(), pick());
  });

  test('every eligible word can be drawn', () {
    final seen = {
      for (var seed = 0; seed < 300; seed++)
        selectedId(
          WordSelector.select(
            candidates: words(5),
            cooldown: WordCooldown(['w-0']),
            random: Random(seed),
          ),
        ),
    };

    expect(seen, {'w-1', 'w-2', 'w-3', 'w-4'});
  });

  group('exhausted pool (PRD §10 progressive release)', () {
    test('returns the least recently used candidate, without chance', () {
      final cooldown = WordCooldown(['w-2', 'w-0', 'w-1']);
      for (var seed = 0; seed < 50; seed++) {
        expect(
          selectedId(
            WordSelector.select(
              candidates: words(3),
              cooldown: cooldown,
              random: Random(seed),
            ),
          ),
          'w-2',
        );
      }
    });

    test('skips released entries that are not candidates', () {
      // w-90 and w-91 belong to packs that are not selected.
      final cooldown = WordCooldown(['w-90', 'w-91', 'w-1', 'w-0']);

      expect(
        selectedId(
          WordSelector.select(
            candidates: words(2),
            cooldown: cooldown,
            random: Random(0),
          ),
        ),
        'w-1',
      );
    });

    test(
      'terminates with a full cooldown and a single candidate at its end',
      () {
        final ids = [for (var i = 1; i <= GameRules.cooldownSize; i++) 'x-$i'];
        final cooldown = WordCooldown([...ids.skip(1), 'w-0']);

        expect(
          selectedId(
            WordSelector.select(
              candidates: words(1),
              cooldown: cooldown,
              random: Random(0),
            ),
          ),
          'w-0',
        );
      },
    );
  });

  group('over many games', () {
    /// Plays [games] selections, consuming each word as C2 would.
    List<String> play(int poolSize, int games, int seed) {
      final random = Random(seed);
      var cooldown = WordCooldown.empty;
      final picked = <String>[];
      for (var i = 0; i < games; i++) {
        final id = selectedId(
          WordSelector.select(
            candidates: words(poolSize),
            cooldown: cooldown,
            random: random,
          ),
        );
        picked.add(id);
        cooldown = cooldown.record(id);
      }
      return picked;
    }

    test('a pool larger than the cooldown never repeats within '
        '${GameRules.cooldownSize + 1} games', () {
      final picked = play(40, 200, 7);
      for (var i = 0; i + GameRules.cooldownSize < picked.length; i++) {
        final window = picked.sublist(i, i + GameRules.cooldownSize + 1);
        expect(window.toSet(), hasLength(window.length));
      }
    });

    test('a pool smaller than the cooldown cycles through every word before '
        'repeating', () {
      final picked = play(5, 25, 3);
      for (var i = 0; i + 5 <= picked.length; i += 5) {
        expect(picked.sublist(i, i + 5).toSet(), hasLength(5));
      }
    });

    test('a pool of exactly ${GameRules.cooldownSize} words cycles too', () {
      final picked = play(GameRules.cooldownSize, 90, 11);
      final first = picked.take(GameRules.cooldownSize).toSet();

      expect(first, hasLength(GameRules.cooldownSize));
      expect(picked.sublist(30, 60).toSet(), hasLength(GameRules.cooldownSize));
    });
  });

  test('a selection does not print its word', () {
    expect(WordSelected(word(1)).toString(), isNot(contains('w-1')));
  });
}
