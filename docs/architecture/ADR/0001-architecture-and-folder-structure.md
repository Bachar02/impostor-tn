# ADR-0001: Architecture and folder structure

Status: Accepted (2026-11-15). The `game` layer's rules exist (2026-11-16; word selection and cooldown not yet); `data` and `features` are designed here but not yet built.

## Context

Impostor TN is a small offline app with one hard problem: a game whose rules, privacy and crash recovery must be exactly right (PRD §4–§12). The UI is a thin, heavily specified layer on top. The architecture must make the rules testable without Flutter and make it hard for a widget to bend a rule.

## Decision

Feature-first folders over a shared core, with a pure-Dart game engine at the centre.

```
lib/
  main.dart
  app/                     composition root: MaterialApp, licences, top-level wiring
  core/
    design/
      tokens/              constants mirroring docs/design/tokens/*.json
      theme/               ThemeData for paper and carbon, TesskraTokens extension
      assets/              typed asset paths
      widgets/             reusable Tesskra components
    text/                  bidi helpers
    diagnostics/           redacted error reporting (ADR-0008)
  game/                    domain + engine, pure Dart            [not started]
  data/                    drift database, repositories, content loader [not started]
  features/
    <feature>/
      application/         Riverpod providers / controllers       [not started]
      presentation/        screens and feature-only widgets       [not started]
  l10n/                    app_ar.arb and generated/
test/                      mirrors lib/
tool/                      developer scripts (Claude Code hooks)
```

### Dependency rule

```
presentation → application → game ← data
        └────────→ core ←──────┘
```

- `game` imports only `dart:core`, `dart:math`, `dart:collection`. No Flutter, no I/O, no clock, no database. It declares the repository interfaces it needs.
- `data` implements those interfaces. Nothing outside `data` sees a drift type.
- `application` orchestrates: ask the engine for the next state, persist it, then publish it.
- `presentation` renders state and sends intents. It contains no rule.
- `core` knows nothing about features or the game.

`test/architecture/layer_dependencies_test.dart` enforces these rules by scanning imports. The `core` rule is active today; the `game` and database rules pass trivially until those folders exist.

### Engine shape

- The session is one immutable value. Each phase (`setup`, `reveal`, `discussion`, `firstBallot`, `runoff`, `finalGuess`, `result`) is a subtype of a `sealed` class, so every `switch` is checked for exhaustiveness.
- A transition is a pure function `(state, event) → next state | typed rejection`. Illegal events are rejected with a reason, never ignored.
- Randomness (Impostor choice, word choice) comes from an injected `Random`, so tests are deterministic.
- Types holding secrets override `toString()` to a redacted form.
- Limits (4–12 players, cooldown 30, name length) are constants in `game`, defined once.

### Commit protocol

For every checkpoint: compute the next state → write it in one database transaction → only then expose it to the UI. If the write fails, the UI stays on the previous state and shows a retryable error. Detail in ADR-0003.

## Alternatives considered

- **Layer-first folders** (`models/`, `screens/`, `services/`): scatters each feature and gives no natural home for the engine boundary.
- **Full clean architecture with use-case classes per action**: more files than rules; the engine's transition functions already are the use cases.
- **Bloc with events and states per screen**: workable, but the game already is one explicit state machine; a second layer of events adds ceremony. See ADR-0002.

## Consequences

- The riskiest code is plain Dart and runs in milliseconds under `flutter test`.
- Some mapping code is needed between engine values and database rows.
- Empty layer folders are not created in advance; each appears with its first real file.
