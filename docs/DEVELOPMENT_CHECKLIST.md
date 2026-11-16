# Impostor TN — Development checklist

Updated after every milestone. Legend: `[x]` done and verified as described, `[~]` partly done, `[ ]` not started, `[!]` blocked.

Last update: 2026-11-17 (rulings D-15 to D-31 recorded; milestones A content, B cooldown, C persistence and recovery implemented).

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
- [~] ADR-0008 (error handling, diagnostics, build configuration): proposed, revision 3 applies D-11 to D-14; awaiting approval and device verification
- [x] Production diagnostics reduced to origin and error type (D-11); console-output source guard test (proved to fail on a planted `debugPrint`)
- [x] `docs/product/DECISIONS.md` with rulings D-01 to D-31 (2026-11-17) and the questions still open
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
- [x] Toolchain: Android toolchain clean in `flutter doctor` (2026-11-16)
- [x] Android: backups and device transfer disabled, RTL enabled, label, paper launch background, adaptive launcher icon
- [x] `flutter analyze` clean; `flutter test` passing (see the Phase C report for counts)
- [x] `flutter build apk --debug` succeeds
- [x] App run on an emulator (Pixel_XL_API_36, Android 16, 2026-11-16): debug startup, home/resume, back, background process kill. Physical device still pending.
- [x] Redacted diagnostics checked on the emulator in profile and release builds with a temporary probe (ADR-0008 "Verification"); probe deleted

## UX and design handoff (Stages 3–5)

- [x] `docs/design/UX_FLOWS.md` drafted: 11 flows, 9 checkpoints, PRD traceability
- [x] `docs/design/SCREEN_SPECIFICATIONS.md` drafted: 14 screens, 2 overlays, all states
- [x] `docs/design/UX_RESEARCH_AND_RISKS.md` drafted: assumptions, risks, Q-06/Q-07 evidence, validation plan
- [x] `docs/DESIGN_HANDOFF.md` updated
- [ ] Product Owner review and approval (Q-05). Approval form for slice 1: `docs/design/UX_APPROVAL_PACKAGE_SLICE_1.md`
- [~] Blocking decisions: Q-01, Q-07, Q-16, Q-18, Q-19, Q-22 settled (D-15 to D-25); Q-06 and Q-17 open
- [x] Full-screen reference renders: 52 states, 172 images, with layout measurements (browser renders; not device-verified)
- [x] Consistency audit: flows, specifications and risks revised (revision 2)
- [~] Audit decisions: Q-25, Q-26, Q-30 settled (D-27, D-30, D-28); Q-27, Q-28, Q-29 open

## Phase D — First vertical slice

- [!] Blocked: needs approved `docs/design/UX_FLOWS.md` and `docs/design/SCREEN_SPECIFICATIONS.md` (D-09, Q-05)

## Work that is not blocked by the design gate (needs Product Owner go-ahead)

- [~] Milestone D (2026-11-17), design-system components with widget tests (real fonts loaded; RTL; 360×720, 320×568, scale 1.5): `TesskraButton` (5 variants, carbon variants, pressed/disabled/focus/loading), `LoadingDots`, `TesskraBanner`, `TesskraDialog`, `TesskraSheet`, `CountPill`, `ScreenFrame`, `PrivateScope`, `HandoffBlock`, `RoleTicket` with D-27 parity, `FittedDisplayText`. D-19 tokens applied. Not yet built (screen-specific, wait for Q-05): text field, app bar, player row, pack card, vote option, tally row, winner stamp, plaque, role reveal row, stamp label, state block, carbon transition. Icon stroke stays as shipped (Q-06).
- [x] D-26: 56 Appendix A strings merged into `app_ar.arb`, all `[REVIEW]`
- [~] D-18 screenshot protection: `setSecure` platform method and `ScreenProtection` provider; not yet switched by the game flow; not verified on a device
- [x] Game engine in pure Dart with full rule tests (no UI). Empty final guess rejected (D-16).
- [x] Milestone A (2026-11-17): word-content model, JSON format, strict decoder and validator, eligibility by build channel, empty production catalog, synthetic fixtures under `test/` only (ADR-0009). Real content is Q-13.
- [x] Milestone B (2026-11-17): cooldown of 30, selection with progressive release, consumption at C2 in one write with the session mark (D-21).
- [x] Milestone C (2026-11-17): atomic single-file state store, checkpoint service C0–C9, launch recovery, Riverpod providers without automatic retry (D-12), platform channel for the private directory (ADR-0003 revision 2). Not run on a device.

## Gameplay (PRD §4–§11)

Engine step 1 (2026-11-16): pure Dart in `lib/game/`, 133 unit tests in `test/game/` with synthetic fixtures. Mutation check: four deliberately injected rule bugs were each caught. No UI, no persistence.

- [x] Setup rules: player count 4–12, unique ids, name rules D-15 (`PlayerNames`), pack candidates by eligibility; no screen
- [x] Role assignment: exactly one Impostor from an injected `Random`; word from the cooldown-aware selector
- [x] Private reveal: role view only after C2 committed; acknowledgement persisted before advancing (service tests)
- [x] Discussion phase (engine)
- [x] First ballot, single runoff among the tied, draw on a runoff tie (engine)
- [x] Final guess with exact matching: D-01 strict reading kept (D-30); case preserved, empty guess rejected (D-16)
- [x] Results (outcome, winner, ballots with counts) and replay (engine)
- [x] Restore by replaying recorded facts; corrupt or impossible facts rejected, never repaired (engine)
- [x] Cooldown of 30 across sessions and restarts (service tests over 70 simulated restarts)
- [x] Session persistence and safe recovery: interruption before and after every checkpoint, restart after every checkpoint at 4 and 12 players, 12 damaged-state cases (in-memory store through the real codec; the file store has its own tests on a temp directory). Process death on Android not tested.

## Privacy (PRD §12) — not started except storage settings

- [x] Android backups disabled
- [~] Private wrapper (`PrivateScope`, removes secrets on hide; widget-tested), `FLAG_SECURE` channel (D-18); neutral resume flow needs the screens
- [ ] Verified on a real device

## Human gates

- [ ] Derja review of all strings (0 approved)
- [ ] Word content: 200–300 words, two human reviews each
- [ ] Real-device checks: fonts and ڨ glyph, launcher icon, screenshots, recents preview, TalkBack
- [ ] Playtests with three distinct groups
