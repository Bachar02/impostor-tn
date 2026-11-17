import 'package:flutter/material.dart';
import 'package:impostor_tn/core/design/theme/tesskra_tokens.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_metrics.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_typography.dart';
import 'package:impostor_tn/core/design/widgets/game_components.dart';
import 'package:impostor_tn/core/design/widgets/screen_frame.dart';
import 'package:impostor_tn/core/design/widgets/small_components.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_banner.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_button.dart';
import 'package:impostor_tn/core/text/bidi.dart';
import 'package:impostor_tn/game/player.dart';
import 'package:impostor_tn/l10n/generated/app_localizations.dart';

/// One row of the vote list.
typedef VoteChoice = ({PlayerId id, String name, bool isVoter});

/// PRV-03 Vote. Shows no earlier votes and no counts. Eligibility comes from
/// the ballot's candidates; the engine still decides on confirm.
class VoteView extends StatelessWidget {
  const VoteView({
    super.key,
    required this.voterName,
    required this.runoff,
    required this.choices,
    required this.selected,
    required this.onSelect,
    required this.onConfirm,
    required this.onBack,
    this.saving = false,
    this.error,
  });

  final String voterName;
  final bool runoff;
  final List<VoteChoice> choices;
  final PlayerId? selected;
  final ValueChanged<PlayerId> onSelect;
  final VoidCallback onConfirm;
  final VoidCallback onBack;
  final bool saving;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = TesskraTokens.of(context).colors;
    return ScreenFrame(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PrivacyHint(text: l10n.privacyOnlyYou),
          const SizedBox(height: TesskraSpacing.s4),
          Text(
            directionIsolate(voterName),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TesskraTypography.titleM.copyWith(color: c.textSecondary),
          ),
          Text(
            runoff ? l10n.voteRunoffTitle : l10n.voteTitle,
            style: TesskraTypography.titleL.copyWith(color: c.textPrimary),
          ),
          if (runoff)
            Text(
              l10n.voteRunoffHint,
              style: TesskraTypography.bodyM.copyWith(color: c.textSecondary),
            ),
          const SizedBox(height: TesskraLayout.itemGap),
          for (final choice in choices) ...[
            VoteOption(
              key: ValueKey(choice.id),
              name: choice.name,
              state: choice.isVoter
                  ? VoteOptionState.unavailable
                  : choice.id == selected
                  ? VoteOptionState.selected
                  : VoteOptionState.available,
              unavailableLabel: l10n.voteSelf,
              onTap: saving ? null : () => onSelect(choice.id),
            ),
            const SizedBox(height: TesskraLayout.itemGap),
          ],
        ],
      ),
      actions: [
        if (error != null)
          TesskraBanner(message: error!, kind: TesskraBannerKind.error),
        TesskraButton(
          label: l10n.actionConfirm,
          loading: saving,
          onPressed: selected == null ? null : onConfirm,
        ),
        TesskraButton(
          label: l10n.actionBack,
          variant: TesskraButtonVariant.secondary,
          onPressed: saving ? null : onBack,
        ),
      ],
    );
  }
}
