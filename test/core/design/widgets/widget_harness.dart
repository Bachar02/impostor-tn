import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_tn/core/design/theme/tesskra_theme.dart';
import 'package:impostor_tn/core/design/tokens/tesskra_typography.dart';
import 'package:impostor_tn/l10n/generated/app_localizations.dart';

bool _fontsLoaded = false;

/// Loads the bundled fonts so layouts are measured with real glyphs.
Future<void> loadTesskraFonts() async {
  if (_fontsLoaded) return;
  Future<ByteData> read(String path) async =>
      ByteData.sublistView(Uint8List.fromList(File(path).readAsBytesSync()));
  const fonts = 'docs/design/assets/fonts';
  await (FontLoader(
    TesskraTypography.displayFamily,
  )..addFont(read('$fonts/NotoKufiArabic[wght].ttf'))).load();
  final plex = FontLoader(TesskraTypography.textFamily);
  for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    plex.addFont(read('$fonts/IBMPlexSansArabic-$weight.ttf'));
  }
  await plex.load();
  _fontsLoaded = true;
}

/// The frames the screen specifications are checked at (§1.7).
const frames = <(String, Size, double)>[
  ('360x720', Size(360, 720), 1),
  ('320x568', Size(320, 568), 1),
  ('360x720 scale 1.5', Size(360, 720), 1.5),
  ('320x568 scale 1.5', Size(320, 568), 1.5),
];

/// Pumps [child] in an RTL paper app of [size] at [textScale].
Future<void> pumpRtl(
  WidgetTester tester,
  Widget child, {
  Size size = const Size(360, 720),
  double textScale = 1,
}) async {
  await tester.runAsync(loadTesskraFonts);
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: TesskraTheme.public,
      locale: const Locale('ar'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      builder: (context, app) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: app!,
      ),
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(body: child),
      ),
    ),
  );
}
