import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_tn/core/design/theme/tesskra_system_bars.dart';
import 'package:impostor_tn/core/design/theme/tesskra_tokens.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_motion.dart';
import 'package:impostor_tn/core/design/widgets/surface_switcher.dart';

// Synthetic screens; no game content.
const _private = 'private screen';

final class _Screen {
  const _Screen(this.key, this.surface, {this.drop = false});

  final String key;
  final TesskraSurface surface;
  final bool drop;
}

/// Hosts a [SurfaceSwitcher] whose screen is changed through [show].
class _Host extends StatefulWidget {
  const _Host({super.key, required this.first, this.reduced = false});

  final _Screen first;
  final bool reduced;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late _Screen screen = widget.first;

  void show(_Screen next) => setState(() => screen = next);

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: widget.reduced),
      child: SurfaceSwitcher(
        screenKey: screen.key,
        surface: screen.surface,
        dropOutgoing: screen.drop,
        child: screen.key == 'counter'
            ? const _Counter()
            : Center(child: Text(screen.key)),
      ),
    ),
  );
}

class _Counter extends StatefulWidget {
  const _Counter();

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int taps = 0;

  @override
  Widget build(BuildContext context) => Center(
    child: TextButton(
      onPressed: () => setState(() => taps++),
      child: Text('taps $taps'),
    ),
  );
}

Future<_HostState> _pump(
  WidgetTester tester,
  _Screen first, {
  bool reduced = false,
}) async {
  await tester.pumpWidget(
    _Host(key: UniqueKey(), first: first, reduced: reduced),
  );
  return tester.state<_HostState>(find.byType(_Host));
}

SystemUiOverlayStyle _bars(WidgetTester tester) => tester
    .widget<AnnotatedRegion<SystemUiOverlayStyle>>(
      find.byType(AnnotatedRegion<SystemUiOverlayStyle>).last,
    )
    .value;

const _paper = TesskraSurface.paper;
const _carbon = TesskraSurface.carbon;

void main() {
  group('carbonOut', () {
    testWidgets('carbon content leaves in the first frame; paper is complete '
        'under an empty sheet', (tester) async {
      final host = await _pump(tester, const _Screen(_private, _carbon));
      host.show(const _Screen('paper screen', _paper));
      await tester.pump();

      expect(find.text(_private), findsNothing);
      expect(find.text('paper screen'), findsOneWidget);
      // The paper screen is tappable and visible at once.
      expect(find.text('paper screen').hitTestable(), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.text(_private), findsNothing);
    });

    testWidgets('lasts carbonShift, and 140 ms with reduced motion', (
      tester,
    ) async {
      for (final (reduced, duration) in [
        (false, TesskraMotion.carbonShift),
        (true, TesskraMotion.carbonReduced),
      ]) {
        final host = await _pump(
          tester,
          const _Screen('carbon', _carbon),
          reduced: reduced,
        );
        host.show(const _Screen('paper', _paper));
        await tester.pump();
        await tester.pump(duration - const Duration(milliseconds: 1));
        expect(tester.hasRunningAnimations, isTrue, reason: '$reduced');
        await tester.pump(const Duration(milliseconds: 2));
        expect(tester.hasRunningAnimations, isFalse, reason: '$reduced');
      }
    });

    testWidgets('bar icons switch from light to dark at the midpoint', (
      tester,
    ) async {
      final host = await _pump(tester, const _Screen('carbon', _carbon));
      expect(_bars(tester), TesskraSystemBars.carbon);
      host.show(const _Screen('paper', _paper));
      await tester.pump();
      expect(_bars(tester), TesskraSystemBars.carbon);
      await tester.pumpAndSettle();
      expect(_bars(tester), TesskraSystemBars.paper);
    });
  });

  group('carbonIn', () {
    testWidgets('keeps the paper screen under the sheet; the new screen is '
        'not tappable until the sheet is in place', (tester) async {
      final host = await _pump(tester, const _Screen('paper', _paper));
      host.show(const _Screen('counter', _carbon));
      await tester.pump();
      await tester.pump(TesskraMotion.carbonShift ~/ 2);

      expect(find.text('paper'), findsOneWidget);
      await tester.tap(find.text('taps 0'), warnIfMissed: false);
      await tester.pump();
      expect(find.text('taps 0'), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.text('paper'), findsNothing);
      await tester.tap(find.text('taps 0'));
      await tester.pump();
      expect(find.text('taps 1'), findsOneWidget);
      expect(_bars(tester), TesskraSystemBars.carbon);
    });

    testWidgets('content fades in only over the last 140 ms', (tester) async {
      final host = await _pump(tester, const _Screen('paper', _paper));
      host.show(const _Screen('carbon', _carbon));
      await tester.pump();

      double contentOpacity() => tester
          .widget<FadeTransition>(
            find
                .ancestor(
                  of: find.text('carbon'),
                  matching: find.byType(FadeTransition),
                )
                .first,
          )
          .opacity
          .value;

      await tester.pump(
        TesskraMotion.carbonShift -
            TesskraMotion.carbonContentIn -
            const Duration(milliseconds: 1),
      );
      expect(contentOpacity(), 0);
      await tester.pump(const Duration(milliseconds: 71));
      expect(contentOpacity(), greaterThan(0));
      expect(contentOpacity(), lessThan(1));
      await tester.pumpAndSettle();
      expect(contentOpacity(), 1);
    });

    testWidgets('the new screen keeps its state once settled', (tester) async {
      final host = await _pump(tester, const _Screen('paper', _paper));
      host.show(const _Screen('counter', _carbon));
      await tester.pumpAndSettle();
      await tester.tap(find.text('taps 0'));
      await tester.pump();
      host.show(const _Screen('counter', _carbon));
      await tester.pumpAndSettle();
      expect(find.text('taps 1'), findsOneWidget);
    });
  });

  group('same surface', () {
    testWidgets('a dropped screen leaves in the first frame', (tester) async {
      final host = await _pump(tester, const _Screen(_private, _carbon));
      host.show(const _Screen('next handoff', _carbon, drop: true));
      await tester.pump();
      expect(find.text(_private), findsNothing);
      expect(find.text('next handoff'), findsOneWidget);
    });

    testWidgets('a kept screen cross-fades for 220 ms', (tester) async {
      final host = await _pump(tester, const _Screen('handoff', _carbon));
      host.show(const _Screen('ticket', _carbon));
      await tester.pump();
      await tester.pump(TesskraDurations.base ~/ 2);
      expect(find.text('handoff'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('handoff'), findsNothing);
    });

    testWidgets('reduced motion: instant', (tester) async {
      final host = await _pump(
        tester,
        const _Screen('handoff', _carbon),
        reduced: true,
      );
      host.show(const _Screen('ticket', _carbon));
      await tester.pump();
      expect(find.text('handoff'), findsNothing);
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  testWidgets('a new screen during a transition replaces it at once', (
    tester,
  ) async {
    final host = await _pump(tester, const _Screen('paper', _paper));
    host.show(const _Screen(_private, _carbon));
    await tester.pump();
    await tester.pump(TesskraMotion.carbonShift ~/ 2);
    host.show(const _Screen('results', _paper));
    await tester.pump();
    expect(find.text(_private), findsNothing);
    await tester.pumpAndSettle();
    expect(find.text('results'), findsOneWidget);
    expect(find.text('paper'), findsNothing);
  });
}
