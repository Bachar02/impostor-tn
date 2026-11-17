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
| D-09 | 2026-11-15 | Scope gate | Phases B and C (configuration, architecture, bootstrap, tokens, themes, test infrastructure) are approved. Phase D and all gameplay or screen work stay blocked until final UX flows and screen specifications are approved. Partly superseded by D-31: engine, content, cooldown, persistence and component work is authorized; **screens remain blocked by Q-05**. | — |
| D-10 | 2026-11-16 | UX documents | UX flows, screen specifications and a risk review are to be written before any gameplay or screen implementation. They are drafts until approved (see Q-05). | — |
| D-11 | 2026-11-16 | Production diagnostics | In profile and release builds, an uncaught error is logged as its origin and error type only: no exception message, no stack trace. Debug builds may keep full detail. No `debugPrint` or other console output outside the approved diagnostics implementation, enforced by a source guard test. ADR-0008 itself remains Proposed. | §12 |
| D-12 | 2026-11-16 | Riverpod retry | Riverpod's default automatic retry is not changed now. When persistence is implemented, checkpoint-related providers must use explicit retry behaviour. | §11 |
| D-13 | 2026-11-16 | Theme slot mapping | The Material colour slots not covered by `DESIGN_SYSTEM.md` §7 (`onError`, the private `secondary`/`onSecondary` fallbacks, and others) are left as they are and revisited at the component implementation milestone. | — |
| D-14 | 2026-11-16 | Unexpected-error screen | Not designed or implemented yet. The inventory in ADR-0008 is input for a later specification. | — |
| D-15 | 2026-11-17 | Player names (Q-01) | Maximum 16 user-perceived characters. Trim and collapse whitespace. Duplicate detection is case-insensitive for Latin letters. | §4 |
| D-16 | 2026-11-17 | Final-guess case and empty guess (Q-02) | Letter case is preserved in the final guess (no case folding, as D-01). An empty guess cannot be submitted. | §8 |
| D-17 | 2026-11-17 | Saved session at rest (Q-03) | App-private storage, backups disabled, no encryption. Persist all session data required for recovery (player names, roles, phase, votes, checkpoints). "Word IDs only" applies to the cooldown history, which stores word IDs and nothing else; the session refers to its word by ID as well (PRD §11 "secret word reference"). | §11, §12 |
| D-18 | 2026-11-17 | Screenshot and app-switcher protection (Q-04) | Option **B**: protection for the entire game, from game start until it ends or is left. Not yet verified on a device. | §12 |
| D-19 | 2026-11-17 | Private-theme tokens (Q-07) | Add `surfaceSunken` → `carbonRaised` and `errorText` → `coralLight` to the private colour tokens. Existing design colours only. | §13 |
| D-20 | 2026-11-17 | Orientation (Q-10) | Portrait only. | — |
| D-21 | 2026-11-17 | When the word enters the cooldown (Q-16) | The selected word is recorded in the cooldown atomically on the first "I am {name}" action of a game, before the first role reveal is prepared (checkpoint C2 in `UX_FLOWS.md`). A game abandoned before that action consumes no word. | §10 |
| D-22 | 2026-11-17 | "The votes" on Results (Q-18) | Per-player vote counts per ballot. Never who voted for whom. | §8 |
| D-23 | 2026-11-17 | Leaving from a private screen (Q-19) | System Back opens the leave-game dialog. No visible leave button on the handoff screen. | §12 |
| D-24 | 2026-11-17 | Seeing one's role again (Q-20) | Not possible. Players cannot review their role during the discussion. | §5, §12 |
| D-25 | 2026-11-17 | Final-guess safeguards (Q-22) | A review step before the single guess is submitted; submission is disabled while the field is empty. | §8 |
| D-26 | 2026-11-17 | Drafted strings (Q-24) | Merge the 56 drafted Arabic strings of `SCREEN_SPECIFICATIONS.md` Appendix A into the localization file as `[REVIEW]`. None is approved. | §13 |
| D-27 | 2026-11-17 | Role-ticket parity (Q-25) | Apply the proposed parity layout (renders `prv02_proposed_*`). | §5, §12 |
| D-28 | 2026-11-17 | Audit layout corrections (Q-30) | Apply all seven corrections (1)–(7). | — |
| D-29 | 2026-11-17 | Slice-1 Home (S-1) | How to Play and Settings are deferred to slice 2. Home in slice 1 shows neither button. | §14 |
| D-30 | 2026-11-17 | Final-guess characters (Q-26) | The Q-26 recommendation is **not** approved. D-01 stays exactly as defined: no removal of invisible formatting marks, no broader Unicode normalization. The engine's strict reading (only U+0020 is a space) stays. | §8 |
| D-31 | 2026-11-17 | Development authorization | Implement, in order: content infrastructure, word selection and cooldown, persistence and recovery, design-system components. Screens of the first playable slice wait for Q-05. No backend, accounts, networking, ads or purchases; no invented content. | — |
| D-32 | 2026-11-17 | UX approval for slice 1 (Q-05) | **Approved**: the slice scope and exclusions of `UX_APPROVAL_PACKAGE_SLICE_1.md` §1; `UX_FLOWS.md` sections approved under rows 2.1–2.12 (F2 excluded, waits for slice 2); `SCREEN_SPECIFICATIONS.md` sections approved under rows 3.1–3.15; together with the earlier rulings D-15 to D-30. Q-30 corrections (D-28) and the parity ticket (D-27) apply. Screens outside the slice (PUB-02, PUB-03, PUB-04) are not approved. | — |
| D-33 | 2026-11-17 | Loading indicator on private screens | Static loading dots on carbon screens are accepted (no looping animation, SCREEN_SPECIFICATIONS §1.5). | §12 |
| D-34 | 2026-11-17 | Long secret words (Q-29) | Q-29 stays provisional. Do not reduce the minimum type size or compromise accessibility to fit long words. | §13 |
| D-35 | 2026-11-17 | Development content (Q-13) | Q-13 does not block screens. Development-only synthetic fixtures may be used, with strict safeguards that keep them out of release builds. They are not content and are never reviewed or published. | §10 |
| D-36 | 2026-11-17 | Milestone E | Build the full first playable slice (Home → … → Replay, leave dialog, resume gate, recovery) on the existing engine and persistence; whole-game screenshot protection at the approved boundaries; then run on the `Pixel_XL_API_36` emulator. | — |
| D-37 | 2026-11-17 | Category labels | Pack and category names are simple, recognizable Derja category labels, not creative phrases. Eight initial labels and five later candidates are proposed as display names only (`ARABIC_LOCALIZATION.md` §5.1), all `[REVIEW]`. No pack, word or ID is created for them and no empty pack is published; they are used when real content arrives (Q-13). | §10 |
| D-38 | 2026-11-17 | One category per pack (Q-31) | A pack is exactly one word category: every word in a pack has the same category, and the pack title and that category are the same Derja label. The category is shown on both role tickets and on results (unchanged). Stable IDs and the architecture are kept; the catalog validator rejects a word whose category differs from its pack title. Every pack label has an explicit review status (`labelStatus`, with a `labelReview` reference when approved); an unreviewed label must not appear in release content, so it rejects a release catalog. No words invented, no empty pack published. | §10 |
| D-39 | 2026-11-17 | Category on the role ticket (Q-32) | Exactly two lines are reserved for the category label on both the Civilian and Impostor tickets, so both keep identical dimensions; no font-size reduction, no role-dependent layout; RTL and Tesskra typography kept. Test all 13 proposed labels at 360 and 320 wide with text scale 1.5, with ticket-height parity for every label. Correction to the Q-32 measurement: the taller ticket was the **Civilian's**, because its chip `reveal.category` ("الصنف: …") wrapped; the Impostor's big text had not wrapped. | §5, §13 |

## Open questions

### Open (design)

| ID | Question | Detail |
|---|---|---|
| Q-06 | Icon stroke width | **Evidence:** three documents specify 2.25; all 26 SVG files carry `stroke-width="2"` (Lucide's default); the reference page forces 2.25 on 24 px icons and 2.4 on 20 px icons through CSS, so every approved render shows those values; no token records any stroke. **Recommendation:** set `stroke-width="2.25"` in the 26 files (updating the manifest sizes), decide whether the 2.4 small-icon value is intended, and record both as tokens. **Alternative:** leave the files at 2 and override in the app. Nothing is changed until approved; meanwhile the files are used as shipped. Detail: `UX_RESEARCH_AND_RISKS.md` §3. |
| Q-08 | Launcher icon below Android 8 | The adaptive icon covers API 26+. API 24–25 would show the default Flutter icon. Either raise `minSdk` to 26 or supply raster PNG exports. **2026-11-17: do not change `minSdk` yet.** |
| Q-09 | Sound | None of the seven sound effects exists. Under D-05 the sound setting is omitted until they are produced; haptics need no assets. Confirm, or schedule sound production. |

### UX decisions still open (2026-11-16)

Each row gives the option the draft documents use. None is approved.

| ID | Question | Used in the drafts (recommended) | Alternative | Blocks |
|---|---|---|---|---|
| Q-17 | How do players change the playing order? | Two buttons, "move earlier" and "move later", in the edit-player sheet. Not in slice 1; meanwhile, order of entry. | Drag and drop in the list (needs a grip icon that is not in the icon set, and is harder with a screen reader). | Players screen |
| Q-21 | First launch | The tutorial opens once automatically, then Home. Not in slice 1; meanwhile, Home opens directly. | Open Home directly and leave the tutorial to the "how to play" button. | Home, tutorial |
| Q-23 | Small token and reference mismatches | (1) Use `labelM` (16) where the reference page uses 15 px; (2) the secret word follows the token (72, shrinking to 40), not the reference page (64); (3) the handoff name shrinks to fit instead of by character count; (4) add the 800 ms acknowledge lock and the icon stroke values to the token files; (5) a long name is ellipsized inside the "I am {name}" button; (6) "play again" uses `carbonIn`, not the 220 ms change listed in the interactions table, because it goes from paper to carbon; (7) the ticket's icon stamp is 52 as rendered, while the token `stampSmall` is 56 and is used nowhere; (8) the winner stamp shrinks until its longest word fits the width; (9) shrink-to-fit floors (40, 32) are absolute and applied after text scale. Meanwhile, the drafted resolutions are used. | Decide each differently. | Minor; components |
| Q-27 | Word count on a pack card | The total of approved words in the pack. The number eligible after the cooldown is never shown, and the cooldown is released silently when it would block a game. | Show both ("60 words, 42 new"), or tell the group when words are about to repeat. | Packs screen |
| Q-28 | Screen readers on private screens | Nothing secret is announced automatically; secret text is spoken only when the player moves focus onto it; names and buttons keep their labels. | (a) Hide secret text from screen readers entirely, which makes the game unplayable without sight. (b) Also show a one-line "use headphones" notice on the handoff when a screen reader is on (needs a new string). | Private screens |
| Q-29 | Secret words too long for one line | Not resolved. Measured: a two-word, 14-character word overflows the ticket even at the minimum size of 40. Proposal: at the minimum size the word may wrap to a second line (render `prv02_proposed_long_word`). | A content rule limiting word length so that every word fits one line (the limit would have to be found by rendering). | Role ticket, results, content rules |

### Content

| ID | Question | Detail |
|---|---|---|
| Q-13 | Word content | No word, pack or category data exists. 200–300 words, each with two human reviews, are required. **2026-11-17: no development word list supplied yet; do not invent or publish content.** The schema, loader and validator are built with synthetic test fixtures only (ADR-0009). Until real content arrives, the app has no playable words and starting a game fails with the controlled "no eligible content" error. |

### Before release

| ID | Question | Detail |
|---|---|---|
| Q-11 | Android application ID | Currently `com.bachar02.impostor_tn`, chosen at bootstrap. It is permanent once published to Google Play. |
| Q-12 | Launcher label | Currently `Impostor TN` (Latin). The Arabic product-name spelling is still under review (glossary key `app.name`). |
| Q-14 | Derja review | 0 of the glossary strings are approved, including the product name used in the wordmark and logo. |
| Q-15 | Device verification | No Android device or emulator check of fonts (ڨ), launcher icon, screenshot blocking or app-switcher cover yet. |

### Resolved

Q-05 → D-32 (slice 1), Q-01 → D-15, Q-02 → D-16, Q-03 → D-17, Q-04 → D-18, Q-07 → D-19, Q-10 → D-20, Q-16 → D-21, Q-18 → D-22, Q-19 → D-23, Q-20 → D-24, Q-22 → D-25, Q-24 → D-26, Q-25 → D-27, Q-26 → D-30, Q-30 → D-28, S-1 → D-29, Q-31 → D-38, Q-32 → D-39 (all 2026-11-17).
