import 'package:flutter/material.dart';
import 'package:impostor_tn/core/design/theme/tesskra_tokens.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_metrics.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_typography.dart';
import 'package:impostor_tn/core/design/widgets/fitted_display_text.dart';
import 'package:impostor_tn/core/design/widgets/screen_frame.dart';
import 'package:impostor_tn/core/design/widgets/small_components.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_banner.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_button.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_text_field.dart';
import 'package:impostor_tn/core/text/bidi.dart';
import 'package:impostor_tn/game/final_guess_matching.dart';
import 'package:impostor_tn/l10n/generated/app_localizations.dart';

/// PRV-04 Final guess: entry, then a review step before the single guess
/// (D-25). Empty input cannot be submitted (D-16). The category is not
/// repeated and no hint is given.
class GuessView extends StatefulWidget {
  const GuessView({
    super.key,
    required this.name,
    required this.reviewing,
    required this.onReview,
    required this.onEdit,
    required this.onSubmit,
    this.saving = false,
    this.error,
  });

  final String name;
  final bool reviewing;
  final VoidCallback onReview;
  final VoidCallback onEdit;

  /// The raw text, exactly as in the field (UX_FLOWS §3.3).
  final ValueChanged<String> onSubmit;
  final bool saving;
  final String? error;

  @override
  State<GuessView> createState() => _GuessViewState();
}

class _GuessViewState extends State<GuessView> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _empty =>
      FinalGuessMatching.comparisonForm(_controller.text).isEmpty;

  void _review() {
    if (_empty) return;
    FocusScope.of(context).unfocus();
    widget.onReview();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = TesskraTokens.of(context).colors;
    final header = [
      PrivacyHint(text: l10n.privacyOnlyYou),
      const SizedBox(height: TesskraSpacing.s4),
      Text(
        directionIsolate(widget.name),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TesskraTypography.titleM.copyWith(color: c.textSecondary),
      ),
    ];

    if (widget.reviewing) {
      return ScreenFrame(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...header,
            Text(
              l10n.guessReviewTitle,
              style: TesskraTypography.titleL.copyWith(color: c.textPrimary),
            ),
            const SizedBox(height: TesskraLayout.sectionGap),
            FittedDisplayText(
              directionIsolate(
                FinalGuessMatching.displayForm(_controller.text),
              ),
              style: TesskraTypography.displayL.copyWith(color: c.textPrimary),
              minFontSize: TesskraTypography.displayLMinFontSize,
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          if (widget.error != null)
            TesskraBanner(
              message: widget.error!,
              kind: TesskraBannerKind.error,
            ),
          TesskraButton(
            label: l10n.guessConfirmFinal,
            loading: widget.saving,
            onPressed: () => widget.onSubmit(_controller.text),
          ),
          TesskraButton(
            label: l10n.guessEdit,
            variant: TesskraButtonVariant.secondary,
            onPressed: widget.saving ? null : widget.onEdit,
          ),
        ],
      );
    }

    return ScreenFrame(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...header,
          Text(
            l10n.guessTitle,
            style: TesskraTypography.titleL.copyWith(color: c.textPrimary),
          ),
          Text(
            l10n.guessOneChance,
            style: TesskraTypography.bodyM.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: TesskraLayout.sectionGap),
          TesskraTextField(
            controller: _controller,
            label: l10n.guessLabel,
            privateInput: true,
            // The keyboard's "done" key moves to the review, like the button.
            onSubmitted: (_) => _review(),
          ),
        ],
      ),
      actions: [
        TesskraButton(
          label: l10n.actionConfirm,
          onPressed: _empty ? null : _review,
        ),
      ],
    );
  }
}
