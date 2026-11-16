import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_tn/features/game/application/active_game.dart';
import 'package:impostor_tn/features/game/application/checkpoint.dart';
import 'package:impostor_tn/features/game/application/launch.dart';
import 'package:impostor_tn/game/content/content_catalog.dart';
import 'package:impostor_tn/game/content/content_eligibility.dart';
import 'package:impostor_tn/game/game_rules.dart';
import 'package:impostor_tn/game/persistence/saved_state.dart';
import 'package:impostor_tn/game/player.dart';

import 'service_fixtures.dart';

/// Word selection and the cooldown checkpoint C2 (PRD §10, D-21).
void main() {
  Future<(MemoryStore, ActiveGame)> started({
    int players = 4,
    List<String> packs = const ['pack-a'],
  }) async {
    final store = await storeWithRoster(players: players, packs: packs);
    final game = savedValue(await service(store).startGame());
    return (store, game);
  }

  group('C1 start', () {
    test('selects a word but does not consume it', () async {
      final (store, game) = await started();

      expect(game.wordConsumed, isFalse);
      expect(store.state.cooldown.oldestFirst, isEmpty);
      expect(game.roleViewForPendingPlayer(), isNull);
    });

    for (final count in [GameRules.minPlayers, GameRules.maxPlayers]) {
      test('works with $count players', () async {
        final (_, game) = await started(players: count);

        expect(game.session.players, hasLength(count));
      });
    }

    test('two simultaneous attempts create one session', () async {
      final store = await storeWithRoster();
      final games = service(store);
      final writesBefore = store.writes;

      final results = await Future.wait([games.startGame(), games.startGame()]);

      final ids = results.map((r) => savedValue(r).sessionId).toSet();
      expect(ids, hasLength(1));
      expect(store.writes, writesBefore + 1);
    });

    test('a start after a committed start returns the same game', () async {
      final (store, first) = await started();

      final again = savedValue(await service(store, seed: 99).startGame());

      expect(again.sessionId, first.sessionId);
      expect(again.session.impostor, first.session.impostor);
      expect(again.session.word.wordId, first.session.word.wordId);
    });

    test('packs without a playable word: controlled refusal, nothing '
        'written', () async {
      final store = await storeWithRoster(packs: ['pack-draft']);
      final writes = store.writes;

      expectRefused(
        await service(store).startGame(),
        RefusalReason.noEligibleWord,
      );
      expect(store.writes, writes);
      expect(store.state.session, isNull);
    });

    test('an empty catalog is a controlled refusal (Q-13 today)', () async {
      final store = await storeWithRoster();

      expectRefused(
        await service(
          store,
          catalog: ContentCatalog(contentVersion: 1, packs: const []),
        ).startGame(),
        RefusalReason.noEligibleWord,
      );
    });

    test('development words are never selected in a release build', () async {
      final store = await storeWithRoster(packs: ['pack-dev']);

      expectRefused(
        await service(store).startGame(),
        RefusalReason.noEligibleWord,
      );
    });

    test('development words can be selected in a debug build', () async {
      final store = await storeWithRoster(packs: ['pack-dev']);

      final game = savedValue(
        await service(store, channel: ContentChannel.development).startGame(),
      );

      expect(game.session.word.wordId, 'v-0');
    });

    test('no pack selected is refused', () async {
      final store = await storeWithRoster(packs: []);

      expectRefused(
        await service(store).startGame(),
        RefusalReason.noPackSelected,
      );
    });

    test('three players are refused', () async {
      final store = await storeWithRoster(players: 3);

      expectRefused(
        await service(store).startGame(),
        RefusalReason.invalidRoster,
      );
    });
  });

  group('C2 consume', () {
    test('the first "I am" records the word and allows the reveal', () async {
      final (store, game) = await started();

      final next = savedValue(
        await service(store).confirmIdentity(game.sessionId, pendingOf(game)),
      );

      expect(next.wordConsumed, isTrue);
      expect(store.state.cooldown.oldestFirst, [game.session.word.wordId]);
      expect(store.state.session!.wordConsumed, isTrue);
      expect(next.roleViewForPendingPlayer(), isNotNull);
    });

    test('later players do not write again', () async {
      final (store, game) = await started();
      final games = service(store);
      final first = pendingOf(game);
      var current = savedValue(
        await games.confirmIdentity(game.sessionId, first),
      );
      current = savedValue(await games.acknowledge(game.sessionId, first));
      final writes = store.writes;

      savedValue(
        await games.confirmIdentity(game.sessionId, pendingOf(current)),
      );

      expect(store.writes, writes);
      expect(store.state.cooldown.oldestFirst, hasLength(1));
    });

    test('a repeated tap writes nothing', () async {
      final (store, game) = await started();
      final games = service(store);
      await games.confirmIdentity(game.sessionId, pendingOf(game));
      final writes = store.writes;

      final again = await games.confirmIdentity(
        game.sessionId,
        pendingOf(game),
      );

      expect(again, isA<Saved<ActiveGame>>());
      expect(store.writes, writes);
    });

    test('two simultaneous taps record the word once', () async {
      final (store, game) = await started();
      final games = service(store);
      final writes = store.writes;

      await Future.wait([
        games.confirmIdentity(game.sessionId, pendingOf(game)),
        games.confirmIdentity(game.sessionId, pendingOf(game)),
      ]);

      expect(store.writes, writes + 1);
      expect(store.state.cooldown.oldestFirst, hasLength(1));
    });

    test('a failed write changes nothing; the retry records once', () async {
      final (store, game) = await started();
      final games = service(store);
      final before = store.document;

      store.failWrites = true;
      expect(
        await games.confirmIdentity(game.sessionId, pendingOf(game)),
        isA<SaveFailed<ActiveGame>>(),
      );
      expect(store.document, before);

      store.failWrites = false;
      savedValue(await games.confirmIdentity(game.sessionId, pendingOf(game)));
      expect(store.state.cooldown.oldestFirst, [game.session.word.wordId]);
    });

    test('a write whose reply was lost is found done on retry', () async {
      final (store, game) = await started();
      final games = service(store);

      store.commitThenFail = true;
      await games.confirmIdentity(game.sessionId, pendingOf(game));
      final writes = store.writes;
      final retry = await games.confirmIdentity(
        game.sessionId,
        pendingOf(game),
      );

      expect(retry, isA<Saved<ActiveGame>>());
      expect(store.writes, writes);
      expect(store.state.cooldown.oldestFirst, hasLength(1));
    });

    test('only the pending player may confirm; nothing is consumed', () async {
      final (store, game) = await started();

      final refused = await service(store)
          .confirmIdentity(game.sessionId, const PlayerId('p3'));

      expectRefused(refused, RefusalReason.rule);
      expect(store.state.cooldown.oldestFirst, isEmpty);
    });

    test('no acknowledgement before the word is consumed', () async {
      final (store, game) = await started();

      expectRefused(
        await service(store).acknowledge(game.sessionId, pendingOf(game)),
        RefusalReason.wordNotConsumed,
      );
    });
  });

  group('restarts', () {
    test(
      'killed after C1: resumes unconsumed; C2 then consumes once',
      () async {
        final (store, game) = await started();

        final launch = await service(store, seed: 5).launch() as LaunchResume;
        expect(launch.game.wordConsumed, isFalse);
        expect(launch.game.session.impostor, game.session.impostor);

        await service(
          store,
          seed: 6,
        ).confirmIdentity(game.sessionId, pendingOf(game));
        expect(store.state.cooldown.oldestFirst, [game.session.word.wordId]);
      },
    );

    test('killed after C2: resumes consumed; never records again', () async {
      final (store, game) = await started();
      await service(store).confirmIdentity(game.sessionId, pendingOf(game));
      final writes = store.writes;

      final launch = await service(store, seed: 7).launch() as LaunchResume;
      await service(
        store,
        seed: 8,
      ).confirmIdentity(game.sessionId, pendingOf(launch.game));

      expect(launch.game.wordConsumed, isTrue);
      expect(store.writes, writes);
      expect(store.state.cooldown.oldestFirst, hasLength(1));
    });

    test('a game abandoned at the first handoff consumes no word', () async {
      final (store, game) = await started();

      savedValue(await service(store).endSession(game.sessionId));

      expect(store.state.session, isNull);
      expect(store.state.cooldown.oldestFirst, isEmpty);
    });

    test('a game abandoned after C2 keeps its word in the cooldown', () async {
      final (store, game) = await started();
      final games = service(store);
      await games.confirmIdentity(game.sessionId, pendingOf(game));

      savedValue(await games.endSession(game.sessionId));

      expect(store.state.cooldown.oldestFirst, [game.session.word.wordId]);
    });

    test('the cooldown carries across sessions and restarts: no word repeats '
        'within ${GameRules.cooldownSize + 1} games', () async {
      final store = await storeWithRoster();
      final picked = <String>[];
      for (var i = 0; i < 70; i++) {
        // A new service per game: the app restarted in between.
        final games = service(store, seed: 100 + i);
        final game = savedValue(await games.startGame());
        await games.confirmIdentity(game.sessionId, pendingOf(game));
        await games.endSession(game.sessionId);
        picked.add(game.session.word.wordId);
      }

      for (var i = 0; i + GameRules.cooldownSize < picked.length; i++) {
        final window = picked.sublist(i, i + GameRules.cooldownSize + 1);
        expect(window.toSet(), hasLength(window.length), reason: 'game $i');
      }
      expect(
        store.state.cooldown.oldestFirst,
        hasLength(GameRules.cooldownSize),
      );
    });

    test(
      'an exhausted pool brings back the least recently used word',
      () async {
        final store = await storeWithRoster();
        final catalog = fixtureCatalog(words: 3);
        final picked = <String>[];
        for (var i = 0; i < 4; i++) {
          final games = service(store, catalog: catalog, seed: i);
          final game = savedValue(await games.startGame());
          await games.confirmIdentity(game.sessionId, pendingOf(game));
          await games.endSession(game.sessionId);
          picked.add(game.session.word.wordId);
        }

        expect(picked.take(3).toSet(), hasLength(3));
        expect(picked[3], picked[0]);
        expect(store.state.cooldown.oldestFirst, [
          picked[1],
          picked[2],
          picked[0],
        ]);
      },
    );
  });

  test('the saved document never contains the word text', () async {
    final (store, game) = await started();
    await service(store).confirmIdentity(game.sessionId, pendingOf(game));

    expect(store.document, isNot(contains(game.session.word.canonical)));
    expect(store.document, isNot(contains('fixture category')));
    expect(store.state.roster, isA<SavedRoster>());
  });
}
