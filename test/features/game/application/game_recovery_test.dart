import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_tn/features/game/application/launch.dart';
import 'package:impostor_tn/game/ballot.dart';
import 'package:impostor_tn/game/content/content_catalog.dart';
import 'package:impostor_tn/game/content/word_entry.dart';
import 'package:impostor_tn/game/game_phase.dart';
import 'package:impostor_tn/game/persistence/saved_state.dart';

import 'flow_helpers.dart';
import 'service_fixtures.dart';

/// Launch-time recovery (UX_FLOWS F1, F11; PRD §11; ADR-0003).
void main() {
  /// A store holding a game in the first ballot with one vote cast, the
  /// word consumed, and the cooldown holding that word.
  Future<MemoryStore> midGame() async {
    final store = await storeWithRoster(players: 4);
    final games = service(store);
    final game = await toFirstBallot(games);
    final voter = pendingOf(game);
    await games.castVote(
      game.sessionId,
      ballot: BallotKind.first,
      voter: voter,
      target: accuseImpostor(game, voter),
    );
    return store;
  }

  void tamper(MemoryStore store, void Function(Map<String, Object?>) change) {
    final json = jsonDecode(store.document!) as Map<String, Object?>;
    change(json);
    store.document = jsonEncode(json);
  }

  Map<String, Object?> sessionOf(Map<String, Object?> json) =>
      json['session']! as Map<String, Object?>;

  test('no saved game: Home without a banner', () async {
    final launch = await service(MemoryStore()).launch();

    expect((launch as LaunchHome).restoreFailed, isFalse);
  });

  test('a valid game resumes with its saved facts', () async {
    final store = await midGame();
    final saved = store.state.session!;

    final game =
        ((await service(store, seed: 77).launch()) as LaunchResume).game;

    expect(game.sessionId, saved.sessionId);
    expect(game.session.impostor, saved.impostor);
    expect(game.session.word.wordId, saved.word.id);
    final ballot = (game.session.phase as FirstBallotPhase).ballot;
    expect(ballot.votes, saved.firstBallotVotes);
  });

  group('damaged facts cancel the game; roster and cooldown stay', () {
    final cases = <String, void Function(Map<String, Object?>)>{
      'a gap in the acknowledgements': (json) {
        final session = sessionOf(json)
          ..['phase'] = 'reveal'
          ..['firstBallot'] = <Object?>[];
        session['acknowledged'] = ['p0', 'p2'];
      },
      'a self-vote': (json) => sessionOf(json)['firstBallot'] = [
        {'voter': 'p0', 'target': 'p0'},
      ],
      'a vote by someone who is not a player': (json) =>
          sessionOf(json)['firstBallot'] = [
            {'voter': 'p9', 'target': 'p1'},
          ],
      'a runoff vote without a runoff': (json) => sessionOf(json)['runoff'] = [
        {'voter': 'p0', 'target': 'p1'},
      ],
      'an Impostor who is not a player': (json) =>
          sessionOf(json)['impostor'] = 'p9',
      'three players': (json) {
        final session = sessionOf(json);
        session['players'] = (session['players']! as List).take(3).toList();
      },
      'a phase the facts do not reach': (json) =>
          sessionOf(json)['phase'] = 'finalGuess',
      'acknowledgements without a consumed word': (json) =>
          sessionOf(json)['wordConsumed'] = false,
      'a word that is not in the catalog': (json) =>
          (sessionOf(json)['word']! as Map<String, Object?>)['id'] = 'w-404',
      'a word whose content version changed': (json) =>
          (sessionOf(json)['word']! as Map<String, Object?>)['version'] = 2,
      'an empty final guess (D-16)': (json) {
        sessionOf(json)
          ..['phase'] = 'result'
          ..['finalGuess'] = ' ';
      },
      'an unknown phase name': (json) => sessionOf(json)['phase'] = 'lobby',
    };

    for (final MapEntry(key: name, value: change) in cases.entries) {
      test(name, () async {
        final store = await midGame();
        final cooldown = store.state.cooldown.oldestFirst;
        tamper(store, change);

        final launch = await service(store, seed: 5).launch();

        expect((launch as LaunchHome).restoreFailed, isTrue);
        expect(launch.roster.players, hasLength(4));
        expect(store.state.session, isNull, reason: 'cancelled on disk');
        expect(store.state.cooldown.oldestFirst, cooldown);
      });
    }
  });

  test(
    'an unreadable document: Home with the banner, a clean document',
    () async {
      final store = await midGame();
      store.document = '{"schema": 1, "sess';

      final launch = await service(store).launch();

      expect((launch as LaunchHome).restoreFailed, isTrue);
      expect(store.state.session, isNull);
      expect(jsonDecode(store.document!), isA<Map<String, Object?>>());
    },
  );

  test('a document from a newer app version is not interpreted', () async {
    final store = await midGame();
    tamper(store, (json) => json['schema'] = 2);

    final launch = await service(store).launch();

    expect((launch as LaunchHome).restoreFailed, isTrue);
  });

  test(
    'a storage read failure: Home with the banner, nothing written',
    () async {
      final store = await midGame();
      final writes = store.writes;
      store.failReads = true;

      final launch = await service(store).launch();

      expect((launch as LaunchHome).restoreFailed, isTrue);
      expect(store.writes, writes);
    },
  );

  test('a damaged cooldown alone does not cancel the game', () async {
    final store = await midGame();
    tamper(store, (json) => json['cooldown'] = ['w-1', 'w-1']);

    final launch = await service(store).launch();

    expect(launch, isA<LaunchResume>());
    expect(store.state.cooldown.oldestFirst, isEmpty);
  });

  test('a finished game resumes at its result', () async {
    final store = await storeWithRoster();
    final games = service(store);
    final game = await voteAll(
      games,
      await toFirstBallot(games),
      BallotKind.first,
      accuseImpostor,
    );
    await games.submitFinalGuess(game.sessionId, 'wrong');

    final launch = await service(store, seed: 9).launch() as LaunchResume;

    expect(launch.game.session.phase, isA<ResultPhase>());
  });

  test('a cancelled game exposes nothing of itself', () async {
    final store = await midGame();
    tamper(store, (json) => sessionOf(json)['impostor'] = 'p9');

    final launch = await service(store).launch();

    expect(launch.toString(), isNot(contains('w-')));
    expect(store.document, isNot(contains('"impostor"')));
  });

  test('after a launch read failure, the announced loss holds: a new setup '
      'starts a new game, never the old one', () async {
    final store = await midGame();
    final old = store.state.session!;
    final games = service(store, seed: 21);
    store.failReads = true;
    final launch = await games.launch();
    store.failReads = false;
    expect((launch as LaunchHome).restoreFailed, isTrue);

    savedValue(
      await games.saveRoster(
        SavedRoster(players: fixturePlayers(5), packIds: const ['pack-a']),
      ),
    );
    final started = savedValue(await games.startGame());

    expect(started.sessionId, isNot(old.sessionId));
    expect(started.session.players, hasLength(5));
    expect(store.state.session!.sessionId, started.sessionId);
    expect(store.state.cooldown.oldestFirst, [old.word.id]);
  });

  group('a word that may no longer be played cancels the game (PRD §10)', () {
    for (final status in [
      EditorialStatus.retired,
      EditorialStatus.draft,
      EditorialStatus.inReview,
      EditorialStatus.development,
    ]) {
      test('word now ${status.name}', () async {
        final store = await midGame();
        final wordId = store.state.session!.word.id;
        final updated = ContentCatalog(
          contentVersion: 2,
          packs: [
            WordPack(
              id: 'pack-a',
              title: 'a',
              labelStatus: LabelStatus.approved,
              words: [fixtureEntry(wordId, status: status)],
            ),
          ],
        );

        final launch = await service(store, catalog: updated).launch();

        expect((launch as LaunchHome).restoreFailed, isTrue);
        expect(store.state.session, isNull);
      });
    }
  });

  for (final (name, names) in [
    ('duplicate names', ['Player 0', 'player 0', 'Player 2', 'Player 3']),
    (
      'a name over 16 characters',
      ['P' * 17, 'Player 1', 'Player 2', 'Player 3'],
    ),
    ('an empty name', [' ', 'Player 1', 'Player 2', 'Player 3']),
  ]) {
    test('$name in a saved session cancel it (D-15)', () async {
      final store = await midGame();
      tamper(store, (json) {
        final players = sessionOf(json)['players']! as List<Object?>;
        for (final (i, player) in players.indexed) {
          (player! as Map<String, Object?>)['name'] = names[i];
        }
      });

      final launch = await service(store).launch();

      expect((launch as LaunchHome).restoreFailed, isTrue);
    });
  }
}
