# Impostor TN — Development checklist

Updated after every milestone. Legend: `[x]` done and verified as described, `[~]` partly done, `[ ]` not started, `[!]` blocked.

Last update: 2026-11-16 (foundation re-assessed; error handling added, ADR-0008).

## Phase A — Repository audit

- [x] Repository, PRD, design docs, tokens and assets inspected
- [x] Blockers reported to the Product Owner

## Phase B — Engineering foundation

- [x] `CLAUDE.md`
- [x] Rules: Dart conventions, Flutter UI and design, gameplay and privacy, testing
- [x] Skills: plan-feature, implement-feature, review-code, test-gameplay, review-rtl, audit-privacy, prepare-release
- [x] Agents: architecture, gameplay, UI/design, QA reviewers (read-only)
- [x] `.claude/settings.json`: Git commands denied; Dart format hook (verified to fire)
- [x] ADR-0001 to ADR-0007
- [~] ADR-0008 (error handling, diagnostics, build configuration): proposed, reviewed against SDK source 2026-11-16, awaiting Product Owner review; release logging not verified on a device
- [x] `docs/product/DECISIONS.md` with rulings D-01 to D-10 and open questions Q-01 to Q-30
- [x] Design path references corrected to `docs/design/`; 43 assets re-verified

## Phase C — Project bootstrap

- [x] Flutter project created (Android only), package `impostor_tn`
- [x] Lints and strict analysis configured
- [x] Dependencies: `flutter_riverpod`, `flutter_svg`, `flutter_localizations`, `intl`
- [x] Design tokens as Dart constants, checked against the JSON by tests
- [x] Paper and carbon themes, `TesskraTokens` extension
- [x] Fonts, icons, logos and licence texts bundled from `docs/design/assets/`
- [x] `TesskraIcon` widget and bidi helpers
- [x] Localization pipeline (`ar` only) with review-status guard
- [x] App shell with a placeholder screen (not a product screen)
- [x] Bootstrap sequence with global error handlers; uncaught errors reported without their message outside debug builds (unit-tested; logcat output not checked on a device)
- [x] Import-scanning test for the layer dependency rule (ADR-0001)
- [ ] Neutral "something went wrong" screen: needs a specification and Arabic copy (ADR-0008)
- [ ] Toolchain: Android cmdline-tools missing, SDK licences not accepted, JDK 19 in use (Product Owner's machine setup)
- [x] Android: backups and device transfer disabled, RTL enabled, label, paper launch background, adaptive launcher icon
- [x] `flutter analyze` clean; `flutter test` passing (see the Phase C report for counts)
- [x] `flutter build apk --debug` succeeds
- [ ] App run on a device or emulator (none connected so far)

## UX and design handoff (Stages 3–5)

- [x] `docs/design/UX_FLOWS.md` drafted: 11 flows, 9 checkpoints, PRD traceability
- [x] `docs/design/SCREEN_SPECIFICATIONS.md` drafted: 14 screens, 2 overlays, all states
- [x] `docs/design/UX_RESEARCH_AND_RISKS.md` drafted: assumptions, risks, Q-06/Q-07 evidence, validation plan
- [x] `docs/DESIGN_HANDOFF.md` updated
- [ ] Product Owner review and approval (Q-05)
- [ ] Blocking decisions settled: Q-01, Q-06, Q-07, Q-16, Q-17, Q-18, Q-19, Q-22
- [x] Full-screen reference renders: 52 states, 172 images, with layout measurements (browser renders; not device-verified)
- [x] Consistency audit: flows, specifications and risks revised (revision 2)
- [ ] Audit decisions settled: Q-25, Q-26, Q-27, Q-28, Q-29, Q-30

## Phase D — First vertical slice

- [!] Blocked: needs approved `docs/design/UX_FLOWS.md` and `docs/design/SCREEN_SPECIFICATIONS.md` (D-09, Q-05)

## Work that is not blocked by the design gate (needs Product Owner go-ahead)

- [ ] Design-system component library from `DESIGN_SYSTEM.md` §5 with widget tests (buttons, inputs, banners, dialogs; no screens). Needs Q-06 and Q-07.
- [ ] Game engine in pure Dart with full rule tests (no UI). Needs Q-01 and Q-02.
- [ ] Word-content schema, loader and structural validator with clearly labelled test fixtures. Real content is Q-13.
- [ ] Persistence layer and recovery tests (ADR-0003). Needs Q-03.

## Gameplay (PRD §4–§11) — not started

- [ ] Setup: players 4–12, order, pack selection, validation
- [ ] Role and word assignment, exactly one Impostor
- [ ] Private reveal and persisted acknowledgement
- [ ] Discussion phase
- [ ] First ballot, runoff, draw
- [ ] Final guess with exact matching
- [ ] Results and replay
- [ ] Cooldown of 30 across sessions and restarts
- [ ] Session persistence and safe recovery

## Privacy (PRD §12) — not started except storage settings

- [x] Android backups disabled
- [ ] Private wrapper, neutral resume, `FLAG_SECURE` (ADR-0006, Q-04)
- [ ] Verified on a real device

## Human gates

- [ ] Derja review of all strings (0 approved)
- [ ] Word content: 200–300 words, two human reviews each
- [ ] Real-device checks: fonts and ڨ glyph, launcher icon, screenshots, recents preview, TalkBack
- [ ] Playtests with three distinct groups
