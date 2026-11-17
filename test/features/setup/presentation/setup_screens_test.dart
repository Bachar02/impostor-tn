import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_tn/core/design/assets/tesskra_assets.dart';
import 'package:impostor_tn/core/design/widgets/setup_components.dart';
import 'package:impostor_tn/core/design/widgets/small_components.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_banner.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_button.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_dialog.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_icon_button.dart';
import 'package:impostor_tn/features/home/presentation/home_screen.dart';
import 'package:impostor_tn/features/setup/presentation/edit_player_sheet.dart';
import 'package:impostor_tn/features/setup/presentation/packs_screen.dart';
import 'package:impostor_tn/features/setup/presentation/players_screen.dart';
import 'package:impostor_tn/game/content/content_catalog.dart';
import 'package:impostor_tn/game/game_rules.dart';
import 'package:impostor_tn/l10n/generated/app_localizations.dart';

import '../../../support/app_harness.dart';
import '../../game/application/service_fixtures.dart';
import '../../game/presentation/flow_driver.dart';

/// PUB-05, OVL-01 and PUB-06 (C0 through the real service).
void main() {
  late FlowDriver driver;
  late AppLocalizations l10n;

  Future<MemoryStore> openPlayers(
    WidgetTester tester, {
    MemoryStore? store,
    ContentCatalog? catalog,
  }) async {
    final s = store ?? MemoryStore();
    await pumpApp(
      tester,
      store: s,
      protection: FakeProtection(),
      catalog: catalog,
    );
    driver = FlowDriver(tester);
    l10n = driver.l10nOf(find.byType(HomeScreen));
    await driver.tapButton(l10n.homeNewGame);
    return s;
  }

  /// The delete button of row [index].
  Finder trashOf(int index) => find
      .byWidgetPredicate(
        (w) => w is TesskraIconButton && w.icon == TesskraIcons.trash,
      )
      .at(index);

  Future<void> confirmDelete(WidgetTester tester) async {
    await tester.tap(
      find.descendant(
        of: find.byType(TesskraDialog),
        matching: find.widgetWithText(TesskraButton, l10n.actionDeletePlayer),
      ),
    );
    await tester.pumpAndSettle();
  }

  bool enabled(WidgetTester tester, String label) =>
      tester
          .widget<TesskraButton>(find.widgetWithText(TesskraButton, label))
          .onPressed !=
      null;

  Future<void> addName(WidgetTester tester, String name) async {
    await tester.enterText(find.byType(TextField), name);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TesskraButton, l10n.actionAdd));
    await tester.pumpAndSettle();
  }

  testWidgets('empty roster: empty state, continue disabled', (tester) async {
    await openPlayers(tester);

    expect(find.byType(PlayersScreen), findsOneWidget);
    expect(find.byType(StateBlock), findsOneWidget);
    expect(enabled(tester, l10n.actionContinue), isFalse);
  });

  testWidgets('adding three players through the sheet, saved at once', (
    tester,
  ) async {
    final store = await openPlayers(tester);
    await tester.tap(find.byType(AddPlayerRow));
    await tester.pumpAndSettle();

    for (final name in ['Sami', 'Lina']) {
      await addName(tester, name);
    }
    expect(find.byType(EditPlayerSheet), findsOneWidget, reason: 'stays open');
    await tester.tapAt(const Offset(10, 10)); // scrim
    await tester.pumpAndSettle();
    expect(find.byType(PlayerRow), findsNWidgets(2));
    expect(find.byType(TesskraBanner), findsOneWidget, reason: '1–2 warning');
    expect(enabled(tester, l10n.actionContinue), isFalse);

    await tester.tap(find.byType(AddPlayerRow));
    await tester.pumpAndSettle();
    await addName(tester, '  Nour   Ben ');
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(find.byType(PlayerRow), findsNWidgets(3));
    expect(find.byType(TesskraBanner), findsNothing);
    expect(enabled(tester, l10n.actionContinue), isTrue);
    expect(store.state.roster.players.map((p) => p.name), [
      'Sami',
      'Lina',
      'Nour Ben',
    ]);
  });

  testWidgets('a Latin duplicate differing in case is refused (D-15)', (
    tester,
  ) async {
    await openPlayers(tester);
    await tester.tap(find.byType(AddPlayerRow));
    await tester.pumpAndSettle();
    await addName(tester, 'Sami');

    await addName(tester, 'sami');

    expect(find.text(l10n.errorNameDuplicate), findsOneWidget);
    expect(find.byType(EditPlayerSheet), findsOneWidget);
  });

  testWidgets('spaces only cannot be added; input stops at 16 characters', (
    tester,
  ) async {
    await openPlayers(tester);
    await tester.tap(find.byType(AddPlayerRow));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '   ');
    await tester.pumpAndSettle();
    expect(enabled(tester, l10n.actionAdd), isFalse);

    await tester.enterText(find.byType(TextField), 'a' * 16);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'a' * 17);
    await tester.pumpAndSettle();

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, 'a' * 16, reason: 'further input ignored');
    expect(find.textContaining('16 / 16'), findsOneWidget);
  });

  testWidgets('a player can be renamed and deleted', (tester) async {
    final store = await tester.runAsync(storeWithRoster);
    await openPlayers(tester, store: store);

    await tester.tap(find.byType(PlayerRow).first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Renamed');
    await tester.tap(find.widgetWithText(TesskraButton, l10n.actionConfirm));
    await tester.pumpAndSettle();
    expect(store!.state.roster.players.first.name, 'Renamed');

    await tester.tap(find.byType(PlayerRow).first);
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(TesskraButton, l10n.actionDeletePlayer),
    );
    await tester.pumpAndSettle();
    await confirmDelete(tester);
    expect(find.byType(PlayerRow), findsNWidgets(3));
    expect(store.state.roster.players, hasLength(3));
  });

  group('delete from the row', () {
    testWidgets('edit and delete sit side by side on every row', (
      tester,
    ) async {
      await openPlayers(tester, store: await tester.runAsync(storeWithRoster));

      for (final row in find.byType(PlayerRow).evaluate()) {
        final buttons = find.descendant(
          of: find.byWidget(row.widget),
          matching: find.byType(TesskraIconButton),
        );
        expect(
          tester.widgetList<TesskraIconButton>(buttons).map((b) => b.icon),
          [TesskraIcons.pencil, TesskraIcons.trash],
        );
      }
    });

    testWidgets('asks first; cancel keeps the player', (tester) async {
      final store = await tester.runAsync(storeWithRoster);
      await openPlayers(tester, store: store);
      final name = store!.state.roster.players[1].name;

      await tester.tap(trashOf(1));
      await tester.pumpAndSettle();
      expect(find.byType(TesskraDialog), findsOneWidget);
      expect(find.textContaining(name), findsWidgets);

      await tester.tap(
        find.widgetWithText(TesskraButton, l10n.dialogDeletePlayerCancel),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TesskraDialog), findsNothing);
      expect(find.byType(PlayerRow), findsNWidgets(4));
      expect(store.state.roster.players, hasLength(4));
    });

    testWidgets('confirming removes that player at once and saves', (
      tester,
    ) async {
      final store = await tester.runAsync(storeWithRoster);
      await openPlayers(tester, store: store);
      final before = store!.state.roster.players;

      await tester.tap(trashOf(1));
      await tester.pumpAndSettle();
      await confirmDelete(tester);

      expect(find.byType(PlayerRow), findsNWidgets(3));
      expect(store.state.roster.players, [before[0], before[2], before[3]]);
    });

    testWidgets('at the minimum every delete is disabled, row and sheet', (
      tester,
    ) async {
      final store = await tester.runAsync(
        () => storeWithRoster(players: GameRules.minPlayers),
      );
      await openPlayers(tester, store: store);

      for (var i = 0; i < GameRules.minPlayers; i++) {
        expect(tester.widget<TesskraIconButton>(trashOf(i)).onPressed, isNull);
      }
      await tester.tap(trashOf(0));
      await tester.pumpAndSettle();
      expect(find.byType(TesskraDialog), findsNothing);
      expect(
        find.byType(EditPlayerSheet),
        findsNothing,
        reason: 'a disabled delete does not fall through to the row',
      );

      await tester.tap(find.byType(PlayerRow).first);
      await tester.pumpAndSettle();
      expect(enabled(tester, l10n.actionDeletePlayer), isFalse);
      expect(store!.state.roster.players, hasLength(GameRules.minPlayers));
    });

    testWidgets('one above the minimum: deleting re-disables the rest', (
      tester,
    ) async {
      final store = await tester.runAsync(
        () => storeWithRoster(players: GameRules.minPlayers + 1),
      );
      await openPlayers(tester, store: store);

      await tester.tap(trashOf(0));
      await tester.pumpAndSettle();
      await confirmDelete(tester);

      expect(store!.state.roster.players, hasLength(GameRules.minPlayers));
      expect(tester.widget<TesskraIconButton>(trashOf(0)).onPressed, isNull);
    });
  });

  group('packs', () {
    testWidgets('no playable content: the no-words state, start disabled', (
      tester,
    ) async {
      final store = await tester.runAsync(storeWithRoster);
      await openPlayers(
        tester,
        store: store,
        catalog: ContentCatalog(contentVersion: 1, packs: const []),
      );
      await driver.tapButton(l10n.actionContinue);

      expect(find.byType(PacksScreen), findsOneWidget);
      expect(find.text(l10n.errorNoWords), findsOneWidget);
      expect(enabled(tester, l10n.actionStart), isFalse);
    });

    testWidgets('unavailable packs cannot be chosen; deselecting all warns', (
      tester,
    ) async {
      final store = await tester.runAsync(storeWithRoster);
      await openPlayers(tester, store: store);
      await driver.tapButton(l10n.actionContinue);

      final cards = tester
          .widgetList<WordPackCard>(find.byType(WordPackCard))
          .toList();
      expect(cards.map((c) => c.state), [
        PackCardState.selected,
        PackCardState.unavailable, // draft words only
        PackCardState.unavailable, // development words in a release build
      ]);

      await tester.tap(find.byType(WordPackCard).first);
      await tester.pumpAndSettle();
      expect(find.text(l10n.errorNoPack), findsOneWidget);
      expect(enabled(tester, l10n.actionStart), isFalse);
      expect(store!.state.roster.packIds, isEmpty);
    });
  });
}
