import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_tn/data/content/bundled_content_source.dart';
import 'package:impostor_tn/data/content/catalog_decoder.dart';
import 'package:impostor_tn/data/content/development_content.dart';
import 'package:impostor_tn/game/content/content_eligibility.dart';

import '../../core/design/widgets/widget_harness.dart';
import '../../support/ticket_category_fit.dart';

/// Regression guard for D-39: a category that would need a third line on a
/// role ticket breaks Civilian/Impostor parity, and the ticket cannot fix
/// that without shrinking or clipping. No character limit exists (D-40
/// instruction); instead every category actually shipped is rendered at
/// the design frames and the suite fails if one does not fit. Categories
/// are reported by pack index, never by text.
void main() {
  List<String> labelsOf(String source, ContentChannel channel) {
    final decoding = CatalogDecoder.decode(source, channel: channel);
    expect(decoding, isA<DecodedCatalog>());
    // D-38: the pack title is every word's category.
    return [
      for (final pack in (decoding as DecodedCatalog).catalog.packs) pack.title,
    ];
  }

  // Decoded inside each test: `expect` cannot run while the file loads.
  final catalogs = <String, List<String> Function()>{
    'bundled catalog': () => labelsOf(
      File(BundledContentSource.catalogAsset).readAsStringSync(),
      ContentChannel.release,
    ),
    'development catalog': () =>
        labelsOf(DevelopmentContent.catalogJson(), ContentChannel.development),
  };

  for (final MapEntry(key: name, value: load) in catalogs.entries) {
    for (final (frame, size, scale) in frames) {
      testWidgets('every category of the $name fits two lines at $frame', (
        tester,
      ) async {
        for (final (i, label) in load().indexed) {
          final fit = await measureCategory(tester, label, size, scale);

          expect(fit.fits, isTrue, reason: 'packs[$i]: $fit');
        }
      });
    }
  }

  group('the guard catches a category needing a third line', () {
    // SYNTHETIC: deliberately too long; not content and not a proposed
    // label. Shows the failure the guard above exists to catch.
    const threeLines =
        'صنف طويل برشة برشة باش يلزمو ثلاثة سطور كاملة في التذكرة';

    for (final (frame, size, scale) in frames) {
      testWidgets('at $frame', (tester) async {
        final fit = await measureCategory(tester, threeLines, size, scale);

        expect(fit.fits, isFalse, reason: '$fit');
        expect(fit.parity, isFalse, reason: 'parity really breaks: $fit');
      });
    }
  });
}
