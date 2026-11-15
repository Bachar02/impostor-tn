import 'package:flutter/painting.dart';

/// Type styles without colour. Mirrors `docs/design/tokens/typography.json`.
///
/// Rules from the token file: letter spacing stays 0 for Arabic, nothing below
/// 12, body never below 16, Western digits.
abstract final class TesskraTypography {
  /// Display family (variable font, `wght` axis). Declared in `pubspec.yaml`.
  static const displayFamily = 'NotoKufiArabic';

  /// Text family (static weights 400–700). Declared in `pubspec.yaml`.
  static const textFamily = 'IBMPlexSansArabic';

  static const double displayXLMinFontSize = 40;
  static const double displayLMinFontSize = 32;
  static const double maxTextScaleSupported = 1.5;

  static const displayXL = TextStyle(
    fontFamily: displayFamily,
    fontSize: 72,
    height: 1.3,
    fontWeight: FontWeight.w900,
    fontVariations: [FontVariation('wght', 900)],
    letterSpacing: 0,
  );
  static const displayL = TextStyle(
    fontFamily: displayFamily,
    fontSize: 48,
    height: 1.3,
    fontWeight: FontWeight.w900,
    fontVariations: [FontVariation('wght', 900)],
    letterSpacing: 0,
  );
  static const displayM = TextStyle(
    fontFamily: displayFamily,
    fontSize: 34,
    height: 1.35,
    fontWeight: FontWeight.w800,
    fontVariations: [FontVariation('wght', 800)],
    letterSpacing: 0,
  );
  static const titleL = TextStyle(
    fontFamily: displayFamily,
    fontSize: 26,
    height: 1.4,
    fontWeight: FontWeight.w800,
    fontVariations: [FontVariation('wght', 800)],
    letterSpacing: 0,
  );
  static const titleM = TextStyle(
    fontFamily: textFamily,
    fontSize: 20,
    height: 1.45,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );
  static const bodyL = TextStyle(
    fontFamily: textFamily,
    fontSize: 18,
    height: 1.6,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );
  static const bodyM = TextStyle(
    fontFamily: textFamily,
    fontSize: 16,
    height: 1.6,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );
  static const labelL = TextStyle(
    fontFamily: displayFamily,
    fontSize: 20,
    height: 1.3,
    fontWeight: FontWeight.w800,
    fontVariations: [FontVariation('wght', 800)],
    letterSpacing: 0,
  );
  static const labelM = TextStyle(
    fontFamily: textFamily,
    fontSize: 16,
    height: 1.3,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );
  static const caption = TextStyle(
    fontFamily: textFamily,
    fontSize: 13,
    height: 1.5,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
  );

  /// Vote counts. Render inside an LTR run (see `core/text/bidi.dart`).
  static const numericL = TextStyle(
    fontFamily: displayFamily,
    fontSize: 34,
    height: 1.2,
    fontWeight: FontWeight.w900,
    fontVariations: [FontVariation('wght', 900)],
    fontFeatures: [FontFeature.tabularFigures()],
    letterSpacing: 0,
  );

  /// Progress pills such as `2 / 6`. Render inside an LTR run.
  static const numericM = TextStyle(
    fontFamily: textFamily,
    fontSize: 16,
    height: 1.3,
    fontWeight: FontWeight.w700,
    fontFeatures: [FontFeature.tabularFigures()],
    letterSpacing: 0,
  );
}
