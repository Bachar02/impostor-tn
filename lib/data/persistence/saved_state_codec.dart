import 'dart:convert';

import 'package:impostor_tn/game/cooldown/word_cooldown.dart';
import 'package:impostor_tn/game/game_phase.dart';
import 'package:impostor_tn/game/game_rules.dart';
import 'package:impostor_tn/game/persistence/saved_state.dart';
import 'package:impostor_tn/game/persistence/state_store.dart';
import 'package:impostor_tn/game/player.dart';

/// JSON form of [SavedState], schema 1 (ADR-0003).
///
/// Decoding is strict and never repairs: a part with any unexpected value is
/// dropped whole and reported in [StoreLoaded.discarded]. The rules
/// themselves (turn order, self-votes, phase) are checked afterwards by
/// `SessionRestore`; this codec checks shape only.
abstract final class SavedStateCodec {
  static const schemaVersion = 1;

  static String encode(SavedState state) => jsonEncode({
    'schema': schemaVersion,
    'cooldown': state.cooldown.oldestFirst,
    'roster': {
      'players': _players(state.roster.players),
      'packs': state.roster.packIds,
    },
    'session': switch (state.session) {
      null => null,
      final session => {
        'id': session.sessionId,
        'players': _players(session.players),
        'packs': session.packIds,
        'impostor': session.impostor.value,
        'word': {'id': session.word.id, 'version': session.word.version},
        'wordConsumed': session.wordConsumed,
        'phase': session.phase.name,
        'acknowledged': [for (final id in session.acknowledged) id.value],
        'firstBallot': _votes(session.firstBallotVotes),
        'runoff': _votes(session.runoffVotes),
        'finalGuess': session.finalGuess,
      },
    },
  });

  static StoreLoaded decode(List<int> bytes) {
    final Map<String, Object?> root;
    try {
      final json = jsonDecode(utf8.decode(bytes));
      if (json is! Map<String, Object?> || json['schema'] != schemaVersion) {
        return _unreadable;
      }
      root = json;
    } on FormatException {
      return _unreadable;
    }

    final discarded = <DiscardedPart>{};
    T? part<T>(DiscardedPart name, T Function() decode) {
      try {
        return decode();
      } on _Invalid {
        discarded.add(name);
        return null;
      }
    }

    final cooldown = part(DiscardedPart.cooldown, () {
      final ids = _strings(root['cooldown']);
      if (ids.toSet().length != ids.length ||
          ids.length > GameRules.cooldownSize) {
        throw const _Invalid();
      }
      return WordCooldown(ids);
    });
    final roster = part(DiscardedPart.roster, () {
      final map = _object(root['roster']);
      return SavedRoster(
        players: _playerList(map['players']),
        packIds: _strings(map['packs']),
      );
    });
    final session = part(
      DiscardedPart.session,
      () => _session(root['session']),
    );

    return StoreLoaded(
      SavedState(
        cooldown: cooldown ?? WordCooldown.empty,
        roster: roster ?? SavedRoster.empty,
        session: session,
      ),
      discarded: discarded,
    );
  }

  static final _unreadable = StoreLoaded(
    SavedState.empty,
    discarded: DiscardedPart.values.toSet(),
  );

  static SavedSession? _session(Object? value) {
    if (value == null) return null;
    final map = _object(value);
    final word = _object(map['word']);
    final finalGuess = map['finalGuess'];
    if (finalGuess != null && finalGuess is! String) throw const _Invalid();
    final acknowledged = _strings(map['acknowledged']);
    if (acknowledged.toSet().length != acknowledged.length) {
      throw const _Invalid();
    }
    return SavedSession(
      sessionId: _string(map['id']),
      players: _playerList(map['players']),
      packIds: _strings(map['packs']),
      impostor: PlayerId(_string(map['impostor'])),
      word: WordReference(
        id: _string(word['id']),
        version: _int(word['version']),
      ),
      wordConsumed: _bool(map['wordConsumed']),
      phase: _phase(map['phase']),
      acknowledged: [for (final id in acknowledged) PlayerId(id)],
      firstBallotVotes: _voteMap(map['firstBallot']),
      runoffVotes: _voteMap(map['runoff']),
      finalGuess: finalGuess as String?,
    );
  }

  static List<Map<String, String>> _players(List<Player> players) => [
    for (final player in players) {'id': player.id.value, 'name': player.name},
  ];

  static List<Map<String, String>> _votes(Map<PlayerId, PlayerId> votes) => [
    for (final MapEntry(key: voter, value: target) in votes.entries)
      {'voter': voter.value, 'target': target.value},
  ];

  static List<Player> _playerList(Object? value) => [
    for (final item in _list(value))
      Player(
        id: PlayerId(_string(_object(item)['id'])),
        name: _string(_object(item)['name']),
      ),
  ];

  static Map<PlayerId, PlayerId> _voteMap(Object? value) {
    final votes = <PlayerId, PlayerId>{};
    for (final item in _list(value)) {
      final map = _object(item);
      final voter = PlayerId(_string(map['voter']));
      // A voter twice in one ballot cannot come from the app: never repair.
      if (votes.containsKey(voter)) throw const _Invalid();
      votes[voter] = PlayerId(_string(map['target']));
    }
    return votes;
  }

  static GamePhaseKind _phase(Object? value) {
    final name = _string(value);
    for (final kind in GamePhaseKind.values) {
      if (kind.name == name) return kind;
    }
    throw const _Invalid();
  }

  static Map<String, Object?> _object(Object? value) =>
      value is Map<String, Object?> ? value : throw const _Invalid();

  static List<Object?> _list(Object? value) =>
      value is List<Object?> ? value : throw const _Invalid();

  static String _string(Object? value) =>
      value is String && value.isNotEmpty ? value : throw const _Invalid();

  static int _int(Object? value) =>
      value is int ? value : throw const _Invalid();

  static bool _bool(Object? value) =>
      value is bool ? value : throw const _Invalid();

  static List<String> _strings(Object? value) => [
    for (final item in _list(value)) _string(item),
  ];
}

/// Internal signal that a part has an unexpected shape. Never escapes.
final class _Invalid implements Exception {
  const _Invalid();
}
