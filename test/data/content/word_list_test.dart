import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_tn/data/content/bundled_content_source.dart';
import 'package:impostor_tn/data/content/catalog_decoder.dart';
import 'package:impostor_tn/game/content/content_catalog.dart';
import 'package:impostor_tn/game/content/content_eligibility.dart';
import 'package:impostor_tn/game/content/word_entry.dart';

import '../../../tool/catalog_builder.dart';
import '../../support/proposed_category_labels.dart';

/// `content/words.tsv` is the editable word list; `catalog.json` is built
/// from it by `dart run tool/build_catalog.dart` (D-42).
void main() {
  const wordListPath = 'content/words.tsv';
  const catalogPath = BundledContentSource.catalogAsset;

  group('the bundled catalog', () {
    test('is in sync with the word list (run tool/build_catalog.dart)', () {
      final result = buildCatalog(
        wordList: File(wordListPath).readAsStringSync(),
        existingCatalog: File(catalogPath).readAsStringSync(),
      );

      expect(result, isA<BuiltCatalog>(), reason: '$result');
      expect(
        (result as BuiltCatalog).changed,
        isFalse,
        reason:
            '$wordListPath was edited: run dart run tool/build_catalog.dart',
      );
    });

    ContentCatalog decode(ContentChannel channel) => (CatalogDecoder.decode(
      File(catalogPath).readAsStringSync(),
      channel: channel,
    ) as DecodedCatalog).catalog;

    test('has one pack per proposed label, in order, 20 words each', () {
      final catalog = decode(ContentChannel.development);

      expect(catalog.packs.map((p) => p.title), proposedLabels);
      for (final pack in catalog.packs) {
        expect(pack.words, hasLength(20), reason: pack.id);
        expect(
          ContentEligibility.playableCount(pack, ContentChannel.development),
          20,
          reason: '${pack.id} playable in debug',
        );
      }
    });

    test('everything is in review; no review is claimed', () {
      for (final pack in decode(ContentChannel.development).packs) {
        expect(pack.labelStatus, LabelStatus.inReview);
        expect(pack.labelReview, isNull);
        for (final word in pack.words) {
          expect(word.status, EditorialStatus.inReview);
          expect(word.reviews, isNull);
        }
      }
    });

    test('a release build shows and plays none of it', () {
      expect(decode(ContentChannel.release).packs, isEmpty);
    });
  });

  group('buildCatalog', () {
    // SYNTHETIC: placeholder labels and words, not content.
    const header = wordListHeader;
    String list(List<String> rows) => ['# comment', header, ...rows].join('\n');
    const empty = '{"format": 1, "contentVersion": 1, "packs": []}';

    Map<String, Object?> built(CatalogBuild result) =>
        jsonDecode((result as BuiltCatalog).json) as Map<String, Object?>;
    Map<String, Object?> pack(Map<String, Object?> catalog, int index) =>
        (catalog['packs']! as List<Object?>)[index]! as Map<String, Object?>;
    Map<String, Object?> word(Map<String, Object?> catalog, int p, int w) =>
        (pack(catalog, p)['words']! as List<Object?>)[w]!
            as Map<String, Object?>;

    test('a new pack and word start in review at version 1', () {
      final result = buildCatalog(
        wordList: list(['p01\tlabel a\tp01-w01\tword a\tvariant a|variant b']),
        existingCatalog: empty,
      );

      final catalog = built(result);
      expect(catalog['contentVersion'], 2);
      expect(pack(catalog, 0)['labelStatus'], 'in_review');
      expect(word(catalog, 0, 0), {
        'id': 'p01-w01',
        'version': 1,
        'canonical': 'word a',
        'aliases': ['variant a', 'variant b'],
        'category': 'label a',
        'language': 'aeb-Arab',
        'access': 'free',
        'status': 'in_review',
      });
    });

    // An existing catalog with one approved label and one reviewed word.
    const reviewed =
        '{"format": 1, "contentVersion": 5, "packs": [{"id": "p01", '
        '"title": "label a", "labelStatus": "approved", '
        '"labelReview": "ref-l", "words": [{"id": "p01-w01", "version": 3, '
        '"canonical": "word a", "aliases": [], "category": "label a", '
        '"language": "aeb-Arab", "access": "free", "status": "published", '
        '"reviews": {"linguistic": "ref-1", "editorial": "ref-2"}}]}]}';

    test('unchanged rows keep version, status and reviews', () {
      final result = buildCatalog(
        wordList: list(['p01\tlabel a\tp01-w01\tword a\t']),
        existingCatalog: reviewed,
      );

      expect((result as BuiltCatalog).changed, isFalse);
      final catalog = built(result);
      expect(catalog['contentVersion'], 5);
      expect(pack(catalog, 0)['labelReview'], 'ref-l');
      expect(word(catalog, 0, 0)['version'], 3);
      expect(word(catalog, 0, 0)['status'], 'published');
      expect(word(catalog, 0, 0)['reviews'], isNotNull);
    });

    test('changed text raises the version and drops an earlier review', () {
      final catalog = built(
        buildCatalog(
          wordList: list(['p01\tlabel a\tp01-w01\tword b\t']),
          existingCatalog: reviewed,
        ),
      );

      expect(catalog['contentVersion'], 6);
      expect(word(catalog, 0, 0)['version'], 4);
      expect(word(catalog, 0, 0)['status'], 'in_review');
      expect(word(catalog, 0, 0).containsKey('reviews'), isFalse);
    });

    test('a new variant also counts as changed text', () {
      final catalog = built(
        buildCatalog(
          wordList: list(['p01\tlabel a\tp01-w01\tword a\tvariant a']),
          existingCatalog: reviewed,
        ),
      );

      expect(word(catalog, 0, 0)['version'], 4);
      expect(word(catalog, 0, 0)['status'], 'in_review');
    });

    test('a changed label goes back to review without its reference', () {
      final catalog = built(
        buildCatalog(
          wordList: list(['p01\tlabel b\tp01-w01\tword a\t']),
          existingCatalog: reviewed,
        ),
      );

      expect(pack(catalog, 0)['labelStatus'], 'in_review');
      expect(pack(catalog, 0).containsKey('labelReview'), isFalse);
      expect(word(catalog, 0, 0)['version'], 4, reason: 'category changed');
    });

    for (final (name, rows, existing, needle) in [
      (
        'a removed word id',
        ['p01\tlabel a\tp01-w02\tword b\t'],
        reviewed,
        'p01-w01',
      ),
      (
        'a removed pack id',
        ['p02\tlabel a\tp02-w01\tword a\t'],
        reviewed,
        'p01',
      ),
      (
        'a word id used twice',
        ['p01\tlabel a\tp01-w01\tword a\t', 'p01\tlabel a\tp01-w01\tword b\t'],
        empty,
        'line 4',
      ),
      (
        'two labels in one pack',
        ['p01\tlabel a\tp01-w01\tword a\t', 'p01\tlabel b\tp01-w02\tword b\t'],
        empty,
        'line 4',
      ),
      ('a missing column', ['p01\tlabel a\tp01-w01'], empty, 'line 3'),
    ]) {
      test('$name is refused, nothing is built', () {
        final result = buildCatalog(
          wordList: list(rows),
          existingCatalog: existing,
        );

        expect(result, isA<CatalogBuildFailed>());
        expect(
          (result as CatalogBuildFailed).errors.join('\n'),
          contains(needle),
        );
      });
    }

    test('a missing header is refused', () {
      final result = buildCatalog(
        wordList: 'p01\tlabel a\tp01-w01\tword a\t',
        existingCatalog: empty,
      );

      expect(result, isA<CatalogBuildFailed>());
    });

    test('rules of the app apply, reported by id without word text', () {
      final result = buildCatalog(
        wordList: list([
          'p01\tlabel a\tp01-w01\tsecret-like\t',
          'p02\tlabel b\tp02-w01\tother\tsecret-like',
        ]),
        existingCatalog: empty,
      );

      final errors = (result as CatalogBuildFailed).errors.join('\n');
      expect(errors, contains('p02-w01'));
      expect(errors, contains('answerSharedWithOtherWord'));
      expect(errors, isNot(contains('secret-like')));
    });

    test('a spreadsheet export with BOM, CRLF and padded cells works', () {
      final result = buildCatalog(
        wordList: '﻿$header\r\np01\t label a \tp01-w01\t word a \t a | b \r\n',
        existingCatalog: empty,
      );

      final catalog = built(result);
      expect(word(catalog, 0, 0)['canonical'], 'word a');
      expect(word(catalog, 0, 0)['aliases'], ['a', 'b']);
      expect(pack(catalog, 0)['title'], 'label a');
    });

    test('building twice changes nothing the second time', () {
      final first = buildCatalog(
        wordList: list(['p01\tlabel a\tp01-w01\tword a\t']),
        existingCatalog: empty,
      );
      final second = buildCatalog(
        wordList: list(['p01\tlabel a\tp01-w01\tword a\t']),
        existingCatalog: (first as BuiltCatalog).json,
      );

      expect((second as BuiltCatalog).changed, isFalse);
      expect(second.json, first.json);
    });
  });
}
