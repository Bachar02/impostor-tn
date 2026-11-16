import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_tn/game/content/content_catalog.dart';
import 'package:impostor_tn/game/content/content_eligibility.dart';
import 'package:impostor_tn/game/content/word_entry.dart';

// SYNTHETIC TEST FIXTURES: placeholder words, no real review.

WordEntry entry(String id, EditorialStatus status, {bool reviewed = true}) =>
    WordEntry(
      id: id,
      version: 1,
      canonical: 'canonical $id',
      aliases: const [],
      category: 'fixture category',
      language: 'aeb-Arab',
      access: AccessStatus.free,
      status: status,
      reviews: reviewed
          ? const WordReviews(linguistic: 'fixture-a', editorial: 'fixture-b')
          : null,
    );

void main() {
  group('isPlayable', () {
    final table = <EditorialStatus, (bool release, bool development)>{
      EditorialStatus.published: (true, true),
      EditorialStatus.development: (false, true),
      EditorialStatus.draft: (false, false),
      EditorialStatus.inReview: (false, false),
      EditorialStatus.retired: (false, false),
    };

    for (final MapEntry(key: status, value: (release, development))
        in table.entries) {
      test('${status.name}: release $release, development $development', () {
        final word = entry('w', status);

        expect(
          ContentEligibility.isPlayable(word, ContentChannel.release),
          release,
        );
        expect(
          ContentEligibility.isPlayable(word, ContentChannel.development),
          development,
        );
      });
    }

    test('a published word without reviews is never playable', () {
      final word = entry('w', EditorialStatus.published, reviewed: false);

      expect(
        ContentEligibility.isPlayable(word, ContentChannel.development),
        isFalse,
      );
    });
  });

  group('packs', () {
    final catalog = ContentCatalog(
      contentVersion: 1,
      packs: [
        WordPack(
          id: 'pack-a',
          title: 'a',
          words: [
            entry('w-1', EditorialStatus.published),
            entry('w-2', EditorialStatus.draft),
            entry('w-3', EditorialStatus.development),
          ],
        ),
        WordPack(
          id: 'pack-b',
          title: 'b',
          words: [entry('w-4', EditorialStatus.published)],
        ),
        WordPack(
          id: 'pack-c',
          title: 'c',
          words: [entry('w-5', EditorialStatus.inReview)],
        ),
      ],
    );

    test('count shows playable words only', () {
      expect(
        catalog.packs.map(
          (p) => ContentEligibility.playableCount(p, ContentChannel.release),
        ),
        [1, 1, 0],
      );
    });

    test('candidates are the playable words of the selected packs', () {
      final ids = ContentEligibility.candidates(catalog, [
        'pack-a',
        'pack-c',
        'unknown',
      ], ContentChannel.release).map((w) => w.id);

      expect(ids, ['w-1']);
    });

    test('development candidates include development words', () {
      final ids = ContentEligibility.candidates(catalog, [
        'pack-a',
      ], ContentChannel.development).map((w) => w.id);

      expect(ids, ['w-1', 'w-3']);
    });
  });

  test('a word entry does not print its id or text', () {
    final text = entry('w-7', EditorialStatus.published).toString();

    expect(text, isNot(contains('w-7')));
    expect(text, isNot(contains('canonical')));
  });
}
