# ADR-0005: Localization and RTL

Status: Accepted (2026-11-15). Infrastructure implemented; one string exists.

## Context

The app has one language, Tunisian Derja in Arabic script, and one direction, RTL (PRD §13, `docs/ARABIC_LOCALIZATION.md`). No string is approved yet (D-06). Mixed Arabic, Western digits and Latin names must render in the right order.

## Decisions

### Flutter's own localization tooling

`flutter_localizations` and `intl` (both first-party; `intl` resolved to 0.20.3 alongside the SDK) with ARB files and `flutter gen-l10n`. No third-party i18n package.

Even with a single language this is worth having: strings live in one reviewable file instead of being scattered through widgets, placeholders and plurals are type-checked, and the Material widgets get correct Arabic defaults and RTL behaviour.

- Source: `lib/l10n/app_ar.arb`. Template and only locale: `ar`.
- Output: `lib/l10n/generated/` (committed so a fresh checkout analyses cleanly; excluded from analysis; never edited by hand).
- `MaterialApp.locale` is fixed to `ar`. The device language does not change the app.

### Key naming

The glossary uses `<area>.<name>` (for example `reveal.ack`). ARB keys must be Dart identifiers, so the dot form maps to lower camel case: `reveal.ack` → `revealAck`. Each ARB description names its glossary key.

### Review status is part of the data

Every ARB entry has a description starting with `[REVIEW]` or `[APPROVED]`. `test/l10n/arb_status_test.dart` fails if one is missing. Only a human Derja reviewer's decision, relayed by the Product Owner, changes a marker. The release skill lists every remaining `[REVIEW]` string.

The same test rejects `?`, `,` and Eastern Arabic digits in strings.

### RTL

- Layout code uses directional APIs only (`EdgeInsetsDirectional`, `AlignmentDirectional`, `start`/`end`).
- Hard shadows are physical and are not mirrored.
- Directional icons are chosen explicitly (`arrowRight` for back, `chevronLeft` for forward); nothing is auto-mirrored.

### Mixed-direction text

`lib/core/text/bidi.dart` provides two helpers built on Unicode isolates:

- `ltrIsolate` for numeric groups (`2 / 6`, `4–12`) and Latin fragments (`TN`), so they keep their internal order inside an Arabic sentence. The en dash and slash are direction-neutral, so without isolation `4–12` can render as `12–4`.
- `directionIsolate` for user-entered names, which may be Arabic or Latin.

Numeric values are passed into ARB strings as placeholders already wrapped by `ltrIsolate`; digits are never written into Arabic strings by hand at the call site.

## Consequences

- Adding a string is a three-step routine: ARB entry with status, `flutter gen-l10n`, use the generated getter.
- Plural forms (for example `pack.word_count`) will use ICU plural syntax once the reviewer decides the Derja rule.
- Real-device rendering of ڨ ڤ پ in both fonts, line heights and keyboard behaviour remain unverified (Q-15).
