import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_tn/core/design/theme/tesskra_theme.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_motion.dart';
import 'package:impostor_tn/features/game/presentation/ticket_view.dart';
import 'package:impostor_tn/game/role_view.dart';

import '../../../core/design/widgets/widget_harness.dart';

// SYNTHETIC: placeholder word and category, not content.
const _word = 'placeholder-word';
const _category = 'placeholder-category';

const _roles = <(String, RoleView)>[
  ('civilian', CivilianView(playerName: 'P', word: _word, category: _category)),
  ('impostor', ImpostorView(playerName: 'P', category: _category)),
];

/// The big text of the revealed ticket for each role.
String _secretOf(RoleView role) => switch (role) {
  CivilianView() => _word,
  ImpostorView() => _category,
};

class _Host extends StatefulWidget {
  const _Host({super.key, required this.role, required this.reduced});

  final RoleView role;
  final bool reduced;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  TicketPhase phase = TicketPhase.sealed;

  void set(TicketPhase next) => setState(() => phase = next);

  @override
  Widget build(BuildContext context) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: widget.reduced),
    // Ticket colours exist only on carbon, as in the game flow.
    child: Theme(
      data: TesskraTheme.private,
      child: TicketView(
        name: 'P',
        phase: phase,
        // As in the game flow: the role only while revealed.
        role: phase == TicketPhase.revealed ? widget.role : null,
        onReveal: () {},
        onAcknowledge: () {},
        onBack: () {},
      ),
    ),
  );
}

Future<_HostState> _pump(
  WidgetTester tester,
  RoleView role, {
  bool reduced = false,
}) async {
  await pumpRtl(tester, _Host(key: UniqueKey(), role: role, reduced: reduced));
  return tester.state<_HostState>(find.byType(_Host));
}

double _opacityOf(WidgetTester tester, Finder finder) {
  var opacity = 1.0;
  for (final fade in tester.widgetList<FadeTransition>(
    find.ancestor(of: finder, matching: find.byType(FadeTransition)),
  )) {
    opacity *= fade.opacity.value;
  }
  return opacity;
}

void main() {
  final sealEnd = TesskraMotion.ticketReveal - TesskraMotion.ticketSecretIn;

  for (final (name, role) in _roles) {
    group('ticketReveal ($name)', () {
      testWidgets('the secret is absent while the seal lifts and fades in '
          'only over the last 120 ms', (tester) async {
        final host = await _pump(tester, role);
        final secret = find.text(_secretOf(role));
        host.set(TicketPhase.revealed);
        await tester.pump();
        expect(secret, findsNothing);

        await tester.pump(sealEnd - const Duration(milliseconds: 1));
        expect(secret, findsNothing);

        await tester.pump(const Duration(milliseconds: 61));
        expect(secret, findsOneWidget);
        final midway = _opacityOf(tester, secret);
        expect(midway, greaterThan(0));
        expect(midway, lessThan(1));

        await tester.pump(TesskraMotion.ticketSecretIn);
        expect(_opacityOf(tester, secret), 1);
        await tester.pumpAndSettle();
      });

      testWidgets('acknowledging during the reveal removes the secret in the '
          'same frame', (tester) async {
        final host = await _pump(tester, role);
        final secret = find.text(_secretOf(role));
        host.set(TicketPhase.revealed);
        await tester.pump();
        await tester.pump(sealEnd + const Duration(milliseconds: 30));
        expect(secret, findsOneWidget);

        host.set(TicketPhase.saving);
        await tester.pump();
        expect(secret, findsNothing);
        await tester.pumpAndSettle();
      });

      testWidgets('reduced motion: no lift, a 120 ms fade', (tester) async {
        final host = await _pump(tester, role, reduced: true);
        final secret = find.text(_secretOf(role));
        host.set(TicketPhase.revealed);
        await tester.pump();
        expect(secret, findsOneWidget);
        expect(_opacityOf(tester, secret), 0);
        await tester.pump(TesskraMotion.ticketReduced);
        expect(_opacityOf(tester, secret), 1);
        await tester.pumpAndSettle();
      });
    });
  }

  testWidgets('both roles follow the same timeline', (tester) async {
    final shownAt = <String, int>{};
    for (final (name, role) in _roles) {
      final host = await _pump(tester, role);
      host.set(TicketPhase.revealed);
      await tester.pump();
      for (var ms = 0; ms <= 420; ms += 10) {
        if (find.text(_secretOf(role)).evaluate().isNotEmpty) {
          shownAt[name] = ms;
          break;
        }
        await tester.pump(const Duration(milliseconds: 10));
      }
      await tester.pumpAndSettle();
    }
    expect(shownAt['civilian'], isNotNull);
    expect(shownAt['civilian'], shownAt['impostor']);
  });
}
