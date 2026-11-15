---
name: implement-feature
description: Implement an approved Impostor TN feature plan end to end with tests, formatting, analysis and an honest report. Use after a plan from plan-feature has been approved.
---

# Implement an approved feature

Precondition: an approved plan. If there is none, run `plan-feature` first. If the plan touches product screens and the design gate in `CLAUDE.md` is closed, stop.

1. **Re-read** the plan, the governing PRD sections and the rules in `.claude/rules/`.
2. **Work inside-out**, one step at a time:
   1. `lib/game/`: types, transition, typed rejections. Unit tests in the same step.
   2. `lib/data/`: schema or repository change, one transaction per checkpoint. Recovery tests in the same step.
   3. `lib/features/<x>/application/`: providers that call the engine, persist, then expose state.
   4. `lib/features/<x>/presentation/`: widgets from tokens and existing components. Widget tests.
3. **After each step** run the tests for the files you touched. Do not stack untested steps.
4. **Strings:** add to `lib/l10n/app_ar.arb` with a `[REVIEW]` description, taken from the glossary where one exists, then run `flutter gen-l10n`.
5. **Stop and ask** if you meet a requirement gap, a design contradiction, or a need for a new dependency. Do not improvise.
6. **Verify the whole change:**
   ```
   dart format lib test tool
   flutter analyze
   flutter test
   ```
   For Android-affecting changes also run `flutter build apk --debug`.
7. **Simplify.** Re-read the diff: remove unused abstractions, duplicated logic, speculative parameters. Check privacy rules (no secret in logs, messages, `toString`).
8. **Update** `docs/DEVELOPMENT_CHECKLIST.md`, and the README or an ADR if behaviour or structure changed.
9. **Report** using this structure:
   - Implemented
   - Tested successfully (commands run and counts)
   - Partially tested / not tested (and why)
   - Known limitations and open questions
   - Git commands for the Product Owner to run (never run them yourself): files to stage, a suggested commit message

Keep the change to the approved scope. Unrelated fixes go in a separate proposal.
