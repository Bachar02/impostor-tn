# ADR-0007: Testing strategy

Status: Accepted (2026-11-15). The design-system, asset, localization and app-shell layers are covered today; the other layers do not exist yet.

## Principles

- A feature is not done when its UI exists (PRD §15). It is done when the tests that would catch its failure exist and pass.
- Put each test at the lowest layer that can catch the bug. Rules are tested in pure Dart; only wiring is tested through widgets.
- Deterministic: seeded `Random`, fake clock, in-memory database. No sleeps, network or real time.
- A result is reported only if it was produced by a command run in that session.

## Layers

| Layer | Tool | What it proves | Location |
|---|---|---|---|
| Design tokens | `flutter_test` + JSON | Dart constants equal `docs/design/tokens/*.json` | `test/core/design/token_sync_test.dart` |
| Assets | `flutter_test` + file system | Manifest equals disk; bundled files exist, are licensed and are not previews | `test/core/design/asset_manifest_test.dart` |
| Strings | `flutter_test` + ARB | Every string carries a review status; punctuation and digit rules | `test/l10n/arb_status_test.dart` |
| Theme and core widgets | widget tests | Mapping to Material slots, token access, icon rendering and semantics | `test/core/design/` |
| App shell | widget tests | Boots in `ar`, RTL, paper theme; no overflow at 320×568, 360×720, 800×1280 and text scale 1.5 | `test/app/` |
| Game engine | unit tests, table-driven | Every PRD rule, every rejection, counts 4–12 | `test/game/` (planned) |
| Persistence and recovery | drift in-memory database | Each checkpoint is atomic and idempotent; restore after interruption before/after every commit; corrupt and incompatible data; migrations | `test/data/` (planned) |
| Content | unit tests on bundled JSON | Schema, unique stable IDs, required metadata, alias collisions, only approved content selectable | `test/data/content/` (planned) |
| Feature widgets | widget tests with provider overrides | States, RTL, long names, privacy invariants per screen | `test/features/` (planned) |
| End-to-end | `integration_test` on device/emulator | Full games (win, runoff, draw), kill-and-resume, offline | `integration_test/` (planned) |
| Android-only | manual, recorded | `FLAG_SECURE`, recents preview, fonts, launcher icon | checklist |

## Interruption testing

Process death is simulated at the repository boundary: run a transition, discard all in-memory state, rebuild the engine from the same database, and assert the resulting state. A fault-injecting repository fails before or after the commit of each checkpoint to cover both halves.

## Privacy testing

For every private screen: the secret string is not in the widget tree before reveal, is present after reveal, and is gone in the frame after acknowledgement and after a simulated lifecycle pause. Civilian and Impostor variants are compared structurally (same widget types and counts).

## Regression checks for UI

Golden (pixel) tests are **not** adopted yet. Test fonts differ from device rendering, Arabic shaping makes goldens brittle, and no approved screen exists to pin. Layout assertions (sizes, no overflow, semantics) are used instead. Revisit once screens are approved and a stable font-loading setup for tests is in place.

## Dependencies

Only SDK packages: `flutter_test` now, `integration_test` when the first flow exists. No mocking library; hand-written fakes behind the repository interfaces are clearer and keep tests honest. Reconsider only if a fake becomes larger than the code it replaces.

## Gates

Per edit: the format hook (one file, cheap). Per milestone, run by hand and reported with counts:

```
dart format lib test tool
flutter analyze
flutter test
flutter build apk --debug      # when Android config or dependencies changed
```

There is no CI yet. A GitHub Actions workflow running the first three commands is a sensible next step once the repository is on GitHub; it is the Product Owner's to add.

## Not automatable

Derja review, playtests with three groups, TalkBack, and real-device privacy checks are human gates tracked in `docs/DEVELOPMENT_CHECKLIST.md`.
