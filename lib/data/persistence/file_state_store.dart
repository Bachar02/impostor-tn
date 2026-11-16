import 'dart:io';

import 'package:impostor_tn/data/persistence/saved_state_codec.dart';
import 'package:impostor_tn/game/persistence/saved_state.dart';
import 'package:impostor_tn/game/persistence/state_store.dart';

/// [StateStore] as one JSON file in the app-private directory (ADR-0003).
///
/// Atomic replace: the new document is written in full to a temporary file
/// and flushed to disk, then renamed over the old one. A rename within one
/// directory is atomic, so a process killed at any point leaves either the
/// old or the new document. A leftover temporary file is an interrupted
/// write and is deleted unread.
final class FileStateStore implements StateStore {
  FileStateStore(Directory directory)
    : _file = File('${directory.path}${Platform.pathSeparator}$fileName'),
      _temp = File('${directory.path}${Platform.pathSeparator}$fileName.tmp');

  static const fileName = 'game_state.json';

  final File _file;
  final File _temp;

  /// Writes and reads run one after another, in call order.
  Future<void> _queue = Future.value();

  @override
  Future<StoreRead> read() => _serial(() async {
    try {
      if (await _temp.exists()) await _temp.delete();
      if (!await _file.exists()) return StoreLoaded(SavedState.empty);
      return SavedStateCodec.decode(await _file.readAsBytes());
    } on FileSystemException {
      return const StoreReadFailed();
    }
  });

  @override
  Future<StoreWrite> write(SavedState state) => _serial(() async {
    try {
      await _temp.writeAsString(SavedStateCodec.encode(state), flush: true);
      await _temp.rename(_file.path);
      return StoreWrite.committed;
    } on FileSystemException {
      await _deleteTemp();
      return StoreWrite.failed;
    }
  });

  Future<void> _deleteTemp() async {
    try {
      if (await _temp.exists()) await _temp.delete();
    } on FileSystemException {
      // The next read deletes it; the old document is intact either way.
      return;
    }
  }

  Future<T> _serial<T>(Future<T> Function() action) {
    final result = _queue.then((_) => action());
    _queue = result.then<void>((_) {}, onError: (Object _) {});
    return result;
  }
}
