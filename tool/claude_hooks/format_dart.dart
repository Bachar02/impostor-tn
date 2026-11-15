// Claude Code PostToolUse hook: formats the Dart file that was just written.
//
// Reads the hook payload (JSON) from stdin, and runs `dart format` on the
// edited file when it is a hand-written Dart file inside this project.
// Deliberately cheap: one file, no analysis, no tests. Never fails the tool
// call; formatting problems are reported on stderr only.
import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final String path;
  try {
    final payload = jsonDecode(await stdin.transform(utf8.decoder).join());
    if (payload is! Map<String, dynamic>) return;
    final input = payload['tool_input'];
    final response = payload['tool_response'];
    final candidate =
        (input is Map<String, dynamic> ? input['file_path'] : null) ??
        (response is Map<String, dynamic> ? response['filePath'] : null);
    if (candidate is! String) return;
    path = candidate;
  } on FormatException {
    return;
  }

  final normalized = path.replaceAll(r'\', '/');
  if (!normalized.endsWith('.dart')) return;
  if (normalized.contains('/lib/l10n/generated/')) return;
  if (normalized.contains('/.dart_tool/') || normalized.contains('/build/')) {
    return;
  }
  if (!File(path).existsSync()) return;

  final result = await Process.run('dart', [
    'format',
    normalized,
  ], runInShell: Platform.isWindows);
  if (result.exitCode != 0) {
    stderr.writeln('dart format failed for $path:\n${result.stderr}');
  }
}
