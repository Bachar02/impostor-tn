import 'package:impostor_tn/game/content/word_entry.dart';

/// A selectable group of words (PRD §4, §10). Each word belongs to exactly
/// one pack.
final class WordPack {
  WordPack({
    required this.id,
    required this.title,
    required List<WordEntry> words,
  }) : words = List.unmodifiable(words);

  final String id;

  /// Shown on the pack card.
  final String title;
  final List<WordEntry> words;

  @override
  String toString() => 'WordPack($id, ${words.length} words)';
}

/// The bundled, read-only word content (ADR-0009). Built only by the
/// decoder after validation, so its invariants hold: unique pack and word
/// IDs, tidy text, no answer shared between words.
final class ContentCatalog {
  ContentCatalog({required this.contentVersion, required List<WordPack> packs})
    : packs = List.unmodifiable(packs),
      _wordsById = {
        for (final pack in packs)
          for (final word in pack.words) word.id: word,
      },
      _packOfWord = {
        for (final pack in packs)
          for (final word in pack.words) word.id: pack.id,
      };

  /// Raised with every published change of the catalog file.
  final int contentVersion;
  final List<WordPack> packs;

  final Map<String, WordEntry> _wordsById;
  final Map<String, String> _packOfWord;

  WordEntry? wordById(String id) => _wordsById[id];

  String? packIdOfWord(String wordId) => _packOfWord[wordId];

  WordPack? packById(String id) {
    for (final pack in packs) {
      if (pack.id == id) return pack;
    }
    return null;
  }

  @override
  String toString() =>
      'ContentCatalog(v$contentVersion, ${packs.length} packs)';
}
