import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_tn/app/bootstrap.dart';
import 'package:impostor_tn/core/diagnostics/diagnostics.dart';

final class _RecordingDiagnostics implements Diagnostics {
  final reports = <(Object, String)>[];

  @override
  void report(Object error, StackTrace stack, {required String origin}) {
    reports.add((error, origin));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _RecordingDiagnostics diagnostics;

  setUp(() {
    diagnostics = _RecordingDiagnostics();
    final frameworkHandler = FlutterError.onError;
    final platformHandler = PlatformDispatcher.instance.onError;
    addTearDown(() {
      FlutterError.onError = frameworkHandler;
      PlatformDispatcher.instance.onError = platformHandler;
    });
  });

  group('installErrorHandlers', () {
    test('sends framework errors to diagnostics when not verbose', () {
      installErrorHandlers(diagnostics, verbose: false);
      final error = StateError('placeholder');

      FlutterError.onError!(FlutterErrorDetails(exception: error));

      expect(diagnostics.reports, [(error, 'framework')]);
    });

    test('sends other uncaught errors to diagnostics and marks them '
        'handled when not verbose', () {
      installErrorHandlers(diagnostics, verbose: false);
      final error = StateError('placeholder');

      final handled = PlatformDispatcher.instance.onError!(
        error,
        StackTrace.empty,
      );

      expect(handled, isTrue);
      expect(diagnostics.reports, [(error, 'platform')]);
    });

    test('leaves the default handlers in place when verbose', () {
      final frameworkHandler = FlutterError.onError;
      final platformHandler = PlatformDispatcher.instance.onError;

      installErrorHandlers(diagnostics, verbose: true);

      expect(FlutterError.onError, same(frameworkHandler));
      expect(PlatformDispatcher.instance.onError, same(platformHandler));
    });
  });
}
