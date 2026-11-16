# Impostor TN — Product decisions and open questions

This log records Product Owner rulings that clarify the PRD, and questions still waiting for a ruling. It does not replace or amend `PRD.md`; where they seem to conflict, stop and ask.

Rule for engineers: an item under "Open questions" is **not** decided. Do not implement it as if it were.

## Decided

| ID | Date | Topic | Decision | PRD reference |
|---|---|---|---|---|
| D-01 | 2026-11-15 | Final-guess normalization | Trim leading and trailing whitespace and collapse repeated internal whitespace. Nothing else: no automatic stripping of Arabic diacritics or tatweel, no letter-variant folding. Legitimate variants are added as curated aliases. | §8 |
| D-02 | 2026-11-15 | Vote correction | A submitted vote cannot be changed. | §7 |
| D-03 | 2026-11-15 | Speaking turns | No turn tracking in the MVP. The "change speaking turn" interaction in `INTERACTIONS_AND_ANIMATIONS.md` is not implemented. | §6 |
| D-04 | 2026-11-15 | Locked packs | No premium or locked-pack functionality in the MVP. The "locked" pack-card state in the design system is not built. | §3, §10 |
| D-05 | 2026-11-15 | Settings | Sound and haptics settings exist only if the feature and its assets actually exist. No sound assets are invented. See Q-09. | §14 |
| D-06 | 2026-11-15 | Arabic copy | Every string stays provisional until reviewed by a Tunisian Derja speaker. Enforced by the `[REVIEW]` / `[APPROVED]` marker on each ARB entry. | §13 |
| D-07 | 2026-11-15 | Design package location | The design package stays under `docs/design/`. All references were updated to that path. | — |
| D-08 | 2026-11-15 | Git | Only the Product Owner runs Git commands. Engineers and agents provide the commands and wait. | — |
| D-09 | 2026-11-15 | Scope gate | Phases B and C (configuration, architecture, bootstrap, tokens, themes, test infrastructure) are approved. Phase D and all gameplay or screen work stay blocked until final UX flows and screen specifications are approved. | — |

## Open questions

### Blocking gameplay implementation

| ID | Question | Proposal (not approved) | Why it matters |
|---|---|---|---|
| Q-01 | Player-name rules | Maximum 16 characters. Duplicate detection ignores leading and trailing whitespace and collapses internal whitespace. Still to decide: is comparison case-insensitive for Latin names (`Sami` vs `sami`)? Is the limit counted in user-perceived characters (so a letter plus shadda counts once)? | PRD §4 defers to "the approved UX", which does not exist yet. |
| Q-02 | Final-guess edge cases | Under D-01, Latin letter case is **not** folded and an empty guess after trimming counts as an incorrect guess. Confirm both. | Needed for exact, testable matching. |
| Q-03 | At-rest protection of the saved session | App-private storage with backups disabled, the secret stored as a word ID, no database encryption (ADR-0003). | PRD §12 asks for "an appropriate secure local-storage strategy". Encryption adds a dependency and key management; the realistic threat is another player at the table, not device forensics. |
| Q-04 | Screenshot protection scope | Apply `FLAG_SECURE` only while a private screen is shown (ADR-0006). Alternative: for the whole app, which is simpler and safer but stops players sharing the result screen. | PRD §12 says "sensitive screens". |

### Blocking screen work

| ID | Question | Detail |
|---|---|---|
| Q-05 | UX flows and screen specifications | `docs/UX_FLOWS.md` and `docs/SCREEN_SPECIFICATIONS.md` do not exist. The design handoff is a Stage 2 draft produced without the PRD. |
| Q-06 | Icon stroke width | `DESIGN_SYSTEM.md` §6 specifies stroke 2.25. The 26 SVG files have `stroke-width="2"`; the reference HTML overrides it with CSS. The app currently renders the files as they are (2). Should the files be re-exported at 2.25? |
| Q-07 | Private-theme tokens missing from `colors.json` | `DESIGN_SYSTEM.md` §1 lists `surfaceSunken` (carbonRaised) and error text (coralLight) for the private theme, but `colors.json → private` defines neither. The token file wins, so the Dart fields are null. Add them to the JSON? |
| Q-08 | Launcher icon below Android 8 | The adaptive icon covers API 26+. API 24–25 would show the default Flutter icon. Either raise `minSdk` to 26 or supply raster PNG exports. |
| Q-09 | Sound | None of the seven sound effects exists. Under D-05 the sound setting is omitted until they are produced; haptics need no assets. Confirm, or schedule sound production. |
| Q-10 | Screen orientation | Layouts are specified for portrait only. Lock the app to portrait? |

### Before release

| ID | Question | Detail |
|---|---|---|
| Q-11 | Android application ID | Currently `com.bachar02.impostor_tn`, chosen at bootstrap. It is permanent once published to Google Play. |
| Q-12 | Launcher label | Currently `Impostor TN` (Latin). The Arabic product-name spelling is still under review (glossary key `app.name`). |
| Q-13 | Word content | No word, pack or category data exists. 200–300 words, each with two human reviews, are required. Schema and validator can be built first; content and review status come from the Product Owner. |
| Q-14 | Derja review | 0 of the glossary strings are approved, including the product name used in the wordmark and logo. |
| Q-15 | Device verification | No Android device or emulator has been used yet. Font rendering (ڨ), launcher icon, screenshot blocking and app-switcher cover are unverified. |
