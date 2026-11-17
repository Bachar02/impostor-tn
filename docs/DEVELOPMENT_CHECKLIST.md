# Impostor TN — Development checklist

Updated after every milestone. Legend: `[x]` done and verified as described, `[~]` partly done, `[ ]` not started, `[!]` blocked.

Last update: 2026-11-17 (Milestone E: first playable slice implemented, Q-05 approved as D-32; device runs on Pixel_XL_API_36 emulator).

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
- [x] Product Owner approval for slice 1 (D-32, 2026-11-17)
- [~] Blocking decisions: Q-01, Q-07, Q-16, Q-18, Q-19, Q-22 settled (D-15 to D-25); Q-06 and Q-17 open
- [x] Full-screen reference renders: 52 states, 172 images, with layout measurements (browser renders; not device-verified)
- [x] Consistency audit: flows, specifications and risks revised (revision 2)
- [~] Audit decisions: Q-25, Q-26, Q-30 settled (D-27, D-30, D-28); Q-27, Q-28, Q-29 open

## Phase D — First vertical slice (Milestone E, 2026-11-17)

- [x] Screens: Home (no settings/how-to, D-29), Players + edit sheet (no reordering, Q-17), Packs, Handoff, Role ticket (parity, D-27), Discussion, Vote, Tally (A–D), Final guess with review, Results, Replay, leave dialog, resume gate
- [x] Single in-game route (`GameFlow`) over the checkpoint service; screen routing is a pure function (`routeGame`) with unit tests
- [x] Whole-game screenshot protection (D-18): on at game start, off when the game is left; no private screen without confirmation
- [x] Secrets leave the tree in the same frame on acknowledgement and on hide; a frame is forced while hidden
- [x] 108 ARB strings, all `[REVIEW]` (glossary keys used by the slice + Appendix A)
- [x] Development-only synthetic words (D-35) in debug builds; absent from a release binary (checked by grep with positive controls)
- [x] Widget-level integration tests: civilian win, Impostor win (12 players), civilian out, tie → runoff → draw, replay, leave, back rules, hide during reveal, protection refused, cold start (gate, result), whole game at 320×568 ×1.5 with 16-character names
- [x] Emulator Pixel_XL_API_36 (Android 16), **final build** (debug x86_64, Dart kernel compiled after the last source change), 2026-11-17, driven by accessibility labels: civilian win; Impostor win (correct guess); civilian out + replay + cold start → resume gate; 6-player tie → runoff → draw (3 runs); leave: Back on discussion and on handoff opens the dialog, Cancel and Back keep the game, Leave goes Home, roster kept, no resume gate after; private screens: Back on sealed ticket returns to the handoff, Back on revealed ticket does nothing, Home during a selected vote and during a typed guess returns to the same player's handoff with nothing restored, Back on guess entry opens the leave dialog, Back on review returns to entry with the text; incoming call during a revealed ticket: heads-up only keeps the app in front, answering brings the in-call screen and the return lands on the same player's handoff without the secret; process kill after 2 acknowledgements, on discussion, after 2 votes, on the tally (gate then the right screen) and on results (results directly, no gate). Screenshots blank on every game screen including results, not on Home (control); app-switcher thumbnail black on the guess and results screens. Acknowledge and Home sent together landed on a handoff without the secret, but a save actually in flight cannot be timed on the emulator: hide-during-save stays covered by widget tests only. Install needed a clean rebuild: the incrementally repackaged APK was 156 MB, 83 MB of it unused
- [ ] Physical device; TalkBack; real keyboard behaviour on small phones. Checklist prepared, not run: `docs/quality/PHYSICAL_DEVICE_PRIVACY_CHECKLIST.md`
- [x] Designed motion (2026-11-17): `carbonIn`/`carbonOut` inside the game (`SurfaceSwitcher`) and on starting and leaving a game (`CarbonInRoute`/`CarbonOutRoute`); `ticketReveal` (seal lifts 24 and fades over 300 ms; the secret is built only after that and fades in over the last 120 ms; identical for both roles); `winnerReveal` on a result reached live (no slam on recovery); `listItemIn`/`listItemOut` on the players list with scroll-into-view; system bar icons per surface; reduced-motion values from `animations.json`. Carbon content is never kept for a transition (mutation-checked). Interpretations to confirm: route-level carbonIn switches bar icons when the sheet reaches the top, not at the midpoint; the winner stamp lands at 300 of 600 ms and the content rises 8 (the token gives no distance); `stampIn` on pack selection and `errorShake` not built
- [x] Emulator re-run on the build with designed motion (2026-11-17, same scenarios as above): all passed. One private-screens run stopped once because a suspect tap did not register (Confirm stayed disabled); not reproduced in a full re-run or in four isolated votes; cause not determined. Transitions not visually inspected on the emulator: FLAG_SECURE blanks every capture of the game

## Work that is not blocked by the design gate (needs Product Owner go-ahead)

- [~] Milestone D (2026-11-17), design-system components with widget tests (real fonts loaded; RTL; 360×720, 320×568, scale 1.5): `TesskraButton` (5 variants, carbon variants, pressed/disabled/focus/loading), `LoadingDots`, `TesskraBanner`, `TesskraDialog`, `TesskraSheet`, `CountPill`, `ScreenFrame`, `PrivateScope`, `HandoffBlock`, `RoleTicket` with D-27 parity, `FittedDisplayText`. D-19 tokens applied. Not yet built (screen-specific, wait for Q-05): text field, app bar, player row, pack card, vote option, tally row, winner stamp, plaque, role reveal row, stamp label, state block, carbon transition. Icon stroke stays as shipped (Q-06).
- [x] D-26: 56 Appendix A strings merged into `app_ar.arb`, all `[REVIEW]`
- [x] D-18 screenshot protection switched by the game flow; screencap blank and recents thumbnail black on the emulator during the game (not checked on a physical device)
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
