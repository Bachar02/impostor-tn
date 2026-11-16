# ADR-0003: Persistence, transactions and recovery

Status: **Revision 2 (2026-11-17), implemented; awaiting Product Owner review.** Revision 2 replaces the drift/SQLite proposal of revision 1 with a single atomically replaced JSON document, and records D-17 (Q-03) and D-21 (Q-16). Revision 1 is kept below for the record.

## Revision 2 — decision

### Mechanism: one document, replaced atomically

All durable state is one small JSON document, `game_state.json`, in the app-private no-backup directory (`Context.getNoBackupFilesDir()`, obtained through the app's own platform channel, the one ADR-0006 uses for `FLAG_SECURE`).

```
{ "schema": 1,
  "cooldown": ["<word id, oldest>", …, "<newest>"],
  "roster":   { "players": [{"id", "name"}], "packs": ["<pack id>"] },
  "session":  null | { "id", "players", "packs", "impostor",
                       "word": {"id", "version"}, "wordConsumed", "phase",
                       "acknowledged": [...], "firstBallot": [{"voter","target"}],
                       "runoff": [...], "finalGuess": null | "<raw>" } }
```

**Write** (`FileStateStore.write`): encode the whole document → write `game_state.json.tmp` with `flush: true` → rename over `game_state.json`. A rename within one directory is atomic, so after a process kill at any instant the file holds either the old or the new document. **Read**: a leftover `.tmp` is an interrupted write and is deleted unread. Reads and writes are serialised.

Every checkpoint is therefore one transaction across session, cooldown and roster together. In particular C2 writes the cooldown entry and `wordConsumed: true` in the same document (D-21).

**Why not drift/SQLite (revision 1).** The state is a few kilobytes with one writer. One whole-document replace gives the same all-or-nothing guarantee as a SQL transaction without four packages (`drift`, `drift_flutter`, `drift_dev`, `build_runner`), code generation, or a native SQLite library in host tests. No new dependency is added; `path_provider` is not needed either.

**What replaces the SQL constraints.** Revision 1 relied on `UNIQUE` and `CHECK` constraints to refuse duplicates. Here:

- The codec (`SavedStateCodec`) refuses a document with a voter twice in a ballot, an acknowledgement twice, a duplicated or over-long cooldown, or any unexpected type, and drops that part whole. It never repairs.
- Every restore replays the saved facts through the engine (`SessionSnapshot.restore` → `SessionRestore`), which refuses self-votes, out-of-order acknowledgements, votes in a ballot that never opened and phase mismatches.
- Every checkpoint (`GameService`) re-reads the saved document, decides through the engine, and writes only when the action is not already saved. A retry, a double tap or a restart finds the work done and writes nothing (UX_FLOWS §3.1).

### Parts are checked independently

The codec decodes `cooldown`, `roster` and `session` separately. A damaged session is cancelled without losing the cooldown history; a damaged cooldown is dropped without cancelling the game. Only a document that is not JSON, not UTF-8 or of an unknown schema loses everything (accepted, as in revision 1).

### Launch and recovery (UX_FLOWS F1, F11)

`GameService.launch`: read → restore the session through the rules → if it is missing, damaged, its word is gone from the catalog, its word `version` changed (ADR-0009), or an acknowledgement exists without `wordConsumed`, the session is cancelled (the document is rewritten without it), Home opens with the "could not be restored" banner, and roster and cooldown are kept. Nothing is redrawn, repaired or invented.

### Schema

`schema` is 1. A future version adds a migration step in the codec, with a test per step. A document with a newer schema than the app understands is unreadable (downgrade), handled as above.

### Storage security (D-17, Q-03)

Unchanged from revision 1: app-private storage, backups and device transfer disabled, no encryption. The session stores names, roles, phase, votes and checkpoint flags, i.e. everything recovery needs; the word is stored by ID and version only, the cooldown holds word IDs only. A session is deleted when the group leaves (C8) or replays (C9).

### Riverpod retry (D-12)

Providers that run checkpoints are `Notifier`s whose methods return the `Checkpoint` result; they never rely on Riverpod's automatic retry. The launch provider (`FutureProvider`) sets `retry: (count, error) => null`, so a failed launch is surfaced once and retried only by an explicit user action.

---

## Revision 1 (2026-11-15, superseded)

## Requirements (PRD §5, §7, §10, §11, §12)

- Survive process death at any moment without a second Impostor assignment, a second word consumption, a lost or duplicated vote, an invalid phase, or an exposed secret.
- Acknowledgements, votes and cooldown entries are committed before the app advances.
- Cooldown history outlives sessions and restarts.
- Corrupt or incompatible state cancels the session safely.

## Decision: SQLite through drift

**Packages (to be added at the persistence milestone, not yet in `pubspec.yaml`):** `drift`, `drift_flutter`, and dev-only `drift_dev` + `build_runner`. A dry run on 2026-11-15 resolved `drift 2.35.4`, `drift_flutter 0.3.1`, `drift_dev 2.35.3`, `build_runner 2.17.1` against Flutter 3.47.9 without conflict. Re-check at adoption time; in particular confirm how `drift_flutter` bundles SQLite, since the resolver reported `sqlite3_flutter_libs 0.6.0+eol`.

**Why a relational, transactional store.** The hard requirements are atomic multi-row updates ("record the vote *and* close the ballot *and* move to the runoff"), uniqueness guarantees, and bounded ordered history. SQLite provides real transactions, constraints and crash-safe journaling; it is the most battle-tested embedded store on Android.

**Why drift on top of it.** Typed queries, explicit transactions, a migration framework with schema snapshots and generated migration tests, and an in-memory database for fast recovery tests.

**Alternatives.**
- `shared_preferences` / a JSON file: no transactions across keys, no constraints; atomicity would be hand-built.
- `hive`, `isar`, `objectbox`: fast key-value/object stores, but weaker transactional and constraint semantics for this use, and a less certain maintenance outlook.
- `sqflite` or raw `sqlite3`: fewer dependencies and no code generation, but hand-written SQL strings, manual mapping and manual migration testing. Reasonable fallback if drift ever becomes a problem; the repository interfaces make the swap local to `lib/data/`.

## Data (indicative)

| Table | Holds | Key constraints |
|---|---|---|
| `roster` | Retained player names and order, selected packs (for replay) | — |
| `session` | The single active game: id, schema version, phase, players snapshot, impostor player id, word id, content version | At most one active row |
| `acknowledgement` | Player id per session | `UNIQUE(session, player)` |
| `vote` | Ballot (first / runoff), voter, target | `UNIQUE(session, ballot, voter)`, `CHECK(voter <> target)` |
| `final_guess` | Normalized guess and outcome | `UNIQUE(session)` |
| `cooldown` | Word id and a monotonically increasing sequence number | `UNIQUE(word_id)` |
| `settings` | Sound, haptics | — |

Word content itself is bundled, read-only JSON; the database stores only word IDs. The secret word is therefore never written to disk as text by the session tables.

The database constraints deliberately duplicate engine invariants: if a bug or a replayed action tries to insert a second vote, the transaction fails instead of corrupting the game.

## Transaction boundaries

Each row below is exactly one transaction. The UI changes only after it commits.

| Checkpoint | Written atomically |
|---|---|
| Start game | New session row (players snapshot, Impostor, word id, phase `reveal`). No cooldown entry yet. |
| Consume word | The cooldown entry for the session's word and a "consumed" mark on the session, once. Triggered by the first "I am {name}" of the game, which is "before the first private role reveal is prepared" (PRD §10). A game abandoned at setup or at the first handoff has prepared no reveal and consumes nothing. **Pending Q-16**; the alternative is to merge this into "Start game". |
| Acknowledge role | Acknowledgement row; if it is the last one, phase → `discussion` |
| Open voting | Phase → `firstBallot` |
| Submit vote | Vote row; if it is the last one, the computed outcome: phase → `finalGuess`, `runoff` or `result` |
| Submit runoff vote | Same, for the runoff ballot |
| Submit final guess | Guess, outcome, phase → `result` |
| Replay / leave | Delete the finished or cancelled session; keep roster, cooldown, settings |

Idempotency: a retried checkpoint either hits a uniqueness constraint (treated as "already done") or finds the phase already advanced; in both cases the engine re-derives the current state from the database rather than applying the action twice.

## Cooldown

Kept as an ordered list of distinct word IDs; trimmed to the newest 30 inside the same transaction that inserts. Selection excludes cooldown IDs; if no candidate remains, the oldest entries are ignored one at a time until a candidate exists (at most 30 steps, so it always terminates); if there is no approved content at all, a typed `noEligibleContent` failure is returned.

## Recovery

On launch:

1. Open the database. If it cannot be opened or migrated → **recovery failure**.
2. Load the active session, if any. Validate it fully: known schema version, phase is legal, 4–12 players, exactly one Impostor who is a player, word id exists in the bundled content at the stored content version, acknowledgements and votes reference real players, vote sets are consistent with the phase.
3. Valid → resume at the stored phase, always entering through a neutral screen (handoff or resume gate), never a revealed secret.
4. Invalid → **cancel safely**: delete the session rows in one transaction, keep roster, cooldown and settings, and show a neutral "the game could not be restored" message. Never repair by guessing, never reassign roles, never invent votes.

Recovery failure of the whole database (unreadable file): move the file aside, create a fresh database, and show the same neutral message. Cooldown history is lost in that case; this is accepted as the only safe option.

## Schema versioning

- `schemaVersion` starts at 1 and increases by one per change, with a drift migration and a generated migration test for every step.
- Schema snapshots are committed under `drift_schemas/`.
- A database with a version **newer** than the app understands (downgrade) is treated as incompatible → cancel safely as above.
- The session row also stores the content version; a session whose word no longer exists is invalid.

## Storage security

- The database lives in the app's private internal storage. Nothing is written to external storage.
- Cloud backup and device-to-device transfer are disabled in the manifest (`allowBackup="false"`, `dataExtractionRules`), so a saved session never leaves the device.
- No database encryption is proposed. The threat in PRD §12 is another player seeing the screen; reading app-private files requires a rooted device or debugger, at which point the same attacker can read process memory. Encryption would add a native dependency and a key-management problem for little gain.
- Retention is minimal: a finished session is deleted when the group replays or leaves.

## Open points for the Product Owner

- Q-03 in `docs/product/DECISIONS.md`: accept "no encryption at rest", or require it.
- Whether losing cooldown history after an unreadable database is acceptable (proposed: yes).
