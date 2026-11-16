# ADR-0006: Android privacy protections

Status: Proposed (2026-11-15). Only the backup settings are implemented. Everything else waits for the private-screen milestone and for a ruling on Q-04. Nothing in this ADR has been verified on a device.

## Requirements (PRD §12)

- `FLAG_SECURE` on sensitive screens where supported.
- App-switcher previews must not show private game information.
- Resume into a neutral screen, never a visible secret.
- No secrets in notifications or logs.
- Minimal retention; a defined secure local-storage strategy.

## Decisions

### Screenshot and recents protection: a small platform channel, no plugin

`FLAG_SECURE` is one call on the activity window. A `MethodChannel` handled in `MainActivity` (a few lines of Kotlin) with a Dart wrapper behind an interface is enough.

Considered and rejected: a third-party plugin for this flag. Such a plugin can only wrap the same single call; owning a few lines is cheaper than tracking a dependency, and it lets us define exactly when the flag changes. No specific plugin was evaluated.

Proposed behaviour (pending Q-04):

- The single private wrapper widget (`PrivateScope` in the design system) turns the flag on **before** any secret can be built and awaits the platform reply. If the call fails, the private content is not shown and an error is surfaced; the app does not silently continue unprotected.
- The flag is cleared when the last private screen is left.
- Alternative for the Product Owner: set the flag once for the whole app. Simpler and removes any timing window, but blocks screenshots of the public result screen.

`FLAG_SECURE` also blanks the recents thumbnail on supported Android versions. Because that is OEM-dependent, a second layer is added:

### Neutral cover on lifecycle change

When the app leaves the foreground (`AppLifecycleState.inactive` / `paused` / `hidden`) while a private screen is shown, the secret is removed from the widget tree immediately and the flow returns to the neutral handoff for the same player. On resume the player must reveal again (allowed by PRD §5 when the acknowledgement was not committed). A revealed ticket is never restored, and Android route/state restoration is not used for game screens.

### No notifications, no logs

The app declares no notification permission and posts none. Logging of game data is forbidden by rule and by lint (`avoid_print`); types that hold secrets redact `toString()`.

### Storage (implemented)

`android:allowBackup="false"`, `android:fullBackupContent="false"` and a `dataExtractionRules` file that excludes every domain from cloud backup and device transfer. The rest of the storage strategy is in ADR-0003.

### Permissions

The release manifest should contain no permissions. In particular `INTERNET` must be absent in release builds (Flutter adds it only to debug and profile manifests). The release skill checks the merged manifest.

## Testing

- Dart side: the lifecycle behaviour and the "no secret before reveal / after acknowledge / after resume" rules are widget-tested with a fake privacy service.
- Platform side: `FLAG_SECURE` and the recents preview can only be verified on real hardware. PRD §12 forbids claiming they work otherwise. Verification is recorded per device and Android version.

## Open points

- Q-04: flag scope (private screens only vs whole app).
- Q-15: no device has been available yet.
