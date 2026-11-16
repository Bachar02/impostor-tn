import 'package:impostor_tn/game/player.dart';

/// How a game ended (PRD §8 win conditions). Shown only on the result
/// screen; [toString] is redacted.
sealed class GameOutcome {
  const GameOutcome();

  @override
  String toString() => 'GameOutcome(<redacted>)';
}

/// A civilian was nominated: the Impostor wins without a guess.
final class CivilianNominated extends GameOutcome {
  const CivilianNominated(this.nominee);

  final PlayerId nominee;
}

/// The Impostor was nominated and made the single final guess.
final class ImpostorGuessed extends GameOutcome {
  const ImpostorGuessed({required this.rawGuess, required this.correct});

  /// Exactly as typed at the final confirmation (UX_FLOWS §3.3).
  final String rawGuess;

  /// Correct: the Impostor wins. Incorrect: the civilians win.
  final bool correct;
}

/// The runoff stayed tied: a draw, with no final guess.
final class RunoffDraw extends GameOutcome {
  const RunoffDraw();
}

enum Winner { impostor, civilians, draw }

extension GameOutcomeWinner on GameOutcome {
  Winner get winner => switch (this) {
    CivilianNominated() => Winner.impostor,
    ImpostorGuessed(correct: true) => Winner.impostor,
    ImpostorGuessed(correct: false) => Winner.civilians,
    RunoffDraw() => Winner.draw,
  };
}
