import 'dart:convert';

import 'package:impostor_tn/data/content/catalog_decoder.dart';
import 'package:impostor_tn/game/content/catalog_validation.dart';
import 'package:impostor_tn/game/content/content_catalog.dart';
import 'package:impostor_tn/game/content/content_eligibility.dart';
import 'package:impostor_tn/game/content/content_source.dart';

/// DEVELOPMENT-ONLY SYNTHETIC CONTENT (D-35, ADR-0009). NOT GAME CONTENT.
///
/// Placeholder words (`dev01`, `dev02`, …) so the slice can be played before
/// real content exists (Q-13). They are not Tunisian words, have status
/// `development`, were never reviewed and must never be published.
///
/// Guards that keep them out of a release build:
/// 1. The only reference is inside `if (kDebugMode)` in `lib/app`, so the
///    release compiler removes this file's code and strings.
/// 2. A source guard test checks that reference.
/// 3. A release catalog containing a `development` word is rejected whole.
/// 4. The release-build check greps the compiled binary for
///    [developmentMarker] (`docs/DEVELOPMENT_CHECKLIST.md`).
abstract final class DevelopmentContent {
  /// Appears in every development pack id; searched for in release binaries.
  static const developmentMarker = 'dev-synthetic';

  static String catalogJson() => jsonEncode({
    'format': CatalogDecoder.supportedFormat,
    'contentVersion': 1,
    'packs': [
      _pack('a', 'DEV pack A (synthetic)', 1),
      _pack('b', 'DEV pack B (synthetic)', 21),
    ],
  });

  /// One label is both the pack title and every word's category (D-38).
  /// It is never reviewed, so `in_review`.
  static Map<String, Object?> _pack(String letter, String label, int first) => {
    'id': '$developmentMarker-$letter',
    'title': label,
    'labelStatus': 'in_review',
    'words': [
      for (var i = first; i < first + 20; i++)
        {
          'id': '$developmentMarker-w${i.toString().padLeft(2, '0')}',
          // 2: the category text changed with D-38.
          'version': 2,
          'canonical': 'dev${i.toString().padLeft(2, '0')}',
          'aliases': <String>[],
          'category': label,
          'language': 'und',
          'access': 'free',
          'status': 'development',
        },
    ],
  };
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
