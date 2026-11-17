import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impostor_tn/features/game/application/checkpoint.dart';
import 'package:impostor_tn/features/game/application/game_providers.dart';
import 'package:impostor_tn/features/game/application/launch.dart';
import 'package:impostor_tn/features/setup/application/player_names.dart';
import 'package:impostor_tn/game/game_rules.dart';
import 'package:impostor_tn/game/persistence/saved_state.dart';
import 'package:impostor_tn/game/player.dart';

final rosterControllerProvider =
    NotifierProvider<RosterController, SavedRoster>(
      RosterController.new,
      retry: noAutomaticRetry,
    );

/// The roster and packs being set up (PUB-05, PUB-06). Every change is saved
/// at once (C0) and published only after it is saved.
class RosterController extends Notifier<SavedRoster> {
  @override
  SavedRoster build() => switch (ref.read(launchProvider).value) {
    LaunchHome(:final roster) => roster,
    _ => SavedRoster.empty,
  };

  /// After a game is left, the retained roster comes back from C8.
  void replace(SavedRoster roster) => state = roster;

  /// Null when [raw] is acceptable for a new player.
  NameProblem? checkNew(String raw) =>
      PlayerNames.check(raw, state.players.map((p) => p.name));

  /// Null when [raw] is acceptable as the new name of [id].
  NameProblem? checkRename(PlayerId id, String raw) => PlayerNames.check(raw, [
    for (final p in state.players)
      if (p.id != id) p.name,
  ]);

  Future<Checkpoint<SavedRoster>> add(String raw) {
    if (state.players.length >= GameRules.maxPlayers) {
      return Future.value(const Refused(RefusalReason.invalidRoster));
    }
    final player = Player(id: _newId(), name: PlayerNames.normalize(raw));
    return _save(
      SavedRoster(players: [...state.players, player], packIds: state.packIds),
    );
  }

  Future<Checkpoint<SavedRoster>> rename(PlayerId id, String raw) => _save(
    SavedRoster(
      players: [
        for (final p in state.players)
          p.id == id ? Player(id: id, name: PlayerNames.normalize(raw)) : p,
      ],
      packIds: state.packIds,
    ),
  );

  /// A deletion never leaves fewer than [GameRules.minPlayers] players.
  bool get canRemove => state.players.length > GameRules.minPlayers;

  Future<Checkpoint<SavedRoster>> remove(PlayerId id) {
    if (!canRemove) {
      return Future.value(const Refused(RefusalReason.invalidRoster));
    }
    return _save(
      SavedRoster(
        players: [
          for (final p in state.players)
            if (p.id != id) p,
        ],
        packIds: state.packIds,
      ),
    );
  }

  Future<Checkpoint<SavedRoster>> togglePack(String packId) => _save(
    SavedRoster(
      players: state.players,
      packIds: state.packIds.contains(packId)
          ? [
              for (final id in state.packIds)
                if (id != packId) id,
            ]
          : [...state.packIds, packId],
    ),
  );

  /// Drops retained packs that no longer exist or have no playable word
  /// (PUB-06: shown unavailable and unticked).
  Future<Checkpoint<SavedRoster>> keepOnlyPacks(Set<String> available) {
    final kept = [
      for (final id in state.packIds)
        if (available.contains(id)) id,
    ];
    if (kept.length == state.packIds.length) {
      return Future.value(Saved(state));
    }
    return _save(SavedRoster(players: state.players, packIds: kept));
  }

  Future<Checkpoint<SavedRoster>> _save(SavedRoster next) async {
    final games = await ref.read(gameServiceProvider.future);
    final result = await games.saveRoster(next);
    if (result case Saved(:final value) when ref.mounted) state = value;
    return result;
  }

  PlayerId _newId() {
    final random = ref.read(randomProvider);
    final used = {for (final p in state.players) p.id};
    while (true) {
      final id = PlayerId(
        'p${random.nextInt(1 << 32).toRadixString(16).padLeft(8, '0')}',
      );
      if (!used.contains(id)) return id;
    }
  }
}
