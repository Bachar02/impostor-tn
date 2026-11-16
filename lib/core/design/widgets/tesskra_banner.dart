import 'package:flutter/material.dart';
import 'package:impostor_tn/core/design/assets/tesskra_assets.dart';
import 'package:impostor_tn/core/design/theme/tesskra_tokens.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_metrics.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_typography.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_icon.dart';

enum TesskraBannerKind { info, warning, error }

/// Inline message (DESIGN_SYSTEM §5 "Banner"): border 2.5, radius 16, icon
/// plus text, never colour alone. Warning does not exist on carbon.
class TesskraBanner extends StatelessWidget {
  const TesskraBanner({
    super.key,
    required this.message,
    required this.kind,
    this.icon = TesskraIcons.alert,
  });

  final String message;
  final TesskraBannerKind kind;
  final TesskraIcons icon;

  @override
  Widget build(BuildContext context) {
    final c = TesskraTokens.of(context).colors;
    final (fill, foreground, border) = switch (kind) {
      TesskraBannerKind.info => (c.surface, c.textPrimary, c.border),
      TesskraBannerKind.warning => (
        c.warning ?? (throw StateError('No warning banner on carbon')),
        c.textPrimary,
        c.border,
      ),
      TesskraBannerKind.error => (c.surface, c.errorText!, c.errorText!),
    };
    return Semantics(
      liveRegion: kind == TesskraBannerKind.error,
      child: Container(
        padding: const EdgeInsetsDirectional.all(TesskraLayout.cardPadding),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(TesskraRadii.md),
          border: Border.all(color: border, width: TesskraBorders.standard),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TesskraIcon(icon, color: foreground),
            const SizedBox(width: TesskraSpacing.s3),
            Expanded(
              child: Text(
                message,
                style: TesskraTypography.bodyM.copyWith(color: foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
