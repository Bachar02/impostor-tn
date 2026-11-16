import 'dart:math';

import 'package:impostor_tn/game/ballot.dart';
import 'package:impostor_tn/game/ballot_resolution.dart';
import 'package:impostor_tn/game/final_guess_matching.dart';
import 'package:impostor_tn/game/game_outcome.dart';
import 'package:impostor_tn/game/game_phase.dart';
import 'package:impostor_tn/game/game_rejection.dart';
import 'package:impostor_tn/game/game_rules.dart';
import 'package:impostor_tn/game/game_session.dart';
import 'package:impostor_tn/game/player.dart';
import 'package:impostor_tn/game/role_view.dart';
import 'package:impostor_tn/game/secret_word.dart';

/// The game rules of PRD §4–§9 as pure transitions.
///
/// Every action returns [Accepted] with the next session or [Rejected] with a
/// reason; nothing is ignored and nothing is mutated. Selecting the word and
/// the cooldown are outside the engine (PRD §10, Q-16): [start] receives an
/// already-selected word.
abstract final class GameEngine {
  /// Creates a session with exactly one Impostor drawn from [random].
  static Transition start({
    required List<Player> players,
    required SecretWord word,
    required Random random,
  }) {
    if (validateRoster(players) case final rejection?) {
      return Rejected(rejection);
    }
    if (!isUsableWord(word)) return const Rejected(GameRejection.invalidWord);
    final impostor = players[random.nextInt(players.length)].id;
    return Accepted(
      GameSession(
        players: players,
        impostor: impostor,
        word: word,
        phase: RevealPhase(),
      ),
    );
  }

  /// PRD §4 count limits and unique ids; null when the roster is valid.
  /// Name rules are not checked here (Q-01).
  static GameRejection? validateRoster(List<Player> players) {
    if (players.length < GameRules.minPlayers) {
      return GameRejection.tooFewPlayers;
    }
    if (players.length > GameRules.maxPlayers) {
      return GameRejection.tooManyPlayers;
    }
    final ids = players.map((player) => player.id).toSet();
    if (ids.length != players.length) return GameRejection.duplicatePlayer;
    return null;
  }

  /// A word whose canonical form is empty could never be guessed.
  static bool isUsableWord(SecretWord word) =>
      FinalGuessMatching.comparisonForm(word.canonical).isNotEmpty;

  /// A new session for the same roster after a finished game (PRD §9). A new
  /// Impostor is drawn; it may be the same player as before.
  static Transition replay(
    GameSession finished, {
    required SecretWord word,
    required Random random,
  }) {
    if (finished.phase is! ResultPhase) {
      return const Rejected(GameRejection.wrongPhase);
    }
    return start(players: finished.players, word: word, random: random);
  }

  /// Whose turn it is: the next player to acknowledge or to vote, or the
  /// Impostor during the final guess. Null in public phases.
  static PlayerId? pendingPlayer(GameSession session) {
    return switch (session.phase) {
      RevealPhase(:final acknowledged) => _firstWithout(
        session,
        acknowledged.contains,
      ),
      FirstBallotPhase(:final ballot) || RunoffPhase(runoff: final ballot) =>
        _firstWithout(session, ballot.votes.containsKey),
      FinalGuessPhase() => session.impostor,
      DiscussionPhase() || ResultPhase() => null,
    };
  }

  /// What the pending player may see after their deliberate reveal (PRD §5).
  /// Null outside the reveal phase. Only ever for the pending player.
  static RoleView? roleViewForPendingPlayer(GameSession session) {
    if (session.phase is! RevealPhase) return null;
    final player = session.playerById(pendingPlayer(session)!);
    final category = session.word.category;
    return player.id == session.impostor
        ? ImpostorView(playerName: player.name, category: category)
        : CivilianView(
            playerName: player.name,
            category: category,
            word: session.word.canonical,
          );
  }

  /// Records [player]'s acknowledgement; after the last one, discussion
  /// starts (PRD §5, §6).
  static Transition acknowledge(GameSession session, PlayerId player) {
    final phase = session.phase;
    if (phase is! RevealPhase) return const Rejected(GameRejection.wrongPhase);
    if (!session.hasPlayer(player)) {
      return const Rejected(GameRejection.unknownPlayer);
    }
    if (phase.acknowledged.contains(player)) {
      return const Rejected(GameRejection.alreadyAcknowledged);
    }
    if (pendingPlayer(session) != player) {
      return const Rejected(GameRejection.notThisPlayersTurn);
    }
    final acknowledged = [...phase.acknowledged, player];
    return Accepted(
      session.withPhase(
        acknowledged.length == session.players.length
            ? const DiscussionPhase()
            : RevealPhase(acknowledged: acknowledged),
      ),
    );
  }

  /// Ends the discussion and opens the first ballot, every player eligible.
  static Transition openVoting(GameSession session) {
    if (session.phase is! DiscussionPhase) {
      return const Rejected(GameRejection.wrongPhase);
    }
    return Accepted(
      session.withPhase(
        FirstBallotPhase(
          Ballot(kind: BallotKind.first, candidates: [...session.playerIds]),
        ),
      ),
    );
  }

  /// Records one vote in the current ballot (PRD §7, D-02). The last vote of
  /// a ballot also resolves it.
  static Transition castVote(
    GameSession session, {
    required PlayerId voter,
    required PlayerId target,
  }) {
    final ballot = switch (session.phase) {
      FirstBallotPhase(:final ballot) => ballot,
      RunoffPhase(:final runoff) => runoff,
      _ => null,
    };
    if (ballot == null) return const Rejected(GameRejection.wrongPhase);
    if (!session.hasPlayer(voter) || !session.hasPlayer(target)) {
      return const Rejected(GameRejection.unknownPlayer);
    }
    if (ballot.votes.containsKey(voter)) {
      return const Rejected(GameRejection.alreadyVoted);
    }
    if (pendingPlayer(session) != voter) {
      return const Rejected(GameRejection.notThisPlayersTurn);
    }
    if (voter == target) return const Rejected(GameRejection.selfVote);
    if (!ballot.candidates.contains(target)) {
      return const Rejected(GameRejection.notACandidate);
    }

    final updated = ballot.withVote(voter, target);
    if (updated.votes.length < session.players.length) {
      return Accepted(
        session.withPhase(switch (session.phase) {
          RunoffPhase(:final firstBallot) => RunoffPhase(
            firstBallot: firstBallot,
            runoff: updated,
          ),
          _ => FirstBallotPhase(updated),
        }),
      );
    }
    return Accepted(
      session.withPhase(resolveCompletedBallot(session, updated)),
    );
  }

  /// The Impostor's single guess (PRD §8, D-01). Any text is accepted and
  /// compared; whether an empty guess needs special handling is Q-02.
  static Transition submitFinalGuess(GameSession session, String rawGuess) {
    final phase = session.phase;
    if (phase is! FinalGuessPhase) {
      return const Rejected(GameRejection.wrongPhase);
    }
    return Accepted(
      session.withPhase(
        ResultPhase(
          ballots: phase.ballots,
          outcome: ImpostorGuessed(
            rawGuess: rawGuess,
            correct: FinalGuessMatching.matches(rawGuess, session.word),
          ),
        ),
      ),
    );
  }

  static PlayerId? _firstWithout(
    GameSession session,
    bool Function(PlayerId) done,
  ) {
    for (final id in session.playerIds) {
      if (!done(id)) return id;
    }
    return null;
  }
}
