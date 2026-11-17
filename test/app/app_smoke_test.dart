import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_tn/core/design/assets/tesskra_assets.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_palette.dart';
import 'package:impostor_tn/features/home/presentation/home_screen.dart';
import 'package:impostor_tn/l10n/generated/app_localizations.dart';

import '../features/game/application/service_fixtures.dart';
import '../support/app_harness.dart';

Future<void> _pumpApp(WidgetTester tester) => pumpApp(
  tester,
  store: MemoryStore(),
  protection: FakeProtection(),
  size: tester.view.physicalSize / tester.view.devicePixelRatio,
  textScale: tester.platformDispatcher.textScaleFactor,
);

void main() {
  testWidgets('boots in Arabic, right-to-left, on the paper theme', (
    tester,
  ) async {
    await _pumpApp(tester);

    final context = tester.element(find.byType(HomeScreen));
    expect(Directionality.of(context), TextDirection.rtl);
    expect(Localizations.localeOf(context), const Locale('ar'));
    expect(Theme.of(context).scaffoldBackgroundColor, TesskraPalette.paper);
    expect(find.text(AppLocalizations.of(context).homeNewGame), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Arabic is the only supported locale', (tester) async {
    expect(AppLocalizations.supportedLocales, [const Locale('ar')]);
  });

  for (final (label, size, scale) in [
    ('small phone 320×568', const Size(320, 568), 1.0),
    ('reference frame 360×720', const Size(360, 720), 1.0),
    ('small phone at text scale 1.5', const Size(320, 568), 1.5),
    ('tablet 800×1280', const Size(800, 1280), 1.0),
  ]) {
    testWidgets('lays out without overflow: $label', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearAllTestValues);

      await _pumpApp(tester);

      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('bundled licence texts are loadable from the asset bundle', (
    tester,
  ) async {
    for (final path in TesskraLicenseFiles.all) {
      final text = await rootBundle.loadString(path);
      expect(text.trim(), isNotEmpty, reason: path);
    }
  });
}
