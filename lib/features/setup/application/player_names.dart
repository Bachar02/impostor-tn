import 'package:characters/characters.dart';
import 'package:impostor_tn/game/game_rules.dart';

enum NameProblem {
  empty,

  /// More than [GameRules.maxNameLength] user-perceived characters.
  tooLong,

  /// Same as another player's name under [PlayerNames.duplicateKey].
  duplicate,
}

/// Player-name rules (D-15).
abstract final class PlayerNames {
  static final _whitespace = RegExp(r'\s+');

  /// The name as saved and shown: trimmed, every run of whitespace reduced to
  /// one space. Unlike the final guess (D-30), any Unicode whitespace counts
  /// here: D-15 says "whitespace" without the D-01 strict reading, and a
  /// name is never compared with content.
  static String normalize(String raw) =>
      raw.trim().replaceAll(_whitespace, ' ');

  /// Length in grapheme clusters, so a letter with shadda counts once.
  static int length(String name) => normalize(name).characters.length;

  /// What duplicates are compared on: the normalized name with Latin letters
  /// lowercased. Other scripts are left as they are (D-15).
  static String duplicateKey(String name) =>
      String.fromCharCodes(normalize(name).runes.map(_latinLower));

  /// The first problem with [raw] among [others] (the other players' names),
  /// or null when it is acceptable.
  static NameProblem? check(String raw, Iterable<String> others) {
    final name = normalize(raw);
    if (name.isEmpty) return NameProblem.empty;
    if (name.characters.length > GameRules.maxNameLength) {
      return NameProblem.tooLong;
    }
    final key = duplicateKey(name);
    if (others.any((other) => duplicateKey(other) == key)) {
      return NameProblem.duplicate;
    }
    return null;
  }

  /// Whether every name is acceptable and no two collide.
  static bool allValid(List<String> names) {
    for (var i = 0; i < names.length; i++) {
      if (check(names[i], names.take(i)) != null) return false;
    }
    return true;
  }

  static int _latinLower(int rune) {
    if (!_isLatin(rune)) return rune;
    final lower = String.fromCharCode(rune).toLowerCase();
    // Keep one-to-one: a lowercase form of a different length is left alone.
    return lower.runes.length == 1 ? lower.runes.single : rune;
  }

  /// Basic Latin, Latin-1, Latin Extended-A/B and Latin Extended Additional.
  static bool _isLatin(int rune) =>
      (rune >= 0x41 && rune <= 0x5A) ||
      (rune >= 0xC0 && rune <= 0x24F && rune != 0xD7 && rune != 0xF7) ||
      (rune >= 0x1E00 && rune <= 0x1EFF);
}
