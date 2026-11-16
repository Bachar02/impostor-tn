import 'package:impostor_tn/features/game/application/active_game.dart';
import 'package:impostor_tn/features/game/application/checkpoint.dart';
import 'package:impostor_tn/game/ballot.dart';
import 'package:impostor_tn/game/game_engine.dart';
import 'package:impostor_tn/game/game_outcome.dart';
import 'package:impostor_tn/game/game_phase.dart';
import 'package:impostor_tn/game/game_rejection.dart';
import 'package:impostor_tn/game/game_session.dart';
import 'package:impostor_tn/game/player.dart';

/// What one checkpoint decides, before anything is written.
sealed class StepOutcome {
  const StepOutcome();
}

/// Write [next]; with [consumeWord], also record the word in the cooldown.
final class Advance extends StepOutcome {
  const Advance(this.next, {this.consumeWord = false});

  final ActiveGame next;
  final bool consumeWord;
}

/// The action's effect is already saved: write nothing, report success.
final class AlreadyDone extends StepOutcome {
  const AlreadyDone();
}

final class Refuse extends StepOutcome {
  const Refuse(this.reason, {this.rule});

  const Refuse.rule(GameRejection this.rule) : reason = RefusalReason.rule;

  final RefusalReason reason;
  final GameRejection? rule;
}

/// The decision of each in-game checkpoint (C2–C7), pure and synchronous.
/// Each distinguishes "already saved" (retry) from "not allowed".
abstract final class GameSteps {
  static StepOutcome confirmIdentity(ActiveGame game, PlayerId player) {
    final session = game.session;
    if (session.phase is! RevealPhase) {
      return const Refuse.rule(GameRejection.wrongPhase);
    }
    if (!session.hasPlayer(player)) {
      return const Refuse.rule(GameRejection.unknownPlayer);
    }
    if (GameEngine.pendingPlayer(session) != player) {
      return const Refuse.rule(GameRejection.notThisPlayersTurn);
    }
    if (game.wordConsumed) return const AlreadyDone();
    return Advance(
      game.withSession(session, wordConsumed: true),
      consumeWord: true,
    );
  }

  static StepOutcome acknowledge(ActiveGame game, PlayerId player) {
    if (!game.wordConsumed) return const Refuse(RefusalReason.wordNotConsumed);
    return switch (GameEngine.acknowledge(game.session, player)) {
      Accepted(:final session) => Advance(game.withSession(session)),
      Rejected(reason: GameRejection.alreadyAcknowledged) =>
        const AlreadyDone(),
      // After the last acknowledgement the phase has moved on: every player,
      // this one included, has acknowledged.
      Rejected(reason: GameRejection.wrongPhase)
          when game.session.hasPlayer(player) =>
        const AlreadyDone(),
      Rejected(:final reason) => Refuse.rule(reason),
    };
  }

  static StepOutcome openVoting(ActiveGame game) =>
      switch (GameEngine.openVoting(game.session)) {
        Accepted(:final session) => Advance(game.withSession(session)),
        Rejected()
            when game.session.phase.kind.index >
                GamePhaseKind.discussion.index =>
          const AlreadyDone(),
        Rejected(:final reason) => Refuse.rule(reason),
      };

  static StepOutcome castVote(
    ActiveGame game,
    BallotKind ballot, {
    required PlayerId voter,
    required PlayerId target,
  }) {
    final recorded = votesOf(game.session, ballot);
    if (recorded != null && recorded.containsKey(voter)) {
      return recorded[voter] == target
          ? const AlreadyDone()
          : const Refuse.rule(GameRejection.alreadyVoted);
    }
    if (openBallotKind(game.session) != ballot) {
      return const Refuse.rule(GameRejection.wrongPhase);
    }
    return switch (GameEngine.castVote(
      game.session,
      voter: voter,
      target: target,
    )) {
      Accepted(:final session) => Advance(game.withSession(session)),
      Rejected(:final reason) => Refuse.rule(reason),
    };
  }

  static StepOutcome finalGuess(ActiveGame game, String rawGuess) {
    if (game.session.phase case ResultPhase(
      outcome: ImpostorGuessed(rawGuess: final saved),
    )) {
      return saved == rawGuess
          ? const AlreadyDone()
          : const Refuse.rule(GameRejection.wrongPhase);
    }
    return switch (GameEngine.submitFinalGuess(game.session, rawGuess)) {
      Accepted(:final session) => Advance(game.withSession(session)),
      Rejected(:final reason) => Refuse.rule(reason),
    };
  }

  /// The ballot currently accepting votes, if any.
  static BallotKind? openBallotKind(GameSession session) =>
      switch (session.phase) {
        FirstBallotPhase() => BallotKind.first,
        RunoffPhase() => BallotKind.runoff,
        _ => null,
      };

  /// The votes saved so far in [kind], or null if that ballot never opened.
  static Map<PlayerId, PlayerId>? votesOf(
    GameSession session,
    BallotKind kind,
  ) {
    final ballots = switch (session.phase) {
      RevealPhase() || DiscussionPhase() => const <Ballot>[],
      FirstBallotPhase(:final ballot) => [ballot],
      RunoffPhase(:final firstBallot, :final runoff) => [firstBallot, runoff],
      FinalGuessPhase(:final ballots) || ResultPhase(:final ballots) => ballots,
    };
    for (final ballot in ballots) {
      if (ballot.kind == kind) return ballot.votes;
    }
    return null;
  }
}
