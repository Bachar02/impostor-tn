# Impostor TN — Screen specifications

Status: **DRAFT for Product Owner review (Stage 4).** Flows are in `UX_FLOWS.md`. Every screen is composed from components already defined in `docs/DESIGN_SYSTEM.md` §5; no new component is introduced. **No full-screen visual render exists yet** for any screen except the four demo frames (`reference/png/09` to `12`); see `UX_RESEARCH_AND_RISKS.md` §4.

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
- `displayXL` shrinks to fit one line down to 40; `displayL` shrinks to 32 and may wrap to two lines.

### 1.4 Buttons and states

As specified in `DESIGN_SYSTEM.md` §5: primary 60, secondary 52, text 44, destructive 52; pressed, disabled, focused and loading states included. A button whose action runs a checkpoint (see `UX_FLOWS.md` §3) shows the loading state (three dots, width unchanged, not tappable) until the save finishes.

### 1.5 Private wrapper (all PRV screens)

- Carbon theme. No role colour, no hard shadow except on the ticket, primary buttons are mustard and flat.
- Screenshot blocking and the app-switcher cover are active while any PRV screen is shown (ADR-0006, scope pending Q-04).
- When the app leaves the foreground, secret content is removed from the screen immediately and the flow returns to PRV-01 (`UX_FLOWS.md` F11).
- No shared-element transitions, no previews or blurred versions of secret content, no looping animation.
- Secret text is not selectable and is never copied to the clipboard.
- Sounds and haptics are identical for Civilian and Impostor.
- Colours missing from `colors.json → private` (`surfaceSunken`, `errorText`) are used as `carbonRaised` and `coralLight`, pending Q-07.

### 1.6 Errors, loading, empty

| Situation | Pattern |
|---|---|
| A save fails | Error `TesskraBanner` above the bottom action area with `state.error`; the triggering button becomes active again as "retry" (`action.retry`) |
| Something is loading for more than about 300 ms | `LoadingDots` with `state.loading`, centred |
| A list is empty | `StateBlock`: 72 circle icon, `titleM` line, `bodyM` hint |
| A field is invalid | Red-text border, helper line with `ic_alert`, one short shake (`errorShake`), error haptic |

### 1.7 Small screens

The reference frame is 360 × 720. Each screen must also work at 320 × 568 and at text scale 1.5. Where content cannot fit, it scrolls; pinned actions stay visible; touch targets stay at least 48 × 48. Screen-specific notes are given only where something beyond this rule applies.

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

1. App bar: back, title `home.new_game`, `CountPill` "1 / 2" (step) at the end.
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
2. `TesskraTextField`: label `players.name_label`, hint `players.name_hint`, helper `players.name_limit`, counter "{n} / 16" (LTR, at the end). Keyboard: the user's current keyboard, action "done".
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

**RTL and small screens.** Text is right-aligned, the caret is at the left end of Arabic text. On a 568-high screen with the keyboard open, the sheet content scrolls; the field and the primary button stay visible.

---

### PUB-06 Packs

**Purpose.** Choose the word packs and start the game (PRD §4, §10).

**Entry.** PUB-05. **Exit.** PRV-01 (game started); back to PUB-05.

**Layout**

1. App bar: back, title `home.new_game`, `CountPill` "2 / 2".
2. Heading `packs.title`★ in `titleL`.
3. List of `WordPackCard` (min height 84, gap `layout.itemGap`): title in the Kufi 20 style (`labelL`), meta line `pack.word_count` in `caption` with the number first as an LTR run.
4. Banner area above the bottom action area (validation or error).
5. Bottom action area: primary `TesskraButton` `action.start`.

**Card states** (multi-select)

| State | Appearance | Tappable |
|---|---|---|
| Selected | Shadow `public.sm`, red "selected" `StampLabel` (`ic_check`, `pack.selected`) | Yes, deselects |
| Available | Empty checkbox (28) at the end | Yes, selects (`stampIn`, medium haptic) |
| Unavailable | Sunken fill, `ic_alert`, meta `pack.empty` | No |

The "locked" card state in the design system is not used (D-04). The word count shown is the number of approved, available words in the pack.

**Screen states**

| State | Appearance | Primary |
|---|---|---|
| Loading content | `LoadingDots` + `state.loading` in place of the list | Disabled |
| Content failed to load | `StateBlock` (`ic_alert`, `state.error`) with a secondary "retry" button | Disabled |
| No approved content at all | `StateBlock` (`ic_alert`, `error.no_words`★) | Disabled |
| Nothing selected | Warning banner (`ic_alert`, `error.no_pack`★) | Disabled |
| At least one selected | No banner | Enabled |
| Starting | — | Loading state while C1 runs |
| Start failed: no eligible word | Error banner `error.no_words`★ | Enabled again |
| Start failed: save error | Error banner `state.error` | Enabled again |

Retained selections are pre-ticked when the pack is still available; a retained pack that became unavailable is shown unavailable and unticked.

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

**RTL and small screens.** Name on the right, marks then count on the left; marks run right to left. With many votes for one player the marks wrap inside their area; the count is always visible. Twelve rows scroll under the pinned button.

**Privacy.** Counts only: who voted for whom is not shown (**Q-18**). The secret word and category never appear here.

---

### PUB-09 Results

**Purpose.** Reveal the outcome and everything PRD §8 requires; offer replay (PRD §9).

**Entry.** From PUB-08 (states A, D), from PRV-04 (`carbonOut`), or launch with a finished game saved. **Exit.** PRV-01 (new game), PUB-05, PUB-01.

**Layout** (scrolling, above the pinned actions)

1. `WinnerStamp` (5 px border, radius 18, Kufi 900 at 34, rotated −5°), centred.
2. One `bodyL` line explaining why (see states).
3. `SecretWordPlaque`: caption `reveal.word_label`, the word in `displayXL` (shrinking), chip `reveal.category`.
4. Final-guess card, only when a guess was made: surface, 2.5 border, radius `md`, padding `layout.cardPadding`; caption `result.guess_label`★; the guess as typed in `titleM` (isolated); then `ic_check` + `result.guess_correct`★ in `public.success`, or `ic_x` + `result.guess_wrong`★ in `public.errorText`.
5. Section heading `players.title` in `titleM`, then one `RoleRevealRow` per player in playing order: badge, name, role tag at the end (Civilian: `role.civilian`, `role.civilian` colour, radius 8, `ic_user`; Impostor: `role.impostor`, `role.impostor` colour, pill, `ic_eye_off`).
6. Section heading `result.votes_title`★ in `titleM`; sub-heading `result.first_ballot`★ in `labelM` and its `VoteTallyRow`s; if there was a runoff, sub-heading `vote.runoff_title`★ and its rows.
7. Bottom action area: accent `TesskraButton` `action.play_again` with `ic_rotate_ccw`; below it secondary `action.change_setup`★; below it text button `action.home`★.

**States**

| State | Stamp | Explanation line | Guess card |
|---|---|---|---|
| Civilian nominated | `result.impostor_wins`, `public.errorText`, solid | `result.civilian_out`★ | No |
| Impostor nominated, guess correct | `result.impostor_wins`, `public.errorText`, solid | — | Yes, correct |
| Impostor nominated, guess wrong | `result.civilians_win`, `role.civilian` colour, solid | — | Yes, wrong |
| Runoff tied | `result.draw`, `public.textPrimary`, dashed | `result.draw_note`★ | No |
| Starting a new game | — | — | Accent button loading while C8 + C1 run |
| New game failed | Error banner (`error.no_words`★ or `state.error`); the result stays visible | | |

**Interactions.** On first display: the stamp slams in and the content rises (`winnerReveal`, 600 ms, heavy haptic). On recovery or with reduced motion: no slam. Play again → `carbonIn` → PRV-01 for player 1 of the new game. System back does nothing (the three buttons are the exits).

**RTL and small screens.** Role tags and counts sit on the left. A long secret word shrinks to one line; a long guess wraps. The three actions take 60 + 52 + 44 plus gaps; at 568 high about half the screen remains for content, which scrolls.

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

1. `handoff.pass_to` without the name ("pass the phone to") in `bodyL`, `private.textSecondary`, centred.
2. The player's name in `displayL`, `private.textPrimary`, centred: 48, shrinking to 36 then 32 for long names, two lines at most, isolated.
3. `CountPill` "{position} / {total}" in `numericM`, 2.5 `private.borderStrong` border. Omitted for the final guess, where there is only one person.
4. Bottom action area: primary `TesskraButton` (private: mustard, flat) `handoff.i_am` with the name.

Nothing else appears: no phase label, no icon, no leave control, no decoration. The screen is identical for reveal, voting, runoff and the final guess, so it tells an onlooker nothing.

**States**

| State | Difference |
|---|---|
| Default | As above |
| Saving | Button loading. Only on the first handoff of a game, while C2 runs |
| Save error | Error banner (`state.error`, `coralLight` border and text) above the button; button active again |

**Interactions.** Button → the phase's private screen, 220 ms content change on the same carbon ground; no haptic, no sound, no motion beyond the content change. System back → OVL-02.

**RTL and small screens.** Everything is centred. If the name wraps to two lines the block grows; the button stays pinned. In the button, "{name}" may be long: the label stays on one line and the name is ellipsized. How far the label may shrink first is not specified anywhere (Q-23).

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
| Sealed | Label `reveal.role_label` (sealed form "دور"), the **player's name**, stamp `ic_lock` | `ic_eye_off` + `reveal.sealed` in `labelL` | Bottom action area: primary `reveal.show`; below it private secondary `action.back` |
| Revealing | Seal lifts (`ticketReveal`, 420 ms, medium haptic); secret content fades in only during the last 120 ms | | None active |
| Revealed, Civilian | Label `reveal.role_label`, `role.civilian`, stamp `ic_user` | Caption `reveal.word_label`; the word in `displayXL` (shrinks to 40, one line); chip `reveal.category` | Under the ticket: primary `reveal.ack`, disabled for the first 800 ms |
| Revealed, Impostor | Label `reveal.role_label`, `role.impostor`, stamp `ic_user` | Caption `reveal.category_only`; the category in `displayXL`; chip `reveal.no_word` | Same |
| Saving | Sealed again, immediately | Sealed | Under the ticket: the same button in its loading state |
| Save error | Sealed | Sealed | Error banner (`state.error`); under the ticket: primary `action.retry` |

The two revealed states use the same widgets, sizes, colours, icon, sound and haptic. Only the text differs. The Impostor never sees the word, an alias or a hint.

**Interactions**

- A tap anywhere other than a button does nothing. There is no hold gesture and no timer; the revealed state stays until acknowledged.
- `reveal.ack`: the secret is removed in the same frame (`ticketHide`, light haptic), then C3 runs. The app moves on only after C3 succeeds: to PRV-01 for the next player (220 ms), or `carbonOut` to PUB-07 after the last player (520 ms, medium haptic).
- Retry after a save error repeats C3 only.
- `action.back` (sealed only) → PRV-01, same player.
- System back: sealed → like `action.back`; revealing, revealed, saving → ignored.
- Leaving the foreground in any state → secret removed → PRV-01, same player, on return (unless C3 had already succeeded).

**RTL and small screens.** Label and role at the right of the top row, stamp at the left. At 320 × 568 the ticket (about 300 high) and the acknowledge button fit with the hint; the sealed-state buttons at the bottom do not overlap the acknowledge position. At text scale 1.5 the ticket grows and the screen scrolls; the 800 ms lock still protects against a double tap landing on "got it".

**Privacy.** The most sensitive screen. §1.5 applies in full. The acknowledge lock value (800 ms) comes from `INTERACTIONS_AND_ANIMATIONS.md` §5 and has no token yet (Q-23). A screen reader would speak the role aloud; see `UX_RESEARCH_AND_RISKS.md` R-07.

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

**Interactions.** Tapping an available option selects it (`selection`, 140 ms, selection haptic); tapping another moves the selection. Confirm → C5 / C6 → the screen clears to PRV-01 for the next voter (220 ms), or `carbonOut` to PUB-08 after the last voter. After a successful save the vote cannot be seen or changed (D-02). `action.back` and system back → PRV-01, same voter, selection discarded. Leaving the foreground → the same.

**RTL and small screens.** Radio on the right, "you" tag on the left. Eleven options do not fit on any phone: the list scrolls under the pinned buttons. On a 568-high screen about three options are visible at once; the list shows a partly visible row at the fold so that scrolling is evident.

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
4. The guess, trimmed and with repeated spaces collapsed, in `displayL` (shrinks, two lines at most), isolated, centred.
5. Bottom action area: primary `guess.confirm_final`★; below it private secondary `guess.edit`★.

**States**

| State | Behaviour |
|---|---|
| Entry, empty or spaces only | Primary disabled |
| Entry, text present | Primary enabled → review state; the keyboard closes |
| Review | `guess.edit`★ returns to entry with the text kept |
| Saving | Primary loading while C7 runs |
| Save error | Error banner (`state.error`); primary active again. The guess is not lost and not counted twice |

**Interactions.** Final confirmation → C7 → `carbonOut` → PUB-09. No haptic or sound distinguishes a correct from a wrong guess on this screen; the result screen does that. System back: review → entry; entry → OVL-02. Leaving the foreground before C7 → PRV-01 for the Impostor, typed text discarded.

**RTL and small screens.** Right-aligned text, caret at the left end of Arabic text; Latin input is accepted and shown as typed. With the keyboard open on a 568-high screen the title, the field and the confirm button must all remain visible; the hint line may scroll away.

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

**Privacy.** Shows no name, phase, count or any other detail of the saved game.

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

Two drafts reuse text that already appears in the design package: `discussion.put_phone` (demo in `reference/index.html`) and `vote.title` (type sample in the same file). They are still unreviewed.

Glossary keys not used by any screen: `home.packs`, `settings.sound`, `pack.locked`, `game.round`. They can stay in the glossary; nothing depends on them.

## Appendix B — Component use by screen

| Component | Screens |
|---|---|
| `TesskraButton` | All |
| `TesskraIconButton`, `TesskraAppBar` | PUB-01 to PUB-08 |
| `TesskraTextField` | OVL-01, PRV-04 |
| `PlayerRow`, `AddPlayerRow`, `CountPill` | PUB-05; `CountPill` also PUB-06, PRV-01 |
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
