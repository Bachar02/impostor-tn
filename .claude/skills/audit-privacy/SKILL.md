---
name: audit-privacy
description: Audit Impostor TN for leaks of the secret word, roles, votes or final guess through logs, screens, storage, Android previews or recovery. Use when asked for a privacy audit or before any release.
---

# Audit privacy

Secrets: the secret word, who the Impostor is, any role, any vote before results, the final guess. Requirements: PRD §5, §7, §11, §12 and ADR-0006.

1. **Logging and messages.** Search `lib/` for `print(`, `debugPrint(`, `log(`, `developer.`, `Logger`, `FlutterError.reportError`, `throw`, `assert(`, `toString()`. For each hit on a code path that can hold a secret, confirm the secret cannot be interpolated. Types that hold secrets must have a redacting `toString()`.
2. **Screens.** For every widget that reads a secret, confirm:
   - it is one of the specified private screens, under the private wrapper;
   - nothing secret is built before the deliberate reveal action;
   - the secret leaves the tree in the same frame as the acknowledgement;
   - no animation, hero, tooltip, semantics label or text-selection path exposes it;
   - Civilian and Impostor variants build the same structure with the same colours, sounds and haptics.
3. **Lifecycle.** Trace `AppLifecycleState` handling: backgrounding on a private screen must return to the neutral handoff; nothing restores a revealed ticket; no notification is ever posted.
4. **Storage.** Confirm the secret is stored as a word ID, only in app-private storage; backups and device transfer are disabled in the Android manifest; nothing is written to external storage; finished sessions keep only what results and replay need.
5. **Android.** Check `FLAG_SECURE` is applied where ADR-0006 specifies and that the app-switcher preview is covered.
6. **Tests.** Confirm tests exist for: secret absent before reveal and after acknowledgement; identical structure for both roles; neutral resume. Add missing ones.
7. **Device verification.** If a device or emulator is connected, verify screenshot blocking, the recents preview and resume behaviour by hand and record the device, Android version and result. If none is connected, mark these **not verified**.

## Output

Leaks found (severity, `file:line`, how to reproduce), checks passed, and an explicit list of what was not verified on a device. Never state that screenshot or app-switcher protection works without having observed it.
