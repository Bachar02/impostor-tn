import 'package:flutter/material.dart';
import 'package:impostor_tn/core/design/assets/tesskra_assets.dart';
import 'package:impostor_tn/core/design/theme/tesskra_tokens.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_metrics.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_shadows.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_typography.dart';
import 'package:impostor_tn/core/design/widgets/small_components.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_icon.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_icon_button.dart';
import 'package:impostor_tn/core/text/bidi.dart';

/// Mustard index badge, 40, rounded square as in render `08_results`
/// (DESIGN_SYSTEM §5 "Player row").
class IndexBadge extends StatelessWidget {
  const IndexBadge({super.key, required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    final tokens = TesskraTokens.of(context);
    final c = tokens.colors;
    return Container(
      width: TesskraSizes.badge,
      height: TesskraSizes.badge,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: c.accent ?? c.primary,
        borderRadius: BorderRadius.circular(TesskraRadii.xs),
        border: Border.all(color: c.border, width: TesskraBorders.standard),
      ),
      child: Text(
        ltrIsolate('$number'),
        style: tokens.numericM.copyWith(color: c.onAccent ?? c.onPrimary),
      ),
    );
  }
}

/// Player row, height 64: badge, name (one line, ellipsis), ghost pencil.
/// Tapping the row or the pencil edits the player.
class PlayerRow extends StatelessWidget {
  const PlayerRow({
    super.key,
    required this.position,
    required this.name,
    required this.editLabel,
    required this.onEdit,
    required this.deleteLabel,
    required this.onDelete,
  });

  final int position;
  final String name;
  final String editLabel;
  final VoidCallback onEdit;
  final String deleteLabel;

  /// Null disables the delete button (no deletion below the minimum).
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final c = TesskraTokens.of(context).colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onEdit,
      child: Container(
        height: TesskraSizes.playerRowHeight,
        padding: const EdgeInsetsDirectional.only(
          start: TesskraSpacing.s3,
          end: TesskraSpacing.s1,
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
            TesskraIconButton(
              icon: TesskraIcons.pencil,
              semanticLabel: editLabel,
              onPressed: onEdit,
              ghost: true,
            ),
            TesskraIconButton(
              icon: TesskraIcons.trash,
              semanticLabel: deleteLabel,
              onPressed: onDelete,
              ghost: true,
            ),
          ],
        ),
      ),
    );
  }
}

/// Dashed "add player" row of the same height.
class AddPlayerRow extends StatelessWidget {
  const AddPlayerRow({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = TesskraTokens.of(context).colors;
    return Semantics(
      button: true,
      label: label,
      onTap: onTap,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: CustomPaint(
          painter: DashedBorderPainter(color: c.border),
          child: SizedBox(
            height: TesskraSizes.playerRowHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TesskraIcon(TesskraIcons.plus, color: c.textPrimary),
                const SizedBox(width: TesskraSpacing.s2),
                Text(
                  label,
                  style: TesskraTypography.labelM.copyWith(
                    color: c.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum PackCardState { selected, available, unavailable }

/// Word-pack card (DESIGN_SYSTEM §5, PUB-06). Multi-select. The "locked"
/// state is not built (D-04).
class WordPackCard extends StatelessWidget {
  const WordPackCard({
    super.key,
    required this.title,
    required this.meta,
    required this.state,
    required this.selectedLabel,
    required this.onTap,
  });

  final String title;

  /// "{n} words" or "contains no words".
  final String meta;
  final PackCardState state;
  final String selectedLabel;
  final VoidCallback onTap;

  /// Card padding 14 × 16 and checkbox 28 (DESIGN_SYSTEM §5). Not tokens.
  static const double _paddingV = 14;
  static const double _checkbox = 28;
  static const double _minHeight = 84;

  @override
  Widget build(BuildContext context) {
    final c = TesskraTokens.of(context).colors;
    final unavailable = state == PackCardState.unavailable;
    final selected = state == PackCardState.selected;
    final trailing = switch (state) {
      PackCardState.selected => StampLabel(
        icon: TesskraIcons.check,
        label: selectedLabel,
      ),
      PackCardState.available => Container(
        width: _checkbox,
        height: _checkbox,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(TesskraRadii.xs),
          border: Border.all(color: c.border, width: TesskraBorders.standard),
        ),
      ),
      PackCardState.unavailable => TesskraIcon(
        TesskraIcons.alert,
        color: c.textSecondary,
      ),
    };
    return Semantics(
      button: !unavailable,
      enabled: !unavailable,
      selected: selected,
      onTap: unavailable ? null : onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: unavailable ? null : onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: _minHeight),
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: TesskraSpacing.s4,
            vertical: _paddingV,
          ),
          decoration: BoxDecoration(
            color: unavailable ? c.surfaceSunken : c.surface,
            borderRadius: BorderRadius.circular(TesskraRadii.md),
            border: Border.all(color: c.border, width: TesskraBorders.standard),
            boxShadow: selected ? const [TesskraShadows.publicSm] : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TesskraTypography.labelL.copyWith(
                        color: unavailable ? c.textSecondary : c.textPrimary,
                      ),
                    ),
                    Text(
                      meta,
                      style: TesskraTypography.caption.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: TesskraSpacing.s3),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}

/// Red stamp with icon and label ("selected"), border strong. No rotation is
/// specified for it, so none is applied.
class StampLabel extends StatelessWidget {
  const StampLabel({super.key, required this.icon, required this.label});

  final TesskraIcons icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = TesskraTokens.of(context).colors;
    final red = c.errorText!;
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: TesskraSpacing.s2,
        vertical: TesskraSpacing.s1,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(TesskraRadii.xs),
        border: Border.all(color: red, width: TesskraBorders.strong),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TesskraIcon(icon, color: red, size: TesskraSizes.iconSmall),
          const SizedBox(width: TesskraSpacing.s1),
          Text(label, style: TesskraTypography.labelM.copyWith(color: red)),
        ],
      ),
    );
  }
}
