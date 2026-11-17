# Impostor TN — Screen specifications

Status: **DRAFT for Product Owner review (Stage 4).** Flows are in `UX_FLOWS.md`. Every screen is composed from components already defined in `docs/DESIGN_SYSTEM.md` §5; no new component is introduced. Full-screen reference renders of every screen now exist in `reference/png/screens/` (built by `tools/build_screens.py`); Appendix C lists them with the layout measurements taken from them. The renders are browser compositions of the tokens, not screenshots of the app, and nothing has been checked on a device.

Revision 2 (2026-11-16, consistency audit): corrected claims that the renders disproved, removed the step pills, changed the pinned actions on PUB-09, defined the final-guess text forms, and added the screen-reader, pack-count and parity notes. Changes are summarised in `UX_RESEARCH_AND_RISKS.md` §7.

How to read this document:

- Token names refer to `docs/design/tokens/*.json`: colours as `public.primary` / `private.surface`, type styles as `titleL`, sizes as `sizes.inputHeight`, spacing as `layout.sectionGap`.
- Component names are the ones listed in `DESIGN_SYSTEM.md` §7 (`TesskraButton`, `RoleTicket`, …).
- String keys are from the glossary in `docs/ARABIC_LOCALIZATION.md` §5. A key marked ★ is new and listed in Appendix A with a draft. **All Arabic is provisional.**
- **Q-nn** marks an open decision in `docs/product/DECISIONS.md`. The specification shows the recommended option.

## 1. Conventions for every screen

### 1.1 Frame

| Property | Value |
|---|---|
| Direction | RTL. "Start" is the right edge, "end" is the left edge |
| Content column | Single column, centred, max width `layout.maxContentWidth` (480) |
| Horizontal margin | `layout.screenMarginH` (24); `layout.screenMarginHCompact` (16) when the width is below `layout.compactBreakpointWidth` (360) |
| Vertical padding | `layout.screenPaddingTop` (16) and `layout.screenPaddingBottom` (24), each added to the system safe-area inset |
| Section spacing | `layout.sectionGap` (24) between sections, `layout.itemGap` (12) between list items and between stacked buttons |
| Bottom action area | Pinned to the bottom of the screen. One primary button, with any lower-emphasis buttons stacked below it. Dialogs and sheets follow their own rule: the safe action is last |
| Scrolling | Everything above the bottom action area scrolls when it does not fit. The action area never scrolls away |
| Background | Paper screens: `public.background`. Carbon screens: `private.background`. The paper-grain texture is not used in the MVP |
| System bars | Dark icons on paper, light icons on carbon; switched at the midpoint of `carbonIn` / `carbonOut` |
| Orientation | Portrait layouts only are specified (Q-10) |

### 1.2 App bar (paper screens that have one)

`TesskraAppBar`, height `sizes.appBarHeight` (56). From start to end: optional ghost `TesskraIconButton` (48), title in `titleL` at 22 as drawn in the reference, optional trailing element (`CountPill` or an icon button). Back uses `ic_arrow_right`; close uses `ic_x`. Each icon button has a semantic label.

### 1.3 Text

- Styles come from `typography.json` only. Three reference elements use 15 px, which is not a token (ticket chip, privacy hint, role tag); this specification uses `labelM` (16) for them, pending Q-23.
- Numbers shown to users (`2 / 6`, `3 / 12`, `4–12`, vote counts) are isolated left-to-right runs in `numericM` or `numericL`.
- Player names are shown as typed, isolated, on one line with an ellipsis unless a screen says otherwise.
- Text scale: layouts must work up to 1.5. Above 1.5, display styles (`displayXL`, `displayL`, `displayM`) are clamped at 1.5; body text keeps scaling and the screen scrolls.
- `displayXL` shrinks to fit one line down to 40; `displayL` shrinks to 32 and may wrap to two lines. The fit is done on the final rendered size (after text scale), and the floors 40 and 32 are absolute, not scaled.
- Measured limits of these rules (Appendix C): a two-word secret word still overflows one line at the floor of 40, and a 30-character name needs three lines at 320 wide. What happens then is open: Q-29 (long words) and Q-01 (name length; a 16-character name fits on one line at every tested size).

### 1.4 Buttons and states

As specified in `DESIGN_SYSTEM.md` §5: primary 60, secondary 52, text 44, destructive 52; pressed, disabled, focused and loading states included. A button whose action runs a checkpoint (see `UX_FLOWS.md` §3) shows the loading state (three dots, width unchanged, not tappable) until the save finishes.

The text button is drawn 44 high (`sizes.buttonCompactHeight`) but `sizes.touchTargetMin` is 48: its tappable area is extended to 48 without changing its look. The renders measure the drawn 44 on PUB-03 and PUB-09.

### 1.5 Private wrapper (all PRV screens)

- Carbon theme. No role colour, no hard shadow except on the ticket, primary buttons are mustard and flat.
- Screenshot blocking and the app-switcher cover are active while any PRV screen is shown. D-18 extends them to the whole game, from starting a game until it ends or is left, public in-game screens included. Not verified on a device. Whatever the scope, the "remove the secret when paused" rule above applies as well, because blocking screenshots does not hide what is on the glass.
- Screen readers (Q-28, proposal): nothing secret is ever announced automatically. Private screens set no live region and never move accessibility focus onto the word, the category, the role or a vote option by themselves. Those elements remain ordinary text, spoken only when the player deliberately moves focus onto them. Buttons and player names keep their labels, since names are not secret. Not tested with TalkBack.
- When the app leaves the foreground, secret content is removed from the screen immediately and the flow returns to PRV-01 (`UX_FLOWS.md` F11). "Leaves the foreground" means Android pauses the activity: home, app switcher, another app, an incoming-call screen, screen lock or timeout. Pulling down the notification shade or changing the volume does not pause the activity and is not treated as an interruption; this boundary has not been verified on a device.
- No shared-element transitions, no previews or blurred versions of secret content, no looping animation.
- Secret text is not selectable and is never copied to the clipboard.
- Sounds and haptics are identical for Civilian and Impostor.
- `private.surfaceSunken` = `carbonRaised` and `private.errorText` = `coralLight`, now in `colors.json` (D-19).

### 1.6 Errors, loading, empty

| Situation | Pattern |
|---|---|
| A save fails | Error `TesskraBanner` above the bottom action area with `state.error`; the triggering button becomes active again as "retry" (`action.retry`) |
| Something is loading for more than about 300 ms | `LoadingDots` with `state.loading`, centred |
| A list is empty | `StateBlock`: 72 circle icon, `titleM` line, `bodyM` hint |
| A field is invalid | Red-text border, helper line with `ic_alert`, one short shake (`errorShake`), error haptic |

### 1.7 Small screens

The reference frame is 360 × 720. Each screen must also work at 320 × 568 and at text scale 1.5. Where content cannot fit, it scrolls; pinned actions stay visible; touch targets stay at least 48 × 48.

These sizes were rendered and measured with a 24 status bar and a 48 navigation bar (the three-button worst case) and an assumed keyboard of 260 at 568 high and 300 at 720 high. Results are in Appendix C; where a screen section below says "measured", the number comes from there. Device behaviour (real keyboards, gesture navigation, font rendering) is unverified.

### 1.8 Motion and haptics

Named interactions, durations and haptics follow `INTERACTIONS_AND_ANIMATIONS.md` §3 and `animations.json`. With "remove animations" on, the `reducedMotion` values apply. No sound is played in the MVP (D-05, Q-09).

---

## 2. Public screens (paper)

### PUB-01 Home

**Purpose.** Entry point: start a game, open help, open settings.

**Entry.** Launch (when no game is saved and the tutorial has been seen), or return from PUB-02, PUB-03, PUB-09, OVL-02, PRV-05 "leave". **Exit.** PUB-05, PUB-02, PUB-03.

**Layout, top to bottom**

1. Top row, height 56: `TesskraIconButton` (surface fill, `ic_settings`) aligned to the end. No title.
2. Information banner, only in the "restore failed" state.
3. Hero: `logo/logo_ticket_lockup.svg`, centred, full content width up to its natural 320, aspect ratio 320 : 190. The file already contains its ticket outline, notches and hard shadow; no extra shadow is added.
4. `home.tagline` in `displayM`, centred, `public.textPrimary`.
5. `home.facts` in `bodyM`, centred, `public.textSecondary`; `4–12` is an isolated LTR run.
6. Flexible space.
7. Bottom action area: primary `TesskraButton` `home.new_game`; below it secondary `TesskraButton` `home.how_to`.

**States**

| State | Difference |
|---|---|
| Default | As above |
| Restore failed | Info `TesskraBanner` (`ic_info`, `state.restore_failed`★) under the top row. It is shown once and disappears when the user leaves Home |

**Interactions.** Primary → PUB-05 (standard screen push). Secondary → PUB-02. Settings → PUB-03. System back leaves the app.

**RTL and small screens.** At 320 wide the hero scales down with the column. If the height is short, the hero and text scroll under the pinned buttons.

**Assets.** `logo_ticket_lockup.svg` (provisional: name spelling awaits review), `ic_settings`.

---

### PUB-02 How to play

**Purpose.** The tutorial required by PRD §14, also used as the first-launch onboarding.

**Entry.** First launch, or PUB-01 secondary button. **Exit.** PUB-01.

**Layout**

1. App bar: back button (help state only), title `home.how_to`.
2. Six cards in a scrolling column, gap `layout.itemGap`. Each card: `public.surface` fill, 2.5 `public.border`, radius `md`, padding `layout.cardPadding`. Inside, a row: icon (24, `public.textPrimary`) at the start, then a column with the title in `titleM` and the body in `bodyM`.

| # | Icon | Title | Body | PRD §14 topic |
|---|---|---|---|---|
| 1 | `ic_users` | `tutorial.goal_title`★ | `tutorial.goal_body`★ | Objective |
| 2 | `ic_user` | `tutorial.roles_title`★ | `tutorial.roles_body`★ | Civilian and Impostor |
| 3 | `ic_smartphone` | `tutorial.handoff_title`★ | `tutorial.handoff_body`★ | Private reveal and handoff |
| 4 | `ic_message_circle` | `tutorial.clues_title`★ | `tutorial.clues_body`★ | One-word clues, passing |
| 5 | `ic_vote` | `tutorial.vote_title`★ | `tutorial.vote_body`★ | Voting and runoff |
| 6 | `ic_trophy` | `tutorial.guess_title`★ | `tutorial.guess_body`★ | Final guess and who wins |

3. Bottom action area: primary `TesskraButton`.

**States**

| State | App bar back | Primary button |
|---|---|---|
| First launch | Hidden | `action.got_it`★ → sets "tutorial seen" → PUB-01 |
| Help | Shown | `action.got_it`★ → PUB-01 |

**Interactions.** Plain scrolling; no pager, no swipe. System back equals the primary button in both states.

**RTL and small screens.** Icons sit at the right of each card. Bodies wrap freely; nothing is truncated. No illustrations exist; icons stand in for them (see the handoff's "not produced" list).

**Notes.** A single scrolling page was chosen over a multi-step pager: fewer states, no swipe-direction questions in RTL, works at any text scale. Role colours are not used here either; the roles are distinguished by text.

---

### PUB-03 Settings

**Purpose.** The basic settings allowed by PRD §14.

**Entry.** PUB-01. **Exit.** PUB-01, PUB-04.

**Layout**

1. App bar: back, title `settings.title`.
2. Row (min height 56, whole row tappable): `ic_vibrate`, `settings.haptics` in `labelM`, switch (56 × 32) at the end.
3. Section heading `settings.credits`★ in `titleM`.
4. Three lines in `bodyM`: "Noto Kufi Arabic — SIL OFL 1.1", "IBM Plex Sans Arabic — SIL OFL 1.1", "Lucide — ISC" (Latin, isolated LTR).
5. Text `TesskraButton` `settings.licenses`★ → PUB-04.
6. `settings.version`★ in `caption`, `public.textSecondary`; the version number is an isolated LTR run.

**States.** Haptics on / off. The switch takes effect immediately and is saved; toggling it gives a light haptic only when turning on.

**Not included.** A sound switch (no sound assets: D-05, Q-09). Nothing else may be added without approval (PRD §14).

**RTL.** The switch thumb rests on the right when off and travels left when on.

---

### PUB-04 Licences

**Purpose.** Show the licence texts that must ship with the fonts and icons (PRD §13).

**Entry / exit.** PUB-03.

**Layout.** App bar (back, title `settings.licenses`★). Three sections, each a `titleM` heading (the product name in Latin) followed by the full licence text in `bodyM`, left-aligned and LTR because the texts are English. Sources: `fonts/OFL-NotoKufiArabic.txt`, `fonts/OFL-IBMPlexSansArabic.txt`, `icons/LICENSE-lucide.txt`.

**States.** Loading (`LoadingDots`) while the texts are read; error (`StateBlock` with `ic_alert`, `state.error`, retry button) if they cannot be read.

**Note.** This is the one place where LTR body text is correct.

---

### PUB-05 Players

**Purpose.** Enter 4–12 player names and their order (PRD §4).

**Entry.** PUB-01 "new game"; PUB-09 "change players or packs"; back from PUB-06. **Exit.** PUB-06; back to PUB-01.

**Layout**

1. App bar: back, title `home.new_game`. No step pill: a "1 / 2" pill next to the "{n} / 12" player count read as two competing counters.
2. Heading row: `players.title` in `titleL`; `CountPill` "{n} / 12" in `numericM` at the end.
3. Warning `TesskraBanner` when the count is out of range.
4. List of `PlayerRow` (height 64, gap `layout.itemGap`): index badge (40, `public.accent`, numeric), name (`titleM`, one line, ellipsis), ghost icon button `ic_pencil`.
5. `AddPlayerRow` (dashed, height 64, `ic_plus` + `players.add`), hidden at 12 players.
6. Bottom action area: primary `TesskraButton` `action.continue`★.

**States**

| State | Appearance | Primary |
|---|---|---|
| Empty | Instead of the list: `StateBlock` (`ic_users`, `players.empty`, `players.empty_hint`), then `AddPlayerRow` | Disabled |
| 1–3 players | Warning banner (`ic_alert`, `error.min_players`) | Disabled |
| 4–11 players | No banner | Enabled |
| 12 players | `AddPlayerRow` hidden; `caption` line `players.max_reached`★ under the list | Enabled |
| Pre-filled | Retained roster shown as it was last saved | By count |

More than 12 cannot be reached, so no "too many" error exists.

**Interactions**

- Tap a row or its pencil → OVL-01 in edit mode. Tap `AddPlayerRow` → OVL-01 in add mode.
- A new row fades in and rises 8 (`listItemIn`, light haptic); a removed row fades and collapses (`listItemOut`, light haptic). The list scrolls to keep a new row visible.
- Every change is saved at once (C0).
- Primary → PUB-06.

**RTL and small screens.** Badge on the right, pencil on the left. With 12 players the list is taller than any phone; it scrolls under the pinned button. Long names never push the pencil off screen.

---

### OVL-01 Edit player sheet

**Purpose.** Add, rename, move or delete one player.

**Layout.** `TesskraSheet` (top radius `xl`, grab handle 44 × 5, padding `layout.dialogPadding`), resting above the keyboard:

1. Title in `titleL` at 22: `players.add` (add mode) or `action.rename` (edit mode).
2. `TesskraTextField`: label `players.name_label`, hint `players.name_hint`, helper `players.name_limit`, counter "{n} / 16" (LTR, at the end). Keyboard: the user's current keyboard, action "done". **The keyboard's "done" key does exactly what the primary button does**, because the primary button is not always visible (see below).
3. Primary `TesskraButton`: `action.add`★ (add mode) or `action.confirm` (edit mode).
4. Edit mode only: two secondary buttons side by side, `players.move_earlier`★ and `players.move_later`★ (**Q-17**).
5. Edit mode only: destructive `TesskraButton` with `ic_trash`, `action.delete_player`.

**States**

| State | Behaviour |
|---|---|
| Empty or spaces only | Primary disabled |
| Duplicate of another player | On confirm: field error with `error.name_duplicate`, shake, error haptic; the sheet stays open |
| At the length limit | Further input is ignored; the counter shows "16 / 16" |
| First in the list / last in the list | "Move earlier" / "move later" disabled |

Rules for length and duplicates are the proposal in Q-01 (16 characters; comparison ignores leading, trailing and repeated spaces). They are not approved.

**Interactions**

- Add mode: on success the row is added, the field is cleared and the sheet stays open for the next name. It closes when dismissed or when the twelfth player is added.
- Edit mode: confirm saves and closes. Move buttons reorder immediately and keep the sheet open. Delete removes the player and closes; no confirmation, because re-adding a name is cheap.
- Dismiss by dragging down, tapping the scrim, or system back; unsaved text is discarded.
- The field receives focus when the sheet opens.

**RTL and small screens.** Text is right-aligned, the caret is at the left end of Arabic text. The sheet never grows past the space above the keyboard; its content scrolls, and the field with its helper or error line is always kept in view.

Measured: at 320 × 568 with the keyboard, 236 of height is left. The title and field fit; the primary button is cut off by 24 and everything below it is out of view. At 360 × 720 the add sheet fits completely; in edit mode the delete button is out of view (and the move buttons too at text scale 1.5). So the earlier statement that the primary button stays visible was wrong for small phones; the "done" key is what makes the sheet usable there. Without the keyboard the edit sheet fits at both sizes.

---

### PUB-06 Packs

**Purpose.** Choose the word packs and start the game (PRD §4, §10).

**Entry.** PUB-05. **Exit.** PRV-01 (game started); back to PUB-05.

**Layout**

1. App bar: back, title `home.new_game`.
2. Heading `packs.title`★ in `titleL`.
3. List of `WordPackCard` (min height 84, gap `layout.itemGap`): title in the Kufi 20 style (`labelL`), meta line `pack.word_count` in `caption` with the number first as an LTR run. The number is the pack's **total of approved, published words**. It does not change with the cooldown (see "Word counts" below).
4. Banner area above the bottom action area (validation or error).
5. Bottom action area: primary `TesskraButton` `action.start`.

**Card states** (multi-select)

| State | Appearance | Tappable |
|---|---|---|
| Selected | Shadow `public.sm`, red "selected" `StampLabel` (`ic_check`, `pack.selected`) | Yes, deselects |
| Available | Empty checkbox (28) at the end | Yes, selects (`stampIn`, medium haptic) |
| Unavailable | Sunken fill, `ic_alert`, meta `pack.empty` | No |

The "locked" card state in the design system is not used (D-04).

**Word counts (Q-27, proposal).** Two different numbers exist for a pack:

| Number | Meaning | Shown? |
|---|---|---|
| Total approved | Published words in the pack that passed both reviews | Yes, on the card |
| Eligible now | Of those, the words not among the 30 most recently used | No |

Showing "eligible now" would make a pack's count shrink and grow as games are played and would suggest that a pack with a low number cannot be played. That is not the case: when every candidate word is on cooldown, the least recently used one is released automatically (PRD §10; `UX_FLOWS.md` §3.4). The player never has to do anything about the cooldown, and the screen never mentions it. A pack is "unavailable" only when its total of approved words is zero.

**Screen states**

| State | Appearance | Primary |
|---|---|---|
| Loading content | `LoadingDots` + `state.loading` in place of the list | Disabled |
| Content failed to load | `StateBlock` (`ic_alert`, `state.error`) with a secondary "retry" button | Disabled |
| No approved content at all | `StateBlock` (`ic_alert`, `error.no_words`★) | Disabled |
| Nothing selected | Warning banner (`ic_alert`, `error.no_pack`★) | Disabled |
| At least one selected | No banner | Enabled |
| Starting | — | Loading state while C1 runs |
| Start failed: no approved word | Error banner `error.no_words`★. Defensive only: with at least one approved word in the selection the cooldown can never cause this, and a selection without approved words cannot be made on this screen | Enabled again |
| Start failed: save error | Error banner `state.error` | Enabled again |

Retained selections are pre-ticked when the pack is still available; a retained pack that became unavailable is shown unavailable and unticked. Every change of selection is saved at once (C0).

**Interactions.** Primary: button press (80 ms), C1, then `carbonIn` (520 ms, medium haptic) → PRV-01 for player 1. Nothing about the chosen word or roles is ever shown on this screen.

**RTL and small screens.** Stamp or checkbox at the left of each card; long pack titles wrap to two lines rather than truncate.

---

### PUB-07 Discussion

**Purpose.** Tell the table that roles are dealt, state the clue rules, and offer the move to voting (PRD §6).

**Entry.** After the last acknowledgement (`carbonOut`), or recovery. **Exit.** PRV-01 (voting), OVL-02.

**Layout**

1. App bar: title `phase.clues`; ghost close button (`ic_x`) at the end.
2. `PhaseChip` (`ic_message_circle`, `phase.clues`), centred.
3. `reveal.all_done` in `titleL`, centred.
4. `discussion.put_phone`★ in `bodyL`, centred.
5. Card (surface, 2.5 border, radius `md`, padding `layout.cardPadding`) with three `bodyL` lines, each preceded by `ic_check` (20): `discussion.rule_one_word`★, `discussion.rule_pass`★, `discussion.rule_then_vote`★.
6. Bottom action area: primary `TesskraButton` `action.start_vote`★ with leading `ic_vote`.

**States.** Default; opening voting (button loading while C4 runs); save error (error banner, button active again).

**Interactions.** Primary → C4 → `carbonIn` → PRV-01 for voter 1. Close and system back → OVL-02. The screen stays as long as the group needs: no timer, no turn marker, no clue entry (D-03, PRD §6).

**Privacy.** Public screen: it contains no word, category or role.

---

### PUB-08 Vote tally

**Purpose.** Show the outcome of the ballot that just closed and what happens next (PRD §7).

**Entry.** After the last vote of a ballot (`carbonOut`), or recovery. **Exit.** PRV-01 (runoff or final guess), PUB-09, OVL-02.

**Layout**

1. App bar: title `tally.title`★; ghost close button at the end.
2. `PhaseChip` (`ic_vote`): `phase.vote` for the first ballot, `vote.runoff_title`★ for the runoff.
3. List of `VoteTallyRow`, one per candidate, ordered by count (highest first; equal counts keep playing order): name in `titleM`, one small rotated red square per vote, count in `numericL`, dashed divider. First ballot: all players. Runoff: the tied players only.
4. Outcome block (see states).
5. Bottom action area: one primary `TesskraButton`.

**States**

| State | Outcome block | Primary |
|---|---|---|
| A. Unique top, civilian | `tally.nominated`★ in `titleL` with the name | `action.see_result`★ → PUB-09 |
| B. Unique top, Impostor | `tally.impostor_caught`★ in `titleL` with the name, then `tally.final_chance`★ in `bodyL` | `handoff.pass_to` with the name → `carbonIn` → PRV-01 |
| C. Top tie on the first ballot | Warning `TesskraBanner` (`ic_equal`, `vote.tie`) | `action.runoff_start`★ → `carbonIn` → PRV-01 |
| D. Tie on the runoff | Warning `TesskraBanner` (`ic_equal`, `result.draw_note`★) | `action.see_result`★ → PUB-09 |

In state A the screen does not say whether the nominee is a civilian; that is the result screen's reveal. In state B it must say so, because the nominee is about to receive the phone for the guess (`UX_FLOWS.md` F8).

**Interactions.** On first display: vote marks land one at a time, 160 ms apart (`voteTally`, light haptic per mark); then the top row or rows are emphasised and the outcome block appears (360 ms, medium haptic). The primary button is enabled only after the sequence ends. With reduced motion everything appears at once. On recovery the screen appears complete, without the sequence.

**RTL and small screens.** Name on the right, marks then count on the left; marks run right to left. With many votes for one player the marks wrap inside their area; the count is always visible. In state B the button label contains the name; it stays on one line and the name is ellipsized.

Measured at 360 × 720 with six players: state D fits; states A, C and B need 51, 88 and 115 of scrolling to reach the outcome block. Because the outcome block is what tells the group what happens next, the list scrolls it into view when the counting sequence ends. Twelve rows need 435 of scrolling (1149 in total).

**Privacy.** Counts only: who voted for whom is not shown (**Q-18**). The secret word and category never appear here.

---

### PUB-09 Results

**Purpose.** Reveal the outcome and everything PRD §8 requires; offer replay (PRD §9).

**Entry.** From PUB-08 (states A, D), from PRV-04 (`carbonOut`), or launch with a finished game saved. **Exit.** PRV-01 (new game), PUB-05, PUB-01.

**Layout** (scrolling, above the pinned actions)

1. `WinnerStamp` (5 px border, radius 18, Kufi 900 at 34, rotated −5°), centred.
2. One `bodyL` line explaining why (see states).
3. `SecretWordPlaque`: caption `reveal.word_label`, the word in `displayXL` (shrinking), chip `reveal.category`.
4. Final-guess card, only when a guess was made: surface, 2.5 border, radius `md`, padding `layout.cardPadding`; caption `result.guess_label`★; the guess in its display form (exactly what the Impostor confirmed on PRV-04; see `UX_FLOWS.md` §3.3) in `titleM`, isolated, wrapping if long; then `ic_check` + `result.guess_correct`★ in `public.success`, or `ic_x` + `result.guess_wrong`★ in `public.errorText`.
5. Section heading `players.title` in `titleM`, then one `RoleRevealRow` per player in playing order: badge, name, role tag at the end (Civilian: `role.civilian`, `role.civilian` colour, radius 8, `ic_user`; Impostor: `role.impostor`, `role.impostor` colour, pill, `ic_eye_off`).
6. Section heading `result.votes_title`★ in `titleM`; sub-heading `result.first_ballot`★ in `labelM` and its `VoteTallyRow`s; if there was a runoff, sub-heading `vote.runoff_title`★ and its rows.
7. At the end of the scrolling content: secondary `TesskraButton` `action.change_setup`★, then text button `action.home`★.
8. Bottom action area: accent `TesskraButton` `action.play_again` with `ic_rotate_ccw`, alone.

The first draft pinned all three actions. Measured at 320 × 568 that left 280 of height for about 1700 of content (render `pub09_results_first_draft_three_pinned`); pinning only the replay button leaves 400.

**States**

| State | Stamp | Explanation line | Guess card |
|---|---|---|---|
| Civilian nominated | `result.impostor_wins`, `public.errorText`, solid | `result.civilian_out`★ | No |
| Impostor nominated, guess correct | `result.impostor_wins`, `public.errorText`, solid | — | Yes, correct |
| Impostor nominated, guess wrong | `result.civilians_win`, `role.civilian` colour, solid | — | Yes, wrong |
| Runoff tied | `result.draw`, `public.textPrimary`, dashed | `result.draw_note`★ | No |
| Starting a new game | — | — | Accent button loading while C9 runs |
| New game failed | Error banner (`error.no_words`★ or `state.error`); the result stays visible | | |

**Interactions.** On first display: the stamp slams in and the content rises (`winnerReveal`, 600 ms, heavy haptic). On recovery or with reduced motion: no slam. Play again → `carbonIn` → PRV-01 for player 1 of the new game. System back does nothing (the three buttons are the exits).

**RTL and small screens.** Role tags and counts sit on the left. A long guess wraps. A long secret word follows the same rule as on the ticket (Q-29).

Measured: with six players and one ballot the content is about 1740 long (2.4 screens at 720); with twelve players and a runoff, 2820. The first screenful shows the winner stamp and the top of the word plaque. At 320 wide and text scale 1.5 the stamp "الإمبوستور ربح" is wider than the screen: the stamp text must shrink until its longest word fits (not specified in the design system; added to Q-23).

**Privacy.** This is the only public screen that shows the word, the roles and the guess, and only after the game is over. Role colours are allowed here and nowhere else. Screenshots of this screen are possible unless Q-04 is decided as "whole app".

---

### OVL-02 Leave-game dialog

**Purpose.** Confirm abandoning the current game.

**Layout.** `TesskraDialog` over a scrim: title `dialog.quit_title` in `titleL`; body `dialog.quit_body` in `bodyM`; destructive button `dialog.quit_confirm`; then secondary button `dialog.quit_cancel` last, closest to the thumb.

| Opened from | Dialog style |
|---|---|
| A paper screen | Paper theme: surface, 2.5 border, radius `lg`, shadow `public.lg`, scrim `public.scrim` |
| A carbon screen | Carbon theme: `private.surface`, 2.5 `private.borderStrong`, radius `lg`, **no shadow**, scrim `private.scrim`; destructive button in `coralLight` (Q-07) |

**Interactions.** Confirm → C8 → PUB-01 (with `carbonOut` if on carbon). Cancel, scrim tap or system back → close. The dialog can never open on top of a revealed secret (`UX_FLOWS.md` F10).

---

## 3. Private screens (carbon)

All of §1.5 applies to every screen in this section.

### PRV-01 Handoff

**Purpose.** The neutral state between players: say who takes the phone next, and nothing else (PRD §5, §12).

**Entry.** Start of a reveal turn, a vote turn, a runoff vote turn, or the final guess; warm return from any private screen; "continue" on PRV-05. **Exit.** PRV-02, PRV-03 or PRV-04, according to the phase.

**Layout** (`HandoffBlock`, vertically centred)

1. `handoff.pass_label`★ ("pass the phone to", without a name, as drawn in the approved render) in `bodyL`, `private.textSecondary`, centred. The glossary key `handoff.pass_to` contains the name and is used only for the PUB-08 button.
2. The player's name in `displayL`, `private.textPrimary`, centred: 48, shrinking to 36 then 32 for long names, two lines at most, isolated.
3. `CountPill` "{position} / {total}" in `numericM`, 2.5 `private.borderStrong` border. Omitted for the final guess, where there is only one person and the table already knows who it is.
4. Bottom action area: primary `TesskraButton` (private: mustard, flat) `handoff.i_am` with the name.

Nothing else appears: no phase label, no icon, no leave control, no decoration. The screen is identical for reveal, voting and the runoff, so it tells an onlooker nothing about the phase or the previous player.

**States**

| State | Difference |
|---|---|
| Default | As above |
| Saving | Button loading while C2 runs. C2 runs on an "I am {name}" tap in the reveal phase whenever the session's word is not yet marked as consumed: normally once, on the first handoff, and again only after a failed attempt or a restart before it succeeded |
| Save error | Error banner (`state.error`, `coralLight` border and text) above the button; button active again |

**Interactions.** Button → the phase's private screen, 220 ms content change on the same carbon ground; no haptic, no sound, no motion beyond the content change. System back → OVL-02.

**RTL and small screens.** Everything is centred. If the name wraps the block grows; the button stays pinned. In the button, "{name}" may be long: the label stays on one line and the name is ellipsized. How far the label may shrink first is not specified anywhere (Q-23).

Measured: a 16-character name (the Q-01 proposal) fits on one line at 37 (360 wide) and 34 (320 wide), above the floor of 32. The 30-character stress name from the design samples needs two lines at 360 wide and **three at 320 wide**, more than the two the design system allows; with a 16-character limit this cannot occur. In the button, the 16-character name is ellipsized at 320 wide with text scale 1.5.

**Privacy.** Shows a name and a position only. It must be impossible to tell from this screen which role the previous player had or what they voted.

---

### PRV-02 Role ticket

**Purpose.** Let one player deliberately reveal their role, read it, and explicitly hide it (PRD §5).

**Entry.** PRV-01 during the reveal phase. **Exit.** PRV-01 (next player, or back), PUB-07 (after the last acknowledgement).

**Layout**

1. Privacy hint row: `ic_eye_off` (24) + `privacy.only_you` in `labelM`, `private.primary` (mustard), at the start.
2. `RoleTicket`: fill `private.ticket`, text `private.onTicket`, radius `lg`, shadow `private.ticket`, padding `layout.ticketPadding`.
   - Top row: small label (`caption`) above a `titleL` line at the start; a 52 outlined square icon stamp (3.5 border, radius `sm`, rotated 6°) at the end.
   - Perforation: 2.5 dashed line with two notches of `sizes.ticketNotchDiameter` (24) filled with `private.background`.
   - Bottom block, min height 206, centred.
3. A button directly under the ticket (revealed state) or in the bottom action area (sealed state). The two positions are different on purpose.

**States**

| State | Ticket top row | Ticket bottom block | Controls |
|---|---|---|---|
| Sealed | Label `reveal.role_label_sealed`★ ("دور"; the glossary notes this form but gives it no key), the **player's name**, stamp `ic_lock` | `ic_eye_off` + `reveal.sealed` in `labelL` | Bottom action area: primary `reveal.show`; below it private secondary `action.back` |
| Revealing | Seal lifts (`ticketReveal`, 420 ms, medium haptic); secret content fades in only during the last 120 ms | | None active |
| Revealed, Civilian | Label `reveal.role_label`, `role.civilian`, stamp `ic_user` | Caption `reveal.word_label`; the word in `displayXL` (shrinks to 40, one line); chip `reveal.category` | Under the ticket: primary `reveal.ack`, disabled for the first 800 ms |
| Revealed, Impostor | Label `reveal.role_label`, `role.impostor`, stamp `ic_user` | Caption `reveal.category_only`; the category in `displayXL`; chip `reveal.no_word` | Same |
| Saving | Sealed again, immediately | Sealed | Under the ticket: the same button in its loading state |
| Save error | Sealed | Sealed | Error banner (`state.error`); under the ticket: primary `action.retry`. No "show me my role" control: the player has already seen it |

The two revealed states use the same widgets, sizes, colours, icon, sound and haptic. Only the text differs. The Impostor never sees the word, an alias or a hint.

**What an onlooker can tell (measured, 360 × 720, text scale 1).** The two tickets are not indistinguishable.

| Element | Civilian | Impostor | Difference |
|---|---|---|---|
| Ticket size | 312 × 301 | 312 × 301 | None |
| Role name, top row, Kufi 26 | مدني, 71 wide | إمبوستور, 125 wide | The largest tell: 76 % wider, in the heaviest type on the top row |
| Caption above the big text, 13 | 66 wide | 56 wide | Small |
| Big text, Kufi 72 | The secret word | The category | Depends on the words; reveals the role only to someone who knows the category |
| Chip, 15 | 81 wide | 98 wide | Small |
| Colours, icon, button, sound, haptic | Same | Same | None |
| Ticket height at text scale 1.5, 320 wide | 386 | 361 | The block grows with the fitted font size, so the two differ by 25 |

Anyone who can read the screen learns the role, and the secret word if it is a Civilian's; no layout can prevent that. What the layout can do is remove tells that work at a glance or from a distance.

**Smallest improvement (Q-25, proposal; renders `prv02_proposed_*`).** Two changes, no new component, no rule change:

1. The top row does not change on reveal: it keeps the sealed label and the **player's name**; only the stamp icon changes from lock to person. The role name moves into the caption of the bottom block: "مدني · الكلمة السرّية" or "إمبوستور · الصنف برك", at 13 instead of 26. Measured: the top rows become identical (82 wide for both); the captions are 100 and 110 wide.
2. The big text keeps a line box of the full `displayXL` height whatever size it is fitted to, so both tickets have the same height at every text scale (measured 389 and 389 at scale 1.5).

This also makes the screen satisfy design principle 3 ("name first"), which the approved revealed-ticket render does not: it shows no name. The remaining differences are the small caption, the chip and the big text itself. **Applied by D-27 (2026-11-17).** These two changes supersede the "Revealed, Civilian" and "Revealed, Impostor" rows of the state table above: the top row keeps `reveal.role_label_sealed` and the player's name, the stamp changes from `ic_lock` to `ic_user`, and the role name opens the caption. Implemented in `RoleTicket` (`lib/core/design/widgets/role_ticket.dart`).

**Category lines (D-39, 2026-11-17).** Both revealed tickets reserve exactly two lines for the category label: the big text (the Impostor's category) reserves two lines at its 40 floor in addition to its `displayXL` line box, and the chip (the Civilian's `reveal.category`) reserves two `labelM` lines; a one-line chip is centred in that space. Same widgets and sizes for both roles; no type size changed. A category needing a third line in either place would break parity.

**Interactions**

- A tap anywhere other than a button does nothing. There is no hold gesture and no timer; the revealed state stays until acknowledged.
- `reveal.ack`: the secret is removed in the same frame (`ticketHide`, light haptic), then C3 runs. The app moves on only after C3 succeeds: to PRV-01 for the next player (220 ms), or `carbonOut` to PUB-07 after the last player (520 ms, medium haptic).
- Retry after a save error repeats C3 only.
- `action.back` (sealed only) → PRV-01, same player.
- System back: sealed → like `action.back`; revealing, revealed, saving → ignored; save error → OVL-02, so a group is never trapped by a storage fault.
- Leaving the foreground in any state → secret removed → PRV-01, same player, on return (unless C3 had already succeeded).

**RTL and small screens.** Label and role at the right of the top row, stamp at the left.

Measured:

| Size | Sealed | Revealed | "Show" button vs "got it" button |
|---|---|---|---|
| 360 × 720 | Fits | Fits | Different places: 524–584 and 389–449 |
| 320 × 568 | 17 of the ticket's lower edge is under the buttons | Fits | **Overlap by 43** (372–432 and 389–449) |
| 360 × 720, scale 1.5 | Fits | Fits | Overlap by 25 |
| 320 × 568, scale 1.5 | 58 hidden | "Got it" is 50 below the fold | No overlap, because the button is off screen |

So the earlier statement that the two buttons never share a position was wrong. They are separated only on tall screens (about 645 high or more at scale 1). On small phones the 800 ms lock is the only protection against a double tap, and the specification relies on it.

When "got it" would not be fully visible under the ticket, it moves to the pinned bottom action area instead, so that the way to hide the role is never off screen. A two-word secret word overflows the ticket at the floor of 40 (render `prv02_revealed_long_word`); see Q-29.

**Privacy.** The most sensitive screen. §1.5 applies in full. The acknowledge lock value (800 ms) comes from `INTERACTIONS_AND_ANIMATIONS.md` §5 and has no token yet (Q-23). With a screen reader on, revealing announces nothing; the role and the word are spoken only if the player moves focus onto them (§1.5, Q-28, risk R-07).

---

### PRV-03 Vote

**Purpose.** One player's private vote (PRD §7).

**Entry.** PRV-01 during a ballot. **Exit.** PRV-01 (next voter, or back), PUB-08 (after the last vote).

**Layout**

1. Privacy hint row, as on PRV-02.
2. The voter's name in `titleM`, `private.textSecondary`, isolated.
3. Title in `titleL`: `vote.title`★ (first ballot) or `vote.runoff_title`★ (runoff). In the runoff, a `bodyM` line `vote.runoff_hint`★ below it.
4. List of `VoteOption` (height `sizes.voteOptionHeight`, gap `layout.itemGap`), in playing order: radio (28) at the start, name in `titleM` (one line, ellipsis).
5. Bottom action area: primary `TesskraButton` `action.confirm`; below it private secondary `action.back`.

**Option states**

| State | Appearance |
|---|---|
| Default | `private.surface` fill, 2.5 `private.border` |
| Selected | 2.5 `private.primary` border plus an inner mustard outline, filled radio, transparent fill |
| Unavailable (the voter's own row) | Dashed border, `private.textDisabled` text and radio, `vote.self` at the end in `caption`; not tappable |

**Screen states**

| State | Options listed | Primary |
|---|---|---|
| First ballot, nothing selected | All players; own row unavailable | Disabled |
| Runoff, nothing selected | Tied players only; own row unavailable if the voter is one of them | Disabled |
| Selected | — | Enabled |
| Saving | List not tappable | Loading while C5 / C6 runs |
| Save error | Error banner (`state.error`); the selection is kept | Enabled again |

**Interactions.** Tapping an available option selects it (`selection`, 140 ms, selection haptic); tapping another moves the selection. Confirm (medium haptic, as in the interactions table) → C5 / C6 → the screen clears to PRV-01 for the next voter (220 ms), or `carbonOut` to PUB-08 after the last voter. After a successful save the vote cannot be seen or changed (D-02). `action.back` and system back → PRV-01, same voter, selection discarded; both are ignored while saving. Leaving the foreground → PRV-01 for the same voter with the selection discarded, or, if the save had already succeeded, for the next voter.

A retry after a save error never records a second vote: before writing, the app checks whether this voter already has a vote in this ballot. If one exists, that vote stands and the flow simply advances (`UX_FLOWS.md` §3.1).

**RTL and small screens.** Radio on the right, "you" tag on the left. The hint, name and title scroll away with the list; only the two buttons are pinned.

Measured with twelve players (twelve rows, 900 of list):

| Size | Rows fully visible on arrival | After scrolling the heading away |
|---|---|---|
| 360 × 720 | 4 | 6 |
| 320 × 568 | 2, and part of a third | 4 |
| 320 × 568, scale 1.5 | 1, and part of a second | 4 |

The earlier "about three" was optimistic. One visible row at large text on a small phone is poor but usable; nothing is unreachable. A runoff with two candidates fits without scrolling at 320 × 568; with three it needs 35. Long names are ellipsized inside the row.

**Privacy.** Shows no earlier votes and no counts. The selection is visible only until confirm. Nothing on PRV-01 afterwards hints at the choice.

---

### PRV-04 Final guess

**Purpose.** The nominated Impostor's single textual guess (PRD §8).

**Entry.** PRV-01 after PUB-08 state B. **Exit.** PUB-09.

**Layout, entry state**

1. Privacy hint row.
2. The player's name in `titleM`, `private.textSecondary`.
3. Title `guess.title`★ in `titleL`.
4. `guess.one_chance`★ in `bodyM`, `private.textSecondary`.
5. `TesskraTextField` on carbon: `private.surface` fill, 2.5 `private.borderStrong`, text `private.textPrimary` in `bodyL`, label `guess.label`★, no counter, no helper. Keyboard: the user's keyboard, action "done", autocorrect and suggestions off so the spelling is not altered.
6. Bottom action area: primary `action.confirm`.

**Layout, review state**

1–2. As above.
3. Title `guess.review_title`★ in `titleL`.
4. The guess in its display form (the text as typed, minus leading and trailing spaces; nothing else changed) in `displayL` (shrinks, two lines at most), isolated, centred. The result screen later shows exactly this text. What is compared with the secret word is defined in `UX_FLOWS.md` §3.3.
5. Bottom action area: primary `guess.confirm_final`★; below it private secondary `guess.edit`★.

**States**

| State | Behaviour |
|---|---|
| Entry, empty or spaces only | Primary disabled |
| Entry, text present | Primary enabled → review state; the keyboard closes |
| Review | `guess.edit`★ returns to entry with the text kept |
| Saving | Primary loading while C7 runs |
| Save error | Error banner (`state.error`); primary active again. The guess is not lost. A retry never records a second guess: if one is already saved for the session, it stands and the flow advances |

**Interactions.** Final confirmation → C7 → `carbonOut` → PUB-09. No haptic or sound distinguishes a correct from a wrong guess on this screen; the result screen does that. System back: review → entry; entry → OVL-02; ignored while saving. Leaving the foreground before C7 has succeeded → PRV-01 for the Impostor, typed text discarded; after it has succeeded → PUB-09. The keyboard's "done" key moves to the review state, like the confirm button. No maximum length is specified for the guess (Q-26).

**RTL and small screens.** Right-aligned text, caret at the left end of Arabic text; Latin input is accepted and shown as typed.

Measured with the keyboard open: at 360 × 720 everything fits. At 320 × 568 only 124 of height remains between the top padding and the pinned button, and the field starts below it: **in the rendered layout the field is completely hidden** (render `prv04_guess_typed__320x568`). The earlier requirement that title, field and button all stay visible cannot be met there. The requirement is therefore: with the keyboard open, the field with its label and the confirm button are visible; the hint, name and title scroll out of view, and the focused field is scrolled into view automatically. The field with its label needs 83 (94 at scale 1.5), which fits in 124.

**Privacy.** The category is **not** repeated here (the Impostor already knows it, and less on screen is safer). The app shows no hint, no letter count and no "almost" feedback. The guess appears publicly only on PUB-09.

---

### PRV-05 Resume gate

**Purpose.** A neutral first screen when the app is opened while a game is in progress (PRD §12: resume into a neutral screen).

**Entry.** Cold start with a saved game whose phase is not "result". **Exit.** The screen for the saved phase (`UX_FLOWS.md` F11), or PUB-01.

**Layout** (vertically centred)

1. `ic_info` in a 72 outlined circle (`StateBlock` pattern), `private.textPrimary`.
2. `state.resumed` in `titleM`, centred.
3. Bottom action area: primary `action.continue`★; below it a destructive button (`coralLight`) `dialog.quit_confirm`.

**States.** Default. Leaving: the destructive button opens OVL-02 (carbon style); confirming it → C8 → `carbonOut` → PUB-01.

**Interactions.** Continue → the destination for the saved phase. To a private destination: 220 ms content change. To a public destination: `carbonOut`. System back → OVL-02.

**Privacy.** Shows no name, phase, count or any other detail of the saved game. This is the one private screen that does not state whose turn it is (design principle 3); the handoff that follows does.

---

## Appendix A — New strings (drafts)

These keys do not exist in the glossary. The Arabic below was drafted in this session to make the specification concrete. **It is not reviewed and not approved**; treat every line as a placeholder for the Derja reviewer, with the same "Review" status as the glossary. Avoiding gendered forms was attempted but not always possible.

| Key | Meaning | Draft |
|---|---|---|
| action.got_it | Got it | فهمت |
| action.continue | Continue | كمّل |
| action.add | Add | زيد |
| action.start_vote | Start voting | نبداو التصويت |
| action.see_result | See the result | شوفوا النتيجة |
| action.runoff_start | Vote again | نعاودو التصويت |
| action.change_setup | Change players or packs | بدّل اللعّابة والباكوات |
| action.home | Home | الرئيسية |
| state.restore_failed | The last game could not be restored | الطرح اللي فات ما نجّمناش نرجّعوه |
| handoff.pass_label | Pass the phone to (shown above the name) | أعطي التليفون لـ |
| reveal.role_label_sealed | Role (label on the sealed ticket, above the player's name) | دور |
| players.max_reached | 12 players is the maximum | 12 لعّاب هو الحدّ |
| players.move_earlier | Move earlier in the order | قدّم |
| players.move_later | Move later in the order | أخّر |
| packs.title | Choose the packs | اختار الباكوات |
| error.no_pack | Choose at least one pack | اختار باكو واحد على الأقل |
| error.no_words | No word is available to play with | ما فمّا حتى كلمة تنجّموا تلعبوا بيها |
| settings.credits | Fonts and icons | الخطوط والأيقونات |
| settings.licenses | Licences | التراخيص |
| settings.version | Version {v} | النسخة {v} |
| tutorial.goal_title | The goal | الهدف |
| tutorial.goal_body | Everyone has the same secret word except one player, the Impostor. Find them. | الكل عندهم نفس الكلمة السرّية، كان واحد: الإمبوستور. لازم تلقاوه. |
| tutorial.roles_title | Civilian and Impostor | المدني والإمبوستور |
| tutorial.roles_body | A civilian sees the word and its category. The Impostor sees the category only. | المدني يشوف الكلمة والصنف متاعها. الإمبوستور يشوف الصنف برك. |
| tutorial.handoff_title | One phone, passed around | تليفون واحد يدور |
| tutorial.handoff_body | Each player takes the phone, looks at their role alone, hides it, then passes it on. | كل لعّاب ياخذ التليفون، يشوف دورو وحدو، يخبّيه، ومبعد يعدّيه. |
| tutorial.clues_title | One-word clues | تلميح بكلمة وحدة |
| tutorial.clues_body | Each player says one word about the secret word. Passing is allowed. | كل واحد يقول كلمة وحدة على الكلمة السرّية. تنجّم تعدّي من غير ما تقول شي. |
| tutorial.vote_title | The vote | التصويت |
| tutorial.vote_body | Everyone votes in secret for the player they suspect; not for themselves. If the top is tied, there is one more vote between the tied players. If it is tied again, the game is a draw. | كل واحد يصوّت في السرّ على اللي يشكّ فيه، وما يصوّتش على روحو. كان فمّا تعادل، نعاودو مرّة وحدة بين المتعادلين. وكان تعاود التعادل، الطرح يوفى بتعادل. |
| tutorial.guess_title | The last chance | آخر فرصة |
| tutorial.guess_body | A caught Impostor gets one guess at the secret word: right, the Impostor wins; wrong, the civilians win. If a civilian is voted out, the Impostor wins. | كان شدّيتو الإمبوستور، عندو محاولة وحدة باش يعرف الكلمة: كان جابها يربح، وكان غلط المدنيين يربحوا. وكان خرّجتو مدني، الإمبوستور يربح. |
| discussion.put_phone | Put the phone in the middle | حطّوا التليفون في الوسط |
| discussion.rule_one_word | Each player says one word about the secret word | كل واحد يقول كلمة وحدة على الكلمة السرّية |
| discussion.rule_pass | Passing is allowed | تنجّم تعدّي من غير ما تقول شي |
| discussion.rule_then_vote | When everyone is ready, start the vote | وقت تكمّلوا، ابداو التصويت |
| vote.title | Who is the Impostor? | شكون الإمبوستور؟ |
| vote.runoff_title | Second vote | التصويت الثاني |
| vote.runoff_hint | Choose among the tied players | اختار من بين المتعادلين |
| tally.title | Vote result | نتيجة التصويت |
| tally.nominated | {name} got the most votes | أكثر أصوات: {name} |
| tally.impostor_caught | {name} is the Impostor | الإمبوستور: {name} |
| tally.final_chance | The Impostor has one last chance: a single guess at the secret word | آخر فرصة للإمبوستور: محاولة وحدة على الكلمة السرّية |
| guess.title | What is the secret word? | شنوّة الكلمة السرّية؟ |
| guess.one_chance | One attempt only | محاولة وحدة برك |
| guess.label | Your answer | جوابك |
| guess.review_title | Is this your final answer? | هذا جوابك النهائي؟ |
| guess.confirm_final | Yes, this is my answer | إيه، هذا جوابي |
| guess.edit | Change it | نبدّلو |
| result.guess_label | The Impostor's answer | جواب الإمبوستور |
| result.guess_correct | Correct | صحيح |
| result.guess_wrong | Wrong | غالط |
| result.votes_title | The votes | الأصوات |
| result.first_ballot | First vote | التصويت الأوّل |
| result.draw_note | The second vote was tied as well | حتى التصويت الثاني وفى بتعادل |
| result.civilian_out | A civilian was voted out | خرّجتو مدني |

Four drafts reuse text that already appears in the design package: `discussion.put_phone` (demo in `reference/index.html`), `vote.title` (type sample in the same file), and `handoff.pass_label` and `reveal.role_label_sealed` (approved render `07_private`). They are still unreviewed.

Glossary keys not used by any screen: `home.packs`, `settings.sound`, `pack.locked`, `game.round`. They can stay in the glossary; nothing depends on them.

## Appendix B — Component use by screen

| Component | Screens |
|---|---|
| `TesskraButton` | All |
| `TesskraIconButton`, `TesskraAppBar` | PUB-01 to PUB-08 |
| `TesskraTextField` | OVL-01, PRV-04 |
| `PlayerRow`, `AddPlayerRow`, `CountPill` | PUB-05; `CountPill` also PRV-01 |
| `WordPackCard`, `StampLabel` | PUB-06 |
| `TesskraSheet` | OVL-01 |
| `TesskraDialog` | OVL-02 |
| `TesskraBanner` | PUB-01, PUB-05, PUB-06, PUB-07, PUB-08, PUB-09, PRV-01 to PRV-04 |
| `StateBlock`, `LoadingDots` | PUB-04, PUB-05, PUB-06, PRV-05 |
| `PhaseChip` | PUB-07, PUB-08 |
| `HandoffBlock` | PRV-01 |
| `RoleTicket` | PRV-02 |
| `VoteOption` | PRV-03 |
| `VoteTallyRow` | PUB-08, PUB-09 |
| `WinnerStamp`, `SecretWordPlaque`, `RoleRevealRow` | PUB-09 |
| `CarbonTransition`, `PrivateScope` | Every paper ↔ carbon change; every PRV screen |

Selection controls: the switch is used on PUB-03 and the checkbox inside `WordPackCard`; the stand-alone radio appears only inside `VoteOption`.

## Appendix C — Reference renders and measurements

Built by `docs/design/tools/build_screens.py --png` from `reference/screens.template.html`. The page takes its component styles, tokens and icons from the same sources as the component reference, so it cannot restyle a component. Open `reference/screens.html` in a browser for an index of every state at every size. Raw measurements are in `reference/screens_metrics.json`.

**What the renders are.** Browser compositions at exact dp sizes with: a 24 status bar and a 48 navigation bar; an assumed keyboard (260 at 568 high, 300 at 720 high); text scale applied to every font size; shrink-to-fit applied as in §1.3. Arabic is provisional; names, packs and words are mock content.

**What they are not.** They are not the app and not a device. Not verified by them: Flutter's text metrics and line breaking, real keyboard heights and behaviour, gesture-navigation insets, display cut-outs, animation, haptics, TalkBack, and how the fonts render on Android.

File names: `<state>__<width>x<height>[_ts150].png`, or `<state>__full.png` for the whole scrolling content at 360 wide.

| Screen | States rendered | Sizes |
|---|---|---|
| PUB-01 | `pub01_home`, `pub01_home_restore_failed` | 360 × 720, 320 × 568, both at scale 1.5 |
| PUB-02 | `pub02_howto` | 360 × 720, full |
| PUB-03 | `pub03_settings` | 360 × 720 |
| PUB-05 | `pub05_players_empty`, `_three`, `_six`, `_twelve` | 360 × 720; twelve also at all sizes and full |
| OVL-01 | `ovl01_add_keyboard`, `ovl01_edit_keyboard`, `ovl01_edit_duplicate`, `ovl01_edit_no_keyboard` | All four |
| PUB-06 | `pub06_packs`, `pub06_packs_none_selected` | 360 × 720 |
| PUB-07 | `pub07_discussion` | 360 × 720 |
| PUB-08 | `pub08_tally_a_nominee`, `_b_impostor`, `_c_tie`, `_d_runoff_tie`, `_12_players` | 360 × 720; twelve at all sizes and full |
| PUB-09 | `pub09_results_civilians_win`, `_impostor_wins`, `_draw`, `_12_players`, `_first_draft_three_pinned` | All four, and full |
| OVL-02 | `ovl02_leave_paper`, `ovl02_leave_carbon` | 360 × 720 |
| PRV-01 | `prv01_handoff`, `_16_chars`, `_long_name`, `_final_guess` | All four |
| PRV-02 | `prv02_sealed`, `_revealed_civilian`, `_revealed_impostor`, `_revealed_long_word`, `_saving`, `_save_error`; proposal: `prv02_proposed_sealed`, `_civilian`, `_impostor`, `_long_word` | All four |
| PRV-03 | `prv03_vote_12_none`, `_12_selected`, `_6_selected`, `_long_voter`, `_runoff_candidate`, `_runoff_non_candidate`, `_save_error` | All four; twelve also full |
| PRV-04 | `prv04_guess_empty`, `_typed`, `_review` | All four |
| PRV-05 | `prv05_resume_gate` | 360 × 720 |

Not rendered: PUB-04 (plain licence text), loading states, and the content-error states of PUB-06.

**Summary of the constrained screens** ("fits" means no scrolling is needed and every control is fully visible)

| Screen | 360 × 720 | 320 × 568 | 320 × 568, scale 1.5 |
|---|---|---|---|
| OVL-01 add, keyboard open | Fits | Primary button cut by 24 | Primary button out of view |
| OVL-01 edit, keyboard open | Delete out of view | Only title and field visible | Only title and field visible |
| PRV-02 sealed | Fits | 17 hidden | 58 hidden |
| PRV-02 revealed | Fits | Fits; buttons overlap in position by 43 | "Got it" 50 below the fold |
| PRV-03, twelve players | 4 rows visible, 541 to scroll | 2 rows visible, 693 to scroll | 1 row visible, 793 to scroll |
| PRV-04, keyboard open | Fits | Field hidden until scrolled | Field hidden until scrolled |
| PRV-04 review | Fits | Fits | 19 hidden |
| PUB-09, six players | 1019 to scroll | 1217 to scroll | 1468 to scroll |
| PRV-01, 16-character name | One line at 37 | One line at 34 | One line; name ellipsized in the button |
| PUB-01 | Fits | 38 hidden | 181 hidden |

Other measurements: no element extends past the screen edge except the winner stamp at 320 wide with scale 1.5; the only tap target under 48 is the text button (44, see §1.4).
