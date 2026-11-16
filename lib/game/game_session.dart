import 'package:impostor_tn/game/game_phase.dart';
import 'package:impostor_tn/game/player.dart';
import 'package:impostor_tn/game/secret_word.dart';

/// One game: the roster, the hidden assignment and the current phase.
///
/// Immutable. The assignment ([impostor], [word]) is fixed at creation and
/// copied unchanged by every transition (PRD §5). [toString] is redacted.
final class GameSession {
  GameSession({
    required List<Player> players,
    required this.impostor,
    required this.word,
    required this.phase,
  }) : players = List.unmodifiable(players);

  /// The roster in playing order.
  final List<Player> players;
  final PlayerId impostor;
  final SecretWord word;
  final GamePhase phase;

  GameSession withPhase(GamePhase next) => GameSession(
    players: players,
    impostor: impostor,
    word: word,
    phase: next,
  );

  Iterable<PlayerId> get playerIds => players.map((player) => player.id);

  Player playerById(PlayerId id) => players.firstWhere((p) => p.id == id);

  bool hasPlayer(PlayerId id) => players.any((player) => player.id == id);

  @override
  String toString() =>
      'GameSession(${players.length} players, ${phase.kind.name}, <redacted>)';
}
