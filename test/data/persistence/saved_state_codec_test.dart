import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_tn/data/persistence/saved_state_codec.dart';
import 'package:impostor_tn/game/cooldown/word_cooldown.dart';
import 'package:impostor_tn/game/game_phase.dart';
import 'package:impostor_tn/game/game_rules.dart';
import 'package:impostor_tn/game/persistence/saved_state.dart';
import 'package:impostor_tn/game/persistence/state_store.dart';
import 'package:impostor_tn/game/player.dart';

// SYNTHETIC TEST FIXTURES: placeholder names and ids.

List<Player> players(int n) => [
  for (var i = 0; i < n; i++) Player(id: PlayerId('p$i'), name: 'Player $i'),
];

SavedState sample() => SavedState(
  cooldown: WordCooldown(['w-1', 'w-2']),
  roster: SavedRoster(players: players(4), packIds: ['pack-a']),
  session: SavedSession(
    sessionId: 'session-1',
    players: players(4),
    packIds: ['pack-a'],
    impostor: const PlayerId('p2'),
    word: const WordReference(id: 'w-2', version: 3),
    wordConsumed: true,
    phase: GamePhaseKind.runoff,
    acknowledged: [for (var i = 0; i < 4; i++) PlayerId('p$i')],
    firstBallotVotes: const {
      PlayerId('p0'): PlayerId('p1'),
      PlayerId('p1'): PlayerId('p0'),
      PlayerId('p2'): PlayerId('p1'),
      PlayerId('p3'): PlayerId('p0'),
    },
    runoffVotes: const {PlayerId('p0'): PlayerId('p1')},
  ),
);

Map<String, Object?> sampleJson() =>
    jsonDecode(SavedStateCodec.encode(sample())) as Map<String, Object?>;

StoreLoaded decodeJson(Object? json) =>
    SavedStateCodec.decode(utf8.encode(jsonEncode(json)));

void main() {
  test('round-trips every fact', () {
    final loaded = SavedStateCodec.decode(
      utf8.encode(SavedStateCodec.encode(sample())),
    );

    expect(loaded.discarded, isEmpty);
    final state = loaded.state;
    expect(state.cooldown.oldestFirst, ['w-1', 'w-2']);
    expect(state.roster.players, players(4));
    expect(state.roster.packIds, ['pack-a']);
    final session = state.session!;
    expect(session.sessionId, 'session-1');
    expect(session.players, players(4));
    expect(session.impostor, const PlayerId('p2'));
    expect(session.word, const WordReference(id: 'w-2', version: 3));
    expect(session.wordConsumed, isTrue);
    expect(session.phase, GamePhaseKind.runoff);
    expect(session.acknowledged, hasLength(4));
    expect(session.firstBallotVotes, sample().session!.firstBallotVotes);
    expect(session.firstBallotVotes.keys.toList(), [
      for (var i = 0; i < 4; i++) PlayerId('p$i'),
    ]);
    expect(session.runoffVotes, sample().session!.runoffVotes);
    expect(session.finalGuess, isNull);
  });

  test('keeps a raw final guess exactly, spaces included', () {
    final json = sampleJson();
    (json['session']! as Map<String, Object?>)
      ..['phase'] = 'result'
      ..['finalGuess'] = '  two  words ';

    expect(decodeJson(json).state.session!.finalGuess, '  two  words ');
  });

  test('a document without a session decodes with none', () {
    final state = SavedState(
      cooldown: WordCooldown.empty,
      roster: SavedRoster.empty,
    );

    final loaded = SavedStateCodec.decode(
      utf8.encode(SavedStateCodec.encode(state)),
    );

    expect(loaded.discarded, isEmpty);
    expect(loaded.state.session, isNull);
  });

  group('an unreadable document loses every part', () {
    final cases = <String, List<int>>{
      'not JSON': utf8.encode('{"schema": 1, '),
      'not UTF-8': [0xFF, 0xFE, 0x00],
      'not an object': utf8.encode('[]'),
      'unknown schema (newer app)': utf8.encode(
        jsonEncode({...sampleJson(), 'schema': 2}),
      ),
      'no schema': utf8.encode(jsonEncode({...sampleJson()..remove('schema')})),
    };
    for (final MapEntry(key: name, value: bytes) in cases.entries) {
      test(name, () {
        final loaded = SavedStateCodec.decode(bytes);

        expect(loaded.discarded, DiscardedPart.values.toSet());
        expect(loaded.state.session, isNull);
        expect(loaded.state.cooldown.oldestFirst, isEmpty);
      });
    }
  });

  group('a damaged session is dropped alone; cooldown and roster survive', () {
    final cases = <String, void Function(Map<String, Object?>)>{
      'unknown phase': (s) => s['phase'] = 'lobby',
      'missing impostor': (s) => s.remove('impostor'),
      'empty session id': (s) => s['id'] = '',
      'word version as text': (s) =>
          (s['word']! as Map<String, Object?>)['version'] = '3',
      'wordConsumed missing': (s) => s.remove('wordConsumed'),
      'acknowledgement twice': (s) => s['acknowledged'] = ['p0', 'p0'],
      'voter twice in a ballot': (s) => s['runoff'] = [
        {'voter': 'p0', 'target': 'p1'},
        {'voter': 'p0', 'target': 'p3'},
      ],
      'vote without target': (s) => s['firstBallot'] = [
        {'voter': 'p0'},
      ],
      'final guess as a number': (s) => s['finalGuess'] = 7,
      'session is a list': (s) => s.clear(),
    };
    for (final MapEntry(key: name, value: damage) in cases.entries) {
      test(name, () {
        final json = sampleJson();
        if (name == 'session is a list') {
          json['session'] = <Object?>[];
        } else {
          damage(json['session']! as Map<String, Object?>);
        }

        final loaded = decodeJson(json);

        expect(loaded.discarded, {DiscardedPart.session});
        expect(loaded.state.session, isNull);
        expect(loaded.state.cooldown.oldestFirst, ['w-1', 'w-2']);
        expect(loaded.state.roster.players, hasLength(4));
      });
    }
  });

  group('a damaged cooldown is dropped alone, never repaired', () {
    final cases = <String, Object?>{
      'not a list': 'w-1',
      'a number entry': ['w-1', 2],
      'a duplicate': ['w-1', 'w-1'],
      'too long': [for (var i = 0; i <= GameRules.cooldownSize; i++) 'w-$i'],
    };
    for (final MapEntry(key: name, value: cooldown) in cases.entries) {
      test(name, () {
        final loaded = decodeJson({...sampleJson(), 'cooldown': cooldown});

        expect(loaded.discarded, {DiscardedPart.cooldown});
        expect(loaded.state.cooldown.oldestFirst, isEmpty);
        expect(loaded.state.session, isNotNull);
      });
    }
  });

  test('a damaged roster is dropped alone', () {
    final loaded = decodeJson({
      ...sampleJson(),
      'roster': {'players': 'nobody', 'packs': <String>[]},
    });

    expect(loaded.discarded, {DiscardedPart.roster});
    expect(loaded.state.roster.players, isEmpty);
    expect(loaded.state.session, isNotNull);
  });

  test('the document stores the word by reference, never its text', () {
    final encoded = SavedStateCodec.encode(sample());

    expect(encoded, contains('"word":{"id":"w-2","version":3}'));
    expect(encoded, isNot(contains('canonical')));
    expect(encoded, isNot(contains('category')));
  });
}
