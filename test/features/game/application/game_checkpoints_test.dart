import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_tn/features/game/application/active_game.dart';
import 'package:impostor_tn/features/game/application/checkpoint.dart';
import 'package:impostor_tn/features/game/application/game_service.dart';
import 'package:impostor_tn/features/game/application/launch.dart';
import 'package:impostor_tn/game/ballot.dart';
import 'package:impostor_tn/game/content/content_catalog.dart';
import 'package:impostor_tn/game/game_engine.dart';
import 'package:impostor_tn/game/game_outcome.dart';
import 'package:impostor_tn/game/game_phase.dart';
import 'package:impostor_tn/game/game_rejection.dart';
import 'package:impostor_tn/game/game_rules.dart';
import 'package:impostor_tn/game/persistence/saved_state.dart';
import 'package:impostor_tn/game/player.dart';

import 'flow_helpers.dart';
import 'service_fixtures.dart';

/// Checkpoints C0 and C3–C9 (UX_FLOWS §3, §3.1; PRD §11).
void main() {
  group('a complete game, restarted after every checkpoint', () {
    for (final count in [GameRules.minPlayers, GameRules.maxPlayers]) {
      test('$count players: nominate the Impostor, correct guess', () async {
        final store = await storeWithRoster(players: count);
        var seed = 10;
        // A fresh service per checkpoint: the process restarted in between.
        GameService restarted() => service(store, seed: seed++);

        Future<ActiveGame> resumeAndCompare(ActiveGame expected) async {
          final launch = await restarted().launch();
          final game = (launch as LaunchResume).game;
          expect(game.sessionId, expected.sessionId);
          expect(game.session.phase.kind, expected.session.phase.kind);
          expect(game.session.impostor, expected.session.impostor);
          expect(game.session.word.wordId, expected.session.word.wordId);
          expect(
            GameEngine.pendingPlayer(game.session),
            GameEngine.pendingPlayer(expected.session),
          );
          return game;
        }

        var game = await resumeAndCompare(
          savedValue(await restarted().startGame()),
        );
        while (game.session.phase is RevealPhase) {
          final player = pendingOf(game);
          game = await resumeAndCompare(
            savedValue(
              await restarted().confirmIdentity(game.sessionId, player),
            ),
          );
          game = await resumeAndCompare(
            savedValue(await restarted().acknowledge(game.sessionId, player)),
          );
        }
        expect(game.session.phase, isA<DiscussionPhase>());
        game = await resumeAndCompare(
          savedValue(await restarted().openVoting(game.sessionId)),
        );
        while (game.session.phase is FirstBallotPhase) {
          final voter = pendingOf(game);
          game = await resumeAndCompare(
            savedValue(
              await restarted().castVote(
                game.sessionId,
                ballot: BallotKind.first,
                voter: voter,
                target: accuseImpostor(game, voter),
              ),
            ),
          );
        }
        expect(game.session.phase, isA<FinalGuessPhase>());
        game = await resumeAndCompare(
          savedValue(
            await restarted().submitFinalGuess(
              game.sessionId,
              ' ${game.session.word.canonical} ',
            ),
          ),
        );

        final outcome = (game.session.phase as ResultPhase).outcome;
        expect(outcome.winner, Winner.impostor);
        expect(
          (outcome as ImpostorGuessed).rawGuess,
          ' ${game.session.word.canonical} ',
        );
        expect(store.state.cooldown.oldestFirst, [game.session.word.wordId]);
      });
    }

    test('tie, runoff, runoff tie: a draw with no final guess', () async {
      final store = await storeWithRoster(players: 6);
      final games = service(store);
      var game = await toFirstBallot(games);

      game = await voteAll(games, game, BallotKind.first, tieTwoCivilians);
      expect(game.session.phase, isA<RunoffPhase>());
      final relaunched =
          (await service(store, seed: 3).launch()) as LaunchResume;
      expect(relaunched.game.session.phase, isA<RunoffPhase>());

      game = await voteAll(games, game, BallotKind.runoff, tieTwoCivilians);
      expect((game.session.phase as ResultPhase).outcome, isA<RunoffDraw>());
    });

    test('runoff with a civilian winner: the Impostor wins', () async {
      final store = await storeWithRoster(players: 4);
      final games = service(store);
      var game = await toFirstBallot(games);
      game = await voteAll(games, game, BallotKind.first, tieTwoCivilians);
      game = await voteAll(games, game, BallotKind.runoff, electCivilianB);

      final outcome = (game.session.phase as ResultPhase).outcome;
      expect(outcome, isA<CivilianNominated>());
      expect(outcome.winner, Winner.impostor);
    });
  });

  group('every checkpoint is safe to interrupt and retry', () {
    /// Brings a game to the point just before the checkpoint, and runs it.
    final scenarios =
        <
          String,
          (
            Future<ActiveGame> Function(GameService) setUp,
            Future<Checkpoint<Object?>> Function(GameService, ActiveGame) act,
          )
        >{
          'C3 acknowledge': (
            (games) async {
              final game = savedValue(await games.startGame());
              return savedValue(
                await games.confirmIdentity(game.sessionId, pendingOf(game)),
              );
            },
            (games, game) => games.acknowledge(game.sessionId, pendingOf(game)),
          ),
          'C3 last acknowledgement': (
            (games) async {
              var game = savedValue(await games.startGame());
              for (var i = 0; i < 3; i++) {
                final p = pendingOf(game);
                await games.confirmIdentity(game.sessionId, p);
                game = savedValue(await games.acknowledge(game.sessionId, p));
              }
              return game;
            },
            (games, game) => games.acknowledge(game.sessionId, pendingOf(game)),
          ),
          'C4 open voting': (
            (games) async =>
                revealAll(games, savedValue(await games.startGame())),
            (games, game) => games.openVoting(game.sessionId),
          ),
          'C5 vote': (
            toFirstBallot,
            (games, game) => games.castVote(
              game.sessionId,
              ballot: BallotKind.first,
              voter: pendingOf(game),
              target: accuseImpostor(game, pendingOf(game)),
            ),
          ),
          'C5 last vote, opening the runoff': (
            (games) async {
              var game = await toFirstBallot(games);
              for (var i = 0; i < 3; i++) {
                final voter = pendingOf(game);
                game = savedValue(
                  await games.castVote(
                    game.sessionId,
                    ballot: BallotKind.first,
                    voter: voter,
                    target: tieTwoCivilians(game, voter),
                  ),
                );
              }
              return game;
            },
            (games, game) => games.castVote(
              game.sessionId,
              ballot: BallotKind.first,
              voter: pendingOf(game),
              target: tieTwoCivilians(game, pendingOf(game)),
            ),
          ),
          'C6 runoff vote': (
            (games) async => voteAll(
              games,
              await toFirstBallot(games),
              BallotKind.first,
              tieTwoCivilians,
            ),
            (games, game) => games.castVote(
              game.sessionId,
              ballot: BallotKind.runoff,
              voter: pendingOf(game),
              target: electCivilianB(game, pendingOf(game)),
            ),
          ),
          'C7 final guess': (
            (games) async => voteAll(
              games,
              await toFirstBallot(games),
              BallotKind.first,
              accuseImpostor,
            ),
            (games, game) => games.submitFinalGuess(game.sessionId, 'wrong'),
          ),
          'C8 end session': (
            toFirstBallot,
            (games, game) => games.endSession(game.sessionId),
          ),
          'C9 play again': (
            (games) async {
              final game = await voteAll(
                games,
                await toFirstBallot(games),
                BallotKind.first,
                accuseImpostor,
              );
              return savedValue(
                await games.submitFinalGuess(game.sessionId, 'wrong'),
              );
            },
            (games, game) => games.playAgain(game.sessionId),
          ),
        };

    for (final MapEntry(key: name, value: (setUp, act)) in scenarios.entries) {
      test('$name: killed before the save, nothing changed', () async {
        final store = await storeWithRoster();
        final game = await setUp(service(store));
        final before = store.document;

        store.failWrites = true;
        expect(
          await act(service(store, seed: 2), game),
          isA<SaveFailed<Object?>>(),
        );
        store.failWrites = false;

        expect(store.document, before);
        // After a restart the same action is simply asked for again.
        expect(isSaved(await act(service(store, seed: 3), game)), isTrue);
      });

      test('$name: killed after the save, the retry writes nothing', () async {
        final store = await storeWithRoster();
        final game = await setUp(service(store));

        store.commitThenFail = true;
        await act(service(store, seed: 2), game);
        final after = store.document;
        final writes = store.writes;

        expect(isSaved(await act(service(store, seed: 3), game)), isTrue);
        expect(store.writes, writes);
        expect(store.document, after);
      });
    }
  });

  group('votes (PRD §7, D-02)', () {
    test('a retried first-ballot vote never lands in the runoff', () async {
      final store = await storeWithRoster();
      final games = service(store);
      var game = await toFirstBallot(games);
      late PlayerId lastVoter;
      late PlayerId lastTarget;
      while (game.session.phase is FirstBallotPhase) {
        lastVoter = pendingOf(game);
        lastTarget = tieTwoCivilians(game, lastVoter);
        game = savedValue(
          await games.castVote(
            game.sessionId,
            ballot: BallotKind.first,
            voter: lastVoter,
            target: lastTarget,
          ),
        );
      }

      final retry = await games.castVote(
        game.sessionId,
        ballot: BallotKind.first,
        voter: lastVoter,
        target: lastTarget,
      );

      expect(retry, isA<Saved<ActiveGame>>());
      expect((store.state.session!.runoffVotes), isEmpty);
    });

    test('a different choice after a saved vote is refused', () async {
      final store = await storeWithRoster();
      final games = service(store);
      final game = await toFirstBallot(games);
      final voter = pendingOf(game);
      await games.castVote(
        game.sessionId,
        ballot: BallotKind.first,
        voter: voter,
        target: accuseImpostor(game, voter),
      );

      final changed = await games.castVote(
        game.sessionId,
        ballot: BallotKind.first,
        voter: voter,
        target: game.session.playerIds.lastWhere(
          (id) => id != voter && id != accuseImpostor(game, voter),
        ),
      );

      expectRefused(changed, RefusalReason.rule);
      expect((changed as Refused<ActiveGame>).rule, GameRejection.alreadyVoted);
    });

    test('a vote out of turn is refused and not saved', () async {
      final store = await storeWithRoster();
      final games = service(store);
      final game = await toFirstBallot(games);
      final writes = store.writes;

      final refused = await games.castVote(
        game.sessionId,
        ballot: BallotKind.first,
        voter: game.session.playerIds.last,
        target: game.session.playerIds.first,
      );

      expect(
        (refused as Refused<ActiveGame>).rule,
        GameRejection.notThisPlayersTurn,
      );
      expect(store.writes, writes);
    });
  });

  group('final guess (D-16, D-25)', () {
    Future<(MemoryStore, GameService, ActiveGame)> atGuess() async {
      final store = await storeWithRoster();
      final games = service(store);
      final game = await voteAll(
        games,
        await toFirstBallot(games),
        BallotKind.first,
        accuseImpostor,
      );
      return (store, games, game);
    }

    test('an empty guess is refused and nothing is saved', () async {
      final (store, games, game) = await atGuess();
      final writes = store.writes;

      final refused = await games.submitFinalGuess(game.sessionId, '  ');

      expect((refused as Refused<ActiveGame>).rule, GameRejection.emptyGuess);
      expect(store.writes, writes);
    });

    test('a second, different guess is refused', () async {
      final (_, games, game) = await atGuess();
      await games.submitFinalGuess(game.sessionId, 'first');

      expectRefused(
        await games.submitFinalGuess(game.sessionId, 'second'),
        RefusalReason.rule,
      );
    });

    test(
      'case is preserved: a guess differing in Latin case is wrong',
      () async {
        final (_, games, game) = await atGuess();
        final upper = game.session.word.canonical.toUpperCase();

        final result = savedValue(
          await games.submitFinalGuess(game.sessionId, upper),
        );

        expect(
          (result.session.phase as ResultPhase).outcome.winner,
          Winner.civilians,
        );
      },
    );
  });

  group('session identity', () {
    test(
      'an action for a session that is no longer saved is refused',
      () async {
        final store = await storeWithRoster();
        final games = service(store);
        final game = savedValue(await games.startGame());
        await games.endSession(game.sessionId);

        expectRefused(
          await games.confirmIdentity(game.sessionId, pendingOf(game)),
          RefusalReason.staleSession,
        );
      },
    );

    test('ending an old session never deletes the current one, and says '
        'so', () async {
      final store = await storeWithRoster();
      final games = service(store);
      final old = savedValue(await games.startGame());
      await games.endSession(old.sessionId);
      final current = savedValue(await games.startGame());

      expectRefused(
        await games.endSession(old.sessionId),
        RefusalReason.staleSession,
      );
      expect(store.state.session!.sessionId, current.sessionId);
    });

    test('"home" racing "play again" on results: the replay wins and the '
        'leave is refused, so nothing believes it left', () async {
      final store = await storeWithRoster();
      final games = service(store);
      var game = await voteAll(
        games,
        await toFirstBallot(games),
        BallotKind.first,
        accuseImpostor,
      );
      game = savedValue(await games.submitFinalGuess(game.sessionId, 'wrong'));

      final results = await Future.wait([
        games.playAgain(game.sessionId),
        games.endSession(game.sessionId),
      ]);

      expect(results[0], isA<Saved<Object?>>());
      expectRefused(results[1], RefusalReason.staleSession);
      expect(store.state.session, isNotNull);
    });
  });

  group('C9 play again (PRD §9)', () {
    Future<(MemoryStore, GameService, ActiveGame)> finished() async {
      final store = await storeWithRoster(players: 5);
      final games = service(store);
      var game = await voteAll(
        games,
        await toFirstBallot(games),
        BallotKind.first,
        accuseImpostor,
      );
      game = savedValue(await games.submitFinalGuess(game.sessionId, 'wrong'));
      return (store, games, game);
    }

    test(
      'a new session, same players and packs, new unconsumed word',
      () async {
        final (store, games, old) = await finished();

        final next = savedValue(await games.playAgain(old.sessionId));

        expect(next.sessionId, isNot(old.sessionId));
        expect(next.session.players, old.session.players);
        expect(next.packIds, old.packIds);
        expect(next.session.phase, isA<RevealPhase>());
        expect(next.wordConsumed, isFalse);
        expect(next.session.word.wordId, isNot(old.session.word.wordId));
        expect(store.state.cooldown.oldestFirst, [old.session.word.wordId]);
        expect(store.state.roster.players, hasLength(5));
      },
    );

    test('is refused before the game is over', () async {
      final store = await storeWithRoster();
      final games = service(store);
      final game = await toFirstBallot(games);

      expectRefused(await games.playAgain(game.sessionId), RefusalReason.rule);
    });

    test('when no word can be chosen, the finished result stays', () async {
      final (store, _, old) = await finished();
      final before = store.document;
      // An update moved the finished game's word to another pack and left
      // the selected pack empty: the game restores, but no word is eligible.
      final moved = ContentCatalog(
        contentVersion: 2,
        packs: [
          WordPack(id: 'pack-a', title: 'a', words: const []),
          WordPack(
            id: 'pack-b',
            title: 'b',
            words: [fixtureEntry(old.session.word.wordId)],
          ),
        ],
      );

      final refused = await service(
        store,
        catalog: moved,
      ).playAgain(old.sessionId);

      expectRefused(refused, RefusalReason.noEligibleWord);
      expect(store.document, before);
    });
  });

  group('C0 roster (D-15)', () {
    Future<Checkpoint<SavedRoster>> save(List<String> names) =>
        service(MemoryStore()).saveRoster(
          SavedRoster(
            players: [
              for (final (i, name) in names.indexed)
                Player(id: PlayerId('p$i'), name: name),
            ],
            packIds: const ['pack-a'],
          ),
        );

    test('names are saved trimmed and collapsed', () async {
      final saved = savedValue(await save(['  Sami   Ben ', 'Lina']));

      expect(saved.players.first.name, 'Sami Ben');
    });

    test('Latin names differing only in case are duplicates', () async {
      expectRefused(await save(['Sami', 'sami']), RefusalReason.invalidRoster);
    });

    test('more than ${GameRules.maxPlayers} players are refused', () async {
      expectRefused(
        await save([for (var i = 0; i <= GameRules.maxPlayers; i++) 'P$i']),
        RefusalReason.invalidRoster,
      );
    });

    test('an incomplete roster (fewer than ${GameRules.minPlayers}) can be '
        'saved while it is being edited', () async {
      expect(isSaved(await save(['Sami'])), isTrue);
    });
  });
}
