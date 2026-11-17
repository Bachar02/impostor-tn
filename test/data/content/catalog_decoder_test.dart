import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_tn/data/content/catalog_decoder.dart';
import 'package:impostor_tn/game/content/content_catalog.dart';
import 'package:impostor_tn/game/content/content_eligibility.dart';
import 'package:impostor_tn/game/content/content_issue.dart';
import 'package:impostor_tn/game/content/word_entry.dart';

import 'catalog_fixtures.dart';

CatalogDecoding decodeJson(
  Map<String, Object?> json, {
  ContentChannel channel = ContentChannel.release,
}) => CatalogDecoder.decode(encode(json), channel: channel);

List<ContentIssue> issuesOf(CatalogDecoding decoding) => switch (decoding) {
  InvalidCatalog(:final issues) => issues,
  DecodedCatalog() => const [],
};

Map<String, Object?> withWord(Map<String, Object?> word) => fixtureCatalog([
  fixturePack('pack-a', [word]),
]);

void main() {
  group('a valid catalog', () {
    test('decodes every field of a word', () {
      final json = withWord({
        ...fixtureWord('w-1', aliases: ['alias one']),
        'difficulty': 'hard',
        'region': 'fixture region',
      });

      final decoding = decodeJson(json);

      expect(decoding, isA<DecodedCatalog>());
      final word =
          (decoding as DecodedCatalog).catalog.packs.single.words.single;
      expect(word.id, 'w-1');
      expect(word.version, 1);
      expect(word.canonical, 'canonical w-1');
      expect(word.aliases, ['alias one']);
      expect(word.category, 'fixture category');
      expect(word.language, 'aeb-Arab');
      expect(word.access, AccessStatus.free);
      expect(word.status, EditorialStatus.published);
      expect(word.difficulty, Difficulty.hard);
      expect(word.region, 'fixture region');
      expect(word.reviews?.linguistic, 'fixture-reviewer-a');
    });

    test('keeps packs and words in file order and indexes them by id', () {
      final catalog =
          (decodeJson(validFixtureCatalog()) as DecodedCatalog).catalog;

      expect(catalog.packs.map((p) => p.id), ['pack-a', 'pack-b']);
      expect(catalog.packs.first.words.map((w) => w.id), ['w-1', 'w-2', 'w-3']);
      expect(catalog.wordById('w-4')?.id, 'w-4');
      expect(catalog.packIdOfWord('w-4'), 'pack-b');
      expect(catalog.wordById('missing'), isNull);
    });

    test('an empty catalog is valid', () {
      expect(decodeJson(fixtureCatalog([])), isA<DecodedCatalog>());
    });

    test('a non-published word may omit reviews and aliases', () {
      final word = fixtureWord('w-1', status: 'in_review', withReviews: false)
        ..remove('aliases');

      expect(decodeJson(withWord(word)), isA<DecodedCatalog>());
    });
  });

  group('the file is rejected as a whole', () {
    test('when it is not JSON', () {
      expect(
        issuesOf(CatalogDecoder.decode('{', channel: ContentChannel.release)),
        [const ContentIssue(r'$', ContentIssueKind.notJson)],
      );
    });

    test('when the root is not an object', () {
      expect(
        issuesOf(CatalogDecoder.decode('[]', channel: ContentChannel.release)),
        [const ContentIssue(r'$', ContentIssueKind.wrongType)],
      );
    });

    test('when the format version is not supported', () {
      expect(issuesOf(decodeJson({...fixtureCatalog([]), 'format': 2})), [
        const ContentIssue('format', ContentIssueKind.unsupportedFormat),
      ]);
    });

    test('when the content version is below 1', () {
      expect(
        issuesOf(decodeJson({...fixtureCatalog([]), 'contentVersion': 0})),
        [const ContentIssue('contentVersion', ContentIssueKind.invalidValue)],
      );
    });
  });

  group('structural issues are reported by path', () {
    final cases = <String, (Map<String, Object?>, ContentIssue)>{
      'missing canonical': (
        withWord(fixtureWord('w-1')..remove('canonical')),
        const ContentIssue(
          'packs[0].words[0].canonical',
          ContentIssueKind.missingField,
        ),
      ),
      'misspelt key': (
        withWord({...fixtureWord('w-1'), 'alises': <String>[]}),
        const ContentIssue(
          'packs[0].words[0].alises',
          ContentIssueKind.unknownField,
        ),
      ),
      'version is a string': (
        withWord({...fixtureWord('w-1'), 'version': '1'}),
        const ContentIssue(
          'packs[0].words[0].version',
          ContentIssueKind.wrongType,
        ),
      ),
      'version is 0': (
        withWord({...fixtureWord('w-1'), 'version': 0}),
        const ContentIssue(
          'packs[0].words[0].version',
          ContentIssueKind.invalidValue,
        ),
      ),
      'alias is a number': (
        withWord({
          ...fixtureWord('w-1'),
          'aliases': [1],
        }),
        const ContentIssue(
          'packs[0].words[0].aliases[0]',
          ContentIssueKind.wrongType,
        ),
      ),
      'unknown status': (
        withWord(fixtureWord('w-1', status: 'approved')),
        const ContentIssue(
          'packs[0].words[0].status',
          ContentIssueKind.invalidValue,
        ),
      ),
      'unknown difficulty': (
        withWord({...fixtureWord('w-1'), 'difficulty': 'extreme'}),
        const ContentIssue(
          'packs[0].words[0].difficulty',
          ContentIssueKind.invalidValue,
        ),
      ),
      'access other than free (D-04)': (
        withWord({...fixtureWord('w-1'), 'access': 'premium'}),
        const ContentIssue(
          'packs[0].words[0].access',
          ContentIssueKind.invalidValue,
        ),
      ),
      'malformed language tag': (
        withWord({...fixtureWord('w-1'), 'language': 'Tunisian'}),
        const ContentIssue(
          'packs[0].words[0].language',
          ContentIssueKind.invalidValue,
        ),
      ),
      'pack without title': (
        fixtureCatalog([fixturePack('pack-a', [])..remove('title')]),
        const ContentIssue('packs[0].title', ContentIssueKind.missingField),
      ),
      'word is not an object': (
        fixtureCatalog([
          {
            'id': 'pack-a',
            'title': 't',
            'words': ['w-1'],
          },
        ]),
        const ContentIssue('packs[0].words[0]', ContentIssueKind.wrongType),
      ),
      'uppercase id': (
        withWord(fixtureWord('W-1')),
        const ContentIssue('packs[0].words[0].id', ContentIssueKind.invalidId),
      ),
      'id with a trailing hyphen': (
        withWord(fixtureWord('w-')),
        const ContentIssue('packs[0].words[0].id', ContentIssueKind.invalidId),
      ),
      'id longer than 64': (
        withWord(fixtureWord('w' * 65)),
        const ContentIssue('packs[0].words[0].id', ContentIssueKind.invalidId),
      ),
    };

    for (final MapEntry(key: name, value: (json, issue)) in cases.entries) {
      test(name, () => expect(issuesOf(decodeJson(json)), contains(issue)));
    }
  });

  group('duplicate checks', () {
    test('a word id used twice in the catalog', () {
      final json = fixtureCatalog([
        fixturePack('pack-a', [fixtureWord('w-1')]),
        fixturePack('pack-b', [fixtureWord('w-1', canonical: 'other')]),
      ]);

      expect(issuesOf(decodeJson(json)), [
        const ContentIssue(
          'packs[1].words[0].id',
          ContentIssueKind.duplicateWordId,
          relatedPath: 'packs[0].words[0].id',
        ),
      ]);
    });

    test('a pack id used twice', () {
      final json = fixtureCatalog([
        fixturePack('pack-a', []),
        fixturePack('pack-a', []),
      ]);

      expect(issuesOf(decodeJson(json)), [
        const ContentIssue(
          'packs[1].id',
          ContentIssueKind.duplicatePackId,
          relatedPath: 'packs[0].id',
        ),
      ]);
    });

    test('an alias equal to its own canonical word', () {
      final json = withWord(fixtureWord('w-1', aliases: ['canonical w-1']));

      expect(issuesOf(decodeJson(json)), [
        const ContentIssue(
          'packs[0].words[0].aliases[0]',
          ContentIssueKind.aliasRepeatsCanonical,
          relatedPath: 'packs[0].words[0].canonical',
        ),
      ]);
    });

    test('the same alias twice in one word', () {
      final json = withWord(fixtureWord('w-1', aliases: ['x', 'x']));

      expect(issuesOf(decodeJson(json)), [
        const ContentIssue(
          'packs[0].words[0].aliases[1]',
          ContentIssueKind.duplicateAlias,
          relatedPath: 'packs[0].words[0].aliases[0]',
        ),
      ]);
    });

    test('an alias equal to another word, in another pack', () {
      final json = fixtureCatalog([
        fixturePack('pack-a', [fixtureWord('w-1')]),
        fixturePack('pack-b', [
          fixtureWord('w-2', aliases: ['canonical w-1']),
        ]),
      ]);

      expect(issuesOf(decodeJson(json)), [
        const ContentIssue(
          'packs[1].words[0].aliases[0]',
          ContentIssueKind.answerSharedWithOtherWord,
          relatedPath: 'packs[0].words[0].canonical',
        ),
      ]);
    });

    test('two words with the same canonical text', () {
      final json = fixtureCatalog([
        fixturePack('pack-a', [
          fixtureWord('w-1', canonical: 'same'),
          fixtureWord('w-2', canonical: 'same'),
        ]),
      ]);

      expect(issuesOf(decodeJson(json)), [
        const ContentIssue(
          'packs[0].words[1].canonical',
          ContentIssueKind.answerSharedWithOtherWord,
          relatedPath: 'packs[0].words[0].canonical',
        ),
      ]);
    });

    test('aliases differing only in Latin case are distinct (D-16)', () {
      final json = withWord(
        fixtureWord('w-1', canonical: 'Sami', aliases: ['sami']),
      );

      expect(decodeJson(json), isA<DecodedCatalog>());
    });
  });

  group('text hygiene', () {
    final cases = <String, (String, ContentIssueKind)>{
      'empty': ('', ContentIssueKind.emptyText),
      'spaces only': ('   ', ContentIssueKind.emptyText),
      'leading space': (' word', ContentIssueKind.untidyText),
      'trailing space': ('word ', ContentIssueKind.untidyText),
      'double inner space': ('two  words', ContentIssueKind.untidyText),
      'tab': ('two\twords', ContentIssueKind.forbiddenCharacter),
      'newline': ('two\nwords', ContentIssueKind.forbiddenCharacter),
      'no-break space': ('two words', ContentIssueKind.forbiddenCharacter),
      'zero-width joiner': ('wo‍rd', ContentIssueKind.forbiddenCharacter),
      'right-to-left mark': ('‏word', ContentIssueKind.forbiddenCharacter),
      'Arabic letter mark': ('؜word', ContentIssueKind.forbiddenCharacter),
      'byte-order mark': ('﻿word', ContentIssueKind.forbiddenCharacter),
    };

    for (final MapEntry(key: name, value: (text, kind)) in cases.entries) {
      test('canonical with $name is rejected', () {
        final json = withWord(fixtureWord('w-1', canonical: text));

        expect(
          issuesOf(decodeJson(json)),
          contains(ContentIssue('packs[0].words[0].canonical', kind)),
        );
      });
    }

    test('an alias is held to the same rules', () {
      final json = withWord(fixtureWord('w-1', aliases: ['alias ']));

      expect(issuesOf(decodeJson(json)), [
        const ContentIssue(
          'packs[0].words[0].aliases[0]',
          ContentIssueKind.untidyText,
        ),
      ]);
    });

    test('tatweel and diacritics are content, not hygiene problems', () {
      final json = withWord(fixtureWord('w-1', canonical: 'كـلمة مُشكّلة'));

      expect(decodeJson(json), isA<DecodedCatalog>());
    });
  });

  group('reviews (PRD §10)', () {
    test('a published word needs both reviews', () {
      final json = withWord(fixtureWord('w-1', withReviews: false));

      expect(issuesOf(decodeJson(json)), [
        const ContentIssue(
          'packs[0].words[0].reviews',
          ContentIssueKind.publishedWithoutReviews,
        ),
      ]);
    });

    test('a published word needs two distinct reviewers', () {
      final json = withWord({
        ...fixtureWord('w-1'),
        'reviews': {'linguistic': 'fixture-r', 'editorial': 'fixture-r'},
      });

      expect(issuesOf(decodeJson(json)), [
        const ContentIssue(
          'packs[0].words[0].reviews',
          ContentIssueKind.reviewsNotDistinct,
        ),
      ]);
    });

    test('a review entry with a missing reviewer is a structural issue', () {
      final json = withWord({
        ...fixtureWord('w-1'),
        'reviews': {'linguistic': 'fixture-r'},
      });

      expect(issuesOf(decodeJson(json)), [
        const ContentIssue(
          'packs[0].words[0].reviews.editorial',
          ContentIssueKind.missingField,
        ),
      ]);
    });
  });

  group('development content (ADR-0009)', () {
    final json = withWord(
      fixtureWord('w-1', status: 'development', withReviews: false),
    );

    test('makes a release catalog invalid as a whole', () {
      expect(issuesOf(decodeJson(json)), [
        const ContentIssue(
          'packs[0].words[0].status',
          ContentIssueKind.developmentContentInRelease,
        ),
      ]);
    });

    test('is accepted in the development channel', () {
      expect(
        decodeJson(json, channel: ContentChannel.development),
        isA<DecodedCatalog>(),
      );
    });
  });

  group('one category per pack (D-38)', () {
    test('decodes the label and its review status', () {
      final pack = (decodeJson(
        validFixtureCatalog(),
      ) as DecodedCatalog).catalog.packs.first;

      expect(pack.title, fixtureLabel);
      expect(pack.labelStatus, LabelStatus.approved);
      expect(pack.labelReview, 'fixture-label-reviewer');
      expect(pack.words.map((w) => w.category).toSet(), {pack.title});
    });

    test('a word whose category differs from the pack title is rejected', () {
      final json = fixtureCatalog([
        fixturePack('pack-a', [
          fixtureWord('w-1'),
          fixtureWord('w-2', category: 'other category'),
          fixtureWord('w-3'),
        ]),
      ]);

      expect(issuesOf(decodeJson(json)), [
        const ContentIssue(
          'packs[0].words[1].category',
          ContentIssueKind.categoryDiffersFromPack,
          relatedPath: 'packs[0].title',
        ),
      ]);
    });

    test('a pack title no word matches rejects every word of the pack', () {
      final json = fixtureCatalog([
        fixturePack('pack-a', [
          fixtureWord('w-1'),
          fixtureWord('w-2'),
        ], title: 'another label'),
      ]);

      expect(issuesOf(decodeJson(json)).map((i) => (i.path, i.kind)), [
        (
          'packs[0].words[0].category',
          ContentIssueKind.categoryDiffersFromPack,
        ),
        (
          'packs[0].words[1].category',
          ContentIssueKind.categoryDiffersFromPack,
        ),
      ]);
    });

    test('the comparison is exact: no space or letter folding (D-01)', () {
      for (final variant in ['$fixtureLabel.', 'Fixture category']) {
        final json = withWord(fixtureWord('w-1', category: variant));

        expect(issuesOf(decodeJson(json)).map((i) => i.kind), [
          ContentIssueKind.categoryDiffersFromPack,
        ]);
      }
    });

    test('each pack is checked against its own title', () {
      final json = fixtureCatalog([
        fixturePack('pack-a', [fixtureWord('w-1')]),
        fixturePack('pack-b', [
          fixtureWord('w-2', category: 'label b'),
        ], title: 'label b'),
      ]);

      expect(decodeJson(json), isA<DecodedCatalog>());
    });

    test('a pack without words is not a category conflict', () {
      final json = fixtureCatalog([fixturePack('pack-a', [])]);

      expect(decodeJson(json), isA<DecodedCatalog>());
    });

    test('a development word is held to the same rule', () {
      final json = withWord(
        fixtureWord(
          'w-1',
          status: 'development',
          withReviews: false,
          category: 'other category',
        ),
      );

      expect(issuesOf(decodeJson(json, channel: ContentChannel.development)), [
        const ContentIssue(
          'packs[0].words[0].category',
          ContentIssueKind.categoryDiffersFromPack,
          relatedPath: 'packs[0].title',
        ),
      ]);
    });
  });

  group('label review status (D-38)', () {
    final cases = <String, (Map<String, Object?>, ContentIssue)>{
      'missing label status': (
        fixtureCatalog([fixturePack('pack-a', [])..remove('labelStatus')]),
        const ContentIssue(
          'packs[0].labelStatus',
          ContentIssueKind.missingField,
        ),
      ),
      'unknown label status': (
        fixtureCatalog([fixturePack('pack-a', [], labelStatus: 'reviewed')]),
        const ContentIssue(
          'packs[0].labelStatus',
          ContentIssueKind.invalidValue,
        ),
      ),
      'approved without a review reference': (
        fixtureCatalog([fixturePack('pack-a', [], withLabelReview: false)]),
        const ContentIssue(
          'packs[0].labelReview',
          ContentIssueKind.approvedLabelWithoutReview,
        ),
      ),
      'untidy review reference': (
        fixtureCatalog([
          {...fixturePack('pack-a', []), 'labelReview': ' fixture-r'},
        ]),
        const ContentIssue('packs[0].labelReview', ContentIssueKind.untidyText),
      ),
    };

    for (final MapEntry(key: name, value: (json, issue)) in cases.entries) {
      test(name, () => expect(issuesOf(decodeJson(json)), [issue]));
    }

    final inReview = fixtureCatalog([
      fixturePack(
        'pack-a',
        [fixtureWord('w-1')],
        labelStatus: 'in_review',
        withLabelReview: false,
      ),
    ]);

    test('an unreviewed label makes a release catalog invalid as a whole', () {
      expect(issuesOf(decodeJson(inReview)), [
        const ContentIssue(
          'packs[0].labelStatus',
          ContentIssueKind.unreviewedLabelInRelease,
        ),
      ]);
    });

    test('an unreviewed label in a pack without words is still rejected', () {
      final json = fixtureCatalog([
        fixturePack('pack-a', [fixtureWord('w-1')]),
        fixturePack('pack-b', [], labelStatus: 'in_review'),
      ]);

      expect(issuesOf(decodeJson(json)), [
        const ContentIssue(
          'packs[1].labelStatus',
          ContentIssueKind.unreviewedLabelInRelease,
        ),
      ]);
    });

    test('an unreviewed label is accepted in the development channel', () {
      expect(
        decodeJson(inReview, channel: ContentChannel.development),
        isA<DecodedCatalog>(),
      );
    });

    test('an approved label still needs its reference in development', () {
      final json = fixtureCatalog([
        fixturePack('pack-a', [], withLabelReview: false),
      ]);

      expect(issuesOf(decodeJson(json, channel: ContentChannel.development)), [
        const ContentIssue(
          'packs[0].labelReview',
          ContentIssueKind.approvedLabelWithoutReview,
        ),
      ]);
    });
  });

  test('issues never quote content text', () {
    const secretLike = 'fixture-secret-text';
    final json = fixtureCatalog([
      fixturePack('pack-a', [
        fixtureWord('w-1', canonical: secretLike, aliases: [secretLike]),
        fixtureWord('w-2', canonical: '$secretLike '),
        fixtureWord('w-3', category: '$secretLike label'),
      ], title: '$secretLike title'),
    ]);

    final issues = issuesOf(decodeJson(json));

    expect(issues, isNotEmpty);
    expect(issues.join('\n'), isNot(contains(secretLike)));
    expect(issues.join('\n'), isNot(contains('w-1')));
  });
}
