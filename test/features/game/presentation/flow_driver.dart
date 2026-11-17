import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_tn/core/design/widgets/game_components.dart';
import 'package:impostor_tn/core/design/widgets/tesskra_button.dart';
import 'package:impostor_tn/features/game/application/active_game.dart';
import 'package:impostor_tn/features/game/application/game_controller.dart';
import 'package:impostor_tn/features/game/presentation/game_flow.dart';
import 'package:impostor_tn/features/game/presentation/ticket_view.dart';
import 'package:impostor_tn/game/game_engine.dart';
import 'package:impostor_tn/game/game_phase.dart';
import 'package:impostor_tn/game/player.dart';
import 'package:impostor_tn/l10n/generated/app_localizations.dart';

/// Plays a game through the real screens by tapping, like a group would.
final class FlowDriver {
  FlowDriver(this.tester);

  final WidgetTester tester;

  ActiveGame get game =>
      ProviderScope.containerOf(tester.element(find.byType(GameFlow)))
          .read(gameControllerProvider)!;

  AppLocalizations get l10n =>
      AppLocalizations.of(tester.element(find.byType(GameFlow)));

  AppLocalizations l10nOf(Finder finder) =>
      AppLocalizations.of(tester.element(finder));

  String nameOf(PlayerId id) => game.session.playerById(id).name;

  Future<void> tapText(String text) async {
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }

  /// The pinned primary button (the last [TesskraButton] in the frame that
  /// has the given label, or the first one when [label] is null).
  Future<void> tapButton(String label) async {
    final button = find.widgetWithText(TesskraButton, label);
    await tester.ensureVisible(button.last);
    await tester.tap(button.last);
    await tester.pumpAndSettle();
  }

  Future<void> tapHandoff() async {
    final player = GameEngine.pendingPlayer(game.session)!;
    final handoff = find.byWidgetPredicate(
      (w) => w is TesskraButton && w.label.contains(nameOf(player)),
    );
    await tester.tap(handoff);
    await tester.pumpAndSettle();
  }

  /// Every player reveals and acknowledges; checks along the way that the
  /// secret is absent before the reveal and after the acknowledgement.
  Future<void> revealAll() async {
    final word = game.session.word.canonical;
    while (game.session.phase is RevealPhase) {
      expect(find.text(word), findsNothing, reason: 'handoff shows no word');
      await tapHandoff();
      expect(find.byType(TicketView), findsOneWidget);
      expect(find.text(word), findsNothing, reason: 'sealed ticket');
      await tapButton(l10n.revealShow);
      await tester.pump(TicketView.ackLock);
      await tapButton(l10n.revealAck);
      expect(find.text(word), findsNothing, reason: 'after acknowledgement');
    }
  }

  /// Casts every vote of the open ballot with [choose].
  Future<void> voteAll(PlayerId Function(PlayerId voter) choose) async {
    final phase = game.session.phase;
    while (game.session.phase.kind == phase.kind &&
        GameEngine.pendingPlayer(game.session) != null) {
      final voter = GameEngine.pendingPlayer(game.session)!;
      await tapHandoff();
      final target = nameOf(choose(voter));
      final option = find.byWidgetPredicate(
        (w) => w is VoteOption && w.name == target,
      );
      await tester.ensureVisible(option);
      await tester.pumpAndSettle();
      await tester.tap(option);
      await tester.pumpAndSettle();
      await tapButton(l10n.actionConfirm);
    }
  }

  /// Waits for the tally sequence and presses its button.
  Future<void> continueTally() async {
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    await tester.tap(find.byType(TesskraButton).last);
    await tester.pumpAndSettle();
  }

  Future<void> guess(String text) async {
    await tapHandoff();
    await tester.enterText(find.byType(TextField), text);
    await tester.pumpAndSettle();
    await tapButton(l10n.actionConfirm);
    await tapButton(l10n.guessConfirmFinal);
  }

  PlayerId get impostor => game.session.impostor;

  List<PlayerId> get civilians =>
      game.session.playerIds.where((id) => id != impostor).toList();

  /// Everyone votes the Impostor; the Impostor votes the first civilian.
  PlayerId accuse(PlayerId voter) =>
      voter == impostor ? civilians.first : impostor;

  /// A tie between the first two civilians A and B (even table).
  PlayerId tie(PlayerId voter) {
    final [a, b, ...] = civilians;
    if (voter == a) return b;
    if (voter == b) return a;
    final others = game.session.playerIds
        .where((id) => id != a && id != b)
        .toList();
    return others.indexOf(voter).isEven ? a : b;
  }

  /// Everyone votes the next player among [candidates] in playing order,
  /// wrapping: 1-1-1-… (the only tie possible at 3 players).
  PlayerId cycle(PlayerId voter) {
    final ids = game.session.playerIds.toList();
    return ids[(ids.indexOf(voter) + 1) % ids.length];
  }

  /// Civilian B is nominated.
  PlayerId electB(PlayerId voter) {
    final [a, b, ...] = civilians;
    return voter == b ? a : b;
  }
}
