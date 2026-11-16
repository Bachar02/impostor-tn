import 'package:impostor_tn/game/game_rules.dart';

/// The most recently used distinct word IDs, oldest first (PRD §10).
///
/// Immutable. Always distinct and never longer than
/// [GameRules.cooldownSize]. Word IDs are content references; this type
/// stores nothing else (D-17), and [toString] does not print them.
final class WordCooldown {
  /// Builds a cooldown from stored IDs, keeping the newest occurrence of a
  /// repeated ID and the newest [GameRules.cooldownSize] entries.
  factory WordCooldown(Iterable<String> oldestFirst) {
    final distinct = <String>[];
    for (final id in oldestFirst) {
      distinct
        ..remove(id)
        ..add(id);
    }
    final overflow = distinct.length - GameRules.cooldownSize;
    return WordCooldown._(
      List.unmodifiable(overflow > 0 ? distinct.sublist(overflow) : distinct),
    );
  }

  const WordCooldown._(this.oldestFirst);

  static const empty = WordCooldown._([]);

  final List<String> oldestFirst;

  bool contains(String wordId) => oldestFirst.contains(wordId);

  /// [wordId] as the newest entry. A word already present moves to the
  /// newest position instead of appearing twice (UX_FLOWS §3.4); the oldest
  /// entry falls off when the list is full.
  WordCooldown record(String wordId) => WordCooldown([...oldestFirst, wordId]);

  @override
  bool operator ==(Object other) =>
      other is WordCooldown &&
      other.oldestFirst.length == oldestFirst.length &&
      Iterable<int>.generate(oldestFirst.length)
          .every((i) => other.oldestFirst[i] == oldestFirst[i]);

  @override
  int get hashCode => Object.hashAll(oldestFirst);

  @override
  String toString() => 'WordCooldown(${oldestFirst.length} entries)';
}
