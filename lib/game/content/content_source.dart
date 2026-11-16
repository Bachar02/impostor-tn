import 'package:impostor_tn/game/content/content_catalog.dart';
import 'package:impostor_tn/game/content/content_issue.dart';

/// Outcome of loading the word content.
sealed class ContentLoad {
  const ContentLoad();
}

final class ContentReady extends ContentLoad {
  const ContentReady(this.catalog);

  final ContentCatalog catalog;
}

enum ContentUnavailableReason { missing, invalid }

/// No content can be played. A controlled state, never a crash (PRD §10).
final class ContentUnavailable extends ContentLoad {
  ContentUnavailable(this.reason, {List<ContentIssue> issues = const []})
    : issues = List.unmodifiable(issues);

  final ContentUnavailableReason reason;

  /// Located by path only; safe to show in a developer report.
  final List<ContentIssue> issues;

  @override
  String toString() => 'ContentUnavailable(${reason.name})';
}

/// Where the catalog comes from. Implemented in `lib/data`.
abstract interface class ContentSource {
  Future<ContentLoad> load();
}
