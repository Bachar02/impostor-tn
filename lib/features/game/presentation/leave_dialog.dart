import 'package:flutter/material.dart';
import 'package:impostor_tn/core/design/theme/tesskra_theme.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_button.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_dialog.dart';
import 'package:impostor_tn/l10n/generated/app_localizations.dart';

/// OVL-02 Leave-game dialog, in the theme of the screen it opens over.
/// True when the player confirms leaving. Cancel, scrim and back: false.
Future<bool> showLeaveDialog(
  BuildContext context, {
  bool carbon = false,
}) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await showTesskraDialog<bool>(
    context: context,
    theme: carbon ? TesskraTheme.private : null,
    builder: (dialogContext) => TesskraDialog(
      title: l10n.dialogQuitTitle,
      body: l10n.dialogQuitBody,
      actions: [
        TesskraButton(
          label: l10n.dialogQuitConfirm,
          variant: TesskraButtonVariant.destructive,
          onPressed: () => Navigator.of(dialogContext).pop(true),
        ),
        // The safe action last, closest to the thumb.
        TesskraButton(
          label: l10n.dialogQuitCancel,
          variant: TesskraButtonVariant.secondary,
          onPressed: () => Navigator.of(dialogContext).pop(false),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
