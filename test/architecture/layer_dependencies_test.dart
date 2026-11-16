import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Enforces the dependency rule of ADR-0001 by scanning import directives.
void main() {
  final importPattern = RegExp(r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''');

  /// Every import or export URI in the Dart files under [directory], as
  /// `path: uri`. Empty when the layer has not been created yet.
  List<String> importsUnder(String directory) {
    final root = Directory(directory);
    if (!root.existsSync()) return const [];
    return [
      for (final file in root.listSync(recursive: true).whereType<File>())
        if (file.path.endsWith('.dart'))
          for (final line in file.readAsLinesSync())
            if (importPattern.firstMatch(line) case final match?)
              '${file.path}: ${match.group(1)}',
    ];
  }

  test('core imports no other layer of the app', () {
    final forbidden = RegExp(
      r': package:impostor_tn/(app|features|game|data)/',
    );

    expect(importsUnder('lib/core').where(forbidden.hasMatch), isEmpty);
  });

  test('game is pure Dart: only dart:core, dart:math, dart:collection and '
      'itself', () {
    final allowed = RegExp(
      r': (dart:(core|math|collection)|package:impostor_tn/game/)',
    );

    expect(
      importsUnder('lib/game').where((line) => !allowed.hasMatch(line)),
      isEmpty,
    );
  });

  test('features never import the data layer; only the composition root '
      'binds it (ADR-0001)', () {
    final data = RegExp(r': package:impostor_tn/data/');

    expect([
      for (final layer in ['core', 'game', 'features'])
        ...importsUnder('lib/$layer').where(data.hasMatch),
    ], isEmpty);
  });

  test('only data imports the database package', () {
    final database = RegExp(r': package:(drift|drift_flutter|sqlite3)/');

    expect([
      for (final layer in ['app', 'core', 'game', 'features'])
        ...importsUnder('lib/$layer').where(database.hasMatch),
    ], isEmpty);
  });
}
