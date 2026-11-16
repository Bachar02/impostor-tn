import 'package:impostor_tn/game/player.dart';

enum BallotKind { first, runoff }

/// One ballot: who may be voted for and the votes cast so far, in the order
/// they were cast. Holds secrets before results: [toString] is redacted.
final class Ballot {
  Ballot({
    required this.kind,
    required List<PlayerId> candidates,
    Map<PlayerId, PlayerId> votes = const {},
  }) : candidates = List.unmodifiable(candidates),
       votes = Map.unmodifiable(votes);

  final BallotKind kind;

  /// Eligible targets, in playing order.
  final List<PlayerId> candidates;

  /// Voter → target, in casting order.
  final Map<PlayerId, PlayerId> votes;

  Ballot withVote(PlayerId voter, PlayerId target) => Ballot(
    kind: kind,
    candidates: candidates,
    votes: {...votes, voter: target},
  );

  /// Votes received by each candidate, zero included, in playing order.
  Map<PlayerId, int> get tally {
    final counts = {for (final candidate in candidates) candidate: 0};
    for (final target in votes.values) {
      counts[target] = counts[target]! + 1;
    }
    return Map.unmodifiable(counts);
  }

  /// The candidates sharing the highest count, in playing order. One entry
  /// means a nominee; more means a tie (PRD §7: never broken by chance or
  /// order).
  List<PlayerId> get leaders {
    final counts = tally;
    final top = counts.values.fold(0, (a, b) => a > b ? a : b);
    return List.unmodifiable([
      for (final MapEntry(:key, :value) in counts.entries)
        if (value == top) key,
    ]);
  }

  @override
  String toString() =>
      'Ballot(${kind.name}, ${votes.length} votes, <redacted>)';
}
