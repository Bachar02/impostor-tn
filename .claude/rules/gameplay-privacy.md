# Gameplay correctness and privacy

Applies to everything that touches game rules, session state or private screens. The PRD (`docs/product/PRD.md`) and `docs/product/DECISIONS.md` are the only sources of rules.

## Engine

- Game rules live in `lib/game/` as pure Dart: no Flutter import, no I/O, no global state, no `DateTime.now()` or unseeded `Random`.
- The game is an explicit state machine. Every phase is a type; every transition is a function that returns either the next state or a typed rejection. Illegal transitions are rejected, never ignored.
- Widgets never decide rules. They send an intent and render the resulting state.
- Do not simplify a rule to make implementation easier. If a rule is ambiguous, stop and ask.

## Invariants that must hold after every transition and every restart

- 4–12 players; exactly one Impostor; assignment and word never change within a session.
- The Impostor's view contains the category only: no word, alias or hint.
- A player advances past reveal only after their acknowledgement is persisted.
- One vote per player per ballot; no self-vote; no change after submission (D-03).
- A top tie on the first ballot leads to exactly one runoff among the tied players, with fresh votes; a runoff tie is a draw with no final guess. No random or order-based tie-break.
- Final guess: trim and collapse whitespace only, then exact match against the canonical word or an explicit alias (D-01). No diacritic, tatweel or letter-variant folding.
- Cooldown: the 30 most recent distinct word IDs, across sessions and restarts; recorded once, in the same transaction that starts the reveal phase.

## Persistence

- Persist first, then advance. The UI moves only after the transaction commits.
- Each checkpoint is one transaction and must be idempotent under retry.
- Restoring never regenerates roles or words and never invents votes. Corrupt or incompatible state cancels the session safely (ADR-0003).

## Privacy

- Secrets are: the secret word, who the Impostor is, any role, any vote before results, the final guess.
- Secrets never appear in logs, `print`, `debugPrint`, exception or assertion messages, `toString()`, analytics, notifications, test descriptions or golden file names. Types that hold a secret override `toString()` to a redacted form.
- A secret is rendered only on its specified private screen, only after the deliberate reveal action, and leaves the widget tree in the same frame as the acknowledgement.
- Civilian and Impostor private screens are structurally identical: same widgets, colours, sizes, sounds and haptics.
- On resume from background, show the neutral handoff, never a restored secret.
- Do not claim screenshot or app-switcher protection works unless it was verified on a real device in this session.

## Tests

Any change here needs deterministic tests in the same change (see `testing.md`).
