import 'package:flutter/material.dart';
import 'package:impostor_tn/core/design/theme/tesskra_tokens.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_metrics.dart';

/// Bottom sheet body (DESIGN_SYSTEM §5 "Bottom sheet", OVL-01): top radius
/// 28, grab handle, padding 24. Rises above the keyboard so the focused
/// field and the action stay visible (DESIGN_SYSTEM §3).
class TesskraSheet extends StatelessWidget {
  const TesskraSheet({super.key, required this.child});

  final Widget child;

  /// Grab handle 44 × 5 (DESIGN_SYSTEM §5). Not tokens.
  static const _handleWidth = 44.0;
  static const _handleHeight = 5.0;

  @override
  Widget build(BuildContext context) {
    final c = TesskraTokens.of(context).colors;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: Container(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(TesskraRadii.xl),
          ),
          border: Border(
            top: BorderSide(color: c.border, width: TesskraBorders.standard),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              TesskraLayout.dialogPadding,
              TesskraSpacing.s3,
              TesskraLayout.dialogPadding,
              TesskraLayout.dialogPadding,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: _handleWidth,
                    height: _handleHeight,
                    decoration: BoxDecoration(
                      color: c.textDisabled,
                      borderRadius: BorderRadius.circular(TesskraRadii.pill),
                    ),
                  ),
                ),
                const SizedBox(height: TesskraSpacing.s4),
                Flexible(child: SingleChildScrollView(child: child)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Opens [builder] in a [TesskraSheet] over the theme's scrim.
Future<T?> showTesskraSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  final tokens = TesskraTokens.of(context);
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0x00000000),
    barrierColor: tokens.colors.scrim,
    elevation: 0,
    builder: (sheetContext) => TesskraSheet(child: builder(sheetContext)),
  );
}
