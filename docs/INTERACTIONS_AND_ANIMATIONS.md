# Impostor TN — Interactions and Animations

Status: **Stage 2 foundation.** Values live in `docs/design/tokens/animations.json`. Per-screen interaction detail will be added in Stage 4 once flows are checked against PRD v0.3. A working example of the reveal sequence is in `docs/design/reference/index.html` (section 9).

## 1. Timing and curves

| Token | ms | | Curve | Cubic |
|---|---|---|---|---|
| instant | 80 | | standard | 0.2, 0, 0, 1 |
| fast | 140 | | enter | 0, 0, 0, 1 |
| base | 220 | | exit | 0.3, 0, 1, 1 |
| slow | 360 | | stamp (overshoot) | 0.34, 1.56, 0.64, 1 |
| reveal | 420 | | | |
| themeShift | 520 | | | |
| stagger | 40 | | | |

## 2. Component states

| State | Treatment |
|---|---|
| Pressed | Element moves by its shadow offset, shadow removed (80 ms). Private: moves down 2 |
| Selected | Border/fill change plus a check or filled radio (140 ms) |
| Disabled | Sunken fill, disabled text and border, no shadow, no response |
| Focused | 3 px focus ring, offset 3 |
| Error | Red-text border and helper line with alert icon; one short shake |
| Loading | Label replaced by three dots; control keeps its size and is not tappable |

## 3. Named interactions

| Moment | Purpose | Motion | ms | Haptic | Sound |
|---|---|---|---|---|---|
| Start a game | Mark the move from setup to play | Button press, then carbonIn | 80 + 520 | medium | paper slide |
| Add player | Confirm the row was added | New row fades in and rises 8 | 220 | light | none |
| Remove player | Confirm removal | Row fades and collapses | 140 | light | none |
| Invalid name | Explain what is wrong | Shake + helper text | 240 | error | none |
| Select word pack | Confirm choice | "Selected" stamp lands (stampIn) | 280 | medium | stamp |
| Pass the phone (handoff) | Calm, unambiguous | No motion beyond the screen change | 220 | none | none |
| Reveal role | Deliberate, private | Seal lifts; content fades in only after the seal is gone | 420 | medium | ticket tear (same for both roles) |
| Acknowledge role | Hide immediately | Content removed in the same frame; next handoff appears | 0 + 220 | light | none |
| Last player done | Return to the table | carbonOut | 520 | medium | paper slide |
| Change speaking turn | Show whose turn it is | Name cross-fades; turn marker slides | 220 | light | soft tick |
| Select suspect | Confirm selection | Radio fills, mustard outline | 140 | selection | none |
| Confirm vote | Final and private | Button press; screen clears to next handoff | 80 + 220 | medium | none |
| Count votes | Build suspense | Vote marks land one by one, 160 apart | variable | light per mark | soft stamp |
| Reveal vote result | Announce outcome | Top row is emphasised; tie banner slides in | 360 | medium | stamp |
| Enter final guess | Keep focus on typing | Keyboard opens; no decoration | system | none | none |
| Reveal winner | Payoff | Winner stamp slams in, headline rises | 600 | heavy | win / lose / draw cue |
| Play again | Fast restart | Standard screen change | 220 | light | none |

Sound file names referenced by tokens (`sfx_stamp`, `sfx_stamp_soft`, `sfx_paper_slide`, `sfx_ticket_tear`, `sfx_win_civilians`, `sfx_win_impostor`, `sfx_draw`) are **not produced yet**; see the handoff document.

## 4. Paper ↔ carbon transition

| | carbonIn (public → private) | carbonOut (private → public) |
|---|---|---|
| Motion | Carbon sheet slides up from the bottom edge and covers the paper | Private content removed first, then the sheet slides down |
| Duration | 520 ms, standard curve | 520 ms, standard curve |
| Content | Private content fades in during the last 140 ms | Public content is already underneath |
| Reduced motion | 140 ms cross-fade | 140 ms cross-fade |
| Status / navigation bars | Switch to light icons on carbon when the sheet passes the midpoint | Switch back to dark icons |

Between two private screens (handoff → ticket → next handoff) the ground stays carbon; only content changes.

## 5. Role reveal sequence

1. **Handoff** (carbon): name and position only. Button "I am {name}".
2. **Sealed ticket**: name on the ticket, role hidden. One labelled button reveals. A tap elsewhere does nothing.
3. **Revealed**: role and word (or category) shown. It stays until acknowledged; there is no timer.
4. **Acknowledge**: the button appears where the reveal button was not (directly under the ticket) and is disabled for the first 800 ms, so a double tap cannot skip the role.
5. On acknowledge, the secret content is removed in the same frame. The app advances only after the acknowledgement has been saved; while saving, the button shows the loading state and the ticket is already sealed.
6. **Interruption** at steps 2–5 (app backgrounded, call, screen lock): on return, show the neutral handoff for the correct player. Never restore a revealed ticket.

## 6. Privacy rules for motion and sound

- No animation renders the word, category or role outside the revealed state: no previews, no shared-element transitions, no blurred versions.
- No looping or attention-seeking animation on handoff screens.
- Sounds and haptics on private screens are identical for both roles.
- The app-switcher preview and screenshots of private screens should show a neutral cover (implementation detail to confirm against the PRD).

## 7. Accessibility

- When Android "Remove animations" is on, use the `reducedMotion` values: cross-fades of 140 ms or less, no shake, no overshoot. Haptics remain.
- Sound and haptics each have a setting; no information is conveyed by sound or vibration alone.
- Every animated state change also has a static visual end state (icon + text).
- Nothing flashes more than three times per second.

None of the above has been tested with users or with TalkBack yet.
