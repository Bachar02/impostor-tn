import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_tn/core/diagnostics/diagnostics.dart';

final class _BrokenStackTrace implements StackTrace {
  static const marker = 'MESSAGE-THAT-MUST-NOT-BE-LOGGED';

  @override
  String toString() => throw StateError(marker);
}

void main() {
  group('RedactedDiagnostics', () {
    test('writes the origin, the error type and the stack trace', () {
      final entries = <String>[];
      final stack = StackTrace.current;

      RedactedDiagnostics(sink: entries.add)
          .report(const FormatException('placeholder'), stack, origin: 'test');

      expect(entries, hasLength(1));
      expect(entries.single, startsWith('[test] FormatException\n'));
      expect(entries.single, contains(stack.toString()));
    });

    test('never writes the error message', () {
      const marker = 'MESSAGE-THAT-MUST-NOT-BE-LOGGED';
      final entries = <String>[];
      final diagnostics = RedactedDiagnostics(sink: entries.add);

      for (final Object error in [
        const FormatException(marker),
        StateError(marker),
        ArgumentError.value(marker, marker, marker),
        Exception(marker),
        marker,
      ]) {
        diagnostics.report(error, StackTrace.empty, origin: 'test');
      }

      expect(entries, hasLength(5));
      expect(entries.join('\n'), isNot(contains(marker)));
    });

    test('writes a fixed entry instead of throwing when the stack trace '
        'cannot be formatted', () {
      final entries = <String>[];

      RedactedDiagnostics(sink: entries.add).report(
        StateError(_BrokenStackTrace.marker),
        _BrokenStackTrace(),
        origin: 'test',
      );

      expect(entries, ['[test] unreportable error']);
    });
  });
}
