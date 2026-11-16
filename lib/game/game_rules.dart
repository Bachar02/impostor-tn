/// Business limits from PRD §4, §10 and D-15. Defined once; never repeat
/// these literals.
abstract final class GameRules {
  static const minPlayers = 4;
  static const maxPlayers = 12;

  /// The 30 most recently used distinct word IDs are excluded (PRD §10).
  static const cooldownSize = 30;

  /// User-perceived characters (grapheme clusters) in a player name (D-15).
  static const maxNameLength = 16;
}
