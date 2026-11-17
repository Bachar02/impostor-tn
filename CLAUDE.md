# Impostor TN

Offline, single-device, pass-and-play party game for Android (Flutter, Dart). Tunisian Derja, Arabic script, RTL only. No backend, accounts, ads or analytics.

## Authority

- Gameplay, privacy, scope: `docs/product/PRD.md`. Product Owner rulings and open questions: `docs/product/DECISIONS.md`.
- Visual implementation: `docs/DESIGN_HANDOFF.md` (read first), then the other design docs; token values in `docs/design/tokens/*.json` win over prose.
- Architecture: `docs/architecture/ADR/`.
- Progress: `docs/DEVELOPMENT_CHECKLIST.md`. Update it after every milestone.

Never silently change the PRD or the design. If something is missing or contradictory, stop and ask the Product Owner; record the answer in `DECISIONS.md`.

## Hard rules

1. **Git is the Product Owner's.** Never run any `git` command, not even read-only ones (it is also denied in `.claude/settings.json`). When a Git step is needed, give the exact commands, their purpose and order, then wait.
2. **Design gate.** Do not build product screens or gameplay UI until `docs/design/UX_FLOWS.md` and `docs/design/SCREEN_SPECIFICATIONS.md` are approved by the Product Owner. Slice 1 is approved (D-32); everything outside it (PUB-02, PUB-03, PUB-04, reordering, tutorial) is not. Do not invent screens, interactions or copy.
3. **Secrets never leak.** A secret word, category-as-role, role, vote or final guess must never reach a log, exception message, notification, `toString`, test name, or any screen other than the one specified. No `print`, no `debugPrint` of game data.
4. **Arabic is provisional.** Every string is `[REVIEW]` until a Tunisian Derja speaker approves it. Never mark a string `[APPROVED]` yourself. Never fabricate word content, reviewer names or review status.
5. **Report honestly.** Say "tested" only for checks actually executed in this session, with the result. Distinguish implemented / tested / partially tested / not tested / known limitation.

## Commands

```
flutter pub get
flutter gen-l10n            # after editing lib/l10n/app_ar.arb
dart format lib test tool
flutter analyze             # must report "No issues found!"
flutter test                # all tests
flutter test test/path/to/file_test.dart
flutter build apk --debug   # Android build check (slow; milestones only)
```

A PostToolUse hook formats each edited Dart file. Run analyze and the relevant tests yourself before reporting a milestone.

## Architecture in one screen

```
lib/app/        composition root: bootstrap, error handlers, provider overrides, MaterialApp, licences
lib/core/       design system (tokens, themes, widgets), text helpers, diagnostics; imports no feature
lib/game/       pure Dart game engine and domain (no Flutter, no I/O)      [rules, content model, cooldown, selection, snapshot]
lib/data/       content loader, atomic JSON state file, platform channel  [done; ADR-0003 rev. 2, ADR-0009]
lib/features/   <feature>/{application,presentation}   [slice 1 screens: home, setup, game flow (D-32)]
lib/l10n/       app_ar.arb (source) and generated/ (committed, not edited)
```

Dependencies point inward: presentation → application → game ← data. `lib/game` depends on nothing but Dart. State and DI use Riverpod without code generation. Details and rationale: ADR-0001 to ADR-0009. `features` never import `data`; only `lib/app` binds them. Unexpected errors go through `Diagnostics` (ADR-0008); there is no free-text logging.

Design assets are bundled directly from `docs/design/assets/`; Dart token constants mirror the JSON and `test/core/design/token_sync_test.dart` fails if they drift.

## Working method

Small reviewable milestones: read the requirement, plan, list edge cases, implement, test, format, analyze, simplify, report. Use the skills in `.claude/skills/` and the reviewer agents in `.claude/agents/` (reviewers investigate and report; they do not edit).
