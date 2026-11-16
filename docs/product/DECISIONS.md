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
| D-10 | 2026-11-16 | UX documents | UX flows, screen specifications and a risk review are to be written before any gameplay or screen implementation. They are drafts until approved (see Q-05). | — |
| D-11 | 2026-11-16 | Production diagnostics | In profile and release builds, an uncaught error is logged as its origin and error type only: no exception message, no stack trace. Debug builds may keep full detail. No `debugPrint` or other console output outside the approved diagnostics implementation, enforced by a source guard test. ADR-0008 itself remains Proposed. | §12 |
| D-12 | 2026-11-16 | Riverpod retry | Riverpod's default automatic retry is not changed now. When persistence is implemented, checkpoint-related providers must use explicit retry behaviour. | §11 |
| D-13 | 2026-11-16 | Theme slot mapping | The Material colour slots not covered by `DESIGN_SYSTEM.md` §7 (`onError`, the private `secondary`/`onSecondary` fallbacks, and others) are left as they are and revisited at the component implementation milestone. | — |
| D-14 | 2026-11-16 | Unexpected-error screen | Not designed or implemented yet. The inventory in ADR-0008 is input for a later specification. | — |
| D-09 | 2026-11-15 | Scope gate | Phases B and C (configuration, architecture, bootstrap, tokens, themes, test infrastructure) are approved. Phase D and all gameplay or screen work stay blocked until final UX flows and screen specifications are approved. | — |

## Open questions

### Blocking gameplay implementation

| ID | Question | Proposal (not approved) | Why it matters |
|---|---|---|---|
| Q-01 | Player-name rules | Maximum 16 characters. Duplicate detection ignores leading and trailing whitespace and collapses internal whitespace. Still to decide: is comparison case-insensitive for Latin names (`Sami` vs `sami`)? Is the limit counted in user-perceived characters (so a letter plus shadda counts once)? | PRD §4 defers to "the approved UX", which does not exist yet. |
| Q-02 | Final-guess edge cases | Under D-01, Latin letter case is **not** folded and an empty guess after trimming counts as an incorrect guess. Confirm both. | Needed for exact, testable matching. |
| Q-03 | At-rest protection of the saved session | App-private storage with backups disabled, the secret stored as a word ID, no database encryption (ADR-0003). | PRD §12 asks for "an appropriate secure local-storage strategy". Encryption adds a dependency and key management; the realistic threat is another player at the table, not device forensics. |
| Q-04 | Screenshot and app-switcher protection scope | **Open.** Three options. **A, private screens only** (used in the drafts): handoff, role ticket, vote, final guess and resume gate are protected; setup, discussion, tally and results can be captured and appear in the app switcher. The protection must be switched on before the first private frame at every paper-to-carbon change. **B, the whole game**, from starting a game until it ends or is left: also covers discussion, tally and results; no switching during a game; players cannot screenshot the result. **C, the whole app**: simplest; nothing can ever be captured. In every option secrets are also removed from the screen whenever the app is paused, because blocking screenshots does not hide what is displayed. | PRD §12 says "sensitive screens". Nothing has been verified on a device. |

### Blocking screen work

| ID | Question | Detail |
|---|---|---|
| Q-05 | Approval of the UX documents | `docs/design/UX_FLOWS.md`, `docs/design/SCREEN_SPECIFICATIONS.md` and `docs/design/UX_RESEARCH_AND_RISKS.md` were drafted on 2026-11-16. They need Product Owner review and approval, together with the decisions under "UX decisions" below, before screens are built. No full-screen renders exist. |
| Q-06 | Icon stroke width | **Evidence:** three documents specify 2.25; all 26 SVG files carry `stroke-width="2"` (Lucide's default); the reference page forces 2.25 on 24 px icons and 2.4 on 20 px icons through CSS, so every approved render shows those values; no token records any stroke. **Recommendation:** set `stroke-width="2.25"` in the 26 files (updating the manifest sizes), decide whether the 2.4 small-icon value is intended, and record both as tokens. **Alternative:** leave the files at 2 and override in the app. Nothing is changed until approved. Detail: `UX_RESEARCH_AND_RISKS.md` §3. |
| Q-07 | Private-theme tokens missing from `colors.json` | **Evidence:** the design-system table, the reference tool (`build_reference.py`) and the built reference page all resolve private `surfaceSunken` to carbonRaised and private error text to coralLight; the first is visible in an approved render (disabled private button), the second has no render. Only the token file omits them. **Recommendation:** add `"surfaceSunken": "{palette.carbonRaised}"` and `"errorText": "{palette.coralLight}"` to `colors.json → private`. No new colour is introduced. Until approved the Dart fields stay null. Detail: `UX_RESEARCH_AND_RISKS.md` §3. |
| Q-08 | Launcher icon below Android 8 | The adaptive icon covers API 26+. API 24–25 would show the default Flutter icon. Either raise `minSdk` to 26 or supply raster PNG exports. |
| Q-09 | Sound | None of the seven sound effects exists. Under D-05 the sound setting is omitted until they are produced; haptics need no assets. Confirm, or schedule sound production. |
| Q-10 | Screen orientation | Layouts are specified for portrait only. Lock the app to portrait? |

### UX decisions raised by the flows and screen specifications (2026-11-16)

Each row gives the option the draft documents use. None is approved.

| ID | Question | Used in the drafts (recommended) | Alternative | Blocks |
|---|---|---|---|---|
| Q-16 | When is the secret word recorded in the cooldown? | On the first "I am {name}" tap of a game. PRD §10 says both "record before the first private role reveal is prepared" and "a game abandoned before the first reveal must not consume a word"; a group that leaves from the first handoff has prepared no reveal. | Record when the game is started on the packs screen (simpler, but a game abandoned at the first handoff consumes a word). | Engine, persistence |
| Q-17 | How do players change the playing order? | Two buttons, "move earlier" and "move later", in the edit-player sheet. Uses existing components only. | Drag and drop in the list (needs a grip icon that is not in the icon set, and is harder with a screen reader). | Players screen |
| Q-18 | What does "the votes" on the result screen mean (PRD §8)? | Counts per player for each ballot. Who voted for whom is never shown. The existing tally component shows counts only. | Also show each player's individual vote after the game. | Tally and results screens |
| Q-19 | Leaving a game from a private screen | No visible control: the handoff specification allows only the name, the position and one button. System back opens the leave dialog; the resume gate also offers "leave". | Add a low-emphasis "leave the game" text button to the handoff. | Handoff screen |
| Q-20 | Can a player look at their word again during the discussion? | No. PRD §5 and §12 require the role to be hidden after acknowledgement and define no way back. | A private "see my role again" path through the handoff; this would be a change to the PRD. | — |
| Q-21 | First launch | The tutorial opens once automatically, then Home. | Open Home directly and leave the tutorial to the "how to play" button. | Home, tutorial |
| Q-22 | Final guess safeguards | A review step ("is this your final answer?") before the single guess is submitted; the confirm button is disabled while the field is empty, so an empty guess cannot be submitted (this narrows Q-02). | Submit directly from the text field. | Final-guess screen, engine |
| Q-23 | Small token and reference mismatches | (1) Use `labelM` (16) where the reference page uses 15 px; (2) the secret word follows the token (72, shrinking to 40), not the reference page (64); (3) the handoff name shrinks to fit instead of by character count; (4) add the 800 ms acknowledge lock and the icon stroke values to the token files; (5) a long name is ellipsized inside the "I am {name}" button; (6) "play again" uses `carbonIn`, not the 220 ms change listed in the interactions table, because it goes from paper to carbon; (7) the ticket's icon stamp is 52 as rendered, while the token `stampSmall` is 56 and is used nowhere; (8) the winner stamp shrinks until its longest word fits the width; (9) shrink-to-fit floors (40, 32) are absolute and applied after text scale. | Decide each differently. | Minor; components |
| Q-24 | New Arabic strings | The screen specifications need 56 strings that are not in the glossary. Drafts are in `SCREEN_SPECIFICATIONS.md` Appendix A, all unreviewed. Merge them into the glossary now, as "Review", so the reviewer has one list? | Keep them in the appendix until the screens are approved. | Derja review |

### Raised by the consistency audit (2026-11-16)

None of these is approved. "Used in the drafts" says what the documents and renders currently show.

| ID | Question | Used in the drafts (recommended) | Alternative | Blocks |
|---|---|---|---|---|
| Q-25 | Role-ticket parity | **Not applied**; the specification still follows the approved render. Proposal: keep the player's name on the top row after the reveal and move the role name into the small caption; reserve a fixed line box for the big text. Measured effect: identical top rows and identical ticket heights at every text scale. Renders: `prv02_proposed_*` beside `prv02_revealed_*`. | Keep the approved layout and accept the tell (role name 71 against 125 wide). | Role ticket |
| Q-26 | Final-guess text details that D-01 does not settle | Strict reading: only the ordinary space is a space; nothing invisible is removed; no Unicode recomposition; no length limit. **Recommendation, needing approval because it extends D-01:** treat all Unicode white-space characters as spaces; remove invisible formatting characters (zero-width joiners and direction marks), which a keyboard or a paste can insert without the player seeing them; compare both sides in the same Unicode composition form; cap the input at a generous length. None of these changes which visible letters match. | Keep the strict reading and rely on content editors to avoid such characters. | Engine, final-guess screen |
| Q-27 | Word count on a pack card | The total of approved words in the pack. The number eligible after the cooldown is never shown, and the cooldown is released silently when it would block a game. | Show both ("60 words, 42 new"), or tell the group when words are about to repeat. | Packs screen |
| Q-28 | Screen readers on private screens | Nothing secret is announced automatically; secret text is spoken only when the player moves focus onto it; names and buttons keep their labels. | (a) Hide secret text from screen readers entirely, which makes the game unplayable without sight. (b) Also show a one-line "use headphones" notice on the handoff when a screen reader is on (needs a new string). | Private screens |
| Q-29 | Secret words too long for one line | Not resolved. Measured: a two-word, 14-character word overflows the ticket even at the minimum size of 40. Proposal: at the minimum size the word may wrap to a second line (render `prv02_proposed_long_word`). | A content rule limiting word length so that every word fits one line (the limit would have to be found by rendering). | Role ticket, results, content rules |
| Q-30 | Layout corrections made to the drafts in this audit | (1) PUB-09 pins only "play again"; "change players or packs" and "home" end the scrolling content. (2) The step pills on PUB-05 and PUB-06 are removed. (3) In OVL-01 the keyboard's "done" key acts as the primary button. (4) On PRV-02 "got it" moves to the pinned area when it would be below the fold. (5) On PRV-04 with the keyboard open only the field and the confirm button are guaranteed visible. (6) Text buttons get a 48 touch target. (7) New keys `handoff.pass_label` and `reveal.role_label_sealed`. | Revert any of them. | The screens concerned |

### Before release

| ID | Question | Detail |
|---|---|---|
| Q-11 | Android application ID | Currently `com.bachar02.impostor_tn`, chosen at bootstrap. It is permanent once published to Google Play. |
| Q-12 | Launcher label | Currently `Impostor TN` (Latin). The Arabic product-name spelling is still under review (glossary key `app.name`). |
| Q-13 | Word content | No word, pack or category data exists. 200–300 words, each with two human reviews, are required. Schema and validator can be built first; content and review status come from the Product Owner. |
| Q-14 | Derja review | 0 of the glossary strings are approved, including the product name used in the wordmark and logo. |
| Q-15 | Device verification | No Android device or emulator has been used yet. Font rendering (ڨ), launcher icon, screenshot blocking and app-switcher cover are unverified. |
