# Impostor TN — UX research and risks

Status: **DRAFT for Product Owner review (Stage 5).**

**No user research has been carried out.** Nobody outside the project has seen or used these flows. This document therefore records assumptions, the risks that follow from them, design inconsistencies found while writing the specifications, and a plan for the testing that still has to happen. It does not report findings.

## 1. Assumptions the flows rest on

| # | Assumption | If it is wrong |
|---|---|---|
| A-1 | Players will look away when the screen turns dark (the paper → carbon signal) | Roles leak at the table; the signal needs reinforcement (sound, wording) |
| A-2 | A player reads the name on the handoff and passes the phone to the right person | The wrong person sees a role. The sealed-ticket "back" button only helps before the reveal |
| A-3 | One tap to reveal and a separate tap to hide, with an 800 ms lock, is deliberate enough and not annoying | Roles skipped by accident, or frustration at the delay |
| A-4 | Groups can run the clue round themselves from three lines of instruction, with no turn tracking (D-03) | Confusion about who speaks next; pressure to add a turn marker |
| A-5 | Players remember their word for the whole discussion | Requests to "see my word again", which the MVP does not allow (Q-20) |
| A-6 | Announcing "{name} is the Impostor" before the final guess feels like part of the game, not a spoiler | The ending feels flat; the order of reveal would need rethinking within what PRD §8 allows |
| A-7 | Six short tutorial cards are enough for people who have never played this kind of game | First games stall; an example round may be needed |
| A-8 | Typing an Arabic word on a phone keyboard, once, is a fair final test | Correct ideas lose to spelling; depends heavily on the quality of the alias lists (D-01) |
| A-9 | Entering up to 12 names through a bottom sheet is fast enough | Setup feels slow; the "sheet stays open in add mode" behaviour is meant to help |
| A-10 | Reordering players is rare enough that two "move" buttons are acceptable (Q-17) | Reordering feels clumsy; drag-and-drop would need a new icon and interaction |

## 2. Risk register

Severity: how bad if it happens. Likelihood is a judgement, not a measurement.

| ID | Risk | Severity | Likelihood | Mitigation in the design | Residual / open |
|---|---|---|---|---|---|
| R-01 | Someone sees another player's role over their shoulder | High | Medium | Carbon ground, privacy hint, nothing secret until a deliberate tap, same layout for both roles | Depends on A-1; test with real groups |
| R-02 | The previous player's secret is still visible when the phone is passed | High | Low | Secret removed in the same frame as "got it"; the app cannot advance without it | None known |
| R-03 | A role is distinguishable at a glance (length of text, layout) | High | Medium | Identical structure; both show one large word and one chip | Measured: the role name on the top row is 76 % wider for the Impostor and is the main tell; ticket heights differ at large text. A minimal fix is proposed (Q-25). Even with it, anyone who reads the screen learns the role |
| R-04 | The wrong person taps "I am {name}" and reveals someone else's role | High | Medium | Name shown large; sealed step before reveal with a "back" button | No protection after the reveal tap. PINs or similar would be a new feature and are not proposed |
| R-05 | App switcher or screenshot exposes a secret | High | Low–Medium | `FLAG_SECURE` and neutral cover on private screens; secret removed when the app leaves the foreground | Not built and not verified on any device (Q-04, Q-15) |
| R-06 | A phone call or lock screen interrupts a reveal | Medium | High | Returns to the handoff for the same player; they reveal again | The interrupted player has to repeat two taps |
| R-07 | A screen reader speaks the role or vote aloud | High | Low | Proposed (Q-28): nothing secret is announced automatically; secret text is spoken only when the player moves focus onto it | A player using the speaker can still expose their own role. Not tested with TalkBack |
| R-08 | Accidental "start voting" ends the discussion early | Low | Medium | Voting can still be discussed over; no vote exists yet | No way back to the discussion screen. Acceptable because the screen only carries instructions |
| R-09 | A player votes for the wrong person by mis-tap | Medium | Medium | Two steps: select, then confirm; selection is clearly marked | No change after confirm (D-02) by design |
| R-10 | The Impostor loses on a typo | Medium | Medium | Review step before the final confirmation (Q-22); autocorrect off | Alias quality (content work) matters more than UI here |
| R-11 | A group cannot leave a stuck game from a private screen | Medium | Low | System back opens the leave dialog; the resume gate offers "leave" | No visible control on the handoff (Q-19). Gesture navigation makes "back" less discoverable |
| R-12 | The public statement that the nominee is the Impostor arrives before the group expects it | Low | Medium | Stated on the tally screen with the reason (one last chance) | Inherent in PRD §8; see A-6 |
| R-13 | Draft Derja strings are unnatural or wrong | Medium | High | Every string is marked for review; 56 new drafts are listed in the specification, Appendix A | Zero strings are reviewed. This is the largest known quality gap |
| R-14 | Long names break layouts | Low | Medium | Ellipsis in rows, shrinking and two lines on the handoff, isolation of mixed-direction names | The 16-character limit is still a proposal (Q-01) |
| R-15 | "Got it" lands where "show me my role" was, so a double tap skips the role | Medium | Medium on small phones | 800 ms lock on "got it" | Measured: the two buttons overlap in position by 43 at 320 × 568 and by 25 at 360 × 720 with text scale 1.5; they are separate only on screens about 645 high or more. The lock is the only protection there |
| R-16 | Dim rooms: the paper screens light up faces and the table | Low | Medium | Accepted trade-off of the Tesskra direction; secrets are only ever on carbon | None |
| R-17 | With few approved words, the same words return quickly | Medium | High at launch | Cooldown of 30 with progressive release (PRD §10) | Content volume, not UX |
| R-18 | Screens had never been drawn as full layouts | Medium | Was certain | Full-screen reference renders now exist for 15 of the 16 screens and overlays (all but the licence page) in 52 states | They are browser renders, not the app; device behaviour is unverified (§7.7) |

## 3. Design inconsistencies found

### Q-06 — Icon stroke width

**Evidence**

| Source | Says |
|---|---|
| `DESIGN_SYSTEM.md` §3 and §6, `DESIGN_DIRECTION.md` §2 | Stroke 2.25 |
| All 26 files in `assets/icons/` | `stroke-width="2"` (the upstream Lucide default; `ic_alert.svg`, drawn for this project, also has 2) |
| `reference/index.template.html` line 32 | CSS forces `stroke-width: 2.25` on 24 px icons |
| The same file, line 33 | CSS forces `stroke-width: 2.4` on 20 px icons, which is 2.0 px on screen after scaling. This value is not mentioned in any document or token |
| `reference/png/01` to `12` (the approved renders) | Produced from that HTML, so they show 2.25 and 2.4 |
| `tokens/*.json`, `ASSET_MANIFEST.json` | No stroke value at all |

**Reading.** The intended look is 2.25: three documents and every approved render agree. The files simply kept Lucide's default because the reference page overrode it in CSS. The app has no such override, so today it draws thinner icons than the approved renders.

**Recommendation.** Make the files carry the intended value: change `stroke-width` to `2.25` in the 26 SVGs, update their sizes in the manifest, and remove the then-redundant CSS override for the 24 px case. For the small size, decide whether the 2.4 override is intended (it keeps small icons at a 2 px visual stroke) and, if so, record both numbers as tokens. Nothing is changed until approved, because it alters 26 approved assets.

**Alternative.** Keep the files at 2 and have the app override the stroke at render time. This keeps upstream files untouched but leaves the real value in code instead of in the design package.

### Q-07 — Carbon-theme colours missing from the token file

**Evidence**

| Source | `surfaceSunken` (private) | Error text (private) |
|---|---|---|
| `tokens/colors.json → private` | Not defined | Only `error` = coralLight; no `errorText` |
| `DESIGN_SYSTEM.md` §1 semantic table | carbonRaised | coralLight (one value for both "error" and "errorText") |
| `tools/build_reference.py` (private mapping) | Uses `private.surface`, which is carbonRaised | Uses `private.error`, which is coralLight |
| Built `reference/index.html` | `--sunken: #1E2942` (= carbonRaised) | `--error-text: #FF8A7A` (= coralLight) |
| Approved renders | `03_buttons` shows the disabled private button with this fill | No render shows an error on carbon |

Contrast on the affected surfaces (computed with the formula in `build_reference.py`): coralLight on carbon 7.40, coralLight on carbonRaised 6.32; carbonOutline (disabled text) on carbonRaised 3.25, which is acceptable only because disabled text is exempt and must never carry essential information.

**Reading.** Both values exist already; the token file omitted two keys that the design system table and the reference tool both resolve the same way. `surfaceSunken` is confirmed by an approved render. The error-text value is consistent across the document and the tool but has never been rendered.

**Recommendation.** Add to `colors.json → private`: `"surfaceSunken": "{palette.carbonRaised}"` and `"errorText": "{palette.coralLight}"`. No new colour is introduced. After approval, add a small error banner on carbon to the reference page so the value has a render. Until approved, the specifications name the two palette colours explicitly wherever they are needed.

### Other mismatches (grouped under Q-23)

| # | Finding | Evidence | Recommendation |
|---|---|---|---|
| 1 | Three elements use 15 px text, which is not a type token: ticket chip, privacy hint, role tag | `index.template.html` lines 107, 109, 117 | Use `labelM` (16), or add a token; specifications currently say `labelM` |
| 2 | The reference draws the secret word at 64 / 48 / 40; the token `displayXL` is 72 with a minimum of 40 | Template line 105–106 vs `typography.json` | The token file wins: 72 shrinking to 40. In practice most words will shrink on a phone-width ticket |
| 3 | The handoff name steps 48 → 36 → 32 by character count (more than 7, more than 12) in the demo script | Template line 287 | Shrink to fit the width instead of counting characters; the three sizes match `DESIGN_SYSTEM.md` |
| 4 | The 800 ms acknowledge lock exists only in prose | `INTERACTIONS_AND_ANIMATIONS.md` §5; not in `animations.json` | Add it to `animations.json` |
| 5 | Icon stroke values have no token | See Q-06 | Add with Q-06 |
| 6 | The handoff button label has no specified minimum size when the name is long | Not specified anywhere | Decide: ellipsize the name at full label size (simplest) |
| 7 | The design system specifies a "locked" pack state and a "change speaking turn" interaction | `DESIGN_SYSTEM.md` §5, `INTERACTIONS_AND_ANIMATIONS.md` §3 | Out of the MVP by D-04 and D-03; mark them so in those documents |
| 8 | Sound cues are named for many interactions but no sound exists | `animations.json`, manifest "notProduced" | MVP is silent (D-05); haptics remain |
| 9 | Dialog and text field are only rendered on paper | `reference/png/04`, `06` | Their carbon versions (OVL-02, PRV-04) are derived from the same tool mapping; add renders |

## 4. What is still missing from the design package

| Missing | Effect | Suggested next step |
|---|---|---|
| Device verification of the layouts | Renders now exist (`reference/png/screens/`), but only as browser compositions | Check the constrained screens on a small and a large phone once they are built |
| Approval of the carbon dialog, text field and error banner | Now rendered (`ovl02_leave_carbon`, `prv04_*`, `prv02_save_error`) from derived values | Review with Q-07 |
| Reviewed Arabic | Blocks release, not development | Derja review of the glossary and Appendix A |
| Tutorial illustrations | Tutorial uses icons | Decide whether icons are enough for the MVP |
| Sounds | App is silent | Product decision (Q-09) |
| Clickable prototype of the full game | No way to test flows before code | The implemented app with test content can serve as the prototype |

## 5. PRD requirements the UX documents do not settle

| PRD | Requirement | Why it is not covered here |
|---|---|---|
| §10 | 200–300 curated words with two human reviews each | Content and editorial work; no data exists (Q-13) |
| §12 | `FLAG_SECURE`, app-switcher protection, verified on real devices | Specified as behaviour, but implementation and device verification are pending (Q-04, Q-15) |
| §12 | Secure local-storage strategy | Engineering decision (ADR-0003, Q-03) |
| §13 | Human-reviewed Tunisian wording | 0 strings reviewed |
| §13 | Font rendering and glyph coverage on devices | Not verified on hardware |
| §15 | Legibility in bright and dim environments; one-handed use | Needs testing with people |
| §16 | Playtests with three distinct groups | Not started |
| §4 | Exact name-uniqueness and length rules | Proposed only (Q-01) |

## 6. Validation plan (not yet executed)

**Before implementation**: Product Owner walkthrough of `UX_FLOWS.md` and the open decisions; Derja review of strings.

**With the first playable build** (test content clearly labelled as such): one moderated session per group, 4–6 people, one phone.

| Task | Observe | Linked risks |
|---|---|---|
| Set up a game for the people present, without help | Time to first handoff; errors adding names | A-9, R-14 |
| Deal the roles | Does everyone look away? Does anyone see a role that is not theirs? Any double-tap skips? | A-1, A-2, A-3, R-01, R-04 |
| Interrupt one reveal (lock the phone) | Do they recover without help? | R-06 |
| Play the clue round | Do they know what to do and who starts? Does anyone ask to see their word again? | A-4, A-5 |
| Vote, including a forced tie | Is the runoff understood? Any mis-votes? | R-09 |
| Final guess | Reaction to the public "is the Impostor" moment; typing problems | A-6, A-8, R-10, R-12 |
| Read the result and play again | Is the outcome clear? Is replay one tap? | — |
| Leave a game midway | Can they find how? | R-11 |

Record per session: group size, ages, device, lighting, whether a privacy leak happened, and where anyone hesitated for more than a few seconds. Repeat until three distinct groups have played (PRD §16).

**On devices**: small phone (about 320–360 dp wide) and large phone; text scale 1.0, 1.3, 1.5 and the maximum; "remove animations" on; screenshots and the app switcher on every private screen; TalkBack on the role ticket (R-07).

## 7. Consistency audit (2026-11-16)

A review of the draft documents against each other, the PRD, the design system, the tokens and new full-screen renders. It is a desk review plus browser measurements. **It is not user research and nothing was run on a device.**

### 7.1 Role privacy and visual parity

The Civilian and Impostor tickets are structurally identical but not indistinguishable. Measured differences and the proposed minimum change (Q-25) are in `SCREEN_SPECIFICATIONS.md`, PRV-02. In short: the ticket size, colours, icon and button are the same; the role name on the top row is the one tell that works at a glance (71 against 125 wide in the heaviest type); at text scale 1.5 the two tickets also differ in height by 25. Keeping the player's name on the top row and reserving a fixed line box for the big text removes both. The big text, the small caption and the chip still differ, and anyone who can actually read the screen learns the role. No claim of indistinguishability is made.

### 7.2 Persistence and recovery

| Issue found | Resolution in the drafts |
|---|---|
| The final guess was "stored normalized" but "shown as typed" | Three forms are now defined (raw, display, comparison). Raw is stored; display is shown in the review step and on the results; comparison decides (`UX_FLOWS.md` §3.3) |
| "Play again" ended the old session and started a new one as two steps, yet promised the result would stay visible if the start failed | One atomic step, C9 |
| Retry behaviour after a failed save was only described for acknowledgements | Rules and a per-checkpoint table for interruption before, after, and retry (`UX_FLOWS.md` §3.1) |
| C2 was tied to "the first handoff", which breaks after a failed attempt or a restart | Tied to the session's "word consumed" mark |
| Releasing a word from the cooldown and then recording it could list it twice | Recording moves an existing entry to the newest position |
| Nothing said how a restore proves that no player is skipped | Restore checks listed (`UX_FLOWS.md` §3.2): acknowledgements must be an unbroken run in playing order |
| Warm-return table missed saves in progress on the vote and guess screens, the resume gate and the leave dialog | Table completed (F11) |
| A group could be trapped on a save error on the role ticket, where back did nothing | Back opens the leave dialog in the error state |
| What counts as a space, invisible characters, and Unicode composition are not defined by D-01 | Not resolved: Q-26. The strict reading applies until decided |

### 7.3 Pack availability

Two numbers were being confused: a pack's total of approved words and the words eligible after the cooldown. The card now shows the total only; the eligible number is never shown, because the cooldown releases its oldest entry automatically and never blocks a game. The "no eligible word" error was reworded: it can only mean "no approved word at all". The selection algorithm is written out in `UX_FLOWS.md` §3.4. Open: Q-27.

### 7.4 Accessibility and privacy

- **Screen readers.** Proposed rule (Q-28): private screens announce nothing secret by themselves; secret text is read only when the player moves focus onto it. This keeps the game playable with TalkBack and headphones without the phone speaking a role to the room. It does not stop a player with the speaker on from exposing their own role. Untested.
- **Screenshot and app-switcher protection.** Q-04 is still open; the three possible scopes and what each covers are now listed there. Independent of the scope, secrets are removed whenever the activity is paused.
- **System back.** F10 is now a table covering every screen and state. Two entries were wrong or missing before: PUB-09 (back does nothing) and the final-guess review state (back returns to entry).
- **Interruptions.** "Leaves the foreground" is now defined (activity paused). The notification shade and volume controls do not pause the activity, so a secret stays visible under them; this is accepted and unverified.
- **Screen timeout.** The app does not keep the screen awake. A phone that locks during a reveal returns to the handoff; during the discussion it returns to the same public screen.

### 7.5 Layout feasibility

Method and limits are described in `SCREEN_SPECIFICATIONS.md`, Appendix C. Findings:

| Screen | Finding | Status |
|---|---|---|
| OVL-01 + keyboard | At 320 × 568 the primary button is cut off; in edit mode only the title and field are visible | Spec corrected: the keyboard's "done" key acts as the primary button; the sheet scrolls |
| PRV-02 | "Show" and "got it" overlap in position by 43 at 320 × 568; "got it" is below the fold at scale 1.5 | Spec corrected: the 800 ms lock is the protection; "got it" moves to the pinned area when it would not be visible |
| PRV-02 | A two-word secret word overflows at the minimum size | Open: Q-29 |
| PRV-03, 12 players | 2 rows visible on arrival at 320 × 568, 1 at scale 1.5 | Spec corrected (it said "about three"). Usable, not good |
| PRV-04 + keyboard | At 320 × 568 the text field is completely hidden behind the pinned button | Spec corrected: field and button are guaranteed; the heading scrolls away |
| PUB-09 | Three pinned buttons left 280 of height for about 1700 of content at 320 × 568 | Draft changed: only "play again" is pinned |
| PUB-09 | Winner stamp wider than the screen at 320, scale 1.5 | Rule added to Q-23 |
| PRV-01 | A 30-character name takes three lines at 320 wide; a 16-character name fits on one | Depends on Q-01 |
| PUB-08 | The outcome block is below the fold with six players | Spec: scrolled into view after the count |
| Text button | Drawn 44 high against a 48 minimum target | Spec: tappable area extended |

### 7.6 Disagreements between documents

| # | Sources | Disagreement | Handling |
|---|---|---|---|
| 1 | `INTERACTIONS_AND_ANIMATIONS.md` §3 vs §4 | "Play again" is a 220 ms standard screen change, but it goes from paper to carbon, which §4 says always uses `carbonIn` (520 ms) | Specs use `carbonIn`. Added to Q-23 |
| 2 | `DESIGN_SYSTEM.md` §5, reference CSS vs `spacing.json` | The ticket's icon stamp is 52; the token `stampSmall` is 56 and no document says what it is for | Specs use 52 as rendered. Added to Q-23 |
| 3 | `DESIGN_SYSTEM.md` §3 | Text button height 44 vs minimum touch target 48 | Visual 44, target 48 |
| 4 | `DESIGN_DIRECTION.md` principle 3 vs approved render `12_demo_revealed` | "Every private screen states whose turn it is"; the revealed ticket shows no name | Resolved if Q-25 is approved |
| 5 | Glossary `handoff.pass_to` vs approved render `07_private` | The key includes the name; the render shows the label and the name as separate lines | New key `handoff.pass_label` |
| 6 | Glossary `reveal.role_label` | The note says the sealed state uses a different word but gives it no key | New key `reveal.role_label_sealed` |
| 7 | First draft of the specs | A step pill "1 / 2" next to the player count "3 / 12" | Step pills removed |
| 8 | First draft of the specs, PRV-01 | "Identical for reveal, voting, runoff and final guess" while the final-guess handoff has no position pill | Wording corrected |
| 9 | `DESIGN_SYSTEM.md` §5, `INTERACTIONS_AND_ANIMATIONS.md` §3 | Locked packs, speaking turns and sounds are specified but excluded from the MVP | Already listed in the handoff §9; the source documents are unchanged |
| 10 | Q-02 vs Q-22 | "An empty guess is incorrect" vs "an empty guess cannot be submitted" | Q-22 narrows Q-02; both stay open |

The approved Stage 2 documents (`DESIGN_SYSTEM.md`, `DESIGN_DIRECTION.md`, `INTERACTIONS_AND_ANIMATIONS.md`), the tokens and the PRD were not edited.

### 7.7 Still unverified

- Everything on a real device: fonts, keyboard heights, navigation insets, cut-outs, lifecycle boundaries, screenshot blocking, the app switcher, TalkBack.
- Flutter's text layout against the browser's (line breaks and shrink-to-fit can differ by a few pixels).
- The assumed keyboard heights (260 and 300). A taller keyboard makes OVL-01 and PRV-04 tighter.
- Any of this with people.
