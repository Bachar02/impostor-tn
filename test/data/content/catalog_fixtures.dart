import 'dart:convert';

// SYNTHETIC TEST FIXTURES. Not game content and never bundled. The words,
// categories and reviewer references are placeholders; "published" here only
// exercises the filter and says nothing about any real review.

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
}) => {
  'id': id,
  'version': 1,
  'canonical': canonical ?? 'canonical $id',
  'aliases': aliases,
  'category': 'fixture category',
  'language': 'aeb-Arab',
  'access': 'free',
  'status': status,
  if (withReviews) 'reviews': fixtureReviews(),
};

Map<String, Object?> fixturePack(String id, List<Map<String, Object?>> words) =>
    {'id': id, 'title': 'title $id', 'words': words};

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
