import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:impostor_tn/data/content/catalog_decoder.dart';
import 'package:impostor_tn/game/content/content_eligibility.dart';
import 'package:impostor_tn/game/content/content_source.dart';

/// Reads the catalog bundled with the app (ADR-0009). Read-only; the
/// database never stores word text.
final class BundledContentSource implements ContentSource {
  const BundledContentSource(
    this._bundle, {
    required this.channel,
    this.assetPath = catalogAsset,
  });

  /// The only content file. Declared in `pubspec.yaml`.
  static const catalogAsset = 'assets/content/catalog.json';

  final AssetBundle _bundle;
  final ContentChannel channel;
  final String assetPath;

  @override
  Future<ContentLoad> load() async {
    final String source;
    try {
      source = await _bundle.loadString(assetPath, cache: false);
    } on FlutterError {
      return ContentUnavailable(ContentUnavailableReason.missing);
    }
    return switch (CatalogDecoder.decode(source, channel: channel)) {
      DecodedCatalog(:final catalog) => ContentReady(catalog),
      InvalidCatalog(:final issues) => ContentUnavailable(
        ContentUnavailableReason.invalid,
        issues: issues,
      ),
    };
  }
}
