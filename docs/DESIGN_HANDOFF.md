# Impostor TN — Design Handoff

Status: **DRAFT — Stage 2 (foundation) only. Not ready for implementation.** Stages 3–6 (flows, per-screen specifications, validation, final handoff) are not done. Do not start Flutter work from this package until the Product Owner approves the final handoff.

Read in this order: this file → `DESIGN_DIRECTION.md` → `DESIGN_SYSTEM.md` → token files → `ARABIC_LOCALIZATION.md` → `INTERACTIONS_AND_ANIMATIONS.md`.

## 1. What exists now

| Deliverable | Path | State |
|---|---|---|
| Direction and identity | `docs/DESIGN_DIRECTION.md` | Complete for Stage 2 |
| Design system | `docs/DESIGN_SYSTEM.md` | Complete for Stage 2 |
| Localization, glossary, font licences | `docs/ARABIC_LOCALIZATION.md` | Drafted; 0 strings approved |
| Interaction and animation rules | `docs/INTERACTIONS_AND_ANIMATIONS.md` | Foundation; per-screen detail pending |
| Tokens | `docs/design/tokens/{colors,typography,spacing,radii,shadows,animations}.json` | Complete for Stage 2 |
| Fonts + licences | `docs/design/assets/fonts/` | Complete, unmodified upstream files |
| Icons (26) + licence | `docs/design/assets/icons/` | Complete for known needs |
| Logo, stamp, app-icon layers | `docs/design/assets/logo/` | Wordmark provisional (name spelling) |
| Texture | `docs/design/assets/decor/paper_grain.png` | Optional |
| Asset manifest | `docs/design/ASSET_MANIFEST.json` | Complete |
| Component reference (HTML, with a working reveal demo) | `docs/design/reference/index.html` | Complete for Stage 2 |
| Component renders (2×) | `docs/design/reference/png/01…12_*.png` | Complete for Stage 2 |
| Design tooling | `docs/design/tools/` | Regenerates logo and reference |

## 2. What does not exist yet

| Missing | Blocked by |
|---|---|
| `docs/UX_FLOWS.md` | PRD v0.3 not available to the design session |
| `docs/SCREEN_SPECIFICATIONS.md` and per-screen visual references (47 screens + states) | UX flows |
| `docs/UX_RESEARCH_AND_RISKS.md` | Stages 3–5 |
| Clickable prototype of the full game | Screen design |
| Sound effects | Not produced; names reserved in `animations.json` |
| Tutorial illustrations, Play Store graphics, raster icon exports | Later stages |
| Approved Arabic strings | Derja review |

## 3. Fonts

- Display: `NotoKufiArabic` (variable file; use `wght` 800 and 900).
- Text: `IBMPlexSansArabic` (400, 500, 600, 700).
- Ship both `OFL-*.txt` files with the app and list both fonts in the in-app credits screen.
- Do not substitute Lalezar, Almarai, Cairo or Tajawal: they lack the letter ڨ.

## 4. Themes

- Two themes built from `colors.json`: `public` (paper, light) and `private` (carbon, dark).
- A screen is private if a single player is meant to see it alone: handoff, role reveal, voting, final guess, resume gate. Everything else is public.
- Private screens share one wrapper that applies the private theme and the privacy protections.
- Moving between themes uses `carbonIn` / `carbonOut` from `animations.json`.
- Role colours are never used inside the private theme.

## 5. Reusable widgets

See the list at the end of `DESIGN_SYSTEM.md` §7. Each maps to one block in the component reference.

## 6. Layout and RTL

- Sizes and spacing: `spacing.json`. Reference frame: 360 × 720; margins tighten below 360 wide; content is capped at 480 wide.
- RTL rules: `ARABIC_LOCALIZATION.md` §2. Use start/end, never left/right.

## 7. Naming conventions

| Kind | Pattern |
|---|---|
| Icons | `ic_<name>.svg` |
| Logo | `<what>_<variant>.svg` |
| App icon | `app_icon_<layer>.svg` |
| Sounds (future) | `sfx_<event>.ogg` |
| Reference renders | `NN_<section>.png` |
| Token references | `{group.key}`, e.g. `{palette.ink}` |
| String keys | `<area>.<name>`, e.g. `reveal.ack` |

## 8. Needs human review

1. **PRD v0.3** must be supplied; every gameplay-dependent choice here is an assumption: self-vote rule, name length (16 shown), pack locking, resume behaviour, what the Impostor sees.
2. **All Arabic strings**, including the product name spelling used in the wordmark.
3. **Fonts on real devices**: rendering, line heights and the ڨ glyph on at least one small and one large Android phone.
4. **Licence reading**: OFL and ISC terms were read from the upstream licence files; not reviewed by a lawyer.
5. **Accessibility**: contrast ratios are computed; nothing has been tested with TalkBack, large text, or users.
6. **Usability**: no user testing has been done on tap-to-reveal, the 800 ms acknowledge lock, or the paper/carbon signal.
