import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impostor_tn/features/game/application/game_service.dart';
import 'package:impostor_tn/features/game/application/launch.dart';
import 'package:impostor_tn/game/content/content_catalog.dart';
import 'package:impostor_tn/game/content/content_eligibility.dart';
import 'package:impostor_tn/game/content/content_source.dart';
import 'package:impostor_tn/game/persistence/state_store.dart';
import 'package:impostor_tn/game/privacy/screen_protection.dart';

/// D-12: no checkpoint-related provider retries on its own. Riverpod would
/// otherwise re-run a failed provider with backoff, which could repeat a
/// launch-time write behind the user's back. A failure is surfaced once and
/// retried only by an explicit action.
Duration? noAutomaticRetry(int retryCount, Object error) => null;

/// Durable storage. Overridden by the composition root (`lib/app`) and by
/// tests; the application layer never constructs a data-layer type.
final stateStoreProvider = FutureProvider<StateStore>(
  (ref) => throw UnimplementedError('Provided by the composition root'),
  retry: noAutomaticRetry,
);

final contentSourceProvider = Provider<ContentSource>(
  (ref) => throw UnimplementedError('Provided by the composition root'),
);

final contentChannelProvider = Provider<ContentChannel>(
  (ref) => throw UnimplementedError('Provided by the composition root'),
);

/// Screenshot and app-switcher protection for the whole game (D-18).
final screenProtectionProvider = Provider<ScreenProtection>(
  (ref) => throw UnimplementedError('Provided by the composition root'),
);

/// Impostor draws, word draws and session IDs. Tests inject a seeded one.
final randomProvider = Provider<Random>((ref) => Random.secure());

final contentProvider = FutureProvider<ContentLoad>(
  (ref) => ref.watch(contentSourceProvider).load(),
  retry: noAutomaticRetry,
);

final gameServiceProvider = FutureProvider<GameService>((ref) async {
  final store = await ref.watch(stateStoreProvider.future);
  final content = await ref.watch(contentProvider.future);
  return GameService(
    store: store,
    // Unavailable content is a controlled state: no word can be chosen and
    // no saved session can be restored (PRD §10).
    catalog: switch (content) {
      ContentReady(:final catalog) => catalog,
      ContentUnavailable() => ContentCatalog(
        contentVersion: 1,
        packs: const [],
      ),
    },
    channel: ref.watch(contentChannelProvider),
    random: ref.watch(randomProvider),
  );
}, retry: noAutomaticRetry);

/// F1: what the app opens on. Read once per process.
final launchProvider = FutureProvider<Launch>(
  (ref) async => (await ref.watch(gameServiceProvider.future)).launch(),
  retry: noAutomaticRetry,
);
