# ADR-0008: Error handling, diagnostics and build configuration

Status: Proposed (2026-11-16), revised after review the same day. The bootstrap and the redacted reporter are implemented and unit-tested. What the player sees after an unexpected error is not designed and not built. Nothing here has been observed on a device (Q-15). **Release logging is not verified as safe**: it has not been run.

## Context

PRD §12 forbids sensitive gameplay data in logs. Rules and lints already forbid `print` and require secret-holding types to redact `toString()`. Errors that nobody catches were still unprotected.

Evidence from the installed SDK (Flutter 3.47.9). In `packages/flutter/lib/src/foundation/assertions.dart`, the default `FlutterError.onError` is `presentError` → `dumpErrorToConsole`:

- in profile and release builds the first error is printed with `label: details.exception.toString()`, followed by its stack (lines 1032–1037);
- every later error prints `Another exception was thrown: ${details.summary}`, which also contains the message (line 1040).

So without this ADR, a release build writes exception messages to the device log (logcat). A message is free text, so one mistake, such as a name, a guess or a word inside an exception string, would put a secret in the log. For errors outside the framework the engine has its own fallback print when `PlatformDispatcher.onError` is unset or returns false. That print is in engine C++ and was **not** inspected.

The app has no backend and no network permission. There is no crash-reporting service and none is proposed.

## Decisions

### 1. Two kinds of failure

- **Expected outcomes** (invalid name, no eligible word, a write that failed) are typed failure values. The engine or a repository returns them and the screen that caused them renders them. They are never thrown and never logged.
- **Programmer errors** are thrown. Whatever is not caught reaches the two global handlers below.

### 2. Uncaught errors are reported without their message

`lib/app/bootstrap.dart` installs both handlers before the first frame.

| Source | Reaches |
|---|---|
| Build, layout, paint, gesture callbacks (the framework catches these and calls `FlutterError.reportError`) | `FlutterError.onError` |
| Uncaught errors in futures, streams and timers in the root zone | `PlatformDispatcher.onError` |
| Riverpod listener and observer errors (`ProviderContainer` defaults to `Zone.current.handleUncaughtError`, riverpod 3.5.0 `provider_container.dart:975`) | `PlatformDispatcher.onError` |
| Riverpod provider build errors | **Neither.** They become an `AsyncError` state that the reading widget must render (see "Open points") |

| Build | Behaviour |
|---|---|
| Debug | Flutter's defaults: full details in the console and the red error screen. Developer machine only. |
| Profile, release | `RedactedDiagnostics` writes one entry: an origin label, the error's **type name** and the stack trace. The message and widget details are dropped. `PlatformDispatcher.onError` returns `true`, so the engine's fallback print does not run. |

The reporter cannot throw because of its input: if formatting fails, it writes a fixed entry instead. This avoids re-entering the handlers. A failing sink (`print`) is not guarded; there is nothing left to report to.

### 3. One logging entry point, no logging package

`Diagnostics` (`lib/core/diagnostics/diagnostics.dart`) has a single method, `report(error, stack, origin:)`. There is deliberately no `log(String)`: free-text logging is how secrets leak, and production has nothing to trace.

Considered: `package:logging` or `logger` (more API than needed, and a free-text interface to police); a crash-reporting SDK (needs network, contradicts the offline and privacy scope).

### 4. Build configuration: one build, no environments

No flavours, no `--dart-define`, no environment files. There is no server, key or per-environment value. Add flavours only when a real second configuration exists.

## Stack traces in production logs

Kept, pending your ruling. A Dart stack trace contains function names, `package:` file paths and line numbers, never values. It is the only way to locate a crash from a tester's report. On Android 4.1 and later, other apps cannot read logcat; reading it needs `adb` with USB debugging on, or a bug report. Dropping the stack too would leave a release log with almost nothing useful. If you prefer zero output in release, the sink can become a no-op for `kReleaseMode` in one line.

## What the player sees today (from SDK source, not observed on a device)

- **Error while building a widget:** that widget's subtree is replaced by `ErrorWidget`. In release, the default builder leaves the message empty: it is filled only inside an `assert` (`widgets/framework.dart:5680–5691`). The box is plain grey, `0xF0C0C0C0` (`rendering/error.dart:115`). The rest of the screen still renders.
- **Error in a tap handler or async code:** nothing visible. The action silently does not happen.
- **Native crash or process death:** the app closes. Recovery happens at the next launch from the saved session (ADR-0003, not built).

Privacy concern for later: on a private screen, a partial grey box beside surviving content could reveal part of a secret. It could also make the civilian and Impostor screens look different.

## Unexpected-error inventory (for the future error-screen specification)

| Where | Example | Kind | Required behaviour |
|---|---|---|---|
| Startup, before `runApp` | Database cannot open (future) | Expected (ADR-0003 "recovery failure") | Neutral "could not be restored" path, already specified as a flow |
| Saved session invalid | Unknown schema, impossible phase | Expected | Cancel safely (ADR-0003); never repair by guessing |
| Checkpoint write | Disk full, constraint violation | Expected, recoverable | UI stays on the last committed state; retry offered |
| Content | No eligible word | Expected | Typed `noEligibleContent`, shown on the packs screen |
| Content bundle unreadable | Malformed bundled JSON | Programmer or build error | Stop the operation; no game can start |
| Privacy platform call | Setting `FLAG_SECURE` fails (ADR-0006) | Expected | Fail closed: do not show the secret |
| Engine transition | Bug in a rule | Programmer error | Abandon the intent. Persist-first means no partial state was written |
| Widget build | Bug in a screen | Programmer error | Today: grey box. Needs a decision, especially on private screens |
| Async callback | Bug in a handler | Programmer error | Today: nothing visible. Operation abandoned |
| Native crash | Engine, OOM, OEM kill | Outside Dart | Next launch restores from the database |

**Terminate the current operation, keep the session:** every programmer error in an intent. State is unchanged because nothing advances before the commit.

**Terminate the session (cancel safely):** only an invalid or unreadable saved session (ADR-0003).

**Must never be displayed:** exception messages, type names, stack traces, error codes derived from data, any secret. On private screens, nothing that differs between roles.

## Needs your approval (not decided here)

1. A neutral replacement for `ErrorWidget` in release. It must be identical for both roles and must remove any private content.
2. Where an unexpected error mid-game leads: stay on the screen, return to the neutral handoff or resume gate, or offer "leave the game". This is tied to Q-19 and ADR-0006.
3. The Arabic copy for that state. New strings start as `[REVIEW]`.
4. Stack traces in release logs: keep (current) or drop.
5. Riverpod's automatic retry. Riverpod 3 re-runs a failing provider up to 10 times by default, with backoff (`ProviderContainer.defaultRetry`, for `Exception`s, not `Error`s). For checkpoint code this would mean hidden repeated attempts. Recommendation: set `retry` to never retry on the root `ProviderScope` at the persistence milestone, and make retries explicit. No providers exist yet, so nothing is affected today.

## Consequences

- If the reporter behaves as designed, a release log line from this app contains only an origin label, a type name and a stack trace. This has **not** been checked on a device.
- Output from third-party packages and from the engine itself is outside this control; the dependency list is short for that reason.

## Testing

| Test | Covers |
|---|---|
| `test/core/diagnostics/diagnostics_test.dart` | The message never reaches the sink, for five error shapes; a stack trace that cannot be formatted produces a fixed entry instead of a throw |
| `test/app/bootstrap_test.dart` | Both global handlers route to the reporter when not verbose; debug leaves the defaults |

**Not tested:** logcat output of a profile or release build on a device; the engine's fallback print; `ErrorWidget` appearance on a device.
