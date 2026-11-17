import 'package:flutter/material.dart';
import 'package:impostor_tn/core/design/assets/tesskra_assets.dart';
import 'package:impostor_tn/core/design/theme/tesskra_tokens.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_metrics.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_typography.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_icon.dart';

/// Empty or error state (DESIGN_SYSTEM §5): 72 outlined circle with an icon,
/// a `titleM` line, an optional `bodyM` hint and an optional action.
class StateBlock extends StatelessWidget {
  const StateBlock({
    super.key,
    required this.icon,
    required this.title,
    this.hint,
    this.action,
  });

  final TesskraIcons icon;
  final String title;
  final String? hint;
  final Widget? action;

  static const double circle = 72;

  @override
  Widget build(BuildContext context) {
    final c = TesskraTokens.of(context).colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: circle,
          height: circle,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: c.textPrimary,
              width: TesskraBorders.standard,
            ),
          ),
          alignment: Alignment.center,
          child: TesskraIcon(icon, color: c.textPrimary),
        ),
        const SizedBox(height: TesskraSpacing.s4),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TesskraTypography.titleM.copyWith(color: c.textPrimary),
        ),
        if (hint != null) ...[
          const SizedBox(height: TesskraSpacing.s2),
          Text(
            hint!,
            textAlign: TextAlign.center,
            style: TesskraTypography.bodyM.copyWith(color: c.textSecondary),
          ),
        ],
        if (action != null) ...[
          const SizedBox(height: TesskraSpacing.s4),
          action!,
        ],
      ],
    );
  }
}

/// `ic_eye_off` + "no one else should see" in mustard (PRV-02, PRV-03,
/// PRV-04 layout item 1).
class PrivacyHint extends StatelessWidget {
  const PrivacyHint({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = TesskraTokens.of(context).colors;
    return Row(
      children: [
        TesskraIcon(TesskraIcons.eyeOff, color: c.primary),
        const SizedBox(width: TesskraSpacing.s2),
        Expanded(
          child: Text(
            text,
            style: TesskraTypography.labelM.copyWith(color: c.primary),
          ),
        ),
      ],
    );
  }
}

/// Pill with an icon (DESIGN_SYSTEM §5 "Chips / pills"): border 2.5,
/// `labelM`.
class PhaseChip extends StatelessWidget {
  const PhaseChip({super.key, required this.icon, required this.label});

  final TesskraIcons icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = TesskraTokens.of(context).colors;
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: TesskraSpacing.s3,
        vertical: TesskraSpacing.s1,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(TesskraRadii.pill),
        border: Border.all(color: c.border, width: TesskraBorders.standard),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TesskraIcon(icon, color: c.textPrimary, size: TesskraSizes.iconSmall),
          const SizedBox(width: TesskraSpacing.s2),
          Flexible(
            child: Text(
              label,
              style: TesskraTypography.labelM.copyWith(color: c.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Paints a dashed rounded rectangle (dashes 8 on, 6 off; DESIGN_SYSTEM §3).
class DashedBorderPainter extends CustomPainter {
  DashedBorderPainter({
    required this.color,
    this.radius = TesskraRadii.md,
    this.width = TesskraBorders.standard,
  });

  final Color color;
  final double radius;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final inset = width / 2;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(inset, inset, size.width - width, size.height - width),
          Radius.circular(radius),
        ),
      );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + TesskraBorders.dashLength),
          paint,
        );
        distance += TesskraBorders.dashLength + TesskraBorders.dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(DashedBorderPainter old) =>
      old.color != color || old.radius != radius || old.width != width;
}
