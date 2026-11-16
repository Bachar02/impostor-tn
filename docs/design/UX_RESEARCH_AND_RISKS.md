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
| R-03 | A role is distinguishable at a glance (length of text, layout) | High | Medium | Identical structure; both show one large word and one chip | The role name itself differs in length (مدني vs إمبوستور) and the Impostor's chip is longer. A watcher who sees the screen at all can tell. Structural identity cannot fix that; only not being seen can |
| R-04 | The wrong person taps "I am {name}" and reveals someone else's role | High | Medium | Name shown large; sealed step before reveal with a "back" button | No protection after the reveal tap. PINs or similar would be a new feature and are not proposed |
| R-05 | App switcher or screenshot exposes a secret | High | Low–Medium | `FLAG_SECURE` and neutral cover on private screens; secret removed when the app leaves the foreground | Not built and not verified on any device (Q-04, Q-15) |
| R-06 | A phone call or lock screen interrupts a reveal | Medium | High | Returns to the handoff for the same player; they reveal again | The interrupted player has to repeat two taps |
| R-07 | A screen reader speaks the role or vote aloud | High | Low | None yet | TalkBack on a shared party phone is unlikely but the conflict between accessibility and privacy is real. Needs a Product Owner decision before release; not tested |
| R-08 | Accidental "start voting" ends the discussion early | Low | Medium | Voting can still be discussed over; no vote exists yet | No way back to the discussion screen. Acceptable because the screen only carries instructions |
| R-09 | A player votes for the wrong person by mis-tap | Medium | Medium | Two steps: select, then confirm; selection is clearly marked | No change after confirm (D-02) by design |
| R-10 | The Impostor loses on a typo | Medium | Medium | Review step before the final confirmation (Q-22); autocorrect off | Alias quality (content work) matters more than UI here |
| R-11 | A group cannot leave a stuck game from a private screen | Medium | Low | System back opens the leave dialog; the resume gate offers "leave" | No visible control on the handoff (Q-19). Gesture navigation makes "back" less discoverable |
| R-12 | The public statement that the nominee is the Impostor arrives before the group expects it | Low | Medium | Stated on the tally screen with the reason (one last chance) | Inherent in PRD §8; see A-6 |
| R-13 | Draft Derja strings are unnatural or wrong | Medium | High | Every string is marked for review; 54 new drafts are listed in the specification, Appendix A | Zero strings are reviewed. This is the largest known quality gap |
| R-14 | Long names break layouts | Low | Medium | Ellipsis in rows, shrinking and two lines on the handoff, isolation of mixed-direction names | The 16-character limit is still a proposal (Q-01) |
| R-15 | Text scale above 1.5 pushes the acknowledge button onto the reveal button's position | Medium | Low | 800 ms lock on "got it"; display styles clamped at 1.5 | Verify on a small device at large text |
| R-16 | Dim rooms: the paper screens light up faces and the table | Low | Medium | Accepted trade-off of the Tesskra direction; secrets are only ever on carbon | None |
| R-17 | With few approved words, the same words return quickly | Medium | High at launch | Cooldown of 30 with progressive release (PRD §10) | Content volume, not UX |
| R-18 | Screens have never been drawn as full layouts | Medium | Certain | Every screen is composed only from components that have approved renders | See §4 |

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
| Full-screen renders of the 14 screens | Composition, spacing and vertical rhythm have not been seen by anyone | Extend `reference/index.template.html` with the screens and regenerate the PNGs, before or alongside implementation |
| Carbon renders of dialog, text field, banner | Small visual risk | Same |
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
