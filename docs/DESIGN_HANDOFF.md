# Impostor TN — Design Handoff

Status: **DRAFT — Stages 2 to 5 written, awaiting Product Owner review. Not approved for implementation.** The foundation (Stage 2) is unchanged. UX flows, screen specifications and the risk review (Stages 3–5) were drafted on 2026-11-16 against PRD v0.3 and `docs/product/DECISIONS.md`. Product screens and gameplay must not be built until the Product Owner approves these documents and settles the blocking open decisions listed in §8.

Read in this order: this file → `DESIGN_DIRECTION.md` → `DESIGN_SYSTEM.md` → token files → `design/UX_FLOWS.md` → `design/SCREEN_SPECIFICATIONS.md` → `ARABIC_LOCALIZATION.md` → `INTERACTIONS_AND_ANIMATIONS.md` → `design/UX_RESEARCH_AND_RISKS.md`.

Location note: the foundation documents live in `docs/`; the three UX documents were created in `docs/design/` as requested. This file was updated in place at `docs/DESIGN_HANDOFF.md` rather than moved, so existing references keep working.

## 1. What exists now

| Deliverable | Path | State |
|---|---|---|
| Direction and identity | `docs/DESIGN_DIRECTION.md` | Complete for Stage 2 |
| Design system | `docs/DESIGN_SYSTEM.md` | Complete for Stage 2; MVP exclusions noted in §9 |
| Localization, glossary, font licences | `docs/ARABIC_LOCALIZATION.md` | Drafted; 0 strings approved |
| Interaction and animation rules | `docs/INTERACTIONS_AND_ANIMATIONS.md` | Foundation; per-screen behaviour is now in the screen specifications |
| UX flows | `docs/design/UX_FLOWS.md` | **Draft, awaiting review** |
| Screen specifications (14 screens, 2 overlays, all states) | `docs/design/SCREEN_SPECIFICATIONS.md` | **Draft, awaiting review** |
| Assumptions, risks, inconsistencies, validation plan | `docs/design/UX_RESEARCH_AND_RISKS.md` | **Draft, awaiting review.** No user research has been done |
| Tokens | `docs/design/tokens/{colors,typography,spacing,radii,shadows,animations}.json` | Complete for Stage 2; additions proposed (Q-06, Q-07, Q-23) |
| Fonts + licences | `docs/design/assets/fonts/` | Complete, unmodified upstream files |
| Icons (26) + licence | `docs/design/assets/icons/` | Complete for the specified screens; stroke width under review (Q-06) |
| Logo, stamp, app-icon layers | `docs/design/assets/logo/` | Wordmark provisional (name spelling) |
| Texture | `docs/design/assets/decor/paper_grain.png` | Optional; not used in the MVP screens |
| Asset manifest | `docs/design/ASSET_MANIFEST.json` | Complete |
| Component reference (HTML, with a working reveal demo) | `docs/design/reference/index.html` | Complete for Stage 2 |
| Component renders (2×) | `docs/design/reference/png/01…12_*.png` | Complete for Stage 2 |
| Design tooling | `docs/design/tools/` | Regenerates logo and reference |

## 2. What does not exist yet

| Missing | Blocked by |
|---|---|
| Product Owner approval of the flows and screen specifications | Review |
| Full-screen visual references for the 14 screens | Not produced. Screens are specified by composition of rendered components only |
| Carbon-theme renders of the dialog, text field and error banner | Not produced; values derived from the reference tool's mapping |
| Clickable prototype of the full game | Not produced |
| Sound effects | Not produced; names reserved in `animations.json`. The MVP is specified as silent (D-05) |
| Tutorial illustrations | Not produced; the tutorial uses icons |
| Play Store graphics, raster icon exports | Later stages |
| Approved Arabic strings | Derja review of the glossary and of the new drafts in the screen specifications, Appendix A |
| User testing of any kind | A first playable build |

## 3. Fonts

- Display: `NotoKufiArabic` (variable file; use `wght` 800 and 900).
- Text: `IBMPlexSansArabic` (400, 500, 600, 700).
- Ship both `OFL-*.txt` files with the app and list both fonts in the in-app credits (Settings, PUB-03, with full texts on PUB-04).
- Do not substitute Lalezar, Almarai, Cairo or Tajawal: they lack the letter ڨ.

## 4. Themes

- Two themes built from `colors.json`: `public` (paper, light) and `private` (carbon, dark).
- A screen is private if a single player is meant to see it alone: handoff, role ticket, vote, final guess, resume gate (PRV-01 to PRV-05). Everything else is public.
- Private screens share one wrapper that applies the private theme and the privacy protections.
- Moving between themes uses `carbonIn` / `carbonOut` from `animations.json`.
- Role colours are never used inside the private theme. They appear only on the results screen (PUB-09).

## 5. Reusable widgets

See the list at the end of `DESIGN_SYSTEM.md` §7. Each maps to one block in the component reference. `SCREEN_SPECIFICATIONS.md` Appendix B lists which screens use which component. No screen needs a component outside that list.

## 6. Layout and RTL

- Sizes and spacing: `spacing.json`. Reference frame: 360 × 720; margins tighten below 360 wide; content is capped at 480 wide.
- RTL rules: `ARABIC_LOCALIZATION.md` §2. Use start/end, never left/right.
- Common screen conventions: `SCREEN_SPECIFICATIONS.md` §1.

## 7. Naming conventions

| Kind | Pattern |
|---|---|
| Screens | `PUB-nn` (paper), `PRV-nn` (carbon), `OVL-nn` (overlay) |
| Flows and checkpoints | `F1`…`F11`, `C0`…`C8` (`UX_FLOWS.md`) |
| Icons | `ic_<name>.svg` |
| Logo | `<what>_<variant>.svg` |
| App icon | `app_icon_<layer>.svg` |
| Sounds (future) | `sfx_<event>.ogg` |
| Reference renders | `NN_<section>.png` |
| Token references | `{group.key}`, e.g. `{palette.ink}` |
| String keys | `<area>.<name>`, e.g. `reveal.ack` |

## 8. Needs Product Owner review

Full wording, evidence and recommendations are in `docs/product/DECISIONS.md`.

**Blocking the screens or the engine**

1. Approval of `UX_FLOWS.md` and `SCREEN_SPECIFICATIONS.md` as a whole.
2. Q-01 player-name length and duplicate rules.
3. Q-16 the moment the word is recorded in the cooldown.
4. Q-17 how players are reordered.
5. Q-18 whether results show counts only or who voted for whom.
6. Q-19 no visible leave control on private screens.
7. Q-22 the review step and the "no empty guess" rule for the final guess (with Q-02).
8. Q-06 and Q-07 the icon stroke and the two carbon colours.

**Can be settled during implementation**

9. Q-20 no "see my word again".
10. Q-21 tutorial shown automatically on first launch.
11. Q-23 small token additions and reference mismatches.
12. Q-04 screenshot-protection scope; Q-09 sound; Q-10 orientation.

**Before release**

13. All Arabic strings, including the product name in the wordmark.
14. Fonts on real devices: rendering, line heights and the ڨ glyph on a small and a large Android phone.
15. Licence reading: OFL and ISC terms were read from the upstream files; not reviewed by a lawyer.
16. Accessibility: contrast ratios are computed; nothing has been tested with TalkBack, large text, or users. The screen-reader and privacy conflict is risk R-07.
17. Usability: no testing has been done on tap-to-reveal, the 800 ms acknowledge lock, or the paper/carbon signal. Plan in `UX_RESEARCH_AND_RISKS.md` §6.

## 9. Design-system items excluded from the MVP

| Item | Where specified | Excluded by |
|---|---|---|
| "Locked" word-pack card state | `DESIGN_SYSTEM.md` §5 | D-04 |
| "Change speaking turn" interaction | `INTERACTIONS_AND_ANIMATIONS.md` §3 | D-03 |
| All sounds | `animations.json`, `INTERACTIONS_AND_ANIMATIONS.md` §3 | D-05 until assets exist |
