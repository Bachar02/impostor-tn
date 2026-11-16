import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_tn/game/game_engine.dart';
import 'package:impostor_tn/game/game_phase.dart';
import 'package:impostor_tn/game/game_session.dart';
import 'package:impostor_tn/game/player.dart';
import 'package:impostor_tn/game/secret_word.dart';
import 'package:impostor_tn/game/session_restore.dart';

import 'game_fixtures.dart';

GameSession restored(RecordedSession recorded) {
  final result = SessionRestore.restore(recorded);
  expect(result, isA<Restored>());
  return (result as Restored).session;
}

void expectCorrupt(RecordedSession recorded, SessionCorruption reason) {
  final result = SessionRestore.restore(recorded);
  expect(result, isA<Corrupt>());
  expect((result as Corrupt).reason, reason);
}

RecordedSession copy(
  RecordedSession base, {
  List<Player>? players,
  PlayerId? impostor,
  SecretWord? word,
  GamePhaseKind? phase,
  Set<PlayerId>? acknowledged,
  Map<PlayerId, PlayerId>? firstBallotVotes,
  Map<PlayerId, PlayerId>? runoffVotes,
  String? finalGuess,
}) => RecordedSession(
  players: players ?? base.players,
  impostor: impostor ?? base.impostor,
  word: word ?? base.word,
  phase: phase ?? base.phase,
  acknowledged: acknowledged ?? base.acknowledged,
  firstBallotVotes: firstBallotVotes ?? base.firstBallotVotes,
  runoffVotes: runoffVotes ?? base.runoffVotes,
  finalGuess: finalGuess ?? base.finalGuess,
);

void main() {
  final runoffSession = castAll(votingSession(), [1, 0, 0, 1]);
  final finalGuessAfterRunoff = castAll(runoffSession, [1, 0, 0, 0]);

  group('restores every phase to the same state (PRD §11)', () {
    for (final (label, session, guess) in <(String, GameSession, String?)>[
      ('reveal, nobody acknowledged', revealSession(impostor: 2), null),
      (
        'reveal, part acknowledged',
        accepted(GameEngine.acknowledge(revealSession(), pid(0))),
        null,
      ),
      ('discussion', acknowledgeAll(revealSession(players: 12)), null),
      ('first ballot, no vote yet', votingSession(), null),
      ('first ballot, part voted', castAll(votingSession(), [1, 0]), null),
      ('runoff, no vote yet', runoffSession, null),
      ('runoff, part voted', castAll(runoffSession, [1]), null),
      ('final guess after the runoff', finalGuessAfterRunoff, null),
      (
        'result after a civilian nomination',
        castAll(votingSession(), [1, 0, 1, 1]),
        null,
      ),
      (
        'result after a runoff draw',
        castAll(runoffSession, [1, 0, 0, 1]),
        null,
      ),
    ]) {
      test(label, () {
        final back = restored(recordedFrom(session, finalGuess: guess));
        expect(back.phase.kind, session.phase.kind);
        expect(back.impostor, session.impostor, reason: 'never redrawn');
        expect(back.word, same(session.word));
        expect(
          GameEngine.pendingPlayer(back),
          GameEngine.pendingPlayer(session),
        );
      });
    }

    test('result after a final guess keeps the guess and its outcome', () {
      final finished = accepted(
        GameEngine.submitFinalGuess(finalGuessAfterRunoff, 'alfa'),
      );
      final back = restored(recordedFrom(finished, finalGuess: 'alfa'));
      expect((back.phase as ResultPhase).ballots, hasLength(2));
      expect(back.phase.kind, GamePhaseKind.result);
    });
  });

  group('interruption around an acknowledgement (PRD §5)', () {
    test('before the commit, the same player reveals again', () {
      final session = accepted(GameEngine.acknowledge(revealSession(), pid(0)));
      // The acknowledgement of p1 was never saved.
      expect(GameEngine.pendingPlayer(restored(recordedFrom(session))), pid(1));
    });

    test('after the commit, the next pending player continues', () {
      var session = accepted(GameEngine.acknowledge(revealSession(), pid(0)));
      session = accepted(GameEngine.acknowledge(session, pid(1)));
      expect(GameEngine.pendingPlayer(restored(recordedFrom(session))), pid(2));
    });
  });

  group('cancels corrupt or impossible state, never repairs it', () {
    final reveal = recordedFrom(revealSession());
    final firstBallot = recordedFrom(castAll(votingSession(), [1, 0]));
    final runoff = recordedFrom(castAll(runoffSession, [1]));

    for (final (label, recorded, reason) in [
      (
        'too few players',
        copy(reveal, players: roster(3)),
        SessionCorruption.invalidRoster,
      ),
      (
        'too many players',
        copy(reveal, players: roster(13)),
        SessionCorruption.invalidRoster,
      ),
      (
        'an Impostor who is not a player',
        copy(reveal, impostor: const PlayerId('stranger')),
        SessionCorruption.impostorNotAPlayer,
      ),
      (
        'a word with an empty canonical form',
        copy(
          reveal,
          word: const SecretWord(
            wordId: 'fixture-empty',
            category: 'c',
            canonical: ' ',
          ),
        ),
        SessionCorruption.invalidWord,
      ),
      (
        'a gap in the acknowledgements',
        copy(reveal, acknowledged: {pid(0), pid(2)}),
        SessionCorruption.inconsistentFacts,
      ),
      (
        'an acknowledgement by an unknown id',
        copy(reveal, acknowledged: {const PlayerId('stranger')}),
        SessionCorruption.inconsistentFacts,
      ),
      (
        'every acknowledgement but the phase is still reveal',
        copy(reveal, acknowledged: roster(4).map((p) => p.id).toSet()),
        SessionCorruption.phaseMismatch,
      ),
      (
        'a vote while roles are still being revealed',
        copy(reveal, firstBallotVotes: {pid(0): pid(1)}),
        SessionCorruption.inconsistentFacts,
      ),
      (
        'a self-vote',
        copy(firstBallot, firstBallotVotes: {pid(0): pid(0)}),
        SessionCorruption.inconsistentFacts,
      ),
      (
        'a gap in the votes',
        copy(firstBallot, firstBallotVotes: {pid(0): pid(1), pid(2): pid(1)}),
        SessionCorruption.inconsistentFacts,
      ),
      (
        'a vote for an unknown id',
        copy(
          firstBallot,
          firstBallotVotes: {pid(0): const PlayerId('stranger')},
        ),
        SessionCorruption.inconsistentFacts,
      ),
      (
        'a runoff vote for a player who was not tied',
        copy(runoff, runoffVotes: {pid(0): pid(2)}),
        SessionCorruption.inconsistentFacts,
      ),
      (
        'runoff votes without a tied first ballot',
        copy(firstBallot, runoffVotes: {pid(0): pid(1)}),
        SessionCorruption.inconsistentFacts,
      ),
      (
        'a final guess before any nomination',
        copy(firstBallot, finalGuess: 'alpha'),
        SessionCorruption.inconsistentFacts,
      ),
      (
        'a complete first ballot stored as still open',
        copy(
          firstBallot,
          firstBallotVotes: {
            pid(0): pid(1),
            pid(1): pid(0),
            pid(2): pid(1),
            pid(3): pid(1),
          },
        ),
        SessionCorruption.phaseMismatch,
      ),
      (
        'a result phase with nothing that produced it',
        copy(firstBallot, phase: GamePhaseKind.result),
        SessionCorruption.phaseMismatch,
      ),
    ]) {
      test(label, () => expectCorrupt(recorded, reason));
    }
  });
}
