# ADR-0008: Error handling, diagnostics and build configuration

Status: Proposed (2026-11-16). The bootstrap and the redacted reporter are implemented and unit-tested. What the player sees after an unexpected error is not designed and is not built. Nothing here has been observed on a device (Q-15).

## Context

PRD §12 forbids sensitive gameplay data in logs. Rules and lints already forbid `print` and require secret-holding types to redact `toString()`. One path was still open: errors nobody catches. By default Flutter writes them to the device log (logcat) **with their message**, in release builds too. A message is free text; a single mistake (a name, a guess, a word inside an exception string) would put a secret in the log.

The app has no backend and no network permission, so there is no crash-reporting service and none is proposed.

## Decisions

### 1. Two kinds of failure

- **Expected outcomes** (invalid name, no eligible word, a write that failed) are typed failure values returned by the engine or a repository and rendered by the screen that caused them. They are never thrown and never logged. (Already in `.claude/rules/dart-conventions.md`.)
- **Programmer errors** are thrown. Whatever is not caught reaches the two global handlers below.

### 2. Uncaught errors are reported without their message

`lib/app/bootstrap.dart` installs `FlutterError.onError` (framework errors) and `PlatformDispatcher.onError` (everything else) before the first frame.

| Build | Behaviour |
|---|---|
| Debug | Flutter's defaults: full details in the console and the red error screen. Developer machine only. |
| Profile, release | `RedactedDiagnostics` writes one entry: where it was caught, the error's **type name**, and the stack trace. The message and any widget details are dropped. |

A stack trace holds file names and line numbers, no data. The type name plus the stack is enough to locate a bug from a tester's bug report, and it cannot carry a secret whatever the message contained.

Debug builds keep full messages because development without assertion text is impractical. The first line of defence there remains the rule that messages and `toString()` never contain a secret.

### 3. One logging entry point, no logging package

`Diagnostics` (`lib/core/diagnostics/diagnostics.dart`) has a single method, `report(error, stack, origin:)`. There is deliberately no `log(String)`: free-text logging is how secrets leak, and the app has nothing it needs to trace in production. Code that catches an unexpected error passes it to `Diagnostics`; it does not format it.

Considered: `package:logging` or `logger` (levels, sinks and formatting the app does not need, and a free-text API we would then have to police); a crash-reporting SDK (needs network, contradicts the offline and privacy scope).

### 4. Build configuration: one build, no environments

No flavours, no `--dart-define` settings, no environment files. There is no server, key or per-environment value to configure; the only variation is Flutter's own debug/profile/release mode. Add flavours only when a real second configuration exists.

## Not decided here

- **What the player sees** when an unexpected error happens mid-game. Today a release build shows Flutter's plain grey box in place of the failed widget, with no text. A proper neutral screen ("something went wrong", return home) needs a specification and Arabic copy; it is not invented here. It must also clear any private content, which ties it to ADR-0006.
- **Recovery after such an error** belongs to ADR-0003: the saved session is the only source of truth.

## Consequences

- A release log line from this app can contain only an origin label, a type name and a stack trace.
- Output from third-party packages or the engine itself is outside this control; the dependency list is short for that reason.
- Type names must stay free of secrets, which is trivially true for classes.

## Testing

`test/core/diagnostics/diagnostics_test.dart` and `test/app/bootstrap_test.dart`: the message of a reported error never reaches the sink; both global handlers route to the reporter outside debug mode. Whether logcat on a real device shows exactly this is **not tested** (Q-15).
