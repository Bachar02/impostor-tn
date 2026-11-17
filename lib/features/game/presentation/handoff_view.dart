import 'package:flutter/material.dart';
import 'package:impostor_tn/core/design/assets/tesskra_assets.dart';
import 'package:impostor_tn/core/design/theme/tesskra_tokens.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_typography.dart';
import 'package:impostor_tn/core/design/widgets/handoff_block.dart';
import 'package:impostor_tn/core/design/widgets/screen_frame.dart';
import 'package:impostor_tn/core/design/widgets/small_components.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_banner.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_button.dart';
import 'package:impostor_tn/core/text/bidi.dart';
import 'package:impostor_tn/l10n/generated/app_localizations.dart';

/// PRV-01 Handoff: the name, the position, one button. Identical for reveal,
/// voting and the runoff; no leave control (D-23).
class HandoffView extends StatelessWidget {
  const HandoffView({
    super.key,
    required this.name,
    required this.onConfirm,
    this.position,
    this.total,
    this.loading = false,
    this.error,
  });

  final String name;
  final int? position;
  final int? total;
  final bool loading;
  final String? error;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ScreenFrame(
      centerBody: true,
      body: HandoffBlock(
        passLabel: l10n.handoffPassLabel,
        name: name,
        position: position,
        total: total,
      ),
      actions: [
        if (error != null)
          TesskraBanner(message: error!, kind: TesskraBannerKind.error),
        TesskraButton(
          label: l10n.handoffIAm(directionIsolate(name)),
          loading: loading,
          onPressed: onConfirm,
        ),
      ],
    );
  }
}

/// PRV-05 Resume gate: neutral, no detail of the saved game.
class ResumeGateView extends StatelessWidget {
  const ResumeGateView({
    super.key,
    required this.onContinue,
    required this.onLeave,
  });

  final VoidCallback onContinue;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = TesskraTokens.of(context).colors;
    return ScreenFrame(
      centerBody: true,
      body: StateBlock(icon: TesskraIcons.info, title: l10n.stateResumed),
      actions: [
        TesskraButton(label: l10n.actionContinue, onPressed: onContinue),
        TesskraButton(
          label: l10n.dialogQuitConfirm,
          variant: TesskraButtonVariant.destructive,
          onPressed: onLeave,
        ),
      ],
    ).withTextColor(c.textPrimary);
  }
}

extension on Widget {
  Widget withTextColor(Color color) => DefaultTextStyle.merge(
    style: TesskraTypography.bodyM.copyWith(color: color),
    child: this,
  );
}
