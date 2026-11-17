import 'package:impostor_tn/game/content/content_catalog.dart';
import 'package:impostor_tn/game/content/content_eligibility.dart';
import 'package:impostor_tn/game/content/content_issue.dart';
import 'package:impostor_tn/game/content/content_text.dart';
import 'package:impostor_tn/game/content/word_entry.dart';
import 'package:impostor_tn/game/final_guess_matching.dart';

/// Rules that span records: IDs, tidy text, aliases, reviews and the release
/// channel (ADR-0009). Type and field checks happen in the decoder first.
abstract final class CatalogValidation {
  static final _idPattern = RegExp(r'^[a-z0-9](?:[a-z0-9-]{0,62}[a-z0-9])?$');

  static List<ContentIssue> validate(
    ContentCatalog catalog,
    ContentChannel channel,
  ) {
    final issues = <ContentIssue>[];
    final packIds = <String, String>{};
    final wordIds = <String, String>{};
    // Comparison form of every accepted answer → path of the word owning it.
    final answers = <String, String>{};

    for (var p = 0; p < catalog.packs.length; p++) {
      final pack = catalog.packs[p];
      final packPath = 'packs[$p]';
      _checkId(issues, '$packPath.id', pack.id);
      if (packIds[pack.id] case final first?) {
        issues.add(
          ContentIssue(
            '$packPath.id',
            ContentIssueKind.duplicatePackId,
            relatedPath: first,
          ),
        );
      } else {
        packIds[pack.id] = '$packPath.id';
      }
      _checkText(issues, '$packPath.title', pack.title);
      _checkLabel(issues, packPath, pack, channel);

      for (var w = 0; w < pack.words.length; w++) {
        final wordPath = '$packPath.words[$w]';
        final word = pack.words[w];
        _validateWord(issues, word, wordPath, channel, wordIds, answers);
        // Exact comparison: hygiene is checked on both texts already.
        if (word.category != pack.title) {
          issues.add(
            ContentIssue(
              '$wordPath.category',
              ContentIssueKind.categoryDiffersFromPack,
              relatedPath: '$packPath.title',
            ),
          );
        }
      }
    }
    return List.unmodifiable(issues);
  }

  static void _validateWord(
    List<ContentIssue> issues,
    WordEntry word,
    String path,
    ContentChannel channel,
    Map<String, String> wordIds,
    Map<String, String> answers,
  ) {
    _checkId(issues, '$path.id', word.id);
    if (wordIds[word.id] case final first?) {
      issues.add(
        ContentIssue(
          '$path.id',
          ContentIssueKind.duplicateWordId,
          relatedPath: first,
        ),
      );
    } else {
      wordIds[word.id] = '$path.id';
    }
    if (word.version < 1) {
      issues.add(ContentIssue('$path.version', ContentIssueKind.invalidValue));
    }
    _checkText(issues, '$path.canonical', word.canonical);
    _checkText(issues, '$path.category', word.category);
    if (word.region case final region?) {
      _checkText(issues, '$path.region', region);
    }

    final own = <String, String>{
      FinalGuessMatching.comparisonForm(word.canonical): '$path.canonical',
    };
    for (var a = 0; a < word.aliases.length; a++) {
      final aliasPath = '$path.aliases[$a]';
      final alias = word.aliases[a];
      _checkText(issues, aliasPath, alias);
      final form = FinalGuessMatching.comparisonForm(alias);
      if (own[form] case final first?) {
        issues.add(
          ContentIssue(
            aliasPath,
            first.endsWith('.canonical')
                ? ContentIssueKind.aliasRepeatsCanonical
                : ContentIssueKind.duplicateAlias,
            relatedPath: first,
          ),
        );
      } else {
        own[form] = aliasPath;
      }
    }
    for (final MapEntry(key: form, value: answerPath) in own.entries) {
      if (form.isEmpty) continue;
      if (answers[form] case final other?) {
        issues.add(
          ContentIssue(
            answerPath,
            ContentIssueKind.answerSharedWithOtherWord,
            relatedPath: other,
          ),
        );
      } else {
        answers[form] = answerPath;
      }
    }

    switch (word.status) {
      case EditorialStatus.published:
        _checkReviews(issues, path, word.reviews);
      case EditorialStatus.development when channel == ContentChannel.release:
        issues.add(
          ContentIssue(
            '$path.status',
            ContentIssueKind.developmentContentInRelease,
          ),
        );
      case EditorialStatus.development ||
          EditorialStatus.draft ||
          EditorialStatus.inReview ||
          EditorialStatus.retired:
        if (word.reviews != null) _checkReviews(issues, path, word.reviews);
    }
  }

  static void _checkReviews(
    List<ContentIssue> issues,
    String path,
    WordReviews? reviews,
  ) {
    if (reviews == null) {
      issues.add(
        ContentIssue('$path.reviews', ContentIssueKind.publishedWithoutReviews),
      );
      return;
    }
    _checkText(issues, '$path.reviews.linguistic', reviews.linguistic);
    _checkText(issues, '$path.reviews.editorial', reviews.editorial);
    if (reviews.linguistic == reviews.editorial) {
      issues.add(
        ContentIssue('$path.reviews', ContentIssueKind.reviewsNotDistinct),
      );
    }
  }

  /// D-38: the label carries an explicit review status, and only approved
  /// labels may ship. An unreviewed label rejects a release catalog as a
  /// whole, like development content.
  static void _checkLabel(
    List<ContentIssue> issues,
    String packPath,
    WordPack pack,
    ContentChannel channel,
  ) {
    if (pack.labelReview case final review?) {
      _checkText(issues, '$packPath.labelReview', review);
    }
    switch (pack.labelStatus) {
      case LabelStatus.approved:
        if (pack.labelReview == null) {
          issues.add(
            ContentIssue(
              '$packPath.labelReview',
              ContentIssueKind.approvedLabelWithoutReview,
            ),
          );
        }
      case LabelStatus.inReview:
        if (channel == ContentChannel.release) {
          issues.add(
            ContentIssue(
              '$packPath.labelStatus',
              ContentIssueKind.unreviewedLabelInRelease,
            ),
          );
        }
    }
  }

  static void _checkId(List<ContentIssue> issues, String path, String id) {
    if (!_idPattern.hasMatch(id)) {
      issues.add(ContentIssue(path, ContentIssueKind.invalidId));
    }
  }

  static void _checkText(List<ContentIssue> issues, String path, String text) {
    if (ContentText.check(text) case final kind?) {
      issues.add(ContentIssue(path, kind));
    }
  }
}
