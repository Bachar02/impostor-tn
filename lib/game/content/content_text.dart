import 'package:impostor_tn/game/content/content_issue.dart';

/// Hygiene rules for content text (ADR-0009). They do not change matching
/// (D-01, D-30); they keep out text that no player could type reliably.
abstract final class ContentText {
  /// Null when [text] is acceptable.
  static ContentIssueKind? check(String text) {
    if (text.isEmpty) return ContentIssueKind.emptyText;
    for (final rune in text.runes) {
      if (_isForbidden(rune)) return ContentIssueKind.forbiddenCharacter;
    }
    if (text.trim().isEmpty) return ContentIssueKind.emptyText;
    if (text.startsWith(' ') || text.endsWith(' ') || text.contains('  ')) {
      return ContentIssueKind.untidyText;
    }
    return null;
  }

  static bool _isForbidden(int rune) =>
      rune < 0x20 ||
      (rune >= 0x7F && rune <= 0x9F) ||
      _otherSpaces.contains(rune) ||
      _invisible.contains(rune) ||
      (rune >= 0x2000 && rune <= 0x200F) ||
      (rune >= 0x2028 && rune <= 0x202F) ||
      (rune >= 0x2060 && rune <= 0x206F);

  /// Whitespace other than U+0020 outside the ranges above.
  static const _otherSpaces = {0x00A0, 0x1680, 0x205F, 0x3000};

  /// Soft hyphen, Arabic letter mark, Mongolian vowel separator, BOM.
  static const _invisible = {0x00AD, 0x061C, 0x180E, 0xFEFF};
}
