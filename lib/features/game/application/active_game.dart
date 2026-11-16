import 'package:impostor_tn/game/game_engine.dart';
import 'package:impostor_tn/game/game_session.dart';
import 'package:impostor_tn/game/role_view.dart';

/// The game the app is playing, as last committed to storage.
///
/// The UI renders this and nothing else; it is published only after the
/// checkpoint that produced it has been saved (ADR-0001 commit protocol).
final class ActiveGame {
  ActiveGame({
    required this.sessionId,
    required this.session,
    required List<String> packIds,
    required this.wordConsumed,
    required this.wordVersion,
  }) : packIds = List.unmodifiable(packIds);

  final String sessionId;
  final GameSession session;
  final List<String> packIds;

  /// Whether C2 has committed the word to the cooldown (D-21).
  final bool wordConsumed;

  /// Content version of the word, saved with the session (ADR-0009).
  final int wordVersion;

  /// The pending player's role, only once the word is consumed: no reveal is
  /// ever prepared before C2 has committed (PRD §10, D-21).
  RoleView? roleViewForPendingPlayer() =>
      wordConsumed ? GameEngine.roleViewForPendingPlayer(session) : null;

  ActiveGame withSession(GameSession next, {bool? wordConsumed}) => ActiveGame(
    sessionId: sessionId,
    session: next,
    packIds: packIds,
    wordConsumed: wordConsumed ?? this.wordConsumed,
    wordVersion: wordVersion,
  );

  @override
  String toString() => 'ActiveGame(${session.phase.kind.name}, <redacted>)';
}
