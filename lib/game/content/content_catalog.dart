import 'package:impostor_tn/game/content/word_entry.dart';

/// Review state of a pack's Derja label (D-38). The label is both the pack
/// title and the category of every word in the pack.
enum LabelStatus {
  /// Not approved by a Tunisian Derja reviewer; never in a release catalog.
  inReview,

  /// Approved; needs [WordPack.labelReview].
  approved,
}

/// A selectable group of words (PRD §4, §10). Each word belongs to exactly
/// one pack, and a pack is exactly one category: every word's category
/// equals [title] (D-38, checked by `CatalogValidation`).
final class WordPack {
  WordPack({
    required this.id,
    required this.title,
    required this.labelStatus,
    this.labelReview,
    required List<WordEntry> words,
  }) : words = List.unmodifiable(words);

  final String id;

  /// The category label, shown on the pack card.
  final String title;

  final LabelStatus labelStatus;

  /// Opaque reference, kept by the Product Owner, to the Derja review of
  /// [title]. Required when [labelStatus] is [LabelStatus.approved]. Never
  /// created by the app.
  final String? labelReview;

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
