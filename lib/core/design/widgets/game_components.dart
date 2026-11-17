import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:impostor_tn/core/design/assets/tesskra_assets.dart';
import 'package:impostor_tn/core/design/theme/tesskra_tokens.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_colors.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_metrics.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_shadows.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_typography.dart';
import 'package:impostor_tn/core/design/widgets/fitted_display_text.dart';
import 'package:impostor_tn/core/design/widgets/setup_components.dart';
import 'package:impostor_tn/core/design/widgets/small_components.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_icon.dart';
import 'package:impostor_tn/core/text/bidi.dart';

enum VoteOptionState { available, selected, unavailable }

/// One choice on the private vote (DESIGN_SYSTEM §5 "Vote option", PRV-03):
/// height 64, radio at the start, name in `titleM`.
class VoteOption extends StatelessWidget {
  const VoteOption({
    super.key,
    required this.name,
    required this.state,
    required this.onTap,
    this.unavailableLabel,
  });

  final String name;
  final VoteOptionState state;
  final VoidCallback? onTap;

  /// "you", shown on the voter's own row.
  final String? unavailableLabel;

  static const double _radio = 28;

  @override
  Widget build(BuildContext context) {
    final c = TesskraTokens.of(context).colors;
    final selected = state == VoteOptionState.selected;
    final unavailable = state == VoteOptionState.unavailable;
    final text = unavailable ? c.textDisabled : c.textPrimary;
    final radio = Container(
      width: _radio,
      height: _radio,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? c.primary : text,
          width: TesskraBorders.standard,
        ),
      ),
      child: selected
          ? Container(
              width: _radio / 2,
              height: _radio / 2,
              decoration: BoxDecoration(
                color: c.primary,
                shape: BoxShape.circle,
              ),
            )
          : null,
    );
    final row = Container(
      height: TesskraSizes.voteOptionHeight,
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: TesskraSpacing.s4,
      ),
      decoration: unavailable
          ? null
          : BoxDecoration(
              color: selected ? null : c.surface,
              borderRadius: BorderRadius.circular(TesskraRadii.md),
              border: Border.all(
                color: selected ? c.primary : c.border,
                width: TesskraBorders.standard,
              ),
            ),
      foregroundDecoration: selected
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(TesskraRadii.md - 3),
              border: Border.all(
                color: c.primary,
                width: TesskraBorders.hairline,
              ),
            )
          : null,
      child: Row(
        children: [
          radio,
          const SizedBox(width: TesskraSpacing.s3),
          Expanded(
            child: Text(
              directionIsolate(name),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TesskraTypography.titleM.copyWith(color: text),
            ),
          ),
          if (unavailable && unavailableLabel != null)
            Text(
              unavailableLabel!,
              style: TesskraTypography.caption.copyWith(color: text),
            ),
        ],
      ),
    );
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      enabled: !unavailable,
      onTap: unavailable ? null : onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: unavailable ? null : onTap,
        child: unavailable
            ? CustomPaint(
                painter: DashedBorderPainter(color: c.textDisabled),
                child: row,
              )
            : row,
      ),
    );
  }
}

/// One candidate's count (DESIGN_SYSTEM §5 "Vote tally row"): name, one
/// outlined red mark per vote, the count in `numericL`, dashed divider.
/// [visibleMarks] lets the tally reveal marks one at a time.
class VoteTallyRow extends StatelessWidget {
  const VoteTallyRow({
    super.key,
    required this.name,
    required this.count,
    int? visibleMarks,
  }) : visibleMarks = visibleMarks ?? count;

  final String name;
  final int count;
  final int visibleMarks;

  /// Mark size as drawn in render `08_results`. Not a token.
  static const double _mark = 16;

  @override
  Widget build(BuildContext context) {
    final tokens = TesskraTokens.of(context);
    final c = tokens.colors;
    final red = c.errorText!;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: TesskraSpacing.s3),
      child: CustomPaint(
        foregroundPainter: _DividerPainter(color: c.border),
        child: Padding(
          padding: const EdgeInsets.only(bottom: TesskraSpacing.s3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  directionIsolate(name),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TesskraTypography.titleM.copyWith(
                    color: c.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: TesskraSpacing.s2),
              Expanded(
                flex: 2,
                child: ExcludeSemantics(
                  child: Wrap(
                    spacing: TesskraSpacing.s1,
                    runSpacing: TesskraSpacing.s1,
                    children: [
                      for (var i = 0; i < visibleMarks; i++)
                        Container(
                          width: _mark,
                          height: _mark,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              TesskraRadii.xs / 2,
                            ),
                            border: Border.all(
                              color: red,
                              width: TesskraBorders.standard,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: TesskraSpacing.s2),
              Text(
                ltrIsolate('${math.min(visibleMarks, count)}'),
                style: tokens.numericL,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DividerPainter extends CustomPainter {
  _DividerPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = TesskraBorders.standard;
    final y = size.height - TesskraBorders.standard / 2;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, y),
        Offset(math.min(x + TesskraBorders.dashLength, size.width), y),
        paint,
      );
      x += TesskraBorders.dashLength + TesskraBorders.dashGap;
    }
  }

  @override
  bool shouldRepaint(_DividerPainter old) => old.color != color;
}

enum WinnerStampKind { civilians, impostor, draw }

/// Winner stamp (DESIGN_SYSTEM §5 "Results components"): 5 px border, radius
/// 18, Kufi 900 at 34, rotated −5°. Civilians: civilian colour; Impostor:
/// stampText; draw: ink, dashed. Wraps instead of overflowing (render
/// `08_results`).
class WinnerStamp extends StatelessWidget {
  const WinnerStamp({super.key, required this.label, required this.kind});

  final String label;
  final WinnerStampKind kind;

  static const double _border = 5;
  static const double _radius = 18;
  static const double _turn = -5 * math.pi / 180;

  @override
  Widget build(BuildContext context) {
    final c = TesskraTokens.of(context).colors;
    final color = switch (kind) {
      WinnerStampKind.civilians => TesskraRoleColors.civilian,
      WinnerStampKind.impostor => c.errorText!,
      WinnerStampKind.draw => c.textPrimary,
    };
    final text = Text(
      label,
      textAlign: TextAlign.center,
      style: TesskraTypography.displayM.copyWith(
        color: color,
        fontWeight: FontWeight.w900,
        fontVariations: const [FontVariation('wght', 900)],
      ),
    );
    const padding = EdgeInsets.symmetric(
      horizontal: TesskraSpacing.s6,
      vertical: TesskraSpacing.s2,
    );
    return Transform.rotate(
      angle: _turn,
      child: kind == WinnerStampKind.draw
          ? CustomPaint(
              painter: DashedBorderPainter(
                color: color,
                radius: _radius,
                width: _border,
              ),
              child: Padding(padding: padding, child: text),
            )
          : Container(
              padding: padding,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_radius),
                border: Border.all(color: color, width: _border),
              ),
              child: text,
            ),
    );
  }
}

/// The secret word after the game (PUB-09): surface, border 2.5, radius 20,
/// shadow md; caption, the word (`displayXL`, shrinking), category chip.
class SecretWordPlaque extends StatelessWidget {
  const SecretWordPlaque({
    super.key,
    required this.caption,
    required this.word,
    required this.chip,
  });

  final String caption;
  final String word;
  final String chip;

  @override
  Widget build(BuildContext context) {
    final c = TesskraTokens.of(context).colors;
    return Container(
      padding: const EdgeInsets.all(TesskraLayout.cardPaddingLarge),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(TesskraRadii.lg),
        border: Border.all(color: c.border, width: TesskraBorders.standard),
        boxShadow: const [TesskraShadows.publicMd],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            caption,
            textAlign: TextAlign.center,
            style: TesskraTypography.caption.copyWith(color: c.textSecondary),
          ),
          FittedDisplayText(
            word,
            style: TesskraTypography.displayXL.copyWith(color: c.textPrimary),
            minFontSize: TesskraTypography.displayXLMinFontSize,
          ),
          Center(
            child: Container(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: TesskraSpacing.s4,
                vertical: TesskraSpacing.s1,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(TesskraRadii.pill),
                border: Border.all(
                  color: c.border,
                  width: TesskraBorders.standard,
                ),
              ),
              child: Text(
                chip,
                textAlign: TextAlign.center,
                style: TesskraTypography.labelM.copyWith(color: c.textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A player and their role (PUB-09): badge, name, role tag at the end.
/// Civilian tag: civilian colour, radius 8, user icon. Impostor tag: impostor
/// colour, pill, eye-off icon. Icon and text, never colour alone.
class RoleRevealRow extends StatelessWidget {
  const RoleRevealRow({
    super.key,
    required this.position,
    required this.name,
    required this.roleLabel,
    required this.isImpostor,
  });

  final int position;
  final String name;
  final String roleLabel;
  final bool isImpostor;

  @override
  Widget build(BuildContext context) {
    final c = TesskraTokens.of(context).colors;
    final fill = isImpostor
        ? TesskraRoleColors.impostor
        : TesskraRoleColors.civilian;
    final on = isImpostor
        ? TesskraRoleColors.onImpostor
        : TesskraRoleColors.onCivilian;
    return Container(
      height: TesskraSizes.playerRowHeight,
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: TesskraSpacing.s3,
      ),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(TesskraRadii.md),
        border: Border.all(color: c.border, width: TesskraBorders.standard),
      ),
      child: Row(
        children: [
          IndexBadge(number: position),
          const SizedBox(width: TesskraSpacing.s3),
          Expanded(
            child: Text(
              directionIsolate(name),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TesskraTypography.titleM.copyWith(color: c.textPrimary),
            ),
          ),
          Container(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: TesskraSpacing.s3,
              vertical: TesskraSpacing.s1,
            ),
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(
                isImpostor ? TesskraRadii.pill : TesskraRadii.xs,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TesskraIcon(
                  isImpostor ? TesskraIcons.eyeOff : TesskraIcons.user,
                  color: on,
                  size: TesskraSizes.iconSmall,
                ),
                const SizedBox(width: TesskraSpacing.s1),
                Text(
                  roleLabel,
                  style: TesskraTypography.labelM.copyWith(color: on),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
