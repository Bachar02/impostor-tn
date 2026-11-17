import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impostor_tn/features/game/application/active_game.dart';
import 'package:impostor_tn/features/game/application/checkpoint.dart';
import 'package:impostor_tn/features/game/application/game_providers.dart';
import 'package:impostor_tn/features/game/application/game_service.dart';
import 'package:impostor_tn/features/game/application/launch.dart';
import 'package:impostor_tn/game/ballot.dart';
import 'package:impostor_tn/game/persistence/saved_state.dart';
import 'package:impostor_tn/game/player.dart';

final gameControllerProvider = NotifierProvider<GameController, ActiveGame?>(
  GameController.new,
  retry: noAutomaticRetry,
);

/// The current game for the screens, null outside a game.
///
/// Persist first, then publish (ADR-0002): [state] changes only when a
/// checkpoint returns [Saved]. Every method returns the checkpoint result so
/// the screen can show its loading, error and retry states; nothing here
/// retries by itself (D-12).
///
/// Actions name the player the screen is showing, rather than "whoever is
/// pending", so a stale screen can never act for someone else.
class GameController extends Notifier<ActiveGame?> {
  /// Starts from the saved game found at launch, if any (F1).
  @override
  ActiveGame? build() => switch (ref.read(launchProvider).value) {
    LaunchResume(:final game) => game,
    _ => null,
  };

  /// From the launch result (F1) or the resume gate.
  void resume(ActiveGame game) => state = game;

  Future<Checkpoint<ActiveGame>> start() => _run((games) => games.startGame());

  Future<Checkpoint<ActiveGame>> confirmIdentity(PlayerId player) =>
      _inGame((games, id) => games.confirmIdentity(id, player));

  Future<Checkpoint<ActiveGame>> acknowledge(PlayerId player) =>
      _inGame((games, id) => games.acknowledge(id, player));

  Future<Checkpoint<ActiveGame>> openVoting() =>
      _inGame((games, id) => games.openVoting(id));

  Future<Checkpoint<ActiveGame>> castVote({
    required BallotKind ballot,
    required PlayerId voter,
    required PlayerId target,
  }) => _inGame(
    (games, id) =>
        games.castVote(id, ballot: ballot, voter: voter, target: target),
  );

  Future<Checkpoint<ActiveGame>> submitFinalGuess(String rawGuess) =>
      _inGame((games, id) => games.submitFinalGuess(id, rawGuess));

  Future<Checkpoint<ActiveGame>> playAgain() =>
      _inGame((games, id) => games.playAgain(id));

  /// C8. On success the controller holds no game.
  Future<Checkpoint<SavedRoster>> leave() async {
    final game = state;
    final games = await ref.read(gameServiceProvider.future);
    if (game == null) return const Refused(RefusalReason.staleSession);
    final result = await games.endSession(game.sessionId);
    if (result is Saved<SavedRoster> && ref.mounted) state = null;
    return result;
  }

  Future<Checkpoint<ActiveGame>> _inGame(
    Future<Checkpoint<ActiveGame>> Function(GameService games, String id)
    action,
  ) {
    final game = state;
    if (game == null) {
      return Future.value(const Refused(RefusalReason.staleSession));
    }
    return _run((games) => action(games, game.sessionId));
  }

  Future<Checkpoint<ActiveGame>> _run(
    Future<Checkpoint<ActiveGame>> Function(GameService games) action,
  ) async {
    final games = await ref.read(gameServiceProvider.future);
    final result = await action(games);
    if (result is Saved<ActiveGame> && ref.mounted) state = result.value;
    return result;
  }
}
