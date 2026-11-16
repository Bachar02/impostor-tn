import 'package:impostor_tn/game/cooldown/word_cooldown.dart';
import 'package:impostor_tn/game/game_phase.dart';
import 'package:impostor_tn/game/player.dart';

/// The secret word of a saved session, by reference only (D-17, ADR-0003).
final class WordReference {
  const WordReference({required this.id, required this.version});

  final String id;

  /// The content record's version when the game started (ADR-0009).
  final int version;

  @override
  bool operator ==(Object other) =>
      other is WordReference && other.id == id && other.version == version;

  @override
  int get hashCode => Object.hash(id, version);

  @override
  String toString() => 'WordReference(<redacted>)';
}

/// Names, order and packs kept for the next game (PRD §4, §9; C0).
final class SavedRoster {
  SavedRoster({required List<Player> players, required List<String> packIds})
    : players = List.unmodifiable(players),
      packIds = List.unmodifiable(packIds);

  static final empty = SavedRoster(players: const [], packIds: const []);

  final List<Player> players;
  final List<String> packIds;

  @override
  String toString() => 'SavedRoster(${players.length} players)';
}

/// Every fact of the active game (PRD §11), exactly as saved. Rebuilt into a
/// session only through `SessionRestore`. [toString] is redacted.
final class SavedSession {
  SavedSession({
    required this.sessionId,
    required List<Player> players,
    required List<String> packIds,
    required this.impostor,
    required this.word,
    required this.wordConsumed,
    required this.phase,
    List<PlayerId> acknowledged = const [],
    Map<PlayerId, PlayerId> firstBallotVotes = const {},
    Map<PlayerId, PlayerId> runoffVotes = const {},
    this.finalGuess,
  }) : players = List.unmodifiable(players),
       packIds = List.unmodifiable(packIds),
       acknowledged = List.unmodifiable(acknowledged),
       firstBallotVotes = Map.unmodifiable(firstBallotVotes),
       runoffVotes = Map.unmodifiable(runoffVotes);

  /// Distinguishes this game from the one before and after it, so a late
  /// action from a finished game cannot touch a new one.
  final String sessionId;
  final List<Player> players;
  final List<String> packIds;
  final PlayerId impostor;
  final WordReference word;

  /// Set together with the cooldown entry at C2 (D-21).
  final bool wordConsumed;
  final GamePhaseKind phase;

  /// In the order they were saved.
  final List<PlayerId> acknowledged;

  /// Voter → target, in the order they were saved.
  final Map<PlayerId, PlayerId> firstBallotVotes;
  final Map<PlayerId, PlayerId> runoffVotes;

  /// The raw guess as confirmed (UX_FLOWS §3.3).
  final String? finalGuess;

  @override
  String toString() => 'SavedSession(${phase.name}, <redacted>)';
}

/// Everything the app keeps between launches: one document, replaced as a
/// whole at every checkpoint, so each checkpoint is atomic (ADR-0003).
final class SavedState {
  SavedState({required this.cooldown, required this.roster, this.session});

  static final empty = SavedState(
    cooldown: WordCooldown.empty,
    roster: SavedRoster.empty,
  );

  final WordCooldown cooldown;
  final SavedRoster roster;
  final SavedSession? session;

  SavedState withSession(SavedSession? next) =>
      SavedState(cooldown: cooldown, roster: roster, session: next);

  @override
  String toString() =>
      'SavedState(session: ${session == null ? 'none' : 'present'})';
}
