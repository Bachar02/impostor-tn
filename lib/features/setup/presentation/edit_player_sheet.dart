import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impostor_tn/core/design/assets/tesskra_assets.dart';
import 'package:impostor_tn/core/design/haptics.dart';
import 'package:impostor_tn/core/design/theme/tesskra_tokens.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_metrics.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_typography.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_app_bar.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_button.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_text_field.dart';
import 'package:impostor_tn/features/game/application/checkpoint.dart';
import 'package:impostor_tn/features/setup/application/player_names.dart';
import 'package:impostor_tn/features/setup/application/roster_controller.dart';
import 'package:impostor_tn/features/setup/presentation/delete_player_dialog.dart';
import 'package:impostor_tn/game/game_rules.dart';
import 'package:impostor_tn/game/player.dart';
import 'package:impostor_tn/l10n/generated/app_localizations.dart';

/// OVL-01 in slice 1: add, rename or delete one player. Reordering is not
/// in the slice (Q-17), so the move buttons are not shown.
class EditPlayerSheet extends ConsumerStatefulWidget {
  const EditPlayerSheet({super.key, this.player});

  /// Null in add mode.
  final Player? player;

  @override
  ConsumerState<EditPlayerSheet> createState() => _EditPlayerSheetState();
}

class _EditPlayerSheetState extends ConsumerState<EditPlayerSheet> {
  late final _controller = TextEditingController(text: widget.player?.name);
  final _focus = FocusNode();
  String? _error;
  bool _saving = false;

  bool get _editing => widget.player != null;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onText);
  }

  void _onText() => setState(() => _error = null);

  @override
  void dispose() {
    _controller
      ..removeListener(_onText)
      ..dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    final l10n = AppLocalizations.of(context);
    final roster = ref.read(rosterControllerProvider.notifier);
    final raw = _controller.text;
    final problem = _editing
        ? roster.checkRename(widget.player!.id, raw)
        : roster.checkNew(raw);
    if (problem != null) {
      Haptics.error();
      setState(
        () => _error = switch (problem) {
          NameProblem.empty => l10n.errorNameEmpty,
          NameProblem.tooLong => l10n.playersNameLimit,
          NameProblem.duplicate => l10n.errorNameDuplicate,
        },
      );
      return;
    }
    setState(() => _saving = true);
    final result = _editing
        ? await roster.rename(widget.player!.id, raw)
        : await roster.add(raw);
    if (!mounted) return;
    setState(() => _saving = false);
    if (result is! Saved<Object?>) {
      setState(() => _error = l10n.stateError);
      return;
    }
    Haptics.light();
    final full =
        ref.read(rosterControllerProvider).players.length >=
        GameRules.maxPlayers;
    if (_editing || full) {
      Navigator.of(context).pop();
    } else {
      _controller.clear();
      _focus.requestFocus();
    }
  }

  Future<void> _delete() async {
    final player = widget.player!;
    if (!await showDeletePlayerDialog(context, player.name)) return;
    if (!mounted) return;
    setState(() => _saving = true);
    final result = await ref
        .read(rosterControllerProvider.notifier)
        .remove(player.id);
    if (!mounted) return;
    setState(() => _saving = false);
    if (result is Saved<Object?>) {
      Haptics.light();
      Navigator.of(context).pop();
    } else {
      setState(() => _error = AppLocalizations.of(context).stateError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = TesskraTokens.of(context).colors;
    final empty = PlayerNames.normalize(_controller.text).isEmpty;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _editing ? l10n.actionRename : l10n.playersAdd,
          style: TesskraTypography.titleL.copyWith(
            fontSize: TesskraAppBar.titleSize,
            color: c.textPrimary,
          ),
        ),
        const SizedBox(height: TesskraSpacing.s4),
        TesskraTextField(
          controller: _controller,
          focusNode: _focus,
          autofocus: true,
          label: l10n.playersNameLabel,
          hint: l10n.playersNameHint,
          helper: l10n.playersNameLimit,
          error: _error,
          counter:
              '${PlayerNames.length(_controller.text)} / ${GameRules.maxNameLength}',
          inputFormatters: const [_NameLengthFormatter()],
          // The keyboard's "done" key is the primary action (Q-30 (3)).
          onSubmitted: (_) {
            if (!empty && !_saving) _confirm();
          },
        ),
        const SizedBox(height: TesskraLayout.sectionGap),
        TesskraButton(
          label: _editing ? l10n.actionConfirm : l10n.actionAdd,
          loading: _saving,
          onPressed: empty ? null : _confirm,
        ),
        if (_editing) ...[
          const SizedBox(height: TesskraLayout.itemGap),
          TesskraButton(
            label: l10n.actionDeletePlayer,
            icon: TesskraIcons.trash,
            variant: TesskraButtonVariant.destructive,
            // Never below the minimum, as on the row's delete button.
            onPressed:
                _saving ||
                    ref.watch(rosterControllerProvider).players.length <=
                        GameRules.minPlayers
                ? null
                : _delete,
          ),
        ],
      ],
    );
  }
}

/// Ignores input beyond the name limit (OVL-01: "further input is
/// ignored"), counted like the rule itself (D-15).
class _NameLengthFormatter extends TextInputFormatter {
  const _NameLengthFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.characters.length <= GameRules.maxNameLength) {
      return newValue;
    }
    return PlayerNames.length(newValue.text) <= GameRules.maxNameLength
        ? newValue
        : oldValue;
  }
}
