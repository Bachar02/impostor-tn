import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_tn/core/design/theme/tesskra_tokens.dart';
import 'package:impostor_tn/core/design/widgets/game_components.dart';
import 'package:impostor_tn/core/design/widgets/role_ticket.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_button.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_dialog.dart';
import 'package:impostor_tn/features/game/presentation/discussion_view.dart';
import 'package:impostor_tn/features/game/presentation/game_flow.dart';
import 'package:impostor_tn/features/game/presentation/handoff_view.dart';
import 'package:impostor_tn/features/game/presentation/results_view.dart';
import 'package:impostor_tn/features/game/presentation/tally_view.dart';
import 'package:impostor_tn/features/game/presentation/vote_view.dart';
import 'package:impostor_tn/features/home/presentation/home_screen.dart';
import 'package:impostor_tn/game/game_engine.dart';
import 'package:impostor_tn/game/game_outcome.dart';
import 'package:impostor_tn/game/game_phase.dart';

import '../../../support/app_harness.dart';
import '../application/service_fixtures.dart';
import 'flow_driver.dart';

/// Complete games through the real screens (widget-level integration).
/// The store is in memory but goes through the real codec.
void main() {
  Future<(FlowDriver, MemoryStore, FakeProtection)> startGame(
    WidgetTester tester, {
    int players = 4,
  }) async {
    final store = await tester.runAsync(
      () => storeWithRoster(players: players),
    );
    final protection = FakeProtection();
    await pumpApp(tester, store: store!, protection: protection);
    final driver = FlowDriver(tester);
    final l10n = driver.l10nOf(find.byType(HomeScreen));
    await driver.tapButton(l10n.homeNewGame);
    await driver.tapButton(l10n.actionContinue);
    await driver.tapButton(l10n.actionStart);
    expect(find.byType(GameFlow), findsOneWidget);
    return (driver, store, protection);
  }

  testWidgets('civilians win: Impostor nominated, wrong guess', (tester) async {
    final (driver, store, protection) = await startGame(tester);
    expect(protection.isOn, isTrue, reason: 'D-18 from game start');

    await driver.revealAll();
    expect(find.byType(DiscussionView), findsOneWidget);
    expect(store.state.cooldown.oldestFirst, hasLength(1));
    await driver.tapButton(driver.l10n.actionStartVote);
    await driver.voteAll(driver.accuse);

    expect(find.byType(TallyView), findsOneWidget);
    final word = driver.game.session.word.canonical;
    expect(find.text(word), findsNothing, reason: 'tally shows no word');
    await driver.continueTally();
    await driver.guess('not the word');

    expect(find.byType(ResultsView), findsOneWidget);
    final outcome = (driver.game.session.phase as ResultPhase).outcome;
    expect(outcome.winner, Winner.civilians);
    expect(find.text(word), findsOneWidget, reason: 'results reveal the word');
    expect(protection.isOn, isTrue, reason: 'results stay protected');
  });

  testWidgets('Impostor wins with a correct guess at 12 players', (
    tester,
  ) async {
    final (driver, _, _) = await startGame(tester, players: 12);

    await driver.revealAll();
    await driver.tapButton(driver.l10n.actionStartVote);
    await driver.voteAll(driver.accuse);
    await driver.continueTally();
    await driver.guess('  ${driver.game.session.word.canonical}  ');

    final outcome = (driver.game.session.phase as ResultPhase).outcome;
    expect(outcome.winner, Winner.impostor);
    expect(find.byType(WinnerStamp), findsOneWidget);
  });

  testWidgets('a civilian nominated: tally, then results, Impostor wins', (
    tester,
  ) async {
    final (driver, _, _) = await startGame(tester);

    await driver.revealAll();
    await driver.tapButton(driver.l10n.actionStartVote);
    await driver.voteAll(driver.electB);
    expect(find.byType(TallyView), findsOneWidget);
    await driver.continueTally();

    expect(find.byType(ResultsView), findsOneWidget);
    expect(
      (driver.game.session.phase as ResultPhase).outcome,
      isA<CivilianNominated>(),
    );
  });

  testWidgets('tie, runoff, runoff tie: a draw without a guess', (
    tester,
  ) async {
    final (driver, _, _) = await startGame(tester, players: 6);

    await driver.revealAll();
    await driver.tapButton(driver.l10n.actionStartVote);
    await driver.voteAll(driver.tie);
    expect(driver.game.session.phase, isA<RunoffPhase>());
    expect(find.byType(TallyView), findsOneWidget);
    await driver.continueTally();
    await driver.voteAll(driver.tie);
    expect(find.byType(TallyView), findsOneWidget);
    await driver.continueTally();

    final outcome = (driver.game.session.phase as ResultPhase).outcome;
    expect(outcome, isA<RunoffDraw>());
    expect(find.byType(ResultsView), findsOneWidget);
  });

  testWidgets('replay starts a new game for the same players', (tester) async {
    final (driver, store, _) = await startGame(tester);
    await driver.revealAll();
    await driver.tapButton(driver.l10n.actionStartVote);
    await driver.voteAll(driver.electB);
    await driver.continueTally();
    final first = driver.game;

    await driver.tapButton(driver.l10n.actionPlayAgain);

    expect(driver.game.sessionId, isNot(first.sessionId));
    expect(driver.game.session.phase, isA<RevealPhase>());
    expect(find.byType(HandoffView), findsOneWidget);
    expect(store.state.cooldown.oldestFirst, [first.session.word.wordId]);
  });

  testWidgets('leaving from the handoff: dialog, then Home; protection off', (
    tester,
  ) async {
    final (driver, store, protection) = await startGame(tester);
    final l10n = driver.l10n;

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await driver.tapButton(l10n.dialogQuitConfirm);

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(store.state.session, isNull);
    expect(store.state.cooldown.oldestFirst, isEmpty, reason: 'D-21');
    expect(protection.isOn, isFalse);
  });

  testWidgets('back on a revealed ticket does nothing', (tester) async {
    final (driver, _, _) = await startGame(tester);
    await driver.tapHandoff();
    await driver.tapButton(driver.l10n.revealShow);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.byType(RoleTicket), findsOneWidget);
    expect(find.text(driver.l10n.dialogQuitTitle), findsNothing);
  });

  testWidgets('hiding the app removes the revealed role and returns to the '
      'same handoff', (tester) async {
    final (driver, _, _) = await startGame(tester);
    final word = driver.game.session.word.canonical;
    final player = driver.game.session.players.first.name;
    await driver.tapHandoff();
    await driver.tapButton(driver.l10n.revealShow);

    tester.binding
      ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
      ..handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    await tester.pump();

    expect(find.text(word), findsNothing);
    expect(find.text(driver.game.session.word.category), findsNothing);
    expect(find.byType(HandoffView), findsOneWidget);
    expect(
      find.byWidgetPredicate((w) => w is HandoffView && w.name == player),
      findsOneWidget,
    );
    tester.binding
      ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
      ..handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  });

  testWidgets('without confirmed screenshot protection no role is shown', (
    tester,
  ) async {
    final store = await tester.runAsync(storeWithRoster);
    final protection = FakeProtection()..allow = false;
    await pumpApp(tester, store: store!, protection: protection);
    final driver = FlowDriver(tester);
    final l10n = driver.l10nOf(find.byType(HomeScreen));
    await driver.tapButton(l10n.homeNewGame);
    await driver.tapButton(l10n.actionContinue);
    await driver.tapButton(l10n.actionStart);

    await driver.tapHandoff();

    expect(find.byType(HandoffView), findsOneWidget);
    expect(find.text(l10n.stateError), findsOneWidget);
    expect(store.state.cooldown.oldestFirst, isEmpty);
  });

  testWidgets('hidden while a vote is saving and the save fails: back to the '
      'same handoff, choice discarded, no error left on screen (F11)', (
    tester,
  ) async {
    final (driver, store, _) = await startGame(tester);
    await driver.revealAll();
    await driver.tapButton(driver.l10n.actionStartVote);
    final voter = GameEngine.pendingPlayer(driver.game.session)!;
    await driver.tapHandoff();
    await tester.tap(
      find.byWidgetPredicate(
        (w) => w is VoteOption && w.name == driver.nameOf(driver.accuse(voter)),
      ),
    );
    await tester.pumpAndSettle();

    final hold = store.holdWrites = Completer<void>();
    store.failWrites = true;
    await tester.tap(
      find.widgetWithText(TesskraButton, driver.l10n.actionConfirm),
    );
    await tester.pump();
    tester.binding
      ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
      ..handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    await tester.pump();
    expect(find.byType(VoteView), findsNothing);

    store.holdWrites = null;
    hold.complete();
    await tester.pumpAndSettle();
    tester.binding
      ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
      ..handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(find.byType(VoteView), findsNothing);
    expect(
      tester.widget<HandoffView>(find.byType(HandoffView)).name,
      driver.nameOf(voter),
    );
    expect(find.text(driver.l10n.stateError), findsNothing);
    expect(store.state.session!.firstBallotVotes, isEmpty);
  });

  testWidgets('hidden while the first "I am" is saving: the ticket does not '
      'open by itself afterwards (F11)', (tester) async {
    final (driver, store, _) = await startGame(tester);
    final hold = store.holdWrites = Completer<void>();
    await driver.tester.tap(
      find.byWidgetPredicate(
        (w) =>
            w is TesskraButton &&
            w.label.contains(driver.game.session.players.first.name),
      ),
    );
    await tester.pump();
    tester.binding
      ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
      ..handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    await tester.pump();

    store.holdWrites = null;
    hold.complete();
    await tester.pumpAndSettle();
    tester.binding
      ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
      ..handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(find.byType(RoleTicket), findsNothing);
    expect(find.byType(HandoffView), findsOneWidget);
    expect(store.state.session!.wordConsumed, isTrue, reason: 'C2 committed');
  });

  testWidgets('the leave dialog is carbon over a private screen and paper '
      'over a public one (OVL-02)', (tester) async {
    final (driver, _, _) = await startGame(tester);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(
      TesskraTokens.of(tester.element(find.byType(TesskraDialog))).isCarbon,
      isTrue,
    );
    await driver.tapButton(driver.l10n.dialogQuitCancel);

    await driver.revealAll();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(
      TesskraTokens.of(tester.element(find.byType(TesskraDialog))).isCarbon,
      isFalse,
    );
  });
}
