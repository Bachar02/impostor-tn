---
paths:
  - "lib/core/design/**"
  - "lib/features/**/presentation/**"
  - "lib/app/**"
  - "lib/l10n/**"
---

# Flutter UI and design implementation

The design documents are specifications. Read the relevant section and open the matching render in `docs/design/reference/png/` before building or changing a component.

## Tokens

- No literal colours, sizes, radii, durations or text styles in widgets. Use `TesskraTokens.of(context)`, `Theme.of(context)`, and the constants in `lib/core/design/tokens/`.
- Token JSON is the source of truth. To change a value, change the JSON (with Product Owner approval), then the Dart constant; `token_sync_test.dart` must pass.
- A nullable field on `TesskraColors` means the token file does not define that role for that theme. Do not substitute a guess; ask.
- Role colours (`TesskraRoleColors`) are for public result screens only.

## Themes

- Public screens use the paper theme; a screen one player sees alone uses the carbon theme through the single private wrapper.
- Hard shadows are physical: never mirror them in RTL. Pressed state translates by the shadow offset and removes the shadow.

## RTL and text

- The app is RTL only. Use `EdgeInsetsDirectional`, `AlignmentDirectional`, `BorderRadiusDirectional`, `start`/`end`. Never `left`/`right`.
- Wrap numeric groups (`2 / 6`, `4–12`) and Latin fragments with `ltrIsolate`; wrap user-entered names with `directionIsolate`.
- Western digits everywhere. Arabic punctuation (`؟`, `،`) in Arabic strings.
- Only `arrowRight` (back) and `chevronLeft` (forward) are directional; no icon is auto-mirrored.
- All user-facing text comes from `lib/l10n/app_ar.arb`. New strings start as `[REVIEW]` and should come from the glossary in `docs/ARABIC_LOCALIZATION.md`; do not write new Derja copy without flagging it.

## Layout and accessibility

- Single column, content capped at 480, margins from `TesskraLayout.screenMarginFor`.
- Touch targets at least 48 × 48. Status is never colour alone: icon + text.
- Must not overflow at 320 wide, at text scale 1.5, or with a long name. Above 1.5 clamp display styles only, never body text.
- Honour `MediaQuery.disableAnimations` with the `reducedMotion` values in `animations.json`.
- Interactive icons need a semantic label; decorative ones are excluded from semantics.

## Performance

- `const` widgets where possible; watch the narrowest provider slice; keep `build` free of I/O and heavy work.
- No animation may render a secret outside the fully revealed state; no shared-element transitions on private screens.

## Scope

Do not add a screen, state, interaction or setting that is not in an approved specification. If the spec is missing or contradictory, stop and ask.
