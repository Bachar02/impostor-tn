# ADR-0009: Word content format, validation and eligibility

Status: Implemented (2026-11-17, under D-31); awaiting Product Owner review. The format can change before the first real content is delivered (Q-13).

## Context

PRD §10 requires each word to carry a stable ID, canonical word, explicit aliases, category, optional difficulty, language, optional region, pack, content version, access status and editorial status, and forbids unpublished or unreviewed content in production gameplay. No real content exists (Q-13); engineers may not invent it (CLAUDE.md rule 4).

## Decision

### One bundled JSON file

`assets/content/catalog.json`, read-only, decoded with `dart:convert`. No new dependency. Words are nested in their pack, so every word belongs to exactly one pack.

```json
{
  "format": 1,
  "contentVersion": 1,
  "packs": [
    {
      "id": "pack-id",
      "title": "<category label: pack card title and every word's category>",
      "labelStatus": "in_review | approved",
      "labelReview": "<label reviewer ref, required when approved>",
      "words": [
        {
          "id": "word-id",
          "version": 1,
          "canonical": "<the word>",
          "aliases": ["<approved variant>"],
          "category": "<equal to the pack title (D-38)>",
          "difficulty": "easy | medium | hard",
          "language": "aeb-Arab",
          "region": "<optional cultural context>",
          "access": "free",
          "status": "draft | in_review | published | retired | development",
          "reviews": { "linguistic": "<reviewer ref>", "editorial": "<reviewer ref>" }
        }
      ]
    }
  ]
}
```

- `format`: the schema version this app reads (1). Any other value rejects the file.
- `contentVersion`: raised with every published change of the file.
- `version` (per word): raised whenever that word's text changes. A saved session stores the word ID **and** this version; on restore a different version cancels the session (ADR-0003), so a game never resumes with a word that changed under it.
- `difficulty`, `region`, `aliases` and, except for published words, `reviews` are optional.
- `access`: only `free` exists (D-04).
- `reviews`: opaque references the Product Owner keeps for the two required human reviews (PRD §10). They are not names and nothing in the app produces them.
- **One category per pack (D-38, 2026-11-17).** A pack is exactly one category: `title` is the category label, and every word's `category` must equal it. The field stays on each word (the engine and saved sessions read it there), so no model or snapshot changed.
- `labelStatus` (required) and `labelReview`: the explicit review state of that label. `labelReview` is an opaque reference like `reviews`, required when `approved`. The format number stayed 1: no catalog with packs had been delivered, and the shipped file has none.

### Validation (`CatalogDecoder`, `CatalogValidation`)

Strict, and the file is accepted or rejected **as a whole**: a bundled file is either valid or a build defect, and the test suite validates the bundled file.

- Unknown keys, missing required keys and wrong types are errors (a misspelt `alises` cannot silently drop aliases).
- IDs: lowercase ASCII letters, digits and inner hyphens, 1–64 characters; pack IDs unique; word IDs unique across the catalog.
- Text (canonical, aliases, category, title, region, reviewer refs): not empty; no leading, trailing or repeated spaces; no control characters, no whitespace other than U+0020, no invisible formatting marks (zero-width and direction marks, Arabic letter mark, soft hyphen, BOM). This does not change matching (D-01, D-30); it keeps out text that a player could not type.
- Aliases: none equal to its own canonical word, none repeated; no canonical word or alias equal to a canonical word or alias of another word anywhere in the catalog. Comparison uses the D-01 comparison form, so Latin case differences are distinct (D-16).
- A `published` word needs both reviews, by two different references.
- Every word's `category` equals its pack's `title`, compared exactly (no folding); a mismatch is reported at the word's `category` with the pack title as related path (`categoryDiffersFromPack`).
- An `approved` label needs `labelReview` (`approvedLabelWithoutReview`), in both channels.
- A label that is not `approved` rejects a **release** catalog as a whole (`unreviewedLabelInRelease`), even in a pack without playable words, because the packs screen shows every pack. Debug builds accept it.
- Issues are reported as JSON paths (`packs[0].words[3].aliases[1]`) and a kind. They never contain content text or IDs, since IDs may be mnemonic.

### Eligibility (`ContentEligibility`)

| Status | Release and profile builds | Debug builds |
|---|---|---|
| `published` (with both reviews) | playable | playable |
| `development` | **catalog rejected** | playable |
| `draft`, `in_review`, `retired` | never | never |

The channel comes from the composition root: `ContentChannel.development` only when `kDebugMode`.

### Development content cannot reach a release

Three independent guards:

1. A release-channel decode rejects any catalog that contains a `development` word or an unreviewed pack label, so such a build has no playable content at all rather than unreviewed content. The development packs carry `in_review` labels, so they trip both checks.
2. `test/data/content/bundled_content_source_test.dart` fails if the bundled file contains a `development` word or if any other content file is declared in `pubspec.yaml`.
3. Synthetic fixtures live only under `test/`, are built in Dart, are labelled as such, and are never declared as assets.

**Development-only synthetic words (D-35, 2026-11-17).** Placeholder words `dev01`…`dev40` in two packs (`dev-synthetic-a/b`), status `development`, no reviews, label `in_review` used as both title and category (D-38; word version raised to 2 when the category text changed), live in `lib/data/content/development_content.dart` as Dart data, not as an asset. The only reference is inside `if (kDebugMode)` in `lib/app/app_providers.dart`, so the release compiler drops them. Checked on 2026-11-17: a release x86_64 build's `libapp.so` does not contain `dev-synthetic` or `DEV pack A`, while it does contain the channel name and the catalog asset path (positive controls); the debug kernel does contain the marker. `test/app/development_content_guard_test.dart` enforces the single guarded reference.

Before that ruling: no development word list existed (Q-13). If the Product Owner supplies one, it is added with status `development`; guards 1 and 2 then keep it out of a release, and guard 2 must be satisfied before a release is cut (it will fail while the words are in the file, which is intended).

### Empty catalog

Until approved words exist, the bundled file has no packs. The packs screen then has nothing to select and starting a game returns the controlled "no eligible content" failure (PRD §10). The app does not crash.

## Alternatives considered

- **One file per pack**: easier merges for editors, but needs a manifest and cross-file duplicate checks; can be adopted later behind `ContentSource`.
- **Content in the SQLite database**: content is read-only and versioned with the app; shipping it as a reviewed text file keeps the review diff readable.
- **Skipping invalid words instead of rejecting the file**: hides defects; with a test on the bundled file, strictness costs nothing at runtime.
- **Flutter flavors with a separate development asset**: would keep development words out of the APK entirely, at the cost of build configuration. Not needed while no development content exists.

## Consequences

- The Product Owner's content pipeline must produce this format; a mistake fails the test suite, not the app at the table.
- Release builds play nothing until published words with both reviews are added.
