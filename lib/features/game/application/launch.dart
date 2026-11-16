import 'package:impostor_tn/features/game/application/active_game.dart';
import 'package:impostor_tn/game/persistence/saved_state.dart';

/// Where the app starts (UX_FLOWS F1).
sealed class Launch {
  const Launch();
}

/// No game to resume: Home, with the retained roster.
final class LaunchHome extends Launch {
  const LaunchHome({required this.roster, required this.restoreFailed});

  final SavedRoster roster;

  /// A saved game existed but could not be restored and was cancelled (F1
  /// step 3). Home shows the neutral banner; no detail of the game is kept.
  final bool restoreFailed;
}

/// A valid saved game: through the resume gate, or straight to results.
final class LaunchResume extends Launch {
  const LaunchResume(this.game);

  final ActiveGame game;

  @override
  String toString() => 'LaunchResume(<redacted>)';
}
