# ADR-0008: Error handling, diagnostics and build configuration

Status: **Proposed** (2026-11-16), revision 4. It applies Product Owner rulings D-11 to D-14 and awaits approval. The bootstrap and redacted reporter are implemented and unit-tested, and were checked on an emulator in profile and release builds (see "Verification", including its limits).

## Context

PRD §12 forbids sensitive gameplay data in logs. Rules and lints already forbid `print` and require secret-holding types to redact `toString()`. Errors that nobody catches were still unprotected.

Evidence from the installed SDK (Flutter 3.47.9). In `packages/flutter/lib/src/foundation/assertions.dart`, the default `FlutterError.onError` is `presentError` → `dumpErrorToConsole`:

- in profile and release builds the first error is printed with `label: details.exception.toString()`, followed by its stack (lines 1032–1037);
- every later error prints `Another exception was thrown: ${details.summary}` (line 1040). On the device this printed `Instance of 'ErrorSummary'` in profile and release, not the message.

The engine has its own fallback for errors outside the framework: when `PlatformDispatcher.onError` is unset or returns false, it logs `Unhandled Exception: <message>` and the stack at error level (`dart_vm_initializer.cc(40)`, observed on the device).

So by default a release build writes exception messages and stack traces to the device log (logcat). A message is free text, so one mistake would put a secret in the log.

There is no backend and no network permission, and no crash-reporting service is proposed.

## Decisions

### 1. Two kinds of failure

- **Expected outcomes** (invalid name, no eligible word, a write that failed) are typed failure values. The engine or a repository returns them and the screen renders them. They are never thrown and never logged.
- **Programmer errors** are thrown. Whatever is not caught reaches the two global handlers below.

### 2. Uncaught errors: origin and type only (D-11)

`lib/app/bootstrap.dart` installs both handlers before the first frame.

| Source | Reaches |
|---|---|
| Build, layout, paint, gesture callbacks (the framework calls `FlutterError.reportError`) | `FlutterError.onError` |
| Uncaught errors in futures, streams and timers in the root zone | `PlatformDispatcher.onError` |
| Riverpod listener and observer errors (`ProviderContainer` defaults to `Zone.current.handleUncaughtError`, riverpod 3.5.0 `provider_container.dart:975`) | `PlatformDispatcher.onError` |
| Riverpod provider build errors | **Neither.** They become an `AsyncError` state that the reading widget must render |

| Build | Behaviour |
|---|---|
| Debug | Flutter's defaults: full message, stack and the red error screen. Developer machine only (D-11 allows this). |
| Profile, release | `RedactedDiagnostics` writes one line: `[origin] ErrorType`. No message, no stack trace, no widget details. `PlatformDispatcher.onError` returns `true`, so the engine does not treat the error as unhandled. |

The reporter does not format the stack trace at all. If reading the error's type throws, it writes the fixed line `[origin] unreportable error`; it never throws back into the handlers. A failing sink (`print`) is not guarded, because there is nothing left to report to.

Cost: a release log line tells you *which kind* of error happened and *where it was caught*, but not the code location. Locating a bug needs a reproduction in a debug build.

### 3. One console entry point (D-11)

`Diagnostics` (`lib/core/diagnostics/diagnostics.dart`) has one method, `report(error, stack, origin:)`. It deliberately has no `log(String)`. `test/architecture/logging_guard_test.dart` fails if any file under `lib/` other than this one uses `print`, the `debugPrint*` family, `debugDump*`, `dart:developer` or `stdout`/`stderr`. Generated localizations are exempt.

Considered: `package:logging` or `logger` (a free-text API to police); a crash-reporting SDK (needs network, contradicts the offline and privacy scope).

### 4. Build configuration: one build, no environments

No flavours, no `--dart-define`, no environment files. Add them only when a real second configuration exists.

## Riverpod retry (D-12)

Riverpod 3 re-runs a failing provider automatically: up to 10 times, with backoff from 200 ms to 6.4 s, for `Exception`s but not `Error`s (`ProviderContainer.defaultRetry`). This is left unchanged for now. **When persistence is implemented, every checkpoint-related provider must set its retry behaviour explicitly**, so that no checkpoint is attempted again without the application deciding to (ADR-0003 idempotency).

## What the player sees today

Taken from SDK source and to be confirmed on a device:

- **Error while building a widget:** that subtree is replaced by `ErrorWidget`. In release the message is empty, because it is set only inside an `assert` (`widgets/framework.dart:5680–5691`). The box is plain grey `0xF0C0C0C0` (`rendering/error.dart:115`). The rest of the screen still renders.
- **Error in a tap handler or async code:** nothing visible; the action does not happen.
- **Native crash or process death:** the app closes; recovery is from the saved session at the next launch (ADR-0003, not built).

Privacy concern for later: on a private screen, a partial grey box beside surviving content could reveal part of a secret or make the two roles look different.

## Unexpected-error inventory (input for a later specification, D-14)

| Where | Example | Kind | Required behaviour |
|---|---|---|---|
| Startup, before `runApp` | Database cannot open (future) | Expected (ADR-0003 "recovery failure") | Neutral "could not be restored" path |
| Saved session invalid | Unknown schema, impossible phase | Expected | Cancel safely; never repair by guessing |
| Checkpoint write | Disk full, constraint violation | Expected, recoverable | Stay on the last committed state; explicit retry (D-12) |
| Content | No eligible word | Expected | Typed `noEligibleContent` |
| Content bundle unreadable | Malformed bundled JSON | Programmer or build error | Stop the operation; no game can start |
| Privacy platform call | `FLAG_SECURE` fails (ADR-0006) | Expected | Fail closed: do not show the secret |
| Engine transition | Rule bug | Programmer error | Abandon the intent; persist-first means no partial state |
| Widget build | Screen bug | Programmer error | Today: grey box. Needs a decision, especially on private screens |
| Async callback | Handler bug | Programmer error | Today: nothing visible |
| Native crash | Engine, OOM, OEM kill | Outside Dart | Restore from the database at next launch |

**Terminate the current operation, keep the session:** any programmer error during an intent.

**Terminate the session (cancel safely):** only an invalid or unreadable saved session.

**Never displayed:** exception messages, type names, stack traces, error codes derived from data, any secret. On private screens, nothing that differs between roles.

**Still needs Product Owner approval:**

- a neutral replacement for `ErrorWidget`, identical for both roles, that removes private content;
- where an error mid-game leads (tied to Q-19 and ADR-0006);
- the Arabic copy for that state, which starts as `[REVIEW]`.

## Outside this ADR's control

- Output written by the Flutter engine (C++) and by Android itself, for example an "Unhandled Exception" fallback, a native crash dump, or ANR traces. See "Verification" for what was observed.
- Output from third-party packages that call `print` directly. The source guard covers `lib/` only. The dependency list is short partly for this reason.

## Testing

| Test | Covers |
|---|---|
| `test/core/diagnostics/diagnostics_test.dart` | Only `[origin] Type` is written; the message never reaches the sink for five error shapes; the stack trace is never written or formatted; an unreadable type gives a fixed line instead of a throw |
| `test/app/bootstrap_test.dart` | Both handlers route to the reporter when not verbose; debug keeps the defaults |
| `test/architecture/logging_guard_test.dart` | No console output outside the diagnostics implementation |

## Verification (2026-11-16)

**Device:** emulator `Pixel_XL_API_36`: Android 16, API 36, x86_64, Google system image `sdk_gphone16k_x86_64` (16 KB pages). No physical device was used.

**Method:** a temporary entry point (`tool/diagnostics_probe.dart`, now deleted) threw a `StateError` through five paths: a widget build, two real taps on a tap handler, an uncaught timer error, and a Riverpod listener. Each message contained a unique marker and the text `secret-word-placeholder`, and each was thrown from a uniquely named function, so a leaked stack trace would be detectable. With the handlers on, the probe called `installErrorHandlers(const RedactedDiagnostics(), verbose: kDebugMode)`, exactly as `bootstrap()` does. For each run, logcat was cleared, the app launched, the taps sent through `adb`, and the **whole-device** log searched.

| Build | Handlers | Lines from our reporter | Message marker found | Stack marker found | Process survived |
|---|---|---|---|---|---|
| profile | ours | 5: `[framework] StateError` ×3, `[platform] StateError` ×2 | **0** | **0** | yes |
| profile | none (baseline) | — | 3 (build, async, Riverpod) | yes, 100-frame stack | yes |
| release | ours | 5, same as profile | **0** | **0** | yes |
| release | none (baseline) | — | 3 (build, async, Riverpod) | yes | yes |

**Result:** in profile and release builds on this emulator, an uncaught error from these five paths reaches logcat only as `[origin] ErrorType`. Without the handlers, the same build leaks messages and full stacks, which include the build machine's absolute source paths (`file:///C:/projects/...`).

**Engine fallback:**

- *Controllable:* the engine's `Unhandled Exception` print happens only when `PlatformDispatcher.onError` is unset or returns false. Returning `true` suppressed it in both builds.
- *Not controllable from Dart:* the engine's own startup lines (the Impeller backend line; the Dart VM service URL, which appears in profile only and not in release); native crash dumps (tombstones); Android system logging about the process (ActivityManager, ANR traces); and anything printed by a future plugin's Java or Kotlin code. None of these were observed to carry app data, but only startup and the probe paths were exercised.

**Also observed:**

- Debug build: cold start 5.05 s with no Dart or Flutter errors. Fonts, logo, paper background and RTL wordmark rendered as expected.
- Lifecycle with the placeholder screen:
  - HOME then resume kept the same process.
  - BACK on the root activity moves the task to the background (Android 16 behaviour); relaunch is warm.
  - Killing the process in the background, then relaunching, gave a clean cold start.
  - No errors in any of these.
- The recents thumbnail shows the full screen content. Expected, since `FLAG_SECURE` is not implemented (ADR-0006, Q-04).
- The adaptive launcher icon renders on API 36.
- With a build error, the throwing widget's area was a plain grey box with no text, as predicted. The rest of the probe screen rendered black instead of its intended green; this was not investigated.

**Not verified:**

- Physical devices, OEM builds, and Android versions other than 16.
- Obfuscated builds (`--obfuscate`, not used).
- An error thrown *inside* our handler. The reporter is unit-tested not to throw, but the engine's behaviour if it did was not observed.
- Errors before `installErrorHandlers` runs.
- Errors in other isolates (none exist).
- Native crashes.
- The real app, rather than the probe, throwing in release.

Profile and release were each tested separately. Neither result is inferred from the other.
