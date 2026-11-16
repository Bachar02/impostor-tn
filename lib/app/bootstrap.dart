import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impostor_tn/app/app.dart';
import 'package:impostor_tn/app/app_licenses.dart';
import 'package:impostor_tn/core/diagnostics/diagnostics.dart';

/// Startup sequence: binding, error handlers, licences, then the first frame.
///
/// Opening the database and restoring a saved session will be added here,
/// before `runApp`, with the persistence milestone (ADR-0003).
void bootstrap() {
  WidgetsFlutterBinding.ensureInitialized();
  installErrorHandlers(const RedactedDiagnostics(), verbose: kDebugMode);
  registerAppLicenses();
  runApp(const ProviderScope(child: ImpostorApp()));
}

/// Routes every uncaught error to [diagnostics] (ADR-0008).
///
/// With [verbose] (debug builds) Flutter's own handlers stay in place so the
/// developer sees full details. Otherwise only the redacted report is written.
void installErrorHandlers(Diagnostics diagnostics, {required bool verbose}) {
  if (verbose) return;

  FlutterError.onError = (details) {
    diagnostics.report(
      details.exception,
      details.stack ?? StackTrace.empty,
      origin: 'framework',
    );
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    diagnostics.report(error, stack, origin: 'platform');
    return true;
  };
}
