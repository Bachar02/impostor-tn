import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impostor_tn/core/design/assets/tesskra_assets.dart';
import 'package:impostor_tn/core/design/haptics.dart';
import 'package:impostor_tn/core/design/theme/tesskra_tokens.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_metrics.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_typography.dart';
import 'package:impostor_tn/core/design/widgets/loading_dots.dart';
import 'package:impostor_tn/core/design/widgets/screen_frame.dart';
import 'package:impostor_tn/core/design/widgets/setup_components.dart';
import 'package:impostor_tn/core/design/widgets/small_components.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_app_bar.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_banner.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_button.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_icon_button.dart';
import 'package:impostor_tn/core/text/bidi.dart';
import 'package:impostor_tn/features/game/application/checkpoint.dart';
import 'package:impostor_tn/features/game/application/game_controller.dart';
import 'package:impostor_tn/features/game/application/game_providers.dart';
import 'package:impostor_tn/features/setup/application/roster_controller.dart';
import 'package:impostor_tn/game/content/content_eligibility.dart';
import 'package:impostor_tn/game/content/content_source.dart';
import 'package:impostor_tn/l10n/generated/app_localizations.dart';

/// PUB-06 Packs: choose packs (C0) and start the game (C1). Nothing about
/// the chosen word or the roles is ever shown here.
class PacksScreen extends ConsumerStatefulWidget {
  const PacksScreen({super.key, required this.onStarted});

  /// Called after C1 has committed.
  final VoidCallback onStarted;

  @override
  ConsumerState<PacksScreen> createState() => _PacksScreenState();
}

class _PacksScreenState extends ConsumerState<PacksScreen> {
  bool _starting = false;
  String? _error;

  Future<void> _start() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _starting = true;
      _error = null;
    });
    final result = await ref.read(gameControllerProvider.notifier).start();
    if (!mounted) return;
    setState(() => _starting = false);
    switch (result) {
      case Saved():
        Haptics.medium();
        widget.onStarted();
      case Refused(reason: RefusalReason.noEligibleWord):
        setState(() => _error = l10n.errorNoWords);
      case Refused(reason: RefusalReason.noPackSelected):
        setState(() => _error = l10n.errorNoPack);
      case Refused() || SaveFailed():
        setState(() => _error = l10n.stateError);
    }
  }

  Future<void> _toggle(String packId) async {
    final result = await ref
        .read(rosterControllerProvider.notifier)
        .togglePack(packId);
    if (!mounted) return;
    if (result is Saved<Object?>) {
      Haptics.medium();
    } else {
      setState(() => _error = AppLocalizations.of(context).stateError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = TesskraTokens.of(context).colors;
    final content = ref.watch(contentProvider);
    final channel = ref.watch(contentChannelProvider);
    final selectedIds = ref.watch(rosterControllerProvider).packIds.toSet();

    Widget body;
    var anySelected = false;
    switch (content) {
      case AsyncData(value: ContentReady(:final catalog)):
        final available = {
          for (final pack in catalog.packs)
            if (ContentEligibility.playableCount(pack, channel) > 0) pack.id,
        };
        anySelected = selectedIds.any(available.contains);
        body = available.isEmpty
            ? StateBlock(icon: TesskraIcons.alert, title: l10n.errorNoWords)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final pack in catalog.packs) ...[
                    WordPackCard(
                      key: ValueKey(pack.id),
                      title: pack.title,
                      meta: available.contains(pack.id)
                          ? isolateNumberRanges(
                              l10n.packWordCount(
                                '${ContentEligibility.playableCount(pack, channel)}',
                              ),
                            )
                          : l10n.packEmpty,
                      state: !available.contains(pack.id)
                          ? PackCardState.unavailable
                          : selectedIds.contains(pack.id)
                          ? PackCardState.selected
                          : PackCardState.available,
                      selectedLabel: l10n.packSelected,
                      onTap: () => _toggle(pack.id),
                    ),
                    const SizedBox(height: TesskraLayout.itemGap),
                  ],
                ],
              );
      case AsyncData(value: ContentUnavailable()) || AsyncError():
        body = StateBlock(
          icon: TesskraIcons.alert,
          title: l10n.stateError,
          action: TesskraButton(
            label: l10n.actionRetry,
            variant: TesskraButtonVariant.secondary,
            onPressed: () => ref.invalidate(contentProvider),
          ),
        );
      case _:
        body = Column(
          children: [
            const LoadingDots(),
            const SizedBox(height: TesskraSpacing.s2),
            Text(l10n.stateLoading, style: TesskraTypography.bodyM),
          ],
        );
    }

    final ready = content.value is ContentReady;
    return Scaffold(
      body: ScreenFrame(
        top: TesskraAppBar(
          title: l10n.homeNewGame,
          leading: TesskraIconButton(
            icon: TesskraIcons.arrowRight,
            semanticLabel: l10n.actionBack,
            ghost: true,
            onPressed: _starting
                ? null
                : () => Navigator.of(context).maybePop(),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: TesskraSpacing.s2),
            Text(
              l10n.packsTitle,
              style: TesskraTypography.titleL.copyWith(color: c.textPrimary),
            ),
            const SizedBox(height: TesskraLayout.itemGap),
            body,
          ],
        ),
        actions: [
          if (_error != null)
            TesskraBanner(message: _error!, kind: TesskraBannerKind.error)
          else if (ready && !anySelected)
            TesskraBanner(
              message: l10n.errorNoPack,
              kind: TesskraBannerKind.warning,
            ),
          TesskraButton(
            label: l10n.actionStart,
            loading: _starting,
            onPressed: ready && anySelected ? _start : null,
          ),
        ],
      ),
    );
  }
}
