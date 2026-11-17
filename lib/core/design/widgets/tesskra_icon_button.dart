import 'package:flutter/material.dart';
import 'package:impostor_tn/core/design/assets/tesskra_assets.dart';
import 'package:impostor_tn/core/design/theme/tesskra_tokens.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_metrics.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_icon.dart';

/// 48 × 48 icon button (DESIGN_SYSTEM §5): surface fill, 2.5 border, radius
/// 14; the ghost variant has neither. Always has a semantic label.
class TesskraIconButton extends StatelessWidget {
  const TesskraIconButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
    this.ghost = false,
  });

  final TesskraIcons icon;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final bool ghost;

  /// DESIGN_SYSTEM §5 "Icon button". Not a token.
  static const double _radius = 14;

  @override
  Widget build(BuildContext context) {
    final c = TesskraTokens.of(context).colors;
    final enabled = onPressed != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticLabel,
      onTap: onPressed,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: Container(
          width: TesskraSizes.iconButton,
          height: TesskraSizes.iconButton,
          alignment: Alignment.center,
          decoration: ghost
              ? null
              : BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(_radius),
                  border: Border.all(
                    color: c.border,
                    width: TesskraBorders.standard,
                  ),
                ),
          child: TesskraIcon(
            icon,
            color: enabled ? c.textPrimary : c.textDisabled,
          ),
        ),
      ),
    );
  }
}
