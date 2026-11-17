import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_motion.dart';
import 'package:impostor_tn/core/design/widgets/animated_rows.dart';

// Synthetic row labels.

class _Host extends StatefulWidget {
  const _Host({super.key, required this.initial, this.reduced = false});

  final List<String> initial;
  final bool reduced;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late List<String> items = widget.initial;

  void set(List<String> next) => setState(() => items = next);

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: MediaQuery(
      data: const MediaQueryData().copyWith(disableAnimations: widget.reduced),
      child: Scaffold(
        body: SingleChildScrollView(
          child: AnimatedRows<String>(
            items: items,
            idOf: (item) => item,
            gap: 8,
            builder: (context, item, index) =>
                SizedBox(height: 40, child: _Counter(label: '$index $item')),
          ),
        ),
      ),
    ),
  );
}

/// A row with its own state: taps counted after the label once tapped.
class _Counter extends StatefulWidget {
  const _Counter({required this.label});

  final String label;

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int taps = 0;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => setState(() => taps++),
    child: Text(taps == 0 ? widget.label : '${widget.label} taps $taps'),
  );
}

Future<_HostState> _pump(
  WidgetTester tester,
  List<String> initial, {
  bool reduced = false,
}) async {
  await tester.pumpWidget(
    _Host(key: UniqueKey(), initial: initial, reduced: reduced),
  );
  return tester.state<_HostState>(find.byType(_Host));
}

double _opacity(WidgetTester tester, String text) => tester
    .widgetList<FadeTransition>(
      find.ancestor(of: find.text(text), matching: find.byType(FadeTransition)),
    )
    .fold(1.0, (value, fade) => value * fade.opacity.value);

double _rowHeight(WidgetTester tester, String text) => tester
    .getSize(
      find
          .ancestor(of: find.text(text), matching: find.byType(SizeTransition))
          .first,
    )
    .height;

void main() {
  testWidgets('rows present at the first build are shown at once', (
    tester,
  ) async {
    await _pump(tester, ['a', 'b']);
    expect(_opacity(tester, '0 a'), 1);
    expect(_opacity(tester, '1 b'), 1);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('a new row fades in and rises over listItemIn', (tester) async {
    final host = await _pump(tester, ['a']);
    host.set(['a', 'b']);
    await tester.pump();
    expect(_opacity(tester, '1 b'), 0);
    final start = tester.getTopLeft(find.text('1 b')).dy;

    await tester.pump(TesskraMotion.listItemIn);
    expect(_opacity(tester, '1 b'), 1);
    final end = tester.getTopLeft(find.text('1 b')).dy;
    expect(start - end, closeTo(TesskraMotion.listItemRise, 0.01));
  });

  testWidgets('a removed row fades and collapses in place, then leaves', (
    tester,
  ) async {
    final host = await _pump(tester, ['a', 'b', 'c']);
    host.set(['a', 'c']);
    await tester.pump();
    // Still in its old place, with its old position.
    expect(find.text('1 b'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('1 b')).dy,
      lessThan(tester.getTopLeft(find.text('1 c')).dy),
    );
    expect(_rowHeight(tester, '1 b'), 48);

    await tester.pump(TesskraMotion.listItemOut ~/ 2);
    expect(_rowHeight(tester, '1 b'), lessThan(48));

    await tester.pumpAndSettle();
    expect(find.text('1 b'), findsNothing);
    expect(find.textContaining(' b'), findsNothing);
  });

  testWidgets('rows keep their state when a row is added before them', (
    tester,
  ) async {
    final host = await _pump(tester, ['a']);
    await tester.tap(find.text('0 a'));
    await tester.pump();
    expect(find.text('0 a taps 1'), findsOneWidget);
    host.set(['z', 'a']);
    await tester.pumpAndSettle();
    expect(find.text('1 a taps 1'), findsOneWidget);
  });

  testWidgets('reduced motion: additions and removals are instant', (
    tester,
  ) async {
    final host = await _pump(tester, ['a', 'b'], reduced: true);
    host.set(['a', 'c']);
    await tester.pump();
    expect(find.text('1 b'), findsNothing);
    expect(_opacity(tester, '1 c'), 1);
    expect(tester.hasRunningAnimations, isFalse);
  });
}
