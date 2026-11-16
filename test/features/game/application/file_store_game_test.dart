import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_tn/data/persistence/file_state_store.dart';
import 'package:impostor_tn/features/game/application/game_service.dart';
import 'package:impostor_tn/features/game/application/launch.dart';
import 'package:impostor_tn/game/ballot.dart';
import 'package:impostor_tn/game/content/content_eligibility.dart';
import 'package:impostor_tn/game/game_phase.dart';
import 'package:impostor_tn/game/persistence/saved_state.dart';

import 'flow_helpers.dart';
import 'service_fixtures.dart';

/// The checkpoint service against the real file store, on a temporary
/// directory: one complete game with a restart (a new store and service on
/// the same directory) after every checkpoint.
void main() {
  late Directory directory;

  setUp(() {
    directory = Directory.systemTemp.createTempSync('impostor_game_test');
  });

  tearDown(() => directory.deleteSync(recursive: true));

  test('a complete game survives a restart after every checkpoint', () async {
    var seed = 0;
    GameService restarted() => GameService(
      store: FileStateStore(directory),
      catalog: fixtureCatalog(),
      channel: ContentChannel.release,
      random: Random(seed++),
    );

    savedValue(
      await restarted().saveRoster(
        SavedRoster(players: fixturePlayers(4), packIds: const ['pack-a']),
      ),
    );
    var game = savedValue(await restarted().startGame());
    while (game.session.phase is RevealPhase) {
      final player = pendingOf(game);
      savedValue(await restarted().confirmIdentity(game.sessionId, player));
      savedValue(await restarted().acknowledge(game.sessionId, player));
      game = ((await restarted().launch()) as LaunchResume).game;
    }
    savedValue(await restarted().openVoting(game.sessionId));
    game = ((await restarted().launch()) as LaunchResume).game;
    while (game.session.phase is FirstBallotPhase) {
      final voter = pendingOf(game);
      savedValue(
        await restarted().castVote(
          game.sessionId,
          ballot: BallotKind.first,
          voter: voter,
          target: accuseImpostor(game, voter),
        ),
      );
      game = ((await restarted().launch()) as LaunchResume).game;
    }
    savedValue(await restarted().submitFinalGuess(game.sessionId, 'wrong'));
    game = ((await restarted().launch()) as LaunchResume).game;

    expect(game.session.phase, isA<ResultPhase>());
    final text = File('${directory.path}/${FileStateStore.fileName}')
        .readAsStringSync();
    expect(text, isNot(contains(game.session.word.canonical)));
  });
}
