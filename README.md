# Impostor TN

An offline, single-device, pass-and-play social-deduction party game for Android, in Tunisian Derja. Four to twelve players share one phone; one of them is the Impostor.

**Status: engineering foundation only.** The project builds and shows a placeholder screen. There is no gameplay and no product screen yet; both wait for approved UX flows and screen specifications. See [docs/DEVELOPMENT_CHECKLIST.md](docs/DEVELOPMENT_CHECKLIST.md).

## Documentation

| Topic | Where |
|---|---|
| Product requirements and gameplay rules | [docs/product/PRD.md](docs/product/PRD.md) |
| Product Owner decisions and open questions | [docs/product/DECISIONS.md](docs/product/DECISIONS.md) |
| Design handoff (start here for UI) | [docs/DESIGN_HANDOFF.md](docs/DESIGN_HANDOFF.md) |
| Design system, direction, motion, localization | [docs/](docs/) |
| Tokens, assets, reference renders | [docs/design/](docs/design/) |
| Architecture decisions | [docs/architecture/ADR/](docs/architecture/ADR/) |
| Progress | [docs/DEVELOPMENT_CHECKLIST.md](docs/DEVELOPMENT_CHECKLIST.md) |
| Instructions for Claude Code | [CLAUDE.md](CLAUDE.md), [.claude/](.claude/) |

## Requirements

- Flutter 3.47.9 (stable) with Dart 3.13.7. Newer stable releases should work; re-run the checks below after upgrading.
- Android SDK with platform 36 and build-tools 36, and a JDK supported by the Android Gradle Plugin.
- No network access is needed at runtime. The first build downloads Gradle and Android dependencies.

## Commands

```
flutter pub get               # resolve packages and generate localizations
flutter gen-l10n              # regenerate after editing lib/l10n/app_ar.arb
dart format lib test tool
flutter analyze
flutter test
flutter build apk --debug
flutter run                   # needs a connected device or emulator
```

## Structure

```
lib/app/      application root, licences, placeholder screen
lib/core/     Tesskra design system (tokens, themes, icon widget) and text helpers
lib/l10n/     Arabic strings (app_ar.arb) and generated localizations
test/         mirrors lib/
tool/         developer scripts
android/      Android project
docs/         product, design and architecture documentation
```

`lib/game/`, `lib/data/` and `lib/features/` are described in ADR-0001 and will be added with the first gameplay milestone.

## Design assets

Fonts, icons and logos are bundled directly from `docs/design/assets/`; there is no second copy. Token values in `lib/core/design/tokens/` mirror `docs/design/tokens/*.json`, and the test suite fails if they differ. Change the JSON first, then the Dart constant.

## Licences

- Noto Kufi Arabic and IBM Plex Sans Arabic: SIL Open Font License 1.1 (`docs/design/assets/fonts/OFL-*.txt`).
- Lucide icons: ISC (`docs/design/assets/icons/LICENSE-lucide.txt`).

These texts ship inside the app and are registered in its licence page.
