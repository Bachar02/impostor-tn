import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impostor_tn/core/design/assets/tesskra_assets.dart';
import 'package:impostor_tn/core/design/haptics.dart';
import 'package:impostor_tn/core/design/theme/tesskra_tokens.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_metrics.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_typography.dart';
import 'package:impostor_tn/core/design/widgets/animated_rows.dart';
import 'package:impostor_tn/core/design/widgets/count_pill.dart';
import 'package:impostor_tn/core/design/widgets/screen_frame.dart';
import 'package:impostor_tn/core/design/widgets/setup_components.dart';
import 'package:impostor_tn/core/design/widgets/small_components.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_app_bar.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_banner.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_button.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_icon_button.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_sheet.dart';
import 'package:impostor_tn/features/game/application/checkpoint.dart';
import 'package:impostor_tn/features/setup/application/roster_controller.dart';
import 'package:impostor_tn/features/setup/presentation/delete_player_dialog.dart';
import 'package:impostor_tn/features/setup/presentation/edit_player_sheet.dart';
import 'package:impostor_tn/game/game_rules.dart';
import 'package:impostor_tn/game/player.dart';
import 'package:impostor_tn/l10n/generated/app_localizations.dart';

/// PUB-05 Players: 3–12 names in order of entry (Q-17 excluded). Each row
/// has edit and delete; a deletion is confirmed first and never leaves
/// fewer than [GameRules.minPlayers] players.
class PlayersScreen extends ConsumerStatefulWidget {
  const PlayersScreen({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  ConsumerState<PlayersScreen> createState() => _PlayersScreenState();
}

class _PlayersScreenState extends ConsumerState<PlayersScreen> {
  bool _deleteFailed = false;

  void _edit(BuildContext context, [Player? player]) => showTesskraSheet<void>(
    context: context,
    builder: (_) => EditPlayerSheet(player: player),
  );

  Future<void> _delete(Player player) async {
    if (!await showDeletePlayerDialog(context, player.name)) return;
    final result = await ref
        .read(rosterControllerProvider.notifier)
        .remove(player.id);
    if (!mounted) return;
    final saved = result is Saved<Object?>;
    if (saved) Haptics.light();
    setState(() => _deleteFailed = !saved);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = TesskraTokens.of(context).colors;
    final players = ref.watch(rosterControllerProvider).players;
    final canRemove = players.length > GameRules.minPlayers;
    final count = players.length;
    final valid =
        count >= GameRules.minPlayers && count <= GameRules.maxPlayers;
    final full = count >= GameRules.maxPlayers;

    return Scaffold(
      body: ScreenFrame(
        top: TesskraAppBar(
          title: l10n.homeNewGame,
          leading: TesskraIconButton(
            icon: TesskraIcons.arrowRight,
            semanticLabel: l10n.actionBack,
            ghost: true,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: TesskraSpacing.s2),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.playersTitle,
                    style: TesskraTypography.titleL.copyWith(
                      color: c.textPrimary,
                    ),
                  ),
                ),
                CountPill(current: count, total: GameRules.maxPlayers),
              ],
            ),
            const SizedBox(height: TesskraLayout.itemGap),
            if (_deleteFailed) ...[
              TesskraBanner(
                message: l10n.stateError,
                kind: TesskraBannerKind.error,
              ),
              const SizedBox(height: TesskraLayout.itemGap),
            ],
            if (count > 0 && count < GameRules.minPlayers) ...[
              TesskraBanner(
                message: l10n.errorMinPlayers,
                kind: TesskraBannerKind.warning,
              ),
              const SizedBox(height: TesskraLayout.itemGap),
            ],
            if (count == 0) ...[
              const SizedBox(height: TesskraLayout.sectionGap),
              StateBlock(
                icon: TesskraIcons.users,
                title: l10n.playersEmpty,
                hint: l10n.playersEmptyHint,
              ),
              const SizedBox(height: TesskraLayout.sectionGap),
            ],
            AnimatedRows<Player>(
              items: players,
              idOf: (player) => player.id.value,
              gap: TesskraLayout.itemGap,
              builder: (context, player, index) => PlayerRow(
                key: ValueKey(player.id),
                position: index + 1,
                name: player.name,
                editLabel: l10n.actionRename,
                onEdit: () => _edit(context, player),
                deleteLabel: l10n.actionDeletePlayer,
                onDelete: canRemove ? () => _delete(player) : null,
              ),
            ),
            if (full)
              Text(
                l10n.playersMaxReached,
                style: TesskraTypography.caption.copyWith(
                  color: c.textSecondary,
                ),
              )
            else
              AddPlayerRow(label: l10n.playersAdd, onTap: () => _edit(context)),
          ],
        ),
        actions: [
          TesskraButton(
            label: l10n.actionContinue,
            onPressed: valid ? widget.onContinue : null,
          ),
        ],
      ),
    );
  }
}
