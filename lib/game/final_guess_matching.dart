import 'package:impostor_tn/game/secret_word.dart';

/// Final-guess text forms (D-01, `docs/design/UX_FLOWS.md` §3.3).
///
/// D-01: trim leading and trailing whitespace and collapse repeated internal
/// whitespace; nothing else (no diacritic, tatweel, letter-variant or case
/// folding). Which characters count as whitespace is open (Q-26); until it is
/// decided, the strict reading applies: only U+0020 SPACE.
abstract final class FinalGuessMatching {
  static const _space = ' ';

  /// The guess as shown back to the table: outer spaces removed only.
  static String displayForm(String raw) => _trimSpaces(raw);

  /// The form that is compared: outer spaces removed, inner runs of spaces
  /// reduced to one.
  static String comparisonForm(String raw) =>
      _trimSpaces(raw).replaceAll(RegExp('$_space{2,}'), _space);

  /// Whether [raw] equals the canonical word or an alias, character for
  /// character, after [comparisonForm] on both sides.
  static bool matches(String raw, SecretWord word) {
    final guess = comparisonForm(raw);
    return [
      word.canonical,
      ...word.aliases,
    ].any((accepted) => comparisonForm(accepted) == guess);
  }

  static String _trimSpaces(String text) {
    var start = 0;
    var end = text.length;
    while (start < end && text[start] == _space) {
      start++;
    }
    while (end > start && text[end - 1] == _space) {
      end--;
    }
    return text.substring(start, end);
  }
}
