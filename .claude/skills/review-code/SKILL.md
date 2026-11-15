---
name: review-code
description: Review Impostor TN code changes for correctness, architecture, privacy, design fidelity and test quality. Use when asked to review a change, a file, a feature or the work since the last milestone.
---

# Review code

Git commands are not available. Establish the scope from what the Product Owner names (files, feature, milestone) or from the files changed in this session. If the scope is unclear, ask.

1. **Read the full files** in scope, not only fragments, plus their tests.
2. **Run the checks** and record the real output:
   ```
   flutter analyze
   flutter test
   ```
3. **Review in this order.** For large changes, delegate each area to its reviewer agent in parallel (`gameplay-reviewer`, `architecture-reviewer`, `ui-design-reviewer`, `qa-reviewer`); they report, they do not edit.
   1. **Correctness against the PRD.** Does behaviour match the cited sections and decisions exactly? Look for simplified rules and unhandled transitions.
   2. **Privacy.** Any path where a secret reaches a log, message, `toString`, wrong screen, or survives acknowledgement or resume.
   3. **Persistence.** Persist-then-advance, one transaction per checkpoint, idempotent retry, safe handling of corrupt state.
   4. **Architecture.** Dependency direction, engine purity, rules duplicated in widgets, unjustified dependency or abstraction.
   5. **UI.** Tokens instead of literals, directional APIs, isolates for digits and names, overflow at 320 and scale 1.5, semantics, resource disposal.
   6. **Tests.** Do they fail if the rule is broken? Deterministic? Boundaries covered?
   7. **Simplicity.** Dead code, speculative generality, oversized classes.
4. **Verify before reporting.** For each finding, re-read the code and, where possible, write the failing input. Drop anything you cannot substantiate.

## Output

Findings ordered by severity (blocker, major, minor), each with `file:line`, what is wrong, a concrete failing scenario, and the suggested fix. Then: what was checked and found sound, and what was not reviewed. Do not modify code unless asked to apply the fixes.
