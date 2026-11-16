import 'dart:io';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_tn/features/game/application/active_game.dart';
import 'package:impostor_tn/features/game/application/checkpoint.dart';
import 'package:impostor_tn/features/game/application/game_controller.dart';
import 'package:impostor_tn/features/game/application/game_providers.dart';
import 'package:impostor_tn/features/game/application/launch.dart';
import 'package:impostor_tn/game/content/content_catalog.dart';
import 'package:impostor_tn/game/content/content_eligibility.dart';
import 'package:impostor_tn/game/content/content_source.dart';
import 'package:impostor_tn/game/persistence/state_store.dart';

import 'service_fixtures.dart';

final class FixedContent implements ContentSource {
  FixedContent(this.catalog);

  final ContentCatalog catalog;

  @override
  Future<ContentLoad> load() async => ContentReady(catalog);
}

ProviderContainer containerFor(MemoryStore store) {
  final container = ProviderContainer(
    overrides: [
      stateStoreProvider.overrideWith((ref) async => store),
      contentSourceProvider.overrideWithValue(FixedContent(fixtureCatalog())),
      contentChannelProvider.overrideWithValue(ContentChannel.release),
      randomProvider.overrideWithValue(Random(4)),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('state changes only after a checkpoint is saved', () async {
    final store = await storeWithRoster();
    final container = containerFor(store);
    final controller = container.read(gameControllerProvider.notifier);

    store.failWrites = true;
    expect(await controller.start(), isA<SaveFailed<ActiveGame>>());
    expect(container.read(gameControllerProvider), isNull);

    store.failWrites = false;
    final saved = await controller.start();
    expect(
      container.read(gameControllerProvider)?.sessionId,
      savedValue(saved).sessionId,
    );
  });

  test('a failed checkpoint keeps the previous state', () async {
    final store = await storeWithRoster();
    final container = containerFor(store);
    final controller = container.read(gameControllerProvider.notifier);
    final game = savedValue(await controller.start());

    store.failWrites = true;
    await controller.confirmIdentity(pendingOf(game));

    expect(container.read(gameControllerProvider)!.wordConsumed, isFalse);
  });

  test('leaving clears the game', () async {
    final store = await storeWithRoster();
    final container = containerFor(store);
    final controller = container.read(gameControllerProvider.notifier);
    await controller.start();

    expect(await controller.leave(), isA<Saved<Object?>>());
    expect(container.read(gameControllerProvider), isNull);
    expect(store.state.session, isNull);
  });

  test('without a game, actions are refused, not thrown', () async {
    final container = containerFor(MemoryStore());

    final result = await container
        .read(gameControllerProvider.notifier)
        .openVoting();

    expectRefused(result, RefusalReason.staleSession);
  });

  test('launch reads the saved game through the providers', () async {
    final store = await storeWithRoster();
    final container = containerFor(store);
    await container.read(gameControllerProvider.notifier).start();

    final launch = await containerFor(store).read(launchProvider.future);

    expect(launch, isA<LaunchResume>());
  });

  testWidgets('a failed launch is not retried automatically (D-12)', (
    tester,
  ) async {
    var attempts = 0;
    final container = ProviderContainer(
      overrides: [
        stateStoreProvider.overrideWith((ref) async {
          attempts++;
          throw const FileSystemException('storage unavailable');
        }),
        contentSourceProvider.overrideWithValue(FixedContent(fixtureCatalog())),
        contentChannelProvider.overrideWithValue(ContentChannel.release),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(launchProvider, (_, _) {});
    addTearDown(subscription.close);

    // Fake time: Riverpod's default retry would have fired several times.
    await tester.pump(const Duration(minutes: 1));

    expect(attempts, 1);
    expect(container.read(launchProvider).hasError, isTrue);
  });

  test('the store provider must be supplied by the composition root', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      container.read(stateStoreProvider.future),
      throwsA(isA<UnimplementedError>()),
    );
    expect(StoreWrite.values, hasLength(2));
  });
}
