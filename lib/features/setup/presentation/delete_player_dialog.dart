import 'package:flutter/material.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_button.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_dialog.dart';
import 'package:impostor_tn/core/text/bidi.dart';
import 'package:impostor_tn/l10n/generated/app_localizations.dart';

/// Confirmation before a player is deleted. True only when confirmed;
/// cancel, scrim and back give false.
Future<bool> showDeletePlayerDialog(BuildContext context, String name) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await showTesskraDialog<bool>(
    context: context,
    builder: (dialogContext) => TesskraDialog(
      // Isolated so a Latin or mixed name keeps its order inside Arabic.
      title: l10n.dialogDeletePlayerTitle(directionIsolate(name)),
      body: l10n.dialogDeletePlayerBody,
      actions: [
        TesskraButton(
          label: l10n.actionDeletePlayer,
          variant: TesskraButtonVariant.destructive,
          onPressed: () => Navigator.of(dialogContext).pop(true),
        ),
        // The safe action last, closest to the thumb (as OVL-02).
        TesskraButton(
          label: l10n.dialogDeletePlayerCancel,
          variant: TesskraButtonVariant.secondary,
          onPressed: () => Navigator.of(dialogContext).pop(false),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
