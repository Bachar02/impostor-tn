import 'package:flutter/material.dart';
import 'package:impostor_tn/core/design/assets/tesskra_assets.dart';
import 'package:impostor_tn/core/design/theme/tesskra_tokens.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_metrics.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_typography.dart';
import 'package:impostor_tn/core/design/widgets/screen_frame.dart';
import 'package:impostor_tn/core/design/widgets/small_components.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_app_bar.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_banner.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_button.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_icon.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_icon_button.dart';
import 'package:impostor_tn/l10n/generated/app_localizations.dart';

/// PUB-07 Discussion: rules and the move to voting. No timer, no turn
/// marker, no clue entry (D-03). Contains no word, category or role.
class DiscussionView extends StatelessWidget {
  const DiscussionView({
    super.key,
    required this.onStartVote,
    required this.onClose,
    this.loading = false,
    this.error,
  });

  final VoidCallback onStartVote;
  final VoidCallback onClose;
  final bool loading;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = TesskraTokens.of(context).colors;
    Widget rule(String text) => Padding(
      padding: const EdgeInsets.symmetric(vertical: TesskraSpacing.s1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: TesskraSpacing.s1),
            child: TesskraIcon(
              TesskraIcons.check,
              size: TesskraSizes.iconSmall,
              color: c.textPrimary,
            ),
          ),
          const SizedBox(width: TesskraSpacing.s2),
          Expanded(
            child: Text(
              text,
              style: TesskraTypography.bodyL.copyWith(color: c.textPrimary),
            ),
          ),
        ],
      ),
    );
    return ScreenFrame(
      top: TesskraAppBar(
        title: l10n.phaseClues,
        trailing: closeButton(context, onClose),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: TesskraSpacing.s2),
          Center(
            child: PhaseChip(
              icon: TesskraIcons.messageCircle,
              label: l10n.phaseClues,
            ),
          ),
          const SizedBox(height: TesskraLayout.sectionGap),
          Text(
            l10n.revealAllDone,
            textAlign: TextAlign.center,
            style: TesskraTypography.titleL.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: TesskraSpacing.s2),
          Text(
            l10n.discussionPutPhone,
            textAlign: TextAlign.center,
            style: TesskraTypography.bodyL.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: TesskraLayout.sectionGap),
          Container(
            padding: const EdgeInsets.all(TesskraLayout.cardPadding),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(TesskraRadii.md),
              border: Border.all(
                color: c.border,
                width: TesskraBorders.standard,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                rule(l10n.discussionRuleOneWord),
                rule(l10n.discussionRulePass),
                rule(l10n.discussionRuleThenVote),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (error != null)
          TesskraBanner(message: error!, kind: TesskraBannerKind.error),
        TesskraButton(
          label: l10n.actionStartVote,
          icon: TesskraIcons.vote,
          loading: loading,
          onPressed: onStartVote,
        ),
      ],
    );
  }
}

/// The ghost close button of public in-game screens (F10): opens OVL-02.
Widget closeButton(BuildContext context, VoidCallback onClose) =>
    TesskraIconButton(
      icon: TesskraIcons.x,
      semanticLabel: AppLocalizations.of(context).dialogQuitTitle,
      ghost: true,
      onPressed: onClose,
    );
