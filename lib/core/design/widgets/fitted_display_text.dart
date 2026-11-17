import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_typography.dart';

/// Display text that shrinks to fit (SCREEN_SPECIFICATIONS §1.3, Q-23 (9)).
///
/// The start size is the style's size times the system text scale, clamped
/// at [TesskraTypography.maxTextScaleSupported]. It then shrinks until the
/// text fits [maxLines] lines in the available width, but not below
/// [minFontSize], which is absolute (not scaled).
///
/// If the text still does not fit at the floor, it stays at the floor and
/// wraps onto further lines. It is never drawn smaller than the floor (D-34)
/// and never clipped. This is a provisional answer to Q-29 (long words).
///
/// With [reserveHeight], the widget takes at least the height of [maxLines]
/// lines at the start size, whatever size the text is fitted to. Role-ticket
/// parity (D-27) uses this so the ticket height never depends on the text,
/// except for a text that must wrap at the floor (Q-29).
///
/// [floorLinesReserved] raises that reserve to at least so many lines at
/// [minFontSize], so a text that wraps at the floor onto that many lines
/// keeps the same height too (D-39).
class FittedDisplayText extends StatelessWidget {
  const FittedDisplayText(
    this.text, {
    super.key,
    required this.style,
    required this.minFontSize,
    this.maxLines = 1,
    this.reserveHeight = false,
    this.floorLinesReserved = 1,
    this.textAlign = TextAlign.center,
    this.textDirection,
  });

  final String text;

  /// Must have `fontSize` and `height`.
  final TextStyle style;
  final double minFontSize;
  final int maxLines;
  final bool reserveHeight;
  final int floorLinesReserved;
  final TextAlign textAlign;
  final TextDirection? textDirection;

  /// The font size [text] is drawn at in [maxWidth], before any last-resort
  /// scaling. Exposed for tests.
  /// Whether [text] fits [maxLines] lines of [maxWidth] at [size].
  static bool fitsAt({
    required String text,
    required TextStyle style,
    required double size,
    required int maxLines,
    required double maxWidth,
    required TextDirection textDirection,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: style.copyWith(fontSize: size),
      ),
      textDirection: textDirection,
      maxLines: maxLines,
      textScaler: TextScaler.noScaling,
    )..layout(maxWidth: maxWidth);
    final fits =
        !painter.didExceedMaxLines &&
        (maxLines > 1 || painter.maxIntrinsicWidth <= maxWidth);
    painter.dispose();
    return fits;
  }

  static double fittedSize({
    required String text,
    required TextStyle style,
    required double startSize,
    required double minFontSize,
    required int maxLines,
    required double maxWidth,
    required TextDirection textDirection,
  }) {
    bool fits(double size) => fitsAt(
      text: text,
      style: style,
      size: size,
      maxLines: maxLines,
      maxWidth: maxWidth,
      textDirection: textDirection,
    );

    if (startSize <= minFontSize || fits(startSize)) return startSize;
    // Whole-pixel binary search: at most about 6 layouts for 72 → 40.
    var low = minFontSize;
    var high = startSize;
    if (!fits(low)) return low;
    while (high - low > 1) {
      final middle = ((low + high) / 2).floorToDouble();
      if (fits(middle)) {
        low = middle;
      } else {
        high = middle;
      }
    }
    return low;
  }

  @override
  Widget build(BuildContext context) {
    final scale = math.min(
      MediaQuery.textScalerOf(context).scale(1),
      TesskraTypography.maxTextScaleSupported,
    );
    final startSize = style.fontSize! * scale;
    final direction = textDirection ?? Directionality.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = fittedSize(
          text: text,
          style: style,
          startSize: startSize,
          minFontSize: minFontSize,
          maxLines: maxLines,
          maxWidth: constraints.maxWidth,
          textDirection: direction,
        );
        final fitsAtSize = fitsAt(
          text: text,
          style: style,
          size: size,
          maxLines: maxLines,
          maxWidth: constraints.maxWidth,
          textDirection: direction,
        );
        final fitted = Text(
          text,
          style: style.copyWith(fontSize: size),
          // At the floor and still too long: wrap, never shrink (D-34).
          maxLines: fitsAtSize ? maxLines : null,
          textAlign: textAlign,
          textDirection: direction,
          textScaler: TextScaler.noScaling,
          softWrap: maxLines > 1 || !fitsAtSize,
        );
        if (!reserveHeight) return fitted;
        return ConstrainedBox(
          constraints: BoxConstraints(
            // Laid-out lines are rounded to whole pixels, so each reserved
            // line is rounded up: text never exceeds the reserve (D-39).
            minHeight: math.max(
              maxLines * (startSize * style.height!).ceilToDouble(),
              floorLinesReserved * (minFontSize * style.height!).ceilToDouble(),
            ),
          ),
          child: Center(child: fitted),
        );
      },
    );
  }
}
