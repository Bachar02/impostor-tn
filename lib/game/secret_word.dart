/// The word of one game, as selected from content (PRD §5, §8).
///
/// Holds a secret: [toString] is redacted (PRD §12).
final class SecretWord {
  const SecretWord({
    required this.wordId,
    required this.category,
    required this.canonical,
    this.aliases = const [],
  });

  /// Stable content id; the only part that is persisted (ADR-0003).
  final String wordId;

  /// Shown to every player, including the Impostor.
  final String category;

  /// The word civilians see and the final guess is compared with.
  final String canonical;

  /// Explicitly approved alternative spellings (PRD §8). Never shown.
  final List<String> aliases;

  @override
  String toString() => 'SecretWord(<redacted>)';
}
