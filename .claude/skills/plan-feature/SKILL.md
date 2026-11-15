---
name: plan-feature
description: Plan one Impostor TN feature or milestone before any code is written. Use when asked to plan, scope or propose a feature, screen, engine rule or persistence change.
---

# Plan a feature

Produce a plan the Product Owner can approve. Write no production code.

1. **Check the gates.**
   - Product screen or gameplay UI: `docs/UX_FLOWS.md` and `docs/SCREEN_SPECIFICATIONS.md` must exist and be approved. If not, stop and report the blocker.
   - Read `docs/DEVELOPMENT_CHECKLIST.md` for the current state and `docs/product/DECISIONS.md` for rulings and open questions.
2. **Collect the requirements.** Quote the exact PRD sections, decision IDs and design sections that govern the feature. List every acceptance criterion from PRD §15 that applies.
3. **Find gaps.** List anything missing, ambiguous or contradictory. For each: the exact ambiguity, its impact, and the simplest safe interpretation. Do not resolve product questions yourself.
4. **Map the change.** Name the files to add or modify per layer (`game`, `data`, `features/<x>/application`, `features/<x>/presentation`, `core`). Confirm dependencies still point inward (ADR-0001). Reuse existing tokens, widgets and helpers before proposing new ones.
5. **List edge cases and failure modes.** Always consider: 4 and 12 players, process death at each step, retry of the same action, backgrounding on a private screen, long names, text scale 1.5, corrupt saved state.
6. **Define the tests** using the table in `.claude/rules/testing.md`.
7. **Check dependencies.** If a new package is proposed, draft the ADR entry (need, maintenance, compatibility, simpler alternative).
8. **Slice it.** Break the work into steps that each leave the app building and the tests green. Flag anything that should be a separate milestone.

## Output

- Goal (one sentence) and what is explicitly out of scope
- Requirements with references
- Open questions for the Product Owner (blocking ones first)
- Files to change, by layer
- Edge cases
- Test plan
- Steps in order

Wait for approval before implementing.
