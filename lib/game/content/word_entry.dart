import 'package:impostor_tn/game/secret_word.dart';

/// Where a word is in the editorial process (PRD §10, ADR-0009).
enum EditorialStatus {
  /// Being written; never playable.
  draft,

  /// Waiting for one or both human reviews; never playable.
  inReview,

  /// Passed both human reviews; the only status playable in a release build.
  published,

  /// Withdrawn; never playable, kept so its ID is never reused.
  retired,

  /// Engineering-only, unreviewed. Playable in debug builds only; a release
  /// catalog containing one is rejected as a whole (ADR-0009).
  development,
}

enum Difficulty { easy, medium, hard }

/// Access model. The MVP has free content only (D-04).
enum AccessStatus { free }

/// The two distinct human reviews a published word needs (PRD §10).
///
/// The values are opaque reviewer references kept by the Product Owner, not
/// names. Nothing in the app creates them.
final class WordReviews {
  const WordReviews({required this.linguistic, required this.editorial});

  /// The Tunisian Derja linguistic review.
  final String linguistic;

  /// The independent gameplay and editorial review.
  final String editorial;

  @override
  String toString() => 'WordReviews(<redacted>)';
}

/// One word record of the content catalog, with the metadata of PRD §10.
///
/// Holds a secret: [toString] is redacted, the ID included, because content
/// IDs may be mnemonic.
final class WordEntry {
  WordEntry({
    required this.id,
    required this.version,
    required this.canonical,
    required List<String> aliases,
    required this.category,
    required this.language,
    required this.access,
    required this.status,
    this.difficulty,
    this.region,
    this.reviews,
  }) : aliases = List.unmodifiable(aliases);

  /// Stable, unique across the catalog, never reused.
  final String id;

  /// Revision of this record; raised whenever its text changes, so a saved
  /// session never resumes with a word that changed under it (ADR-0003).
  final int version;

  final String canonical;

  /// Explicitly approved alternative answers (PRD §8). Never displayed.
  final List<String> aliases;

  /// Shown to every player, the Impostor included.
  final String category;

  /// BCP 47 language tag.
  final String language;

  final AccessStatus access;
  final EditorialStatus status;
  final Difficulty? difficulty;

  /// Region or cultural context, where relevant.
  final String? region;

  /// Required when [status] is [EditorialStatus.published].
  final WordReviews? reviews;

  /// The engine's view of this word for one game.
  SecretWord toSecretWord() => SecretWord(
    wordId: id,
    category: category,
    canonical: canonical,
    aliases: aliases,
  );

  @override
  String toString() => 'WordEntry(<redacted>)';
}
