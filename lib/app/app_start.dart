import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_metrics.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_typography.dart';
import 'package:impostor_tn/core/design/widgets/loading_dots.dart';
import 'package:impostor_tn/core/design/widgets/surface_routes.dart';
import 'package:impostor_tn/features/game/application/active_game.dart';
import 'package:impostor_tn/features/game/application/game_providers.dart';
import 'package:impostor_tn/features/game/application/launch.dart';
import 'package:impostor_tn/features/game/presentation/game_flow.dart';
import 'package:impostor_tn/features/home/presentation/home_screen.dart';
import 'package:impostor_tn/features/setup/application/roster_controller.dart';
import 'package:impostor_tn/features/setup/presentation/packs_screen.dart';
import 'package:impostor_tn/features/setup/presentation/players_screen.dart';
import 'package:impostor_tn/game/game_phase.dart';
import 'package:impostor_tn/game/persistence/saved_state.dart';
import 'package:impostor_tn/l10n/generated/app_localizations.dart';

/// F1 Launch: Home, or the saved game (through the resume gate unless it is
/// finished). A storage failure lands on Home with the neutral banner.
class AppStart extends ConsumerWidget {
  const AppStart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(launchProvider)) {
      AsyncData(value: LaunchResume(:final game)) => _Resume(game: game),
      AsyncData(value: LaunchHome(:final restoreFailed)) => homeScreen(
        context,
        restoreFailed: restoreFailed,
      ),
      AsyncError() => homeScreen(context, restoreFailed: true),
      _ => const _Loading(),
    };
  }
}

/// Home, wired to the setup flow.
Widget homeScreen(BuildContext context, {bool restoreFailed = false}) =>
    HomeScreen(
      restoreFailed: restoreFailed,
      onNewGame: () => openSetup(context),
    );

/// PUB-05 → PUB-06 → game.
void openSetup(BuildContext context) {
  final navigator = Navigator.of(context);
  navigator.push(
    MaterialPageRoute<void>(
      builder: (playersContext) => PlayersScreen(
        onContinue: () => navigator.push(
          MaterialPageRoute<void>(
            builder: (_) => PacksScreen(onStarted: () => openGame(navigator)),
          ),
        ),
      ),
    ),
  );
}

/// The game replaces the whole stack: back inside a game never returns to
/// setup (F10).
void openGame(NavigatorState navigator, {bool coldStart = false}) {
  navigator.pushAndRemoveUntil(
    // Setup is paper, the first game screen carbon (PUB-06 → PRV-01).
    CarbonInRoute<void>(
      reducedMotion: MediaQuery.disableAnimationsOf(navigator.context),
      builder: (_) => Consumer(
        builder: (context, ref, _) => GameFlow(
          coldStart: coldStart,
          onExit: (exit, roster, {required fromCarbon}) =>
              _exitGame(navigator, ref, exit, roster, fromCarbon: fromCarbon),
        ),
      ),
    ),
    (_) => false,
  );
}

void _exitGame(
  NavigatorState navigator,
  WidgetRef ref,
  GameExit exit,
  SavedRoster roster, {
  required bool fromCarbon,
}) {
  ref.read(rosterControllerProvider.notifier).replace(roster);
  navigator.pushAndRemoveUntil(
    // OVL-02 from a carbon screen: carbonOut; Home covers the game screen
    // from the first frame.
    fromCarbon
        ? CarbonOutRoute<void>(
            reducedMotion: MediaQuery.disableAnimationsOf(navigator.context),
            builder: homeScreen,
          )
        : MaterialPageRoute<void>(builder: homeScreen),
    (_) => false,
  );
  if (exit == GameExit.changeSetup) {
    // PUB-09 "change players or packs" → PUB-05, with Home beneath it.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => openSetup(navigator.context),
    );
  }
}

class _Resume extends ConsumerStatefulWidget {
  const _Resume({required this.game});

  final ActiveGame game;

  @override
  ConsumerState<_Resume> createState() => _ResumeState();
}

class _ResumeState extends ConsumerState<_Resume> {
  // GameController starts from the same launch result (F1).
  @override
  Widget build(BuildContext context) => GameFlow(
    // A finished game opens on its result without the gate (F1 step 2).
    coldStart: widget.game.session.phase is! ResultPhase,
    onExit: (exit, roster, {required fromCarbon}) => _exitGame(
      Navigator.of(context),
      ref,
      exit,
      roster,
      fromCarbon: fromCarbon,
    ),
  );
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const LoadingDots(),
          const SizedBox(height: TesskraSpacing.s2),
          Text(
            AppLocalizations.of(context).stateLoading,
            style: TesskraTypography.bodyM,
          ),
        ],
      ),
    ),
  );
}
