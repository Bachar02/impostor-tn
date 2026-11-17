import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_motion.dart';
import 'package:impostor_tn/core/design/widgets/winner_reveal.dart';

// Synthetic labels; no game content.

final _heavy = <int>[];

Future<void> _pump(
  WidgetTester tester, {
  required bool animate,
  bool reduced = false,
  Duration delay = Duration.zero,
}) async {
  _heavy.clear();
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method == 'HapticFeedback.vibrate' &&
          call.arguments == 'HapticFeedbackType.heavyImpact') {
        _heavy.add(tester.binding.clock.now().microsecondsSinceEpoch);
      }
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );
  await tester.pumpWidget(
    MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData().copyWith(disableAnimations: reduced),
        child: WinnerReveal(
          key: UniqueKey(),
          animate: animate,
          delay: delay,
          stamp: const Text('stamp'),
          content: const Text('content'),
        ),
      ),
    ),
  );
}

double _opacity(WidgetTester tester, String text) => tester
    .widgetList<FadeTransition>(
      find.ancestor(of: find.text(text), matching: find.byType(FadeTransition)),
    )
    .fold(1.0, (value, fade) => value * fade.opacity.value);

double _scale(WidgetTester tester) => tester
    .widget<ScaleTransition>(
      find.ancestor(
        of: find.text('stamp'),
        matching: find.byType(ScaleTransition),
      ),
    )
    .scale
    .value;

void main() {
  testWidgets('recovery: shown at once, no haptic', (tester) async {
    await _pump(tester, animate: false);
    expect(_opacity(tester, 'stamp'), 1);
    expect(_opacity(tester, 'content'), 1);
    expect(_scale(tester), 1);
    await tester.pumpAndSettle();
    expect(_heavy, isEmpty);
  });

  testWidgets('first display: the stamp slams in, lands with one heavy '
      'haptic, then the content rises', (tester) async {
    await _pump(tester, animate: true);
    await tester.pump();
    expect(_opacity(tester, 'stamp'), 0);
    expect(_scale(tester), TesskraMotion.stampScale);
    expect(_opacity(tester, 'content'), 0);

    await tester.pump(TesskraMotion.winnerReveal * 0.45);
    expect(_heavy, isEmpty);
    expect(_opacity(tester, 'content'), greaterThan(0));
    await tester.pump(TesskraMotion.winnerReveal * 0.1);
    expect(_heavy, hasLength(1));

    await tester.pumpAndSettle();
    expect(_scale(tester), 1);
    expect(_opacity(tester, 'content'), 1);
    expect(_heavy, hasLength(1));
  });

  testWidgets('waits for the delay before it starts', (tester) async {
    await _pump(tester, animate: true, delay: TesskraMotion.carbonShift);
    await tester.pump(
      TesskraMotion.carbonShift - const Duration(milliseconds: 1),
    );
    expect(_opacity(tester, 'stamp'), 0);
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(TesskraMotion.winnerReveal);
    expect(_opacity(tester, 'stamp'), 1);
    await tester.pumpAndSettle();
  });

  testWidgets('reduced motion: a 140 ms fade without the slam; the haptic '
      'remains', (tester) async {
    await _pump(tester, animate: true, reduced: true);
    await tester.pump();
    expect(_scale(tester), 1);
    expect(_heavy, hasLength(1));
    await tester.pump(TesskraMotion.winnerReduced);
    expect(_opacity(tester, 'stamp'), 1);
    expect(_opacity(tester, 'content'), 1);
    await tester.pump(const Duration(milliseconds: 17));
    expect(tester.hasRunningAnimations, isFalse);
  });
}
