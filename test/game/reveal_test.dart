import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_tn/game/game_engine.dart';
import 'package:impostor_tn/game/game_phase.dart';
import 'package:impostor_tn/game/game_rejection.dart';
import 'package:impostor_tn/game/game_rules.dart';
import 'package:impostor_tn/game/player.dart';
import 'package:impostor_tn/game/role_view.dart';

import 'game_fixtures.dart';

void main() {
  group('role view (PRD §5)', () {
    test('a civilian sees the word and the category', () {
      final view = GameEngine.roleViewForPendingPlayer(
        revealSession(impostor: 1),
      );
      expect(view, isA<CivilianView>());
      view as CivilianView;
      expect(view.word, fixtureWord.canonical);
      expect(view.category, fixtureWord.category);
      expect(view.playerName, 'Player 0');
    });

    test('the Impostor sees the category only', () {
      final view = GameEngine.roleViewForPendingPlayer(
        revealSession(impostor: 0),
      );
      expect(view, isA<ImpostorView>());
      expect(view, isNot(isA<CivilianView>()));
      expect(view!.category, fixtureWord.category);
    });

    test('is always for the next player without an acknowledgement', () {
      var session = revealSession(players: 5, impostor: 4);
      for (var i = 0; i < 5; i++) {
        expect(GameEngine.pendingPlayer(session), pid(i));
        expect(
          GameEngine.roleViewForPendingPlayer(session)!.playerName,
          'Player $i',
        );
        session = accepted(GameEngine.acknowledge(session, pid(i)));
      }
    });

    test('is not available outside the reveal phase', () {
      final discussion = acknowledgeAll(revealSession());
      expect(GameEngine.roleViewForPendingPlayer(discussion), isNull);
    });
  });

  group('acknowledge', () {
    test('the last acknowledgement starts the discussion', () {
      for (final count in [GameRules.minPlayers, GameRules.maxPlayers]) {
        final session = acknowledgeAll(revealSession(players: count));
        expect(session.phase, isA<DiscussionPhase>());
        expect(GameEngine.pendingPlayer(session), isNull);
      }
    });

    test('earlier acknowledgements stay in the reveal phase', () {
      final session = accepted(GameEngine.acknowledge(revealSession(), pid(0)));
      expect(session.phase, isA<RevealPhase>());
      expect((session.phase as RevealPhase).acknowledged, [pid(0)]);
    });

    test('never changes the assignment', () {
      final start = revealSession(players: 6, impostor: 3);
      final end = acknowledgeAll(start);
      expect(end.impostor, start.impostor);
      expect(end.word, same(start.word));
      expect(end.players, start.players);
    });

    test('rejects a player out of turn', () {
      expectRejected(
        GameEngine.acknowledge(revealSession(), pid(1)),
        GameRejection.notThisPlayersTurn,
      );
    });

    test('rejects a second acknowledgement by the same player', () {
      final session = accepted(GameEngine.acknowledge(revealSession(), pid(0)));
      expectRejected(
        GameEngine.acknowledge(session, pid(0)),
        GameRejection.alreadyAcknowledged,
      );
    });

    test('rejects an unknown player', () {
      expectRejected(
        GameEngine.acknowledge(revealSession(), const PlayerId('stranger')),
        GameRejection.unknownPlayer,
      );
    });

    test('rejects acknowledging after the reveal phase', () {
      expectRejected(
        GameEngine.acknowledge(acknowledgeAll(revealSession()), pid(0)),
        GameRejection.wrongPhase,
      );
    });
  });

  group('open voting', () {
    test('opens a first ballot with every player as candidate', () {
      final session = votingSession(players: 5);
      final phase = session.phase as FirstBallotPhase;
      expect(phase.ballot.candidates, roster(5).map((p) => p.id));
      expect(phase.ballot.votes, isEmpty);
      expect(GameEngine.pendingPlayer(session), pid(0));
    });

    test('is rejected during the reveal phase', () {
      expectRejected(
        GameEngine.openVoting(revealSession()),
        GameRejection.wrongPhase,
      );
    });

    test('is rejected once voting is open', () {
      expectRejected(
        GameEngine.openVoting(votingSession()),
        GameRejection.wrongPhase,
      );
    });
  });
}
