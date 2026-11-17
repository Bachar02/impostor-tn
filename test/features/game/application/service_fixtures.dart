import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_tn/data/persistence/saved_state_codec.dart';
import 'package:impostor_tn/features/game/application/active_game.dart';
import 'package:impostor_tn/features/game/application/checkpoint.dart';
import 'package:impostor_tn/features/game/application/game_service.dart';
import 'package:impostor_tn/game/content/content_catalog.dart';
import 'package:impostor_tn/game/content/content_eligibility.dart';
import 'package:impostor_tn/game/content/word_entry.dart';
import 'package:impostor_tn/game/game_engine.dart';
import 'package:impostor_tn/game/persistence/saved_state.dart';
import 'package:impostor_tn/game/persistence/state_store.dart';
import 'package:impostor_tn/game/player.dart';

// SYNTHETIC TEST FIXTURES. Placeholder words, packs, names and reviewer
// references; nothing here is content or was reviewed.

/// A [StateStore] that keeps the encoded document in memory, so every read
/// goes through the real codec, and can fail on demand.
final class MemoryStore implements StateStore {
  String? document;
  int writes = 0;

  /// The next writes fail before anything is stored (process died, disk
  /// full).
  bool failWrites = false;

  /// The next write is stored but reported as failed (the reply was lost).
  bool commitThenFail = false;

  bool failReads = false;

  /// While set, writes wait for it: a save that is still in flight.
  Completer<void>? holdWrites;

  SavedState get state => document == null
      ? SavedState.empty
      : SavedStateCodec.decode(utf8.encode(document!)).state;

  @override
  Future<StoreRead> read() async {
    if (failReads) return const StoreReadFailed();
    if (document == null) return StoreLoaded(SavedState.empty);
    return SavedStateCodec.decode(utf8.encode(document!));
  }

  @override
  Future<StoreWrite> write(SavedState state) async {
    if (holdWrites case final hold?) await hold.future;
    if (failWrites) return StoreWrite.failed;
    document = SavedStateCodec.encode(state);
    writes++;
    if (commitThenFail) {
      commitThenFail = false;
      return StoreWrite.failed;
    }
    return StoreWrite.committed;
  }
}

WordEntry fixtureEntry(
  String id, {
  EditorialStatus status = EditorialStatus.published,
  int version = 1,
}) => WordEntry(
  id: id,
  version: version,
  canonical: 'canonical $id',
  aliases: ['alias $id'],
  category: 'fixture category',
  language: 'aeb-Arab',
  access: AccessStatus.free,
  status: status,
  reviews: status == EditorialStatus.published
      ? const WordReviews(linguistic: 'fixture-a', editorial: 'fixture-b')
      : null,
);

/// pack-a: [words] published words w-0…; pack-draft: one draft word;
/// pack-dev: one development word.
ContentCatalog fixtureCatalog({int words = 40, int version = 1}) =>
    ContentCatalog(
      contentVersion: 1,
      packs: [
        WordPack(
          id: 'pack-a',
          title: 'pack a',
          words: [
            for (var i = 0; i < words; i++)
              fixtureEntry('w-$i', version: version),
          ],
        ),
        WordPack(
          id: 'pack-draft',
          title: 'draft',
          words: [fixtureEntry('d-0', status: EditorialStatus.draft)],
        ),
        WordPack(
          id: 'pack-dev',
          title: 'dev',
          words: [fixtureEntry('v-0', status: EditorialStatus.development)],
        ),
      ],
    );

List<Player> fixturePlayers(int count) => [
  for (var i = 0; i < count; i++)
    Player(id: PlayerId('p$i'), name: 'Player $i'),
];

GameService service(
  MemoryStore store, {
  ContentCatalog? catalog,
  ContentChannel channel = ContentChannel.release,
  int seed = 1,
}) => GameService(
  store: store,
  catalog: catalog ?? fixtureCatalog(),
  channel: channel,
  random: Random(seed),
);

/// A store holding a saved roster and nothing else.
Future<MemoryStore> storeWithRoster({
  int players = 4,
  List<String> packs = const ['pack-a'],
}) async {
  final store = MemoryStore();
  final saved = await service(
    store,
  ).saveRoster(SavedRoster(players: fixturePlayers(players), packIds: packs));
  expect(saved, isA<Saved<SavedRoster>>());
  return store;
}

T savedValue<T>(Checkpoint<T> checkpoint) => switch (checkpoint) {
  Saved(:final value) => value,
  _ => throw StateError('Expected Saved, got $checkpoint'),
};

void expectRefused(Checkpoint<Object?> checkpoint, RefusalReason reason) {
  expect(checkpoint, isA<Refused<Object?>>());
  expect((checkpoint as Refused<Object?>).reason, reason);
}

PlayerId pendingOf(ActiveGame game) => GameEngine.pendingPlayer(game.session)!;

/// Confirms and acknowledges every player, in order.
Future<ActiveGame> revealAll(GameService games, ActiveGame game) async {
  var current = game;
  while (GameEngine.pendingPlayer(current.session) != null &&
      current.session.phase.kind.name == 'reveal') {
    final player = pendingOf(current);
    current = savedValue(
      await games.confirmIdentity(current.sessionId, player),
    );
    current = savedValue(await games.acknowledge(current.sessionId, player));
  }
  return current;
}
