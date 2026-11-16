# ADR-0004: Design tokens and asset integration

Status: Accepted (2026-11-15). Implemented.

## Context

The design package under `docs/design/` is the specification: six token JSON files, 43 assets and an asset manifest. The app must use those exact values and files, and a later design change must not be able to drift silently from the code.

## Decisions

### 1. Assets are bundled straight from `docs/design/assets/`

`pubspec.yaml` points at the design files; nothing is copied into a separate `assets/` folder. One copy means the app cannot ship a stale file.

- The icons directory is bundled whole (26 SVGs plus the Lucide licence).
- Logo files are listed one by one so `app_icon_preview.svg` ("do not ship") and the app-icon layers are not bundled.
- Fonts are declared with their upstream file names, including `NotoKufiArabic[wght].ttf`.
- Both OFL texts and the Lucide licence are bundled and registered with Flutter's `LicenseRegistry` at startup (PRD §13).
- The paper-grain texture, tools and reference renders are not bundled.

Cost: asset keys are long (`docs/design/assets/icons/ic_eye.svg`). They appear only in `lib/core/design/assets/tesskra_assets.dart`.

### 2. Tokens are hand-written Dart constants, checked against the JSON by a test

`lib/core/design/tokens/` mirrors the JSON files. `test/core/design/token_sync_test.dart` reads each JSON file and fails if any key is missing on either side or any value differs.

Chosen over a code generator because the token set is small and stable, constants stay `const` and readable, and there is no build step to maintain. If the token files start changing often, a generator can replace the hand-written files behind the same test.

A semantic colour that the JSON does not define for a theme is a nullable Dart field, and the test asserts it is null. Gaps in the design are surfaced, not papered over (see Q-07).

### 3. Theme mapping

Follows `docs/DESIGN_SYSTEM.md` §7: two `ThemeData` objects (`TesskraTheme.public`, `TesskraTheme.private`); a single `ThemeExtension` (`TesskraTokens`) for roles without a Material slot; the type scale mapped onto `TextTheme`. Metrics, motion and shadows are plain constants because they do not vary by theme at the point of use. Component themes will be added with the components.

Variable-font weights are set both as `fontWeight` and as a `wght` `FontVariation`; the sync test checks this for every Kufi style.

### 4. SVG rendering: `flutter_svg`

**Package:** `flutter_svg` 2.4.0. Flutter has no built-in SVG renderer, and the icon set and logos are delivered as SVG. The package is the de facto standard, long maintained, and resolves cleanly on the current SDK. Icons are tinted with a `ColorFilter`, like a Material `Icon`.

Alternatives: converting icons to an icon font (extra tooling, loses the 1:1 link to the design files); precompiled `vector_graphics` assets (a possible later optimisation if startup profiling shows SVG parsing matters; no evidence yet); rasterising to PNG (blurry at large sizes, many files).

Material's icon font is switched off (`uses-material-design: false`); the app uses only its own icons.

### 5. Android launcher icon

`android/app/src/main/res/drawable/ic_launcher_foreground.xml` and `ic_launcher_monochrome.xml` are VectorDrawables derived from `app_icon_foreground.svg` and `app_icon_monochrome.svg`; the background is the mustard palette colour. No icon-generation package is used.

These files are a second representation of the design and must be regenerated if the SVG layers change. Known limits: dashes are drawn as explicit segments (VectorDrawable has no dash array); devices on API 24–25 fall back to the default raster icon (Q-08); the result has not been checked on a device (Q-15).

### 6. Integrity

`test/core/design/asset_manifest_test.dart` checks that the manifest lists exactly the files on disk with matching byte sizes, that every icon has an enum value, that nothing marked `preview` is bundled, and that every font named in `typography.json` is declared in `pubspec.yaml`. `.gitattributes` marks the asset folder `-text` so Git never rewrites line endings and breaks the byte check.

## Known gaps

- Icon stroke is 2 in the files, 2.25 in the specification (Q-06).
- Real-device font rendering is unverified (Q-15).
