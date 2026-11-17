import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_motion.dart';
import 'package:impostor_tn/core/design/widgets/surface_routes.dart';

// Synthetic screens; no game content.

/// The product of every opacity above [finder], and whether any slide
/// above it is off its resting place.
(double, bool) _shown(WidgetTester tester, Finder finder) {
  expect(finder, findsOneWidget);
  var opacity = 1.0;
  var moved = false;
  for (final fade in tester.widgetList<FadeTransition>(
    find.ancestor(of: finder, matching: find.byType(FadeTransition)),
  )) {
    opacity *= fade.opacity.value;
  }
  for (final slide in tester.widgetList<SlideTransition>(
    find.ancestor(of: finder, matching: find.byType(SlideTransition)),
  )) {
    moved |= slide.position.value != Offset.zero;
  }
  return (opacity, moved);
}

Future<NavigatorState> _pumpGame(
  WidgetTester tester, {
  bool reduced = false,
}) async {
  final navigatorKey = GlobalKey<NavigatorState>();
  await tester.pumpWidget(
    MaterialApp(
      navigatorKey: navigatorKey,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
        child: child!,
      ),
      home: const Scaffold(body: Center(child: Text('game screen'))),
    ),
  );
  return navigatorKey.currentState!;
}

/// A pushed route spends its first frame offstage (hero measurement); the
/// next frame is the first one the user sees.
Future<void> _firstOnstageFrame(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets('carbonOut: the new screen is in place and opaque from the '
      'first frame', (tester) async {
    final navigator = await _pumpGame(tester);
    unawaited(
      navigator.pushAndRemoveUntil(
        CarbonOutRoute<void>(
          reducedMotion: false,
          builder: (_) => const Scaffold(body: Center(child: Text('home'))),
        ),
        (_) => false,
      ),
    );
    await _firstOnstageFrame(tester);

    expect(_shown(tester, find.text('home')), (1.0, false));
    // Only an empty sheet moves; it holds nothing.
    final sheet = find.byKey(CarbonOutRoute.sheetKey);
    expect(sheet, findsOneWidget);
    expect(tester.widget<ColoredBox>(sheet).child, isNull);

    await tester.pumpAndSettle();
    expect(find.text('game screen'), findsNothing);
  });

  testWidgets('carbonOut with reduced motion lasts 140 ms', (tester) async {
    final navigator = await _pumpGame(tester, reduced: true);
    unawaited(
      navigator.pushAndRemoveUntil(
        CarbonOutRoute<void>(
          reducedMotion: true,
          builder: (_) => const Scaffold(body: Center(child: Text('home'))),
        ),
        (_) => false,
      ),
    );
    await _firstOnstageFrame(tester);
    expect(_shown(tester, find.text('home')), (1.0, false));
    final sheet = tester.widget<FadeTransition>(
      find
          .ancestor(
            of: find.byKey(CarbonOutRoute.sheetKey),
            matching: find.byType(FadeTransition),
          )
          .first,
    );
    expect(sheet.opacity.value, 1);
    await tester.pump(TesskraMotion.carbonReduced);
    expect(sheet.opacity.value, 0);
  });

  testWidgets('carbonIn: content is invisible until the last 140 ms', (
    tester,
  ) async {
    final navigator = await _pumpGame(tester);
    unawaited(
      navigator.pushAndRemoveUntil(
        CarbonInRoute<void>(
          reducedMotion: false,
          builder: (_) => const Scaffold(body: Center(child: Text('handoff'))),
        ),
        (_) => false,
      ),
    );
    await _firstOnstageFrame(tester);
    await tester.pump(
      TesskraMotion.carbonShift -
          TesskraMotion.carbonContentIn -
          const Duration(milliseconds: 1),
    );
    final (early, moving) = _shown(tester, find.text('handoff'));
    expect(early, 0);
    expect(moving, isTrue);

    await tester.pumpAndSettle();
    expect(_shown(tester, find.text('handoff')), (1.0, false));
  });
}
