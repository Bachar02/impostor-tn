import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Source guard for PRD §12 and ADR-0008: nothing under `lib/` writes to the
/// console except the approved diagnostics implementation. The `avoid_print`
/// lint does not catch `debugPrint`, `dart:developer` or `stdout`.
void main() {
  const approved = 'lib/core/diagnostics/diagnostics.dart';

  final forbidden = <String, RegExp>{
    'print': RegExp(r'(^|[^\w.])print\s*\('),
    'debugPrint family': RegExp(r'\bdebugPrint\w*\b'),
    'debugDump family': RegExp(r'\bdebugDump\w*\s*\('),
    'dart:developer': RegExp(r'''['"]dart:developer['"]'''),
    'stdout / stderr': RegExp(r'\b(stdout|stderr)\b'),
  };

  test('only the diagnostics implementation writes to the console', () {
    final violations = <String>[];

    for (final file in Directory('lib').listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.dart')) continue;
      final path = file.path.replaceAll(r'\', '/');
      if (path == approved || path.startsWith('lib/l10n/generated/')) {
        continue;
      }

      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final code = lines[i].split('//').first;
        for (final MapEntry(key: name, value: pattern) in forbidden.entries) {
          if (pattern.hasMatch(code)) violations.add('$path:${i + 1} $name');
        }
      }
    }

    expect(violations, isEmpty);
  });

  test(
    'the approved diagnostics file exists, so the exemption is not stale',
    () {
      expect(File(approved).existsSync(), isTrue);
    },
  );
}
