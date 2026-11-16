import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_tn/core/diagnostics/diagnostics.dart';

const _marker = 'MESSAGE-THAT-MUST-NOT-BE-LOGGED';

/// A stack trace whose text must never be written, or cannot be formatted.
final class _BrokenStackTrace implements StackTrace {
  @override
  String toString() => throw StateError(_marker);
}

/// An error whose type name cannot be read.
final class _UnnameableError {
  @override
  Type get runtimeType => throw StateError(_marker);
}

void main() {
  group('RedactedDiagnostics', () {
    test('writes only the origin and the error type', () {
      final entries = <String>[];

      RedactedDiagnostics(sink: entries.add).report(
        const FormatException('placeholder'),
        StackTrace.current,
        origin: 'test',
      );

      expect(entries, ['[test] FormatException']);
    });

    test('never writes the error message', () {
      final entries = <String>[];
      final diagnostics = RedactedDiagnostics(sink: entries.add);

      for (final Object error in [
        const FormatException(_marker),
        StateError(_marker),
        ArgumentError.value(_marker, _marker, _marker),
        Exception(_marker),
        _marker,
      ]) {
        diagnostics.report(error, StackTrace.empty, origin: 'test');
      }

      expect(entries, hasLength(5));
      expect(entries.join('\n'), isNot(contains(_marker)));
    });

    test('never writes the stack trace', () {
      final entries = <String>[];

      RedactedDiagnostics(sink: entries.add).report(
        StateError('placeholder'),
        StackTrace.fromString('STACK-THAT-MUST-NOT-BE-LOGGED'),
        origin: 'test',
      );

      expect(entries.single, isNot(contains('STACK-THAT-MUST-NOT-BE-LOGGED')));
    });

    test('does not format the stack trace, so a broken one cannot throw', () {
      final entries = <String>[];

      RedactedDiagnostics(sink: entries.add)
          .report(StateError(_marker), _BrokenStackTrace(), origin: 'test');

      expect(entries, ['[test] StateError']);
    });

    test('writes a fixed entry instead of throwing when the error type '
        'cannot be read', () {
      final entries = <String>[];

      RedactedDiagnostics(sink: entries.add)
          .report(_UnnameableError(), StackTrace.empty, origin: 'test');

      expect(entries, ['[test] unreportable error']);
    });
  });
}
