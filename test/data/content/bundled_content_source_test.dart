import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_tn/data/content/bundled_content_source.dart';
import 'package:impostor_tn/data/content/catalog_decoder.dart';
import 'package:impostor_tn/game/content/content_eligibility.dart';
import 'package:impostor_tn/game/content/content_source.dart';
import 'package:impostor_tn/game/content/word_entry.dart';

import 'catalog_fixtures.dart';

/// Serves fixed strings by key; an unknown key fails like a missing asset.
final class FakeBundle extends CachingAssetBundle {
  FakeBundle(this.files);

  final Map<String, String> files;

  @override
  Future<ByteData> load(String key) async {
    final text = files[key];
    if (text == null) throw FlutterError('missing asset');
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(text)));
  }
}

void main() {
  const path = BundledContentSource.catalogAsset;

  test('a valid file loads as ready', () async {
    final source = BundledContentSource(
      FakeBundle({path: encode(validFixtureCatalog())}),
      channel: ContentChannel.release,
    );

    expect(await source.load(), isA<ContentReady>());
  });

  test('a missing file is a controlled unavailable state', () async {
    final source = BundledContentSource(
      FakeBundle({}),
      channel: ContentChannel.release,
    );

    final load = await source.load();

    expect(load, isA<ContentUnavailable>());
    expect(
      (load as ContentUnavailable).reason,
      ContentUnavailableReason.missing,
    );
  });

  test('an invalid file is a controlled unavailable state', () async {
    final source = BundledContentSource(
      FakeBundle({path: '{"format": 1}'}),
      channel: ContentChannel.release,
    );

    final load = await source.load();

    expect(
      (load as ContentUnavailable).reason,
      ContentUnavailableReason.invalid,
    );
    expect(load.issues, isNotEmpty);
  });

  group('the bundled production catalog', () {
    final file = File(path);

    test('is declared as an asset', () {
      expect(File('pubspec.yaml').readAsStringSync(), contains('- $path'));
    });

    test('is valid for a release build', () {
      final decoding = CatalogDecoder.decode(
        file.readAsStringSync(),
        channel: ContentChannel.release,
      );

      expect(decoding, isA<DecodedCatalog>(), reason: '$decoding');
    });

    test('contains no development word, so none can reach a release', () {
      final catalog = (CatalogDecoder.decode(
        file.readAsStringSync(),
        channel: ContentChannel.development,
      ) as DecodedCatalog).catalog;

      final development = [
        for (final pack in catalog.packs)
          for (final word in pack.words)
            if (word.status == EditorialStatus.development) word,
      ];
      expect(development, isEmpty);
    });

    test('no other content file is bundled', () {
      final declared = File('pubspec.yaml')
          .readAsLinesSync()
          .where((line) => line.trim().startsWith('- assets/'))
          .map((line) => line.trim());

      expect(declared, ['- $path']);
    });
  });
}
