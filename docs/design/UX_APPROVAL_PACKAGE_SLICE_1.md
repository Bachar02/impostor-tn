# UX approval package: first playable slice

Prepared 2026-11-16 for the Product Owner. **Nothing in this file is approved.** It collects, in one place, what must be ruled on before the screens of the first playable slice are built (D-09, Q-05). It does not change the draft documents; it points into them.

**How to use it:** mark each row **A** (approve as written), **C** (approve with the change you write in the row) or **R** (reject). Rulings are then recorded in `docs/product/DECISIONS.md`, and only then does screen work start.

Renders are in `docs/design/reference/png/screens/`, named `<state>__<width>x<height>[_ts150].png`. Open `docs/design/reference/screens.html` in a browser for an index. The renders are browser compositions with mock content, not the app and not a device (`SCREEN_SPECIFICATIONS.md` Appendix C).

## 1. Slice scope

Home → Players → Packs → Handoff ⇄ Role ticket → Discussion → Handoff ⇄ Vote → Vote tally (→ runoff, or → final guess) → Results → Play again. Also in the slice: the leave-game dialog, the resume gate, and recovery after the app is closed.

**Not in the slice:**

- PUB-02 How to play
- PUB-03 Settings
- PUB-04 Licences
- reordering players (Q-17)
- the first-launch tutorial (Q-21)

| # | Ruling | A / C / R |
|---|---|---|
| 1.1 | The slice scope above | |
| 1.2 | **S-1**: in slice 1, Home shows no "How to play" or "Settings" buttons; they arrive with their screens in slice 2. *Alternative:* build PUB-02 and PUB-03 now. | |

## 2. Flows (`docs/design/UX_FLOWS.md`, revision 2)

| # | Section | What approving it fixes | A / C / R |
|---|---|---|---|
| 2.1 | §1 Screen inventory and §2 Overview | The 14 screens and 2 overlays and how they connect | |
| 2.2 | §3 Checkpoints C0–C9, §3.1 Retries, §3.2 Restore rules | What is saved at each step, and that restore never repairs or redraws. The engine already follows §3.2: acknowledgements and votes are in playing order, and only the next pending player may act | |
| 2.3 | §3.3 Final-guess forms (raw, display, comparison) | What is stored, shown and compared (D-01) | |
| 2.4 | F1 Launch | Includes the "could not be restored" path | |
| 2.5 | F3 Setup | | |
| 2.6 | F4 Role reveal | Separate reveal and acknowledge actions; neutral handoff between players | |
| 2.7 | F5 Discussion | | |
| 2.8 | F6 First ballot, F7 Runoff | | |
| 2.9 | F8 Final guess | | |
| 2.10 | F9 Results and replay | | |
| 2.11 | F10 System back and leaving | | |
| 2.12 | F11 Interruption and recovery | | |

F2 (help and settings) waits for slice 2.

## 3. Screens (`docs/design/SCREEN_SPECIFICATIONS.md`, revision 2)

| # | Spec | Screen | Renders to open (360 × 720 first, then `320x568` and `_ts150`) | A / C / R |
|---|---|---|---|---|
| 3.1 | §1 | Conventions for every screen: frame, app bar, text, buttons, private wrapper, errors, small screens, motion | — | |
| 3.2 | PUB-01 | Home | `pub01_home`, `pub01_home_restore_failed` | |
| 3.3 | PUB-05 | Players | `pub05_players_empty`, `_three`, `_six`, `_twelve` | |
| 3.4 | OVL-01 | Edit player sheet | `ovl01_add_keyboard`, `ovl01_edit_keyboard`, `ovl01_edit_duplicate`, `ovl01_edit_no_keyboard` | |
| 3.5 | PUB-06 | Packs | `pub06_packs`, `pub06_packs_none_selected` | |
| 3.6 | PRV-01 | Handoff | `prv01_handoff`, `_16_chars`, `_long_name`, `_final_guess` | |
| 3.7 | PRV-02 | Role ticket | `prv02_sealed`, `_revealed_civilian`, `_revealed_impostor`, `_saving`, `_save_error` (see 4.9 for the proposed variant) | |
| 3.8 | PUB-07 | Discussion | `pub07_discussion` | |
| 3.9 | PRV-03 | Vote | `prv03_vote_12_none`, `_12_selected`, `_6_selected`, `_long_voter`; `prv03_runoff_candidate`, `prv03_runoff_non_candidate`, `prv03_save_error` | |
| 3.10 | PUB-08 | Vote tally | `pub08_tally_a_nominee`, `_b_impostor`, `_c_tie`, `_d_runoff_tie`, `_12_players` | |
| 3.11 | PRV-04 | Final guess | `prv04_guess_empty`, `_typed`, `_review` | |
| 3.12 | PUB-09 | Results | `pub09_results_civilians_win`, `_impostor_wins`, `_draw`, `_12_players` | |
| 3.13 | OVL-02 | Leave-game dialog | `ovl02_leave_paper`, `ovl02_leave_carbon` | |
| 3.14 | PRV-05 | Resume gate | `prv05_resume_gate` | |
| 3.15 | Appendix A | The draft strings these screens use, merged into the ARB file as `[REVIEW]` (**Q-24**). Nothing becomes `[APPROVED]` | — | |

**Known layout limits** (from Appendix C, for your judgement while reviewing):

- At 320 × 568 with text scale 1.5, "Got it" on the role ticket is 50 below the fold. Q-30 (4) moves it into the pinned area.
- With the keyboard open, the edit sheet shows only its title and field.
- The final-guess field is hidden until scrolled on small screens.

## 4. Decisions the slice needs

Each row gives the option the drafts use or the recommended default. None is applied.

| # | ID | Question | Recommended | Trade-off | A / C / R |
|---|---|---|---|---|---|
| 4.1 | Q-01 | Player-name rules | Max 16 user-perceived characters; duplicates compared after trimming and collapsing spaces, case-insensitive for Latin letters | Avoids "Sami"/"sami" confusion at the table; rejects deliberate case-only names | |
| 4.2 | Q-02 | Empty guess and letter case | No case folding (D-01). An empty guess cannot be submitted (Q-22); if one reached the engine it would count as incorrect, which is how the engine behaves today | — | |
| 4.3 | Q-22 | Final-guess safeguards | A review step before the single guess; confirm disabled while the field is empty | One extra tap | |
| 4.4 | Q-26 | Characters D-01 does not settle | Every kind of whitespace counts as a space; invisible formatting marks removed; same Unicode form on both sides; input capped (64) | Extends D-01. Without it, an invisible mark from a keyboard can make a correct guess fail. The engine applies the strict reading until this is ruled | |
| 4.5 | Q-16 | When the word enters the cooldown | First "I am {name}" tap of the game (checkpoint C2) | One extra checkpoint; satisfies both PRD §10 sentences | |
| 4.6 | Q-03 | Saved session at rest | No encryption; app-private storage; backups off; word stored as an ID | Encryption guards against a rooted device, not the table | |
| 4.7 | Q-04 | Screenshot and app-switcher protection | **B**, the whole game | Fewer protection switches to get right; results cannot be screenshotted | |
| 4.8 | Q-07 | Two private-theme tokens | Add `surfaceSunken` → carbonRaised and `errorText` → coralLight, as the design already renders | No new colour | |
| 4.9 | Q-25 | Role-ticket parity | Apply the proposal: renders `prv02_proposed_sealed`, `_civilian`, `_impostor`, `_long_word` | The approved layout lets the ticket width reveal the role | |
| 4.10 | Q-18 | "The votes" on Results | Counts per player per ballot; never who voted for whom | Avoids post-game friction | |
| 4.11 | Q-19 | Leaving from a private screen | System back opens the leave dialog; no visible button on the handoff | Hidden, but the handoff stays neutral | |
| 4.12 | Q-30 | Layout corrections (1)–(7) made in the audit | Keep all seven | — | |
| 4.13 | Q-10 | Orientation | Lock to portrait | All layouts are portrait | |
| 4.14 | Q-13 | Words for development | A development-only pack of about 20 words **supplied by the Product Owner**, marked unreviewed; a test fails if it can reach a release build | Engineers may not invent words (CLAUDE.md rule 4) | |
| 4.15 | Q-20 | Seeing your role again | No (matches PRD §5, §12) | — | |

## 5. Deferred, with the default used meanwhile

| ID | Default until ruled |
|---|---|
| Q-06 icon stroke | Files as shipped (2) |
| Q-17 reordering | Order of entry |
| Q-21 first launch | Open Home |
| Q-23 small mismatches | Drafted resolutions (1)–(9) |
| Q-27 pack word count | Total approved words |
| Q-28 screen readers | Draft behaviour |
| Q-29 long words | Development words chosen to fit one line |
| Q-08, Q-09, Q-11, Q-12, Q-14, Q-15 | Before release |
