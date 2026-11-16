import 'dart:math';

import 'package:impostor_tn/game/content/word_entry.dart';
import 'package:impostor_tn/game/cooldown/word_cooldown.dart';

sealed class WordSelection {
  const WordSelection();
}

final class WordSelected extends WordSelection {
  const WordSelected(this.word);

  final WordEntry word;

  @override
  String toString() => 'WordSelected(<redacted>)';
}

/// The selected packs hold no playable word. The cooldown alone can never
/// cause this (UX_FLOWS §3.4).
final class NoEligibleWord extends WordSelection {
  const NoEligibleWord();
}

/// Chooses the word of a new game (PRD §10, UX_FLOWS §3.4).
abstract final class WordSelector {
  /// - Eligible: [candidates] not in [cooldown]. If any, one is drawn from
  ///   [random], uniformly, in candidate order.
  /// - Otherwise the cooldown is released from its oldest entry forward, one
  ///   entry at a time, until a released entry is a candidate; that word is
  ///   used. No chance is involved, and it takes at most
  ///   `cooldown.oldestFirst.length` steps.
  /// - No candidates: [NoEligibleWord].
  ///
  /// Releasing only decides this selection; the cooldown itself is changed
  /// later, when the word is consumed (D-21).
  static WordSelection select({
    required List<WordEntry> candidates,
    required WordCooldown cooldown,
    required Random random,
  }) {
    if (candidates.isEmpty) return const NoEligibleWord();

    final eligible = [
      for (final word in candidates)
        if (!cooldown.contains(word.id)) word,
    ];
    if (eligible.isNotEmpty) {
      return WordSelected(eligible[random.nextInt(eligible.length)]);
    }

    final byId = {for (final word in candidates) word.id: word};
    for (final released in cooldown.oldestFirst) {
      if (byId[released] case final word?) return WordSelected(word);
    }
    // Unreachable: every candidate is in the cooldown, so the loop returned.
    throw StateError('Cooldown release found no candidate');
  }
}
