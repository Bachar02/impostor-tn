import 'package:impostor_tn/features/game/application/active_game.dart';
import 'package:impostor_tn/game/ballot.dart';
import 'package:impostor_tn/game/game_engine.dart';
import 'package:impostor_tn/game/game_outcome.dart';
import 'package:impostor_tn/game/game_phase.dart';
import 'package:impostor_tn/game/player.dart';

/// The private screen a player has opened from their handoff.
enum PrivateView { ticket, vote, guess }

/// What the game screens remember that is not saved: which private screen
/// is open, which tallies were seen. All of it may be lost at any time
/// (process death, leaving the foreground) without breaking a rule; the
/// saved game always decides who is next (UX_FLOWS F11).
final class GameUiState {
  const GameUiState({
    this.gate = false,
    this.openFor,
    this.view,
    this.seenTallies = const {},
    this.resultViaBallot = false,
  });

  /// The resume gate (PRV-05) is up: cold start into an unfinished game.
  final bool gate;

  /// The player whose private screen is open, and which one.
  final PlayerId? openFor;
  final PrivateView? view;

  /// Tallies already acknowledged in this session.
  final Set<BallotKind> seenTallies;

  /// The result was reached by a vote in this process, so its tally comes
  /// first (PUB-08 states A and D). After a cold start or a final guess the
  /// result opens directly.
  final bool resultViaBallot;

  GameUiState closePrivate() => GameUiState(
    gate: gate,
    seenTallies: seenTallies,
    resultViaBallot: resultViaBallot,
  );

  GameUiState open(PlayerId player, PrivateView view) => GameUiState(
    gate: gate,
    openFor: player,
    view: view,
    seenTallies: seenTallies,
    resultViaBallot: resultViaBallot,
  );

  GameUiState copyWith({
    bool? gate,
    Set<BallotKind>? seenTallies,
    bool? resultViaBallot,
  }) => GameUiState(
    gate: gate ?? this.gate,
    openFor: openFor,
    view: view,
    seenTallies: seenTallies ?? this.seenTallies,
    resultViaBallot: resultViaBallot ?? this.resultViaBallot,
  );
}

/// The screen to show.
sealed class GameScreen {
  const GameScreen();
}

final class ResumeGateScreen extends GameScreen {
  const ResumeGateScreen();
}

/// PRV-01. [position] and [total] are null for the final guess.
final class HandoffScreen extends GameScreen {
  const HandoffScreen(this.player, {this.position, this.total});

  final PlayerId player;
  final int? position;
  final int? total;
}

final class TicketScreen extends GameScreen {
  const TicketScreen(this.player);

  final PlayerId player;
}

final class DiscussionScreen extends GameScreen {
  const DiscussionScreen();
}

final class VoteScreen extends GameScreen {
  const VoteScreen(this.voter, this.ballot);

  final PlayerId voter;
  final Ballot ballot;
}

/// PUB-08 for a completed [ballot].
final class TallyScreen extends GameScreen {
  const TallyScreen(this.ballot, this.outcome);

  final Ballot ballot;
  final TallyOutcome outcome;
}

final class GuessScreen extends GameScreen {
  const GuessScreen(this.impostor);

  final PlayerId impostor;
}

final class ResultsScreen extends GameScreen {
  const ResultsScreen();
}

/// PUB-08 states A–D.
sealed class TallyOutcome {
  const TallyOutcome();
}

final class TallyNominatedCivilian extends TallyOutcome {
  const TallyNominatedCivilian(this.nominee);

  final PlayerId nominee;
}

final class TallyImpostorCaught extends TallyOutcome {
  const TallyImpostorCaught(this.nominee);

  final PlayerId nominee;
}

final class TallyFirstBallotTie extends TallyOutcome {
  const TallyFirstBallotTie();
}

final class TallyRunoffTie extends TallyOutcome {
  const TallyRunoffTie();
}

/// UX_FLOWS F4–F9 and F11: the screen for [game] and [ui].
GameScreen routeGame(ActiveGame game, GameUiState ui) {
  if (ui.gate) return const ResumeGateScreen();
  final session = game.session;

  GameScreen privateTurn(PlayerId player, PrivateView view, GameScreen open) {
    if (ui.openFor == player && ui.view == view) return open;
    final index = session.playerIds.toList().indexOf(player);
    return view == PrivateView.guess
        ? HandoffScreen(player)
        : HandoffScreen(
            player,
            position: index + 1,
            total: session.players.length,
          );
  }

  switch (session.phase) {
    case RevealPhase():
      final player = GameEngine.pendingPlayer(session)!;
      return privateTurn(player, PrivateView.ticket, TicketScreen(player));
    case DiscussionPhase():
      return const DiscussionScreen();
    case FirstBallotPhase(:final ballot):
      final voter = GameEngine.pendingPlayer(session)!;
      return privateTurn(voter, PrivateView.vote, VoteScreen(voter, ballot));
    case RunoffPhase(:final firstBallot, :final runoff):
      if (runoff.votes.isEmpty && !ui.seenTallies.contains(BallotKind.first)) {
        return TallyScreen(firstBallot, const TallyFirstBallotTie());
      }
      final voter = GameEngine.pendingPlayer(session)!;
      return privateTurn(voter, PrivateView.vote, VoteScreen(voter, runoff));
    case FinalGuessPhase(:final ballots, :final nominee):
      if (!ui.seenTallies.contains(ballots.last.kind)) {
        return TallyScreen(ballots.last, TallyImpostorCaught(nominee));
      }
      return privateTurn(nominee, PrivateView.guess, GuessScreen(nominee));
    case ResultPhase(:final ballots, :final outcome):
      if (ui.resultViaBallot && !ui.seenTallies.contains(ballots.last.kind)) {
        return TallyScreen(ballots.last, switch (outcome) {
          CivilianNominated(:final nominee) => TallyNominatedCivilian(nominee),
          RunoffDraw() => const TallyRunoffTie(),
          // A guess is never followed by a tally (resultViaBallot is
          // cleared by the guess): reaching this is a programming error.
          ImpostorGuessed() => throw StateError('No tally after a guess'),
        });
      }
      return const ResultsScreen();
  }
}

/// Tally rows: candidates by count, highest first; equal counts keep playing
/// order (PUB-08 layout item 3).
List<MapEntry<PlayerId, int>> tallyRows(Ballot ballot) {
  final entries = ballot.tally.entries.toList();
  final order = {for (final (i, e) in entries.indexed) e.key: i};
  return entries..sort((a, b) {
    final byCount = b.value.compareTo(a.value);
    return byCount != 0 ? byCount : order[a.key]!.compareTo(order[b.key]!);
  });
}
