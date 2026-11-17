# Testing requirements

Tests are part of the change, not a later phase. Strategy and rationale: `docs/architecture/ADR/0007-testing-strategy.md`.

## What each change needs

| Change | Required tests |
|---|---|
| Game rule or transition | Unit tests for the legal path, every rejection, and boundary player counts (3 and 12) |
| Persistence or recovery | Tests against an in-memory database, including interruption before and after each commit, and corrupt/incompatible data |
| Widget or screen | Widget tests: RTL, 320 wide, text scale 1.5, long name, disabled/error/loading states |
| Private screen | A test that the secret is absent before reveal and after acknowledgement, and that both roles build the same widget structure |
| Design token or asset | `token_sync_test.dart` and `asset_manifest_test.dart` stay green |
| String | `arb_status_test.dart` stays green; new strings are `[REVIEW]` |
| Word content | Structural validation test; never assert or invent review status |

## Rules

- Deterministic only: inject seeded `Random` and a fake clock. No real time, network or sleeps.
- Prefer hand-written fakes over mocking libraries.
- Test names describe behaviour and never contain a real secret word.
- One reason to fail per test where practical; use table-driven cases for rule matrices (vote tallies, tie shapes).
- Do not weaken or delete a failing test to make a change pass. Fix the code or raise the conflict.
- Android-only behaviour (FLAG_SECURE, app-switcher cover, process death) is "not tested" until run on a device or emulator; say so.

## Before reporting a milestone

```
dart format lib test tool
flutter analyze
flutter test
```

Report the actual counts and any failure text. Never write "tests pass" from memory or expectation.
