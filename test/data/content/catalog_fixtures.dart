import 'dart:convert';

// SYNTHETIC TEST FIXTURES. Not game content and never bundled. The words,
// categories, labels and reviewer references are placeholders; "published"
// and "approved" here only exercise the filters and say nothing about any
// real review.

/// The default label of a fixture pack: distinct per pack (D-40). Words
/// without an explicit category take their pack's label (D-38).
String fixtureLabel(String packId) => 'label $packId';

Map<String, Object?> fixtureReviews() => {
  'linguistic': 'fixture-reviewer-a',
  'editorial': 'fixture-reviewer-b',
};

Map<String, Object?> fixtureWord(
  String id, {
  String? canonical,
  List<String> aliases = const [],
  String status = 'published',
  bool withReviews = true,
  String? category,
}) => {
  'id': id,
  'version': 1,
  'canonical': canonical ?? 'canonical $id',
  'aliases': aliases,
  'category': ?category,
  'language': 'aeb-Arab',
  'access': 'free',
  'status': status,
  if (withReviews) 'reviews': fixtureReviews(),
};

Map<String, Object?> fixturePack(
  String id,
  List<Map<String, Object?>> words, {
  String? title,
  String labelStatus = 'approved',
  bool withLabelReview = true,
}) {
  final label = title ?? fixtureLabel(id);
  return {
    'id': id,
    'title': label,
    'labelStatus': labelStatus,
    if (withLabelReview) 'labelReview': 'fixture-label-reviewer',
    'words': [
      for (final word in words) {'category': label, ...word},
    ],
  };
}

Map<String, Object?> fixtureCatalog(List<Map<String, Object?>> packs) => {
  'format': 1,
  'contentVersion': 1,
  'packs': packs,
};

/// A valid catalog: two packs, three published words, one draft.
Map<String, Object?> validFixtureCatalog() => fixtureCatalog([
  fixturePack('pack-a', [
    fixtureWord('w-1', aliases: ['alias w-1']),
    fixtureWord('w-2'),
    fixtureWord('w-3', status: 'draft', withReviews: false),
  ]),
  fixturePack('pack-b', [fixtureWord('w-4')]),
]);

String encode(Map<String, Object?> json) => jsonEncode(json);
