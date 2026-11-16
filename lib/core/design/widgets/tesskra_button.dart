import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:impostor_tn/core/design/assets/tesskra_assets.dart';
import 'package:impostor_tn/core/design/theme/tesskra_tokens.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_metrics.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_typography.dart';
import 'package:impostor_tn/core/design/widgets/button_style_resolver.dart';
import 'package:impostor_tn/core/design/widgets/loading_dots.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_icon.dart';

enum TesskraButtonVariant { primary, accent, secondary, destructive, text }

/// The Tesskra button (DESIGN_SYSTEM §5 "Buttons", render `03_buttons`).
///
/// Paper or carbon styling follows the ambient theme: on carbon the primary
/// button is mustard and flat, and the accent variant does not exist.
/// It fills the width it is given.
///
/// States: pressed (moves by its shadow offset, or down 2 on carbon),
/// disabled ([onPressed] null), focused (3 px ring), and [loading] (three
/// dots, same width, not tappable) for checkpoints (SCREEN_SPECIFICATIONS
/// §1.4).
class TesskraButton extends StatefulWidget {
  const TesskraButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = TesskraButtonVariant.primary,
    this.loading = false,
    this.icon,
  });

  final String label;

  /// Null disables the button.
  final VoidCallback? onPressed;
  final TesskraButtonVariant variant;
  final bool loading;

  /// Leading icon, used by the destructive variant.
  final TesskraIcons? icon;

  @override
  State<TesskraButton> createState() => _TesskraButtonState();
}

class _TesskraButtonState extends State<TesskraButton> {
  /// Focus ring: 3 px wide, 3 px outside the button (DESIGN_SYSTEM §5). Not
  /// a token yet; the space is always reserved so focus never shifts layout.
  static const double _ring = 3;

  bool _pressed = false;
  bool _focused = false;

  bool get _enabled => widget.onPressed != null && !widget.loading;

  void _activate() {
    if (!_enabled) return;
    widget.onPressed!();
  }

  void _setPressed(bool value) {
    if (_pressed != value && mounted) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = TesskraTokens.of(context);
    final look = ButtonStyleResolver.resolve(
      tokens,
      widget.variant,
      enabled: widget.onPressed != null,
      pressed: _pressed && _enabled,
    );
    final isText = widget.variant == TesskraButtonVariant.text;
    final textStyle =
        (look.largeLabel ? TesskraTypography.labelL : TesskraTypography.labelM)
            .copyWith(
              color: look.foreground,
              decoration: isText ? TextDecoration.underline : null,
              decorationColor: look.foreground,
            );

    final label = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.icon case final icon?) ...[
          TesskraIcon(
            icon,
            color: look.foreground,
            size: TesskraSizes.iconSmall,
          ),
          const SizedBox(width: TesskraSpacing.s2),
        ],
        Flexible(
          child: Text(
            widget.label,
            style: textStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );

    final face = Container(
      height: look.height,
      transform: Matrix4.translationValues(
        look.pressOffset.dx,
        look.pressOffset.dy,
        0,
      ),
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: TesskraSpacing.s4,
      ),
      decoration: isText
          ? null
          : BoxDecoration(
              color: look.fill,
              borderRadius: BorderRadius.circular(TesskraRadii.md),
              border: Border.all(
                color: look.border,
                width: TesskraBorders.standard,
              ),
              boxShadow: look.shadow == null ? null : [look.shadow!],
            ),
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Visibility.maintain(visible: !widget.loading, child: label),
          if (widget.loading) LoadingDots(color: look.foreground),
        ],
      ),
    );

    final focusRing = _focused
        ? DecoratedBox(
            position: DecorationPosition.foreground,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                TesskraRadii.md + TesskraSpacing.s1,
              ),
              border: Border.all(color: tokens.colors.focusRing, width: _ring),
            ),
            child: Padding(padding: const EdgeInsets.all(_ring), child: face),
          )
        : Padding(padding: const EdgeInsets.all(_ring), child: face);

    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.label,
      onTap: _enabled ? _activate : null,
      excludeSemantics: true,
      child: FocusableActionDetector(
        enabled: _enabled,
        onShowFocusHighlight: (value) => setState(() => _focused = value),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) => _activate(),
          ),
        },
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _enabled ? (_) => _setPressed(true) : null,
          onTapUp: _enabled ? (_) => _setPressed(false) : null,
          onTapCancel: () => _setPressed(false),
          onTap: _enabled ? _activate : null,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: TesskraSizes.touchTargetMin,
              minWidth: TesskraSizes.touchTargetMin,
            ),
            child: Center(child: focusRing),
          ),
        ),
      ),
    );
  }
}
