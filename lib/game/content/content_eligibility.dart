import 'package:impostor_tn/game/content/content_catalog.dart';
import 'package:impostor_tn/game/content/word_entry.dart';

/// Which content a build may play (ADR-0009). Release and profile builds use
/// [release]; only debug builds may use [development].
enum ContentChannel { release, development }

/// Which words may enter a game (PRD §10: "do not expose unpublished or
/// unreviewed content in production gameplay").
abstract final class ContentEligibility {
  static bool isPlayable(WordEntry word, ContentChannel channel) =>
      switch (word.status) {
        EditorialStatus.published => word.reviews != null,
        EditorialStatus.development => channel == ContentChannel.development,
        EditorialStatus.draft ||
        EditorialStatus.inReview ||
        EditorialStatus.retired => false,
      };

  /// The playable words of [pack], in catalog order.
  static List<WordEntry> playableWords(WordPack pack, ContentChannel channel) =>
      List.unmodifiable([
        for (final word in pack.words)
          if (isPlayable(word, channel)) word,
      ]);

  /// The number shown on a pack card (Q-27 default: total playable words,
  /// independent of the cooldown). A pack with none is unavailable.
  static int playableCount(WordPack pack, ContentChannel channel) =>
      pack.words.where((word) => isPlayable(word, channel)).length;

  /// The playable words of the selected packs: the candidates of PRD §10.
  /// Unknown pack IDs contribute nothing.
  static List<WordEntry> candidates(
    ContentCatalog catalog,
    Iterable<String> packIds,
    ContentChannel channel,
  ) {
    final selected = packIds.toSet();
    return List.unmodifiable([
      for (final pack in catalog.packs)
        if (selected.contains(pack.id)) ...playableWords(pack, channel),
    ]);
  }
}
