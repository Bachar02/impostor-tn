/// Helpers for mixed Arabic / Latin / digit text
/// (`docs/ARABIC_LOCALIZATION.md` §3).
library;

// Built from code points so no invisible direction character ever sits in
// the source file.
final _leftToRightIsolate = String.fromCharCode(0x2066);
final _firstStrongIsolate = String.fromCharCode(0x2068);
final _popDirectionalIsolate = String.fromCharCode(0x2069);

/// Wraps [text] so it renders as one left-to-right run inside RTL text.
///
/// Use for numeric groups such as `2 / 6` or `4–12` and Latin fragments such
/// as `TN`, so their internal order never flips inside an Arabic sentence.
String ltrIsolate(String text) =>
    '$_leftToRightIsolate$text$_popDirectionalIsolate';

/// Wraps user-entered [text] (for example a player name typed in Latin or
/// Arabic) so its direction comes from its own first strong character and it
/// cannot reorder the surrounding sentence.
String directionIsolate(String text) =>
    '$_firstStrongIsolate$text$_popDirectionalIsolate';

final _numberRun = RegExp(r'\d+(?:\s*[–/-]\s*\d+)?');

/// Wraps every number or number range (`4–12`, `3 / 12`) in [text] as an
/// isolated left-to-right run (ARABIC_LOCALIZATION.md §3), so a string that
/// carries its own digits still renders them in order.
String isolateNumberRanges(String text) =>
    text.replaceAllMapped(_numberRun, (m) => ltrIsolate(m[0]!));
