import 'dart:io';

import 'catalog_builder.dart';

/// Rebuilds `assets/content/catalog.json` from `content/words.tsv`.
///
///     dart run tool/build_catalog.dart
///
/// Run from the project root after editing the word list. Nothing is
/// written if the list breaks a rule; the problems are listed by line or id.
void main() {
  const wordList = 'content/words.tsv';
  const catalog = 'assets/content/catalog.json';

  final result = buildCatalog(
    wordList: File(wordList).readAsStringSync(),
    existingCatalog: File(catalog).readAsStringSync(),
  );
  switch (result) {
    case CatalogBuildFailed(:final errors):
      stderr.writeln('$wordList was not applied:');
      for (final error in errors) {
        stderr.writeln('  - $error');
      }
      exitCode = 1;
    case BuiltCatalog(changed: false):
      stdout.writeln('$catalog is already up to date.');
    case BuiltCatalog(:final json):
      File(catalog).writeAsStringSync(json);
      stdout.writeln('$catalog updated.');
  }
}
