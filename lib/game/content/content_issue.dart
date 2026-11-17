/// What is wrong with a content catalog (ADR-0009).
enum ContentIssueKind {
  notJson,
  unsupportedFormat,
  missingField,
  unknownField,
  wrongType,

  /// An enum value, number range or tag pattern that is not allowed.
  invalidValue,

  /// IDs are lowercase ASCII letters, digits and inner hyphens, at most 64.
  invalidId,
  duplicatePackId,
  duplicateWordId,

  emptyText,

  /// Leading, trailing or repeated spaces.
  untidyText,

  /// A control character, a whitespace character other than U+0020, or an
  /// invisible formatting mark. Under D-01 and D-30 no player could type
  /// such a word reliably.
  forbiddenCharacter,

  aliasRepeatsCanonical,
  duplicateAlias,

  /// A canonical word or alias equals a canonical word or alias of another
  /// word in the catalog.
  answerSharedWithOtherWord,

  publishedWithoutReviews,

  /// The linguistic and editorial reviews must be by distinct people.
  reviewsNotDistinct,

  /// A release catalog must not contain development content.
  developmentContentInRelease,

  /// A word's category differs from its pack's title: a pack is exactly one
  /// category (D-38). The related path is the pack title.
  categoryDiffersFromPack,

  /// A pack label marked approved without its review reference (D-38).
  approvedLabelWithoutReview,

  /// Two packs with the same label: a category belongs to one pack only
  /// (D-40). Carries both pack IDs.
  duplicatePackLabel,
}

/// One problem, located by a JSON path such as `packs[0].words[3].aliases[1]`.
///
/// Deliberately carries no content text and no word ID: word IDs may be
/// mnemonic, and an issue may end up in a test report (PRD §12). Pack IDs
/// are not secret (the pack label is public) and are carried only where a
/// decision asks for them ([ContentIssueKind.duplicatePackLabel], D-40).
final class ContentIssue {
  const ContentIssue(
    this.path,
    this.kind, {
    this.relatedPath,
    this.packId,
    this.relatedPackId,
  });

  final String path;
  final ContentIssueKind kind;

  /// The other location involved in a duplicate, if any.
  final String? relatedPath;

  /// The pack at [path], and the pack at [relatedPath] (D-40 only).
  final String? packId;
  final String? relatedPackId;

  @override
  bool operator ==(Object other) =>
      other is ContentIssue &&
      other.path == path &&
      other.kind == kind &&
      other.relatedPath == relatedPath &&
      other.packId == packId &&
      other.relatedPackId == relatedPackId;

  @override
  int get hashCode =>
      Object.hash(path, kind, relatedPath, packId, relatedPackId);

  @override
  String toString() {
    final related = relatedPath == null ? '' : ' ($relatedPath)';
    final packs = packId == null
        ? ''
        : ' [pack $packId conflicts with pack $relatedPackId]';
    return '$path: ${kind.name}$related$packs';
  }
}
