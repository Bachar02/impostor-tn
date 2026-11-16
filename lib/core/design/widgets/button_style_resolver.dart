import 'package:flutter/painting.dart';
import 'package:impostor_tn/core/design/theme/tesskra_tokens.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_metrics.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_shadows.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_button.dart';

/// The resolved look of one button state.
final class ButtonLook {
  const ButtonLook({
    required this.fill,
    required this.foreground,
    required this.border,
    required this.height,
    required this.largeLabel,
    this.shadow,
    this.pressOffset = Offset.zero,
  });

  final Color fill;
  final Color foreground;
  final Color border;
  final double height;

  /// `labelL` (Kufi) for primary and accent, `labelM` otherwise.
  final bool largeLabel;
  final BoxShadow? shadow;
  final Offset pressOffset;
}

/// Maps a variant and state to colours (DESIGN_SYSTEM §5 "Buttons").
abstract final class ButtonStyleResolver {
  static const _transparent = Color(0x00000000);

  /// Carbon buttons have no shadow and move down 2 when pressed.
  static const _carbonPress = Offset(0, 2);

  static ButtonLook resolve(
    TesskraTokens tokens,
    TesskraButtonVariant variant, {
    required bool enabled,
    required bool pressed,
  }) {
    final c = tokens.colors;
    final carbon = tokens.isCarbon;
    final large =
        variant == TesskraButtonVariant.primary ||
        variant == TesskraButtonVariant.accent;
    final height = switch (variant) {
      TesskraButtonVariant.primary ||
      TesskraButtonVariant.accent => TesskraSizes.buttonPrimaryHeight,
      TesskraButtonVariant.secondary ||
      TesskraButtonVariant.destructive => TesskraSizes.buttonSecondaryHeight,
      TesskraButtonVariant.text => TesskraSizes.buttonCompactHeight,
    };

    if (!enabled) {
      return ButtonLook(
        fill: variant == TesskraButtonVariant.text
            ? _transparent
            : _required(c.surfaceSunken, 'surfaceSunken'),
        foreground: c.textDisabled,
        border: c.textDisabled,
        height: height,
        largeLabel: large,
      );
    }

    switch (variant) {
      case TesskraButtonVariant.primary || TesskraButtonVariant.accent:
        final accent = variant == TesskraButtonVariant.accent;
        if (accent && carbon) {
          throw StateError('The accent button does not exist on carbon');
        }
        final fill = accent
            ? (pressed ? c.accentPressed! : c.accent!)
            : (pressed ? c.primaryPressed : c.primary);
        final shadow = carbon ? null : TesskraShadows.publicMd;
        return ButtonLook(
          fill: fill,
          foreground: accent ? c.onAccent! : c.onPrimary,
          // Paper buttons are outlined in ink; carbon in the outline colour.
          border: c.border,
          height: height,
          largeLabel: true,
          shadow: pressed ? null : shadow,
          pressOffset: pressed
              ? (carbon ? _carbonPress : TesskraShadows.publicMd.offset)
              : Offset.zero,
        );
      case TesskraButtonVariant.secondary:
        return ButtonLook(
          fill: pressed
              ? _required(c.surfaceSunken, 'surfaceSunken')
              : _transparent,
          foreground: c.textPrimary,
          border: carbon ? (c.borderStrong ?? c.border) : c.border,
          height: height,
          largeLabel: false,
          pressOffset: pressed && carbon ? _carbonPress : Offset.zero,
        );
      case TesskraButtonVariant.destructive:
        final red = _required(c.errorText, 'errorText');
        return ButtonLook(
          fill: pressed
              ? _required(c.surfaceSunken, 'surfaceSunken')
              : _transparent,
          foreground: red,
          border: red,
          height: height,
          largeLabel: false,
          pressOffset: pressed && carbon ? _carbonPress : Offset.zero,
        );
      case TesskraButtonVariant.text:
        return ButtonLook(
          fill: _transparent,
          foreground: c.textPrimary,
          border: _transparent,
          height: height,
          largeLabel: false,
        );
    }
  }

  static Color _required(Color? color, String name) =>
      color ?? (throw StateError('Theme defines no $name'));
}
