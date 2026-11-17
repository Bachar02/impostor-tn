# Physical-device privacy checklist

Status: **prepared 2026-11-17; not yet run on any physical device.** Every result below is empty until someone runs it on a real phone. PRD §12 forbids claiming screenshot or app-switcher protection works without this verification.

Purpose: verify on real Android phones the protections of PRD §12, D-18 (screenshot protection for the whole game) and UX_FLOWS F11 (return to the neutral handoff), which automated tests and the emulator cannot prove.

## Before you start

- **Build:** a debug build (`flutter build apk --debug`). Release builds have no playable words until Q-13 is resolved; the screenshot flag is set the same way in every build type.
- **Devices:** at least one Pixel or other near-stock Android phone, and one phone with a heavily customised Android (Samsung One UI, Xiaomi HyperOS/MIUI, Oppo/Realme ColorOS). Record the oldest Android version available.
- **Second phone:** for the incoming-call checks, with a SIM, or a VoIP app if the test phone has none.
- **Record for each device:** make, model, Android version, OEM skin and version, build date of the APK.
- **Game set-up:** 4 players, development pack A. Note which player is the Impostor only from the ticket, as a player would.

In each table, write **Pass**, **Fail** (with a short note and, if possible, a photo taken with another phone), or **N/A** (the phone lacks the feature).

## 1. Screenshots and recordings

| # | Where | Action | Expected | Result |
|---|---|---|---|---|
| 1.1 | Home | Power + volume-down | Normal screenshot (control) | |
| 1.2 | First handoff | Power + volume-down | Screenshot refused or black | |
| 1.3 | Sealed ticket | Same | Refused or black | |
| 1.4 | Revealed ticket, Civilian | Same | Refused or black | |
| 1.5 | Revealed ticket, Impostor | Same | Refused or black | |
| 1.6 | Vote screen with an option selected | Same | Refused or black | |
| 1.7 | Final guess with text typed | Same | Refused or black | |
| 1.8 | Discussion, tally, results | Same | Refused or black (D-18: the whole game) | |
| 1.9 | Revealed ticket | OEM gesture screenshot (three-finger swipe, palm swipe, "smart select", scrolling capture) | Refused or black | |
| 1.10 | Revealed ticket | Built-in screen recorder running, then reveal | The recording shows black for the game | |
| 1.11 | Revealed ticket | Assistant "what's on my screen" / Circle to Search | Nothing of the ticket is read or shown | |
| 1.12 | Revealed ticket | Cast or mirror the screen to a TV or another device | The cast shows black for the game | |
| 1.13 | Home after leaving a game | Power + volume-down | Normal screenshot again (protection switched off) | |

## 2. App switcher (recents) thumbnails

| # | Where | Action | Expected | Result |
|---|---|---|---|---|
| 2.1 | Home | Open recents | Normal thumbnail (control) | |
| 2.2 | Revealed ticket | Open recents | Thumbnail blank or cover, no role, word or category | |
| 2.3 | Vote screen with an option selected | Open recents | No ballot or selection visible | |
| 2.4 | Final guess with text typed | Open recents | No typed text visible | |
| 2.5 | Results | Open recents | Blank (D-18) | |
| 2.6 | Revealed ticket | Recents, then back into the game | Neutral handoff of the same player; ticket sealed | |
| 2.7 | Revealed ticket | Press Home, wait 10 s, open recents | Thumbnail still blank | |
| 2.8 | Revealed ticket | Swipe between apps on the gesture bar without opening recents | No frame of the ticket visible in the swipe animation | |

## 3. Leaving the foreground

| # | Where | Action | Expected on return | Result |
|---|---|---|---|---|
| 3.1 | Revealed ticket | Home, then reopen from the launcher | Handoff of the same player; ticket sealed | |
| 3.2 | Revealed ticket | Power button (screen off), then unlock | Lock screen shows nothing of the game; then the handoff | |
| 3.3 | Revealed ticket | Pull down the notification shade, then close it | Ticket still revealed (the shade alone does not count as leaving; same player holding the phone) | |
| 3.4 | Vote screen with an option selected | Home, then return | Handoff of the same voter; no selection | |
| 3.5 | Final guess with text typed | Home, then return | Handoff of the Impostor; field empty | |
| 3.6 | Revealed ticket | Enter split-screen or pop-up view | Neutral handoff, or the game blanked; never the ticket in a small window | |
| 3.7 | Revealed ticket | Tap "got it", then press Home at once | On return: a handoff (same or next player), never a ticket | |
| 3.8 | Any game screen | Force-stop from settings, reopen | Resume gate, then the right handoff; nothing secret before "continue" | |
| 3.9 | Mid-game | Restart the phone, reopen | Resume gate, then the right handoff | |

## 4. Incoming calls

| # | Where | Action | Expected | Result |
|---|---|---|---|---|
| 4.1 | Revealed ticket, phone unlocked | Call the phone; do not answer | Call banner over the game. Game state unchanged; nothing secret in the banner | |
| 4.2 | Revealed ticket | Answer from the banner | Call screen in front. After hanging up: handoff of the same player, ticket sealed | |
| 4.3 | Revealed ticket | Decline from the banner | Ticket still revealed (the app never left the foreground) | |
| 4.4 | Revealed ticket, screen off | Call the phone (full-screen call UI) | After the call and unlocking: handoff, never the ticket | |
| 4.5 | Vote screen with an option selected | Answer a call, hang up | Handoff of the same voter, no selection | |
| 4.6 | Final guess with text typed | Answer a call, hang up | Handoff of the Impostor, field empty | |
| 4.7 | During a save ("got it" or "confirm" pressed) | Answer a call right after pressing | On return: a handoff, never a secret; the vote or acknowledgement counted once | |

## 5. Other channels

| # | Check | Expected | Result |
|---|---|---|---|
| 5.1 | Notifications during and after a game | The app posts none | |
| 5.2 | TalkBack on a sealed ticket | Reads the name and "role hidden" only | |
| 5.3 | TalkBack on a revealed ticket | Reads the role only after the reveal action; nothing after "got it" | |
| 5.4 | Select to Speak / screen reader text selection on a revealed ticket | Secret text not selectable or copyable | |
| 5.5 | Keyboard suggestions after typing a guess | The guess does not appear later as a suggestion in other apps (private input) | |
| 5.6 | Settings → Apps → the app → Storage | No backup option exposes game data; "clear data" ends the game safely | |

## 6. Motion and accessibility on the device

| # | Check | Expected | Result |
|---|---|---|---|
| 6.1 | Start a game, finish the reveals, vote | Carbon sheet slides up and down without flashes of the previous screen's secret | |
| 6.2 | Reveal a ticket | Seal lifts, then the role fades in; identical for both roles (duration, haptic) | |
| 6.3 | Android Settings → Accessibility → Remove animations, repeat 6.1 and 6.2 | Short cross-fades only, no slides or slam | |
| 6.4 | Status bar icons on carbon and paper screens | Light icons on carbon, dark on paper | |

## Reporting

Copy the tables into a dated run record per device (`docs/quality/runs/<date>-<device>.md`). Report failures to the Product Owner with the device details. A failure in sections 1–4 blocks the release.

For comparison, the emulator results (`Pixel_XL_API_36`, Android 16) are in `docs/DEVELOPMENT_CHECKLIST.md`. They do not count as physical-device verification.
