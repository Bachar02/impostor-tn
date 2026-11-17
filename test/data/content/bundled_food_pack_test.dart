import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_tn/data/content/bundled_content_source.dart';
import 'package:impostor_tn/data/content/catalog_decoder.dart';
import 'package:impostor_tn/data/content/development_content.dart';
import 'package:impostor_tn/features/game/application/game_service.dart';
import 'package:impostor_tn/game/content/content_catalog.dart';
import 'package:impostor_tn/game/content/content_eligibility.dart';
import 'package:impostor_tn/game/content/content_source.dart';
import 'package:impostor_tn/game/content/word_entry.dart';
import 'package:impostor_tn/game/final_guess_matching.dart';
import 'package:impostor_tn/game/persistence/saved_state.dart';

import '../../features/game/application/service_fixtures.dart';

/// Pack 01 of the bundled catalog: real words from the Product Owner, all
/// in review (D-42). Test names carry no word; the table below is the
/// Product Owner's list, checked against the file entry by entry.
void main() {
  const packId = 'p01';
  const label = 'ماكلة';

  // (canonical, aliases) in the Product Owner's order. Variants identical
  // to the canonical word are not aliases (the validator rejects them).
  const expected = <(String, List<String>)>[
    ('كسكسي', []),
    ('ملاوي', []),
    ('لبلابي', []),
    ('بريك', []),
    ('مقرونة', ['مكرونة']),
    ('شربة', ['شوربة']),
    ('عجة', []),
    ('طاجين', []),
    ('كفتاجي', []),
    ('مرقة', []),
    ('فريكاسي', []),
    ('سلاطة مشوية', ['سلطة مشوية']),
    ('زبيب', []),
    ('هروس', []),
    ('لبن', []),
    ('زلابية', []),
    ('مقروض', []),
    ('يويو', []),
    ('بمبالوني', []),
    ('غريبة', []),
  ];

  final source = File(BundledContentSource.catalogAsset).readAsStringSync();

  ContentCatalog decode(ContentChannel channel) {
    final decoding = CatalogDecoder.decode(source, channel: channel);
    expect(decoding, isA<DecodedCatalog>(), reason: '$decoding');
    return (decoding as DecodedCatalog).catalog;
  }

  WordPack pack() => decode(ContentChannel.development).packById(packId)!;

  test('the pack holds exactly the 20 listed words, in order', () {
    final words = pack().words;

    // Records holding lists compare the lists by identity: compare fields.
    expect(words.map((w) => w.canonical), [for (final (c, _) in expected) c]);
    expect(words.map((w) => w.aliases), [for (final (_, a) in expected) a]);
  });

  test('stable ids p01-w01 … p01-w20, unique', () {
    expect(pack().words.map((w) => w.id), [
      for (var i = 1; i <= 20; i++) 'p01-w${i.toString().padLeft(2, '0')}',
    ]);
  });

  test('label and every word are in review; no review is claimed', () {
    final p = pack();

    expect(p.title, label);
    expect(p.labelStatus, LabelStatus.inReview);
    expect(p.labelReview, isNull);
    for (final word in p.words) {
      expect(word.status, EditorialStatus.inReview);
      expect(word.reviews, isNull);
      expect(word.category, label, reason: 'one category per pack (D-38)');
      expect(word.language, 'aeb-Arab');
      expect(word.version, 1);
    }
  });

  test('every canonical word and alias is accepted as a final guess', () {
    for (final word in pack().words) {
      final secret = word.toSecretWord();
      for (final accepted in [word.canonical, ...word.aliases]) {
        expect(FinalGuessMatching.matches(accepted, secret), isTrue);
        expect(FinalGuessMatching.matches('  $accepted ', secret), isTrue);
      }
    }
  });

  test('matching stays exact: no letter folding (D-01)', () {
    final words = pack().words;
    // Alef maqsura for the final ya, and ha for the final ta marbuta, are
    // different letters under D-01, so they are not accepted.
    final first = words.first.toSecretWord();
    final withTaMarbuta = words
        .firstWhere((w) => w.canonical.endsWith('ة'))
        .toSecretWord();

    expect(
      FinalGuessMatching.matches(
        first.canonical.replaceFirst(RegExp('ي\$'), 'ى'),
        first,
      ),
      isFalse,
    );
    expect(
      FinalGuessMatching.matches(
        withTaMarbuta.canonical.replaceFirst(RegExp('ة\$'), 'ه'),
        withTaMarbuta,
      ),
      isFalse,
    );
  });

  test('a release build hides the pack and plays none of its words', () {
    final release = decode(ContentChannel.release);

    expect(release.packById(packId), isNull);
    for (final word in pack().words) {
      expect(release.wordById(word.id), isNull);
      expect(
        ContentEligibility.isPlayable(word, ContentChannel.release),
        isFalse,
      );
    }
  });

  test('a debug build shows the pack with 20 playable words', () {
    expect(
      ContentEligibility.playableCount(pack(), ContentChannel.development),
      20,
    );
  });

  test(
    'merged with the development packs, the debug catalog is valid',
    () async {
      final load = await DevelopmentContentSource(
        _FixedSource(decode(ContentChannel.development)),
      ).load();

      expect(load, isA<ContentReady>(), reason: '$load');
      final titles = (load as ContentReady).catalog.packs.map((p) => p.title);
      expect(titles.where((t) => t == label), hasLength(1));
    },
  );

  test('all 20 words can be selected in debug gameplay', () async {
    // Twenty consecutive games on this pack only, through the real service:
    // each consumes its word into the cooldown (30), so no word repeats and
    // every word must come up once.
    final catalog = decode(ContentChannel.development);
    final store = MemoryStore();
    GameService games() =>
        service(store, catalog: catalog, channel: ContentChannel.development);
    savedValue(
      await games().saveRoster(
        SavedRoster(players: fixturePlayers(3), packIds: const [packId]),
      ),
    );

    final seen = <String>[];
    for (var game = 0; game < 20; game++) {
      final started = savedValue(await games().startGame());
      final first = started.session.playerIds.first;
      savedValue(await games().confirmIdentity(started.sessionId, first));
      seen.add(started.session.word.wordId);
      savedValue(await games().endSession(started.sessionId));
    }

    expect(seen.toSet(), {for (final word in pack().words) word.id});
  });
}

final class _FixedSource implements ContentSource {
  const _FixedSource(this.catalog);

  final ContentCatalog catalog;

  @override
  Future<ContentLoad> load() async => ContentReady(catalog);
}
