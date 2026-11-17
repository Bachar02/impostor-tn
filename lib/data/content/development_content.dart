import 'dart:convert';

import 'package:impostor_tn/data/content/catalog_decoder.dart';
import 'package:impostor_tn/game/content/catalog_validation.dart';
import 'package:impostor_tn/game/content/content_catalog.dart';
import 'package:impostor_tn/game/content/content_eligibility.dart';
import 'package:impostor_tn/game/content/content_source.dart';

/// DEVELOPMENT-ONLY SYNTHETIC CONTENT (D-35, ADR-0009). NOT GAME CONTENT.
///
/// One pack per proposed category label (D-37/D-38), so the labels can be
/// seen and played in debug builds. The labels are `in_review` (not
/// approved). The words are placeholders (`dev001`, `dev002`, …): not
/// Tunisian words, status `development`, never reviewed, never published.
/// Real word content is Q-13.
///
/// Guards that keep them out of a release build:
/// 1. The only reference is inside `if (kDebugMode)` in `lib/app`, so the
///    release compiler removes this file's code and strings.
/// 2. A source guard test checks that reference.
/// 3. A release catalog containing a `development` word or an unreviewed
///    label is rejected whole.
/// 4. The release-build check greps the compiled binary for
///    [developmentMarker] (`docs/DEVELOPMENT_CHECKLIST.md`).
abstract final class DevelopmentContent {
  /// Appears in every development pack id; searched for in release binaries.
  static const developmentMarker = 'dev-synthetic';

  /// The proposed category labels, in the Product Owner's order. [REVIEW]:
  /// not approved by a Derja reviewer.
  static const categoryLabels = [
    'مكلة',
    'بلايص',
    'حيوانات',
    'خدمة',
    'حاجات في الدار',
    'تنقّل',
    'رياضة',
    'فنّ وفرجة',
    'تكنولوجيا',
    'بدن الإنسان',
    'قراية',
    'حاجات في الشارع',
    'عادات وتقاليد',
  ];

  static const wordsPerPack = 20;

  static String catalogJson() => jsonEncode({
    'format': CatalogDecoder.supportedFormat,
    'contentVersion': 1,
    'packs': [
      for (final (index, label) in categoryLabels.indexed) _pack(index, label),
    ],
  });

  /// Pack ids `dev-synthetic-a` … `-m` and word ids `dev-synthetic-w01` …
  /// in sequence, so the ids of the first two packs are the ones used
  /// before. One label is both the title and every word's category (D-38).
  static Map<String, Object?> _pack(int index, String label) {
    final letter = String.fromCharCode('a'.codeUnitAt(0) + index);
    final first = index * wordsPerPack + 1;
    return {
      'id': '$developmentMarker-$letter',
      'title': label,
      'labelStatus': 'in_review',
      'words': [
        for (var i = first; i < first + wordsPerPack; i++)
          {
            'id': '$developmentMarker-w${i.toString().padLeft(2, '0')}',
            // 3: label and placeholder text changed again.
            'version': 3,
            'canonical': 'dev${i.toString().padLeft(3, '0')}',
            'aliases': <String>[],
            'category': label,
            'language': 'und',
            'access': 'free',
            'status': 'development',
          },
      ],
    };
  }
}

/// [ContentSource] for debug builds: the bundled catalog plus the
/// development packs, validated together so they cannot collide.
final class DevelopmentContentSource implements ContentSource {
  const DevelopmentContentSource(this._bundled);

  final ContentSource _bundled;

  @override
  Future<ContentLoad> load() async {
    final bundled = await _bundled.load();
    if (bundled is! ContentReady) return bundled;
    final development = CatalogDecoder.decode(
      DevelopmentContent.catalogJson(),
      channel: ContentChannel.development,
    );
    if (development is! DecodedCatalog) {
      return ContentUnavailable(
        ContentUnavailableReason.invalid,
        issues: (development as InvalidCatalog).issues,
      );
    }
    final merged = ContentCatalog(
      contentVersion: bundled.catalog.contentVersion,
      packs: [...bundled.catalog.packs, ...development.catalog.packs],
    );
    final issues = CatalogValidation.validate(
      merged,
      ContentChannel.development,
    );
    return issues.isEmpty
        ? ContentReady(merged)
        : ContentUnavailable(ContentUnavailableReason.invalid, issues: issues);
  }
}
