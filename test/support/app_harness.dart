import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_tn/app/app.dart';
import 'package:impostor_tn/features/game/application/game_providers.dart';
import 'package:impostor_tn/game/content/content_catalog.dart';
import 'package:impostor_tn/game/content/content_eligibility.dart';
import 'package:impostor_tn/game/content/content_source.dart';
import 'package:impostor_tn/game/privacy/screen_protection.dart';

import '../core/design/widgets/widget_harness.dart';
import '../features/game/application/service_fixtures.dart';

/// Records every protection change; [allow] false simulates a platform that
/// refuses (ADR-0006).
final class FakeProtection implements ScreenProtection {
  final changes = <bool>[];
  bool allow = true;

  bool get isOn => changes.isNotEmpty && changes.last;

  @override
  Future<bool> setProtected({required bool on}) async {
    if (!allow) return false;
    changes.add(on);
    return true;
  }
}

final class FixedContentSource implements ContentSource {
  FixedContentSource(this.catalog);

  final ContentCatalog catalog;

  @override
  Future<ContentLoad> load() async => ContentReady(catalog);
}

/// The app with test doubles: an in-memory store going through the real
/// codec, the synthetic fixture catalog, a seeded random, fake protection.
List<Override> testOverrides({
  required MemoryStore store,
  required FakeProtection protection,
  ContentCatalog? catalog,
  int seed = 7,
}) => [
  stateStoreProvider.overrideWith((ref) async => store),
  contentSourceProvider.overrideWithValue(
    FixedContentSource(catalog ?? fixtureCatalog()),
  ),
  contentChannelProvider.overrideWithValue(ContentChannel.release),
  randomProvider.overrideWithValue(Random(seed)),
  screenProtectionProvider.overrideWithValue(protection),
];

Future<void> pumpApp(
  WidgetTester tester, {
  required MemoryStore store,
  required FakeProtection protection,
  ContentCatalog? catalog,
  Size size = const Size(360, 720),
  double textScale = 1,
}) async {
  await tester.runAsync(loadTesskraFonts);
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearAllTestValues);
  await tester.pumpWidget(
    ProviderScope(
      overrides: testOverrides(
        store: store,
        protection: protection,
        catalog: catalog,
      ),
      child: const ImpostorApp(),
    ),
  );
  await tester.pumpAndSettle();
}
