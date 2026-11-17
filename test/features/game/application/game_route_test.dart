import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_tn/features/game/application/active_game.dart';
import 'package:impostor_tn/features/game/application/game_route.dart';
import 'package:impostor_tn/game/ballot.dart';
import 'package:impostor_tn/game/game_engine.dart';
import 'package:impostor_tn/game/game_session.dart';

import '../../../game/game_fixtures.dart';

ActiveGame active(GameSession session) => ActiveGame(
  sessionId: 's1',
  session: session,
  packIds: const ['pack-a'],
  wordConsumed: true,
  wordVersion: 1,
);

/// UX_FLOWS F4–F11 screen routing, independent of widgets.
void main() {
  test('the resume gate comes first on a cold start', () {
    expect(
      routeGame(active(revealSession()), const GameUiState(gate: true)),
      isA<ResumeGateScreen>(),
    );
  });

  test('reveal: the handoff of the first player without acknowledgement, '
      'with position', () {
    final session = accepted(GameEngine.acknowledge(revealSession(), pid(0)));

    final screen = routeGame(active(session), const GameUiState());

    expect(screen, isA<HandoffScreen>());
    expect((screen as HandoffScreen).player, pid(1));
    expect((screen.position, screen.total), (2, 4));
  });

  test('the ticket only for the player it was opened for', () {
    final game = active(revealSession());

    expect(
      routeGame(game, const GameUiState().open(pid(0), PrivateView.ticket)),
      isA<TicketScreen>(),
    );
    expect(
      routeGame(game, const GameUiState().open(pid(1), PrivateView.ticket)),
      isA<HandoffScreen>(),
      reason: 'a stale view never shows another player a ticket',
    );
  });

  test('discussion after the last acknowledgement', () {
    expect(
      routeGame(active(acknowledgeAll(revealSession())), const GameUiState()),
      isA<DiscussionScreen>(),
    );
  });

  group('tallies', () {
    final tied = castAll(votingSession(), [1, 0, 0, 1]);
    final caught = castAll(votingSession(), [1, 0, 0, 0]);
    final civilianOut = castAll(votingSession(), [1, 2, 1, 1]);

    test('a first-ballot tie shows its tally before the runoff', () {
      final screen = routeGame(active(tied), const GameUiState());

      expect(screen, isA<TallyScreen>());
      expect((screen as TallyScreen).outcome, isA<TallyFirstBallotTie>());
    });

    test('after the tie is seen, the first runoff handoff', () {
      final screen = routeGame(
        active(tied),
        const GameUiState(seenTallies: {BallotKind.first}),
      );

      expect(screen, isA<HandoffScreen>());
    });

    test('Impostor caught: tally, then the guess handoff without '
        'position', () {
      expect(
        (routeGame(active(caught), const GameUiState()) as TallyScreen).outcome,
        isA<TallyImpostorCaught>(),
      );
      final handoff = routeGame(
        active(caught),
        const GameUiState(seenTallies: {BallotKind.first}),
      ) as HandoffScreen;
      expect(handoff.player, pid(0));
      expect(handoff.position, isNull);
    });

    test('a civilian out reached live shows the tally, then results', () {
      final live = routeGame(
        active(civilianOut),
        const GameUiState(resultViaBallot: true),
      );
      expect((live as TallyScreen).outcome, isA<TallyNominatedCivilian>());
      expect(
        routeGame(
          active(civilianOut),
          const GameUiState(
            resultViaBallot: true,
            seenTallies: {BallotKind.first},
          ),
        ),
        isA<ResultsScreen>(),
      );
    });

    test('a finished game after a cold start opens on results', () {
      expect(
        routeGame(active(civilianOut), const GameUiState()),
        isA<ResultsScreen>(),
      );
    });
  });

  test('tally rows: highest first, equal counts in playing order', () {
    final ballot = Ballot(
      kind: BallotKind.first,
      candidates: [pid(0), pid(1), pid(2), pid(3)],
      votes: {pid(0): pid(2), pid(1): pid(3), pid(2): pid(3), pid(3): pid(1)},
    );

    expect(tallyRows(ballot).map((e) => (e.key, e.value)), [
      (pid(3), 2),
      (pid(1), 1),
      (pid(2), 1),
      (pid(0), 0),
    ]);
  });
}
