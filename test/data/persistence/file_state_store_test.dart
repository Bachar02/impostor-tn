import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_tn/data/persistence/file_state_store.dart';
import 'package:impostor_tn/data/persistence/saved_state_codec.dart';
import 'package:impostor_tn/game/cooldown/word_cooldown.dart';
import 'package:impostor_tn/game/persistence/saved_state.dart';
import 'package:impostor_tn/game/persistence/state_store.dart';

SavedState withCooldown(List<String> ids) =>
    SavedState(cooldown: WordCooldown(ids), roster: SavedRoster.empty);

List<String> cooldownOf(StoreRead read) =>
    (read as StoreLoaded).state.cooldown.oldestFirst;

void main() {
  late Directory directory;
  late File file;
  late File temp;

  setUp(() {
    directory = Directory.systemTemp.createTempSync('impostor_store_test');
    file = File('${directory.path}/${FileStateStore.fileName}');
    temp = File('${file.path}.tmp');
  });

  tearDown(() {
    if (directory.existsSync()) directory.deleteSync(recursive: true);
  });

  test('a first launch reads an empty state', () async {
    final read = await FileStateStore(directory).read();

    expect(read, isA<StoreLoaded>());
    expect((read as StoreLoaded).discarded, isEmpty);
    expect(read.state.session, isNull);
  });

  test('a write is read back by a new store instance (restart)', () async {
    expect(
      await FileStateStore(directory).write(withCooldown(['w-1'])),
      StoreWrite.committed,
    );

    expect(cooldownOf(await FileStateStore(directory).read()), ['w-1']);
  });

  test('a second write replaces the first', () async {
    final store = FileStateStore(directory);
    await store.write(withCooldown(['w-1']));
    await store.write(withCooldown(['w-1', 'w-2']));

    expect(cooldownOf(await store.read()), ['w-1', 'w-2']);
    expect(temp.existsSync(), isFalse);
  });

  test(
    'a write interrupted before the rename leaves the old document',
    () async {
      await FileStateStore(directory).write(withCooldown(['w-1']));
      // The process died after writing part of the new document.
      temp.writeAsStringSync('{"schema": 1, "cooldown": ["w-1", "w-');

      final read = await FileStateStore(directory).read();

      expect(cooldownOf(read), ['w-1']);
      expect((read as StoreLoaded).discarded, isEmpty);
      expect(temp.existsSync(), isFalse);
    },
  );

  test(
    'a complete temporary file without a rename is still discarded',
    () async {
      await FileStateStore(directory).write(withCooldown(['w-1']));
      temp.writeAsStringSync(SavedStateCodec.encode(withCooldown(['w-9'])));

      expect(cooldownOf(await FileStateStore(directory).read()), ['w-1']);
    },
  );

  test('a damaged document is reported, not thrown', () async {
    file.writeAsStringSync('not json');

    final read = await FileStateStore(directory).read();

    expect((read as StoreLoaded).discarded, DiscardedPart.values.toSet());
  });

  test('a write to a missing directory fails without throwing', () async {
    final store = FileStateStore(directory);
    directory.deleteSync(recursive: true);

    expect(await store.write(withCooldown(['w-1'])), StoreWrite.failed);
  });

  test('calls run one after another in call order', () async {
    final store = FileStateStore(directory);

    final writes = [
      for (var i = 0; i < 10; i++)
        store.write(withCooldown([for (var j = 0; j <= i; j++) 'w-$j'])),
    ];
    final read = store.read();
    await Future.wait(writes);

    expect(cooldownOf(await read), hasLength(10));
  });
}
