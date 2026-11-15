---
paths:
  - "lib/**/*.dart"
  - "test/**/*.dart"
  - "tool/**/*.dart"
---

# Dart conventions

- `flutter analyze` must be clean. Fix the cause; do not add `// ignore` without a one-line reason the Product Owner could understand.
- Package imports only (`package:impostor_tn/...`), never relative.
- Prefer `final`, `const` constructors and immutable classes. Model closed sets of states with `sealed` classes and exhaustive `switch`; no `default` branch that hides a new case.
- No code generation for models or providers. If equality is needed, write `==` and `hashCode` by hand.
- No `dynamic` in public APIs. Decode JSON at the boundary into typed values and validate there.
- Errors are explicit. Return a typed failure for expected outcomes (invalid name, no eligible word); throw only for programmer errors. Never write an empty `catch`, and never catch `Object` without rethrowing or converting to a typed failure.
- Exception and failure messages must not contain game secrets (see `gameplay-privacy.md`).
- One responsibility per file. Split a widget or class before it passes roughly 200 lines.
- Business constants (player limits, cooldown size, name length) are defined once in `lib/game/` and imported; never repeat the literal in a widget.
- Inject time and randomness (`Random`, clock) through constructors so behaviour is deterministic in tests.
- Dispose every controller, focus node, subscription and timer in the owner that created it.
- New dependency: justify it in an ADR first (need, maintenance, compatibility, why Flutter itself is not enough).
- Comments explain why, not what. Reference the PRD section or decision ID when a rule comes from there.
