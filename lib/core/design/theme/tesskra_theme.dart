import 'package:flutter/material.dart';
import 'package:impostor_tn/core/design/theme/tesskra_tokens.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_colors.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_typography.dart';

/// The two Tesskra themes, mapped as described in `docs/DESIGN_SYSTEM.md` §7.
///
/// `public` (paper) is for screens the whole table may see; `private` (carbon)
/// is for screens one player sees alone. Component themes are added together
/// with the components that need them.
abstract final class TesskraTheme {
  static final ThemeData public = _build(
    TesskraSurface.paper,
    TesskraColors.public,
    Brightness.light,
  );
  static final ThemeData private = _build(
    TesskraSurface.carbon,
    TesskraColors.private,
    Brightness.dark,
  );

  static ThemeData _build(
    TesskraSurface surface,
    TesskraColors c,
    Brightness brightness,
  ) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: c.primary,
      onPrimary: c.onPrimary,
      // The private theme has no accent; Material still requires the slot.
      secondary: c.accent ?? c.primary,
      onSecondary: c.onAccent ?? c.onPrimary,
      error: c.error,
      onError: c.onPrimary,
      surface: c.background,
      onSurface: c.textPrimary,
      onSurfaceVariant: c.textSecondary,
      surfaceContainer: c.surface,
      outline: c.border,
      shadow: c.shadow,
      scrim: c.scrim,
    );

    return ThemeData(
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.background,
      fontFamily: TesskraTypography.textFamily,
      textTheme: _textTheme(c.textPrimary),
      extensions: [
        TesskraTokens(
          surface: surface,
          colors: c,
          numericL: TesskraTypography.numericL.copyWith(color: c.textPrimary),
          numericM: TesskraTypography.numericM.copyWith(color: c.textPrimary),
        ),
      ],
    );
  }

  static TextTheme _textTheme(Color color) {
    TextStyle on(TextStyle style) => style.copyWith(color: color);
    return TextTheme(
      displayLarge: on(TesskraTypography.displayXL),
      displayMedium: on(TesskraTypography.displayL),
      displaySmall: on(TesskraTypography.displayM),
      headlineSmall: on(TesskraTypography.titleL),
      titleLarge: on(TesskraTypography.titleM),
      bodyLarge: on(TesskraTypography.bodyL),
      bodyMedium: on(TesskraTypography.bodyM),
      labelLarge: on(TesskraTypography.labelL),
      labelMedium: on(TesskraTypography.labelM),
      bodySmall: on(TesskraTypography.caption),
    );
  }
}
