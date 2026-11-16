import 'package:impostor_tn/game/persistence/saved_state.dart';

/// A part of the saved document that could not be interpreted and was
/// dropped. Each part is checked on its own, so damage to the session does
/// not cost the cooldown history.
enum DiscardedPart { session, cooldown, roster }

sealed class StoreRead {
  const StoreRead();
}

final class StoreLoaded extends StoreRead {
  StoreLoaded(this.state, {Set<DiscardedPart> discarded = const {}})
    : discarded = Set.unmodifiable(discarded);

  /// What could be read. Missing or dropped parts are empty.
  final SavedState state;
  final Set<DiscardedPart> discarded;
}

/// The storage itself failed (I/O). Nothing is known about the saved data.
final class StoreReadFailed extends StoreRead {
  const StoreReadFailed();
}

enum StoreWrite { committed, failed }

/// Durable storage of [SavedState] (ADR-0003). Implemented in `lib/data`.
///
/// [write] replaces the whole document atomically: after it returns, a read
/// yields either the previous document or the new one, never a mixture, even
/// if the process dies during the write.
abstract interface class StateStore {
  Future<StoreRead> read();

  Future<StoreWrite> write(SavedState state);
}
