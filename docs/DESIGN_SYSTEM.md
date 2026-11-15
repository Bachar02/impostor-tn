# Impostor TN — Design System (Tesskra)

Status: **Stage 2 foundation, awaiting review.** Source of truth for values: `docs/design/tokens/*.json`. Visual reference: `docs/design/reference/index.html` and `docs/design/reference/png/`. If this document and a token file disagree, the token file wins.

Units are Flutter logical pixels (dp / sp).

## 1. Colour

### Palette (`colors.json → palette`)

| Token | Hex | Token | Hex |
|---|---|---|---|
| paper | `#F3EBDD` | carbon | `#141C30` |
| paperRaised | `#FFFDF7` | carbonRaised | `#1E2942` |
| paperSunken | `#EADFCB` | carbonOutline | `#6B7798` |
| paperEdge | `#C9BEA8` | carbonMuted | `#B4BACB` |
| ink | `#1B2A4A` | coralLight | `#FF8A7A` |
| inkMuted | `#4F5A73` | mintLight | `#7FD1A8` |
| inkDisabled | `#8A8FA0` | shadowDeep | `#0A0F1C` |
| stamp | `#C92D22` | mustard | `#E9A820` |
| stampPressed | `#A9241B` | mustardPressed | `#CF9212` |
| stampText | `#B3261C` | mustardText | `#7A5200` |
| bottle | `#1F6B4E` | blueInk | `#24508F` |

### Semantic roles

| Role | Public (paper) | Private (carbon) |
|---|---|---|
| background | paper | carbon |
| surface | paperRaised | carbonRaised |
| surfaceSunken (pressed, disabled fill) | paperSunken | carbonRaised |
| textPrimary | ink | paper |
| textSecondary | inkMuted | carbonMuted |
| textDisabled | inkDisabled | carbonOutline |
| border | ink | carbonOutline (default), paper (strong) |
| primary / onPrimary | stamp / paperRaised | mustard / carbon |
| accent / onAccent | mustard / ink | not used |
| success | bottle | mintLight |
| warning (fill) / warningText | mustard / mustardText | not used |
| error (fill) / errorText | stamp / stampText | coralLight |
| focusRing | blueInk | paper |
| ticket / onTicket | n/a | paper / ink |

**Role colours** (`colors.json → role`): civilian = blueInk, impostor = stamp. Public result screens only. Always with icon and label.

### Contrast (computed, WCAG 2.x)

| Pair | Ratio | Pair | Ratio |
|---|---|---|---|
| ink on paper | 12.01 | paper on carbon | 14.32 |
| inkMuted on paper | 5.83 | carbonMuted on carbon | 8.74 |
| paperRaised on stamp | 5.32 | mustard on carbon | 8.14 |
| stampText on paper | 5.52 | carbonOutline on carbon (borders) | 3.81 |
| ink on mustard | 6.83 | coralLight on carbon | 7.40 |
| blueInk on paper | 6.77 | mintLight on carbon | 9.36 |

Rules: use `stampText`, not `stamp`, for red text on paper. Disabled text is exempt from contrast and must never carry essential information.

## 2. Typography

| Family | Role | Weights | File | Licence |
|---|---|---|---|---|
| Noto Kufi Arabic | Display, titles, primary button labels, big numerals | 800, 900 (variable `wght`) | `NotoKufiArabic[wght].ttf` | SIL OFL 1.1 |
| IBM Plex Sans Arabic | Body, labels, captions | 400, 500, 600, 700 | `IBMPlexSansArabic-*.ttf` | SIL OFL 1.1 |

| Style | Family | Size / line height | Weight | Use |
|---|---|---|---|---|
| displayXL | Kufi | 72 / 1.3 | 900 | Secret word, winner. Auto-shrink to one line, min 40 |
| displayL | Kufi | 48 / 1.3 | 900 | Name on handoff, result headline. Min 32 |
| displayM | Kufi | 34 / 1.35 | 800 | Large headings |
| titleL | Kufi | 26 / 1.4 | 800 | Screen and dialog titles |
| titleM | Plex | 20 / 1.45 | 700 | Section headings, names in lists |
| bodyL | Plex | 18 / 1.6 | 400 | Instructions |
| bodyM | Plex | 16 / 1.6 | 400 | Secondary text |
| labelL | Kufi | 20 / 1.3 | 800 | Primary and accent buttons |
| labelM | Plex | 16 / 1.3 | 600 | Secondary buttons, chips |
| caption | Plex | 13 / 1.5 | 500 | Helper text, counters |
| numericL | Kufi | 34 / 1.2 | 900 | Vote counts (LTR, tabular) |
| numericM | Plex | 16 / 1.3 | 700 | Progress pills such as `2 / 6` (LTR) |

Rules: letter spacing 0; never below 12; body never below 16; Western digits; support system text scale up to 1.5 (above that, clamp display styles only, never body).

## 3. Spacing, layout, radii, borders

| Group | Values |
|---|---|
| Spacing scale | 0, 4, 8, 12, 16, 20, 24, 32, 40, 48, 64 |
| Screen margin | 24 horizontal; 16 when width < 360 |
| Screen padding | top 16, bottom 24, both added to system safe-area insets |
| Gaps | section 24, list item 12 |
| Padding | card 16, large card and ticket 20, dialog 24 |
| Max content width | 480, centred on larger devices |
| Touch target | minimum 48 × 48 |
| Heights | primary button 60, secondary 52, compact/text 44, input 56, player row 64, vote option 64, app bar 56 |
| Icons | 24 (20 inside chips and stamps), stroke 2.25 |
| Radii | xs 8, sm 12, md 16 (buttons, inputs, cards), lg 20 (ticket, dialog), xl 28 (sheet top), pill 999 |
| Borders | standard 2.5, strong 3.5 (stamps), hairline 1.5; dashes 8 on / 6 off |
| Ticket notch | circle diameter 24, centred on the perforation line, filled with the screen background |

Layout: single column. Primary action pinned to the bottom of the screen; content scrolls behind it if needed. With the keyboard open, the focused input and the primary action stay visible (sheet or screen resizes; nothing is hidden under the keyboard).

## 4. Shadows

Hard offset, zero blur, colour ink. Not mirrored in RTL.

| Token | Offset | Use |
|---|---|---|
| public.sm | 3, 3 | Selected card |
| public.md | 4, 4 | Primary and accent buttons, plaque |
| public.lg | 6, 6 | Dialog, hero ticket |
| private.ticket | 0, 6 (shadowDeep) | Role ticket only |

Pressed: translate the element by its shadow offset and remove the shadow. Private buttons have no shadow and move down 2.

## 5. Components

Each has a render in `docs/design/reference/png/` (file in brackets).

### Buttons [03_buttons]

| Variant | Fill / text / border | Height | Label | Notes |
|---|---|---|---|---|
| Primary (public) | stamp / paperRaised / ink 2.5 | 60 | labelL | Shadow md. One per screen |
| Accent (public) | mustard / ink / ink 2.5 | 60 | labelL | Shadow md. Replay and positive secondary |
| Secondary | transparent / textPrimary / border 2.5 | 52 | labelM | Pressed fill surfaceSunken |
| Destructive | transparent / errorText / errorText 2.5 | 52 | labelM | Optional leading icon |
| Text | none / textPrimary underlined | 44 | labelM | Low-emphasis navigation |
| Primary (private) | mustard / carbon / carbonOutline 2.5 | 60 | labelL | Flat |
| Icon button | surface / textPrimary / border 2.5, radius 14 | 48 × 48 | n/a | Ghost variant has no border or fill. Needs a semantic label |

States: default, pressed (see Shadows), disabled (fill surfaceSunken, text and border textDisabled, no shadow), focused (3 px focusRing, offset 3), loading (label replaced by three dots, width unchanged).

### Text input [04_inputs]
Height 56, radius 16, border 2.5, fill surface, text bodyL, right-aligned. Label above (labelM), helper and counter below (caption; counter is LTR on the left). Focused: 3 px focusRing. Error: border and helper in errorText with alert icon. Keyboard: Arabic text, action "done".

### Selection controls [04_inputs]
Checkbox 28 (radius 8), radio 28, switch 56 × 32. On = primary fill. In RTL the control sits on the left of its label and the switch thumb travels left when on. The whole row (min height 56) is the touch target.

### Player row [05_players_packs]
Height 64. Right to left: index badge (40, mustard, numeric), name (titleM, one line, ellipsis), one ghost edit button. Tapping the row or the pencil opens the edit sheet, which holds rename and delete. "Add player" is a dashed row of the same height. Count pill (`3 / 12`, numericM) sits opposite the section title. Validation banner (mustard, alert icon) appears when the count is out of range and the start button is disabled.

### Word-pack card [05_players_packs]
Min height 84, padding 14 × 16. Title labelL-size kufi 20, meta caption. States: selected (shadow sm + red "selected" stamp with check), available (empty checkbox), locked (sunken fill, ink "locked" stamp with lock icon), empty/unavailable (sunken fill, alert icon, reason in meta).

### Feedback and navigation [06_feedback]
- **Dialog**: surface, border 2.5, radius 20, shadow lg, padding 24. Title titleL, body bodyM. Buttons stacked full width; the safe action is last (closest to the thumb). Scrim carbon 60 %.
- **Bottom sheet**: top radius 28, grab handle 44 × 5, padding 24. Used for edit player and pickers.
- **Banner**: border 2.5, radius 16, icon + bodyM. Variants: info (surface), warning (mustard fill), error (errorText border and text).
- **Empty / error state**: 72 circle outline icon, titleM line, bodyM hint, optional button.
- **Loading**: three ink dots pulsing; static when animations are disabled.
- **App bar**: height 56. Back icon button on the right (arrow points right), title titleL at 22, optional step pill on the left.
- **Chips / pills**: border 2.5, pill radius, labelM. Phase chips carry an icon.

### Private components [07_private]
- **Handoff block**: carbon ground. Small line "pass the phone to", name in displayL (shrinks to 36 then 32 for long names, wraps to two lines at most), position pill, then one primary button "I am {name}". Nothing else on screen.
- **Role ticket**: paper fill on carbon, radius 20, shadow private.ticket. Top row: label + role name (titleL) and a 52 px outlined square icon stamp rotated 6°. Perforation with two notches. Bottom block min height 206: label (caption), big text (displayXL, shrinks), chip. States: **sealed** (top row shows the player name and a lock; bottom shows eye-off icon and "role hidden"), **revealed**.
- **Identical structure for both roles**: Civilian shows label "secret word", the word, chip "category: X". Impostor shows label "category only", the category, chip "you don't know the word". Same icon, same colours, same sizes.
- **Vote option**: height 64, surface fill, border carbonOutline. Radio on the right, name titleM. Selected: mustard border plus inner mustard outline and filled radio. Unavailable: dashed border, disabled text, reason on the left.

### Results components [08_results]
- **Winner stamp**: 5 px border, radius 18, kufi 900 at 34, rotated −5°. Civilians win: blueInk. Impostor wins: stampText. Draw: ink, dashed.
- **Secret word plaque**: surface, border 2.5, radius 20, shadow md; caption, word (displayXL shrinking), category chip.
- **Role reveal row**: player row with a role tag on the left. Civilian: blueInk fill, radius 8, user icon. Impostor: stamp fill, pill radius, eye-off icon.
- **Vote tally row**: name, one small rotated red square per vote, count in numericL, dashed divider. Tie banner (mustard, equals icon) introduces a runoff.

## 6. Iconography
Lucide (ISC licence), 24 × 24, stroke 2.25, round caps, `currentColor`. Files: `docs/design/assets/icons/ic_<name>.svg`. `ic_alert.svg` is drawn for this project in the same style. Directional icons: use `ic_arrow_right` for "back" and `ic_chevron_left` for "forward / next" in RTL; do not auto-mirror other icons.

## 7. Mapping to Flutter (guidance, not code)

| Token source | Flutter target |
|---|---|
| `colors.json → public` | `ThemeData(brightness: light)` `ColorScheme`: background/surface → `surface`, primary → `primary`, onPrimary → `onPrimary`, accent → `secondary`, error → `error`, textPrimary → `onSurface`, border → `outline` |
| `colors.json → private` | A second `ThemeData(brightness: dark)` built the same way |
| Tokens with no Material slot (surfaceSunken, ticket, role colours, hard shadows, borders, durations) | One `ThemeExtension` (suggested name `TesskraTokens`) registered on both themes |
| `typography.json → styles` | `TextTheme`: displayXL→displayLarge, displayL→displayMedium, displayM→displaySmall, titleL→headlineSmall, titleM→titleLarge, bodyL→bodyLarge, bodyM→bodyMedium, labelL→labelLarge, labelM→labelMedium, caption→bodySmall; numeric styles in the extension |
| Kufi weights | `fontVariations: [FontVariation('wght', 800 or 900)]` on the variable file |
| `radii.json`, `spacing.json` | Constants; component themes (`FilledButtonThemeData`, `InputDecorationTheme`, `DialogTheme`, `BottomSheetThemeData`) |
| `shadows.json` | `BoxShadow(offset, blurRadius: 0, color)` |
| `animations.json` | `Duration` and `Cubic` constants; honour `MediaQuery.disableAnimations` |

Private screens are wrapped in the private theme by one wrapper widget; that wrapper is also where screenshot blocking and the app-switcher cover belong (to be confirmed against the PRD).

Suggested reusable widgets: `TesskraButton` (variants), `TesskraIconButton`, `TesskraTextField`, `PlayerRow`, `AddPlayerRow`, `CountPill`, `WordPackCard`, `StampLabel`, `TesskraDialog`, `TesskraSheet`, `TesskraBanner`, `StateBlock`, `LoadingDots`, `TesskraAppBar`, `PhaseChip`, `HandoffBlock`, `RoleTicket`, `VoteOption`, `WinnerStamp`, `SecretWordPlaque`, `RoleRevealRow`, `VoteTallyRow`, `CarbonTransition`, `PrivateScope`.
