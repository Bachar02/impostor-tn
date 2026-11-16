import 'package:impostor_tn/game/game_rejection.dart';

/// The result of one checkpoint (UX_FLOWS §3). The UI advances only on
/// [Saved].
sealed class Checkpoint<T> {
  const Checkpoint();
}

/// Committed to storage, or found already committed by an earlier attempt
/// (UX_FLOWS §3.1 rule 1).
final class Saved<T> extends Checkpoint<T> {
  const Saved(this.value);

  final T value;

  @override
  String toString() => 'Saved(<redacted>)';
}

enum RefusalReason {
  /// The action names a session that is no longer the saved one.
  staleSession,

  /// The selected packs hold no playable word (PRD §10).
  noEligibleWord,

  /// The roster breaks a setup rule (PRD §4, D-15).
  invalidRoster,

  /// No pack is selected.
  noPackSelected,

  /// No role may be shown before the word is consumed (D-21).
  wordNotConsumed,

  /// The engine refused the action; see [Refused.rule].
  rule,
}

/// Not allowed; nothing was written. Retrying the same action cannot help.
final class Refused<T> extends Checkpoint<T> {
  const Refused(this.reason, {this.rule});

  final RefusalReason reason;
  final GameRejection? rule;

  @override
  String toString() =>
      'Refused(${reason.name}${rule == null ? '' : ', ${rule!.name}'})';
}

/// Storage failed. Nothing changed; the same action may be retried.
final class SaveFailed<T> extends Checkpoint<T> {
  const SaveFailed();
}
