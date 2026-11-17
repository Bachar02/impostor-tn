import 'package:flutter/material.dart';
import 'package:impostor_tn/core/design/theme/tesskra_tokens.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_metrics.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_shadows.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_typography.dart';

/// Confirmation dialog (DESIGN_SYSTEM §5 "Dialog", OVL-02).
///
/// [actions] are stacked full width in the given order; by convention the
/// safe action is last, closest to the thumb. Paper: border in ink, shadow
/// `public.lg`. Carbon: border `borderStrong`, no shadow.
class TesskraDialog extends StatelessWidget {
  const TesskraDialog({
    super.key,
    required this.title,
    required this.body,
    required this.actions,
  });

  final String title;
  final String body;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final tokens = TesskraTokens.of(context);
    final c = tokens.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TesskraLayout.screenMarginHCompact),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: TesskraLayout.maxContentWidth,
          ),
          child: Semantics(
            scopesRoute: true,
            namesRoute: true,
            explicitChildNodes: true,
            label: title,
            child: Container(
              padding: const EdgeInsets.all(TesskraLayout.dialogPadding),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(TesskraRadii.lg),
                border: Border.all(
                  color: tokens.isCarbon
                      ? (c.borderStrong ?? c.border)
                      : c.border,
                  width: TesskraBorders.standard,
                ),
                boxShadow: tokens.isCarbon
                    ? null
                    : const [TesskraShadows.publicLg],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      title,
                      style: TesskraTypography.titleL.copyWith(
                        color: c.textPrimary,
                      ),
                    ),
                    const SizedBox(height: TesskraSpacing.s3),
                    Text(
                      body,
                      style: TesskraTypography.bodyM.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                    const SizedBox(height: TesskraLayout.sectionGap),
                    for (final (index, action) in actions.indexed) ...[
                      if (index > 0)
                        const SizedBox(height: TesskraLayout.itemGap),
                      action,
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shows [builder]'s dialog over the theme's scrim. Tapping the scrim or
/// system back closes it with null.
///
/// [theme] overrides the theme of [context], for a dialog opened over a
/// screen that applies its own theme below [context] (carbon screens).
Future<T?> showTesskraDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  ThemeData? theme,
}) {
  final resolvedTheme = theme ?? Theme.of(context);
  final tokens = resolvedTheme.extension<TesskraTokens>()!;
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: tokens.colors.scrim,
    // The dialog keeps the theme of the screen it opens over.
    pageBuilder: (dialogContext, _, _) => Theme(
      data: resolvedTheme,
      // A route of its own has no Material ancestor: without one, text falls
      // back to the debug style (yellow double underline).
      child: Material(
        type: MaterialType.transparency,
        child: Builder(builder: builder),
      ),
    ),
  );
}
