import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_tn/data/content/catalog_decoder.dart';
import 'package:impostor_tn/data/content/development_content.dart';
import 'package:impostor_tn/game/content/content_eligibility.dart';
import 'package:impostor_tn/game/content/content_issue.dart';
import 'package:impostor_tn/game/content/content_source.dart';
import 'package:impostor_tn/game/content/word_entry.dart';

/// D-35: development words can never reach a release build.
void main() {
  const file = 'package:impostor_tn/data/content/development_content.dart';

  test('only the composition root imports the development content', () {
    final importers = [
      for (final f in Directory('lib').listSync(recursive: true))
        if (f is File &&
            f.path.endsWith('.dart') &&
            f.readAsStringSync().contains(file))
          f.path.replaceAll(r'\', '/'),
    ];

    expect(importers, ['lib/app/app_providers.dart']);
  });

  test('it is used only inside a kDebugMode branch', () {
    final source = File('lib/app/app_providers.dart').readAsStringSync();
    final uses = RegExp(r'DevelopmentContent\w*').allMatches(source).toList();
    final guard = source.indexOf('if (kDebugMode) {');

    expect(guard, isNot(-1));
    for (final use in uses) {
      final inImport =
          source.lastIndexOf('import', use.start) >
          source.lastIndexOf(';', use.start);
      if (inImport) continue;
      expect(use.start, greaterThan(guard), reason: 'use before the guard');
      final branchEnd = source.indexOf('}', guard);
      expect(use.start, lessThan(branchEnd), reason: 'use outside the branch');
    }
  });

  test('every development word has development status and the marker', () {
    final catalog = (CatalogDecoder.decode(
      DevelopmentContent.catalogJson(),
      channel: ContentChannel.development,
    ) as DecodedCatalog).catalog;

    final words = [for (final p in catalog.packs) ...p.words];
    expect(words, hasLength(40));
    for (final pack in catalog.packs) {
      expect(pack.id, contains(DevelopmentContent.developmentMarker));
    }
    for (final word in words) {
      expect(word.status, EditorialStatus.development);
      expect(word.reviews, isNull);
      expect(word.id, contains(DevelopmentContent.developmentMarker));
    }
  });

  test('the development catalog is rejected in the release channel', () {
    final decoding = CatalogDecoder.decode(
      DevelopmentContent.catalogJson(),
      channel: ContentChannel.release,
    );

    expect(decoding, isA<InvalidCatalog>());
    // Twice guarded: development words, and labels never reviewed (D-38).
    expect((decoding as InvalidCatalog).issues.map((i) => i.kind).toSet(), {
      ContentIssueKind.developmentContentInRelease,
      ContentIssueKind.unreviewedLabelInRelease,
    });
  });

  test('merged with an empty bundled catalog, it loads', () async {
    final load = await DevelopmentContentSource(_Empty()).load();

    expect(load, isA<ContentReady>());
  });
}

final class _Empty implements ContentSource {
  @override
  Future<ContentLoad> load() async => ContentReady(
    (CatalogDecoder.decode(
      '{"format":1,"contentVersion":1,"packs":[]}',
      channel: ContentChannel.development,
    ) as DecodedCatalog).catalog,
  );
}
