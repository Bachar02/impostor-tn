# ADR-0002: State management, dependency injection and navigation

Status: Accepted (2026-11-15).

## State management and dependency injection: Riverpod

**Package:** `flutter_riverpod` 3.5.0 (resolved 2026-11-15 on Flutter 3.47.9 / Dart 3.13.7). Used **without** `riverpod_generator` or annotations.

**Why it is needed.** The app needs (1) one place that owns the current game session and survives navigation, (2) explicit, overridable construction of the database, content loader, random source and clock, and (3) rebuilds limited to the widgets that read a changed value. Flutter's own tools (`InheritedWidget`, `ValueNotifier`, `ChangeNotifier`) cover (3) but leave (1) and (2) to hand-written plumbing.

**Why Riverpod.**
- One mechanism for both state and dependency injection; no separate service locator.
- Compile-time safe: no `ProviderNotFoundException`, no dependence on `BuildContext` for non-UI code.
- `ProviderScope(overrides: …)` / `ProviderContainer` make every dependency replaceable in tests without mocks.
- `select` and narrow providers keep rebuilds small.
- Actively maintained; resolves cleanly against the current SDK.

**Rules of use.**
- Providers live in `features/<x>/application/` or `app/`. The engine (`lib/game/`) never imports Riverpod.
- No code generation: plain `Provider`, `Notifier`, `AsyncNotifier`.
- A notifier never mutates and then persists. It persists, then sets state (ADR-0003).

**Alternatives.**
- `provider` + `ChangeNotifier`: fewer features, runtime lookup errors, weaker test overrides.
- `flutter_bloc`: solid, but adds an event/state layer on top of an engine that is already an explicit state machine, and still needs a DI solution.
- `get_it`: a global service locator; hides dependencies and needs manual reset between tests.
- Hand-rolled `InheritedWidget`s: no dependency, but we would rebuild a small part of Riverpod.

## Navigation: Flutter's built-in `Navigator`

No routing package.

**Why.** Android only, no deep links, no web URLs, no nested shells. The screen shown during a game is a function of the persisted game phase, not of a URL: after a restart the app must land on the screen the saved phase dictates (PRD §11), and private screens must not be reachable or restorable by route. A declarative router's main benefits (URL parsing, deep linking, web history) are unused here.

**Shape (to be confirmed against the UX flows).**
- Outside a game (home, setup, help, settings): ordinary `Navigator.push` / `pop`.
- Inside a game: one route hosts a widget that switches on the session phase. System back opens the "leave the game?" dialog instead of popping to a previous player's screen.
- Android state restoration is **not** enabled for game routes; recovery comes from the database only.

**Alternative.** `go_router` (maintained by the Flutter team) would work and can be adopted later without touching the engine if deep links or a larger route tree appear.

## Models: no code generation

Dart 3 `sealed` classes, records and pattern matching cover the needs of the domain. `freezed`, `json_serializable` and `equatable` are not used; the few value types write `==`/`hashCode` by hand. This keeps `build_runner` out of the daily loop (it will still be needed for drift, ADR-0003).

## Consequences

- One runtime dependency for state and DI; none for navigation or models.
- Riverpod is a framework-level choice and would be costly to replace; the engine is insulated from it by design.
