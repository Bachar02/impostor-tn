import 'package:flutter/foundation.dart';

/// The only way the app reports an unexpected error (ADR-0008).
///
/// There is deliberately no free-text `log` method: an error is handed over
/// as an object and the implementation decides what may be written.
abstract interface class Diagnostics {
  /// Reports [error] caught at [origin], a short constant label such as
  /// `'framework'`. [origin] must never be built from game data.
  void report(Object error, StackTrace stack, {required String origin});
}

/// Writes the error's type name and stack trace, never its message.
///
/// An exception message is free text and could carry a secret by mistake
/// (PRD §12); a type name and a stack trace cannot.
final class RedactedDiagnostics implements Diagnostics {
  const RedactedDiagnostics({this.sink = _deviceLog});

  /// Receives each finished entry. Replaced by a list in tests.
  final void Function(String entry) sink;

  @override
  void report(Object error, StackTrace stack, {required String origin}) {
    String entry;
    try {
      entry = '[$origin] ${error.runtimeType}\n$stack';
    } on Object {
      // This runs inside the global error handlers: if formatting throws
      // (a custom StackTrace with a broken toString), throwing again would
      // re-enter them. Write a fixed entry instead (ADR-0008).
      entry = '[$origin] unreportable error';
    }
    sink(entry);
  }

  static void _deviceLog(String entry) => debugPrintSynchronously(entry);
}
