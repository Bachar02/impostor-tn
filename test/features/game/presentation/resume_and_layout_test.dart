import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_tn/features/game/application/checkpoint.dart';
import 'package:impostor_tn/features/game/presentation/game_flow.dart';
import 'package:impostor_tn/features/game/presentation/handoff_view.dart';
import 'package:impostor_tn/features/game/presentation/results_view.dart';
import 'package:impostor_tn/features/home/presentation/home_screen.dart';
import 'package:impostor_tn/game/ballot.dart';
import 'package:impostor_tn/game/persistence/saved_state.dart';
import 'package:impostor_tn/game/player.dart';

import '../../../support/app_harness.dart';
import '../application/flow_helpers.dart';
import '../application/service_fixtures.dart';
import 'flow_driver.dart';

/// Cold start (F1, F11) and small-screen layout of the whole flow.
void main() {
  testWidgets('cold start mid-reveal: the gate, then the next player', (
    tester,
  ) async {
    final store = await tester.runAsync(() async {
      final store = await storeWithRoster();
      final games = service(store);
      final game = savedValue(await games.startGame());
      await games.confirmIdentity(game.sessionId, pendingOf(game));
      await games.acknowledge(game.sessionId, pendingOf(game));
      return store;
    });
    await pumpApp(tester, store: store!, protection: FakeProtection());
    final driver = FlowDriver(tester);

    expect(find.byType(ResumeGateView), findsOneWidget);
    expect(find.textContaining('Player'), findsNothing, reason: 'neutral');
    await driver.tapButton(driver.l10n.actionContinue);

    final handoff = tester.widget<HandoffView>(find.byType(HandoffView));
    expect(handoff.name, 'Player 1');
  });

  testWidgets('cold start with a finished game opens on its result', (
    tester,
  ) async {
    final store = await tester.runAsync(() async {
      final store = await storeWithRoster();
      final games = service(store);
      final game = await voteAll(
        games,
        await toFirstBallot(games),
        BallotKind.first,
        accuseImpostor,
      );
      await games.submitFinalGuess(game.sessionId, 'wrong');
      return store;
    });
    await pumpApp(tester, store: store!, protection: FakeProtection());

    expect(find.byType(ResultsView), findsOneWidget);
    expect(find.byType(ResumeGateView), findsNothing);
  });

  testWidgets('leaving from the gate ends the game and keeps the roster', (
    tester,
  ) async {
    final store = await tester.runAsync(() async {
      final store = await storeWithRoster();
      await service(store).startGame();
      return store;
    });
    await pumpApp(tester, store: store!, protection: FakeProtection());
    final driver = FlowDriver(tester);

    await driver.tapButton(driver.l10n.dialogQuitConfirm);
    await driver.tapButton(driver.l10n.dialogQuitConfirm);

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(store.state.session, isNull);
    expect(store.state.roster.players, hasLength(4));
  });

  for (final (label, size, scale) in [
    ('320x568 at text scale 1.5', const Size(320, 568), 1.5),
    ('360x720', const Size(360, 720), 1.0),
  ]) {
    testWidgets('a whole game with 16-character names fits at $label', (
      tester,
    ) async {
      final store = await tester.runAsync(() async {
        final store = MemoryStore();
        final saved = await service(store).saveRoster(
          SavedRoster(
            players: [
              for (var i = 0; i < 6; i++)
                // Exactly 16 user-perceived characters (D-15).
                Player(id: PlayerId('p$i'), name: 'اسم طويل جدا $i${'ب' * 2}'),
            ],
            packIds: const ['pack-a'],
          ),
        );
        expect(saved, isA<Saved<Object?>>());
        return store;
      });
      await pumpApp(
        tester,
        store: store!,
        protection: FakeProtection(),
        size: size,
        textScale: scale,
      );
      final driver = FlowDriver(tester);
      final l10n = driver.l10nOf(find.byType(HomeScreen));
      await driver.tapButton(l10n.homeNewGame);
      await driver.tapButton(l10n.actionContinue);
      await driver.tapButton(l10n.actionStart);

      await driver.revealAll();
      await driver.tapButton(driver.l10n.actionStartVote);
      await driver.voteAll(driver.accuse);
      await driver.continueTally();
      await driver.guess('x');

      expect(find.byType(GameFlow), findsOneWidget);
      expect(find.byType(ResultsView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
