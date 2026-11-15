---
name: review-rtl
description: Audit Impostor TN screens and widgets for right-to-left layout, Arabic typography, mixed-direction text, digits and string review status. Use when asked to review RTL, Arabic rendering, localization or bidi issues.
---

# Review RTL and Arabic

Reference: `docs/ARABIC_LOCALIZATION.md` §2–§4 and `.claude/rules/flutter-ui-design.md`.

1. **Static scan** of `lib/` (excluding `lib/l10n/generated/`). Search for and judge each hit:
   - `EdgeInsets.only(`, `EdgeInsets.fromLTRB(`, `Alignment.centerLeft`, `Alignment.centerRight`, `Alignment.topLeft` and similar, `BorderRadius.only(`, `Positioned(left:` / `right:`, `TextAlign.left` / `TextAlign.right`. Directional equivalents are required unless the value is deliberately physical (hard shadows are).
   - `TextDirection.ltr`: allowed only for numeric runs and Latin fragments.
   - String literals shown to users outside `app_ar.arb`.
   - Digits or Latin text interpolated into Arabic strings without `ltrIsolate`; player names without `directionIsolate`.
   - Icons: back uses `arrowRight`, forward uses `chevronLeft`; nothing else mirrors.
2. **Strings.** In `lib/l10n/app_ar.arb` check every entry has a `[REVIEW]` or `[APPROVED]` status, matches the glossary term for its concept, uses `؟` and `،`, Western digits, and one term per concept. List strings that are not in the glossary.
3. **Typography.** Display text uses the Kufi styles with the `wght` variation; body uses Plex; nothing below 12; letter spacing 0. Flag any text containing ڨ ڤ پ that uses a fallback font.
4. **Widget checks.** For each screen in scope ensure a widget test covers: `Directionality` is RTL, no overflow at 320 × 568, at text scale 1.5, and with the long sample name `عبد الرحمان بن عاشور الطرابلسي`. Add the missing tests.
5. **Behaviour.** Progress fills right to left; switch thumb moves left when on; pushed screens enter from the left; the text caret sits at the left end of typed Arabic.
6. **Run** `flutter test` and record the result.

## Output

Findings with `file:line` and the rule broken; strings still awaiting Derja review (count and keys); what could not be verified without a device (real font rendering, ڨ glyph, keyboard behaviour). Never change a string's status to `[APPROVED]`.
