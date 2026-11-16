import 'dart:convert';

import 'package:impostor_tn/data/content/json_fields.dart';
import 'package:impostor_tn/game/content/catalog_validation.dart';
import 'package:impostor_tn/game/content/content_catalog.dart';
import 'package:impostor_tn/game/content/content_eligibility.dart';
import 'package:impostor_tn/game/content/content_issue.dart';
import 'package:impostor_tn/game/content/word_entry.dart';

sealed class CatalogDecoding {
  const CatalogDecoding();
}

final class DecodedCatalog extends CatalogDecoding {
  const DecodedCatalog(this.catalog);

  final ContentCatalog catalog;
}

/// The catalog is rejected as a whole: a bundled catalog is either valid or
/// a build defect (ADR-0009).
final class InvalidCatalog extends CatalogDecoding {
  InvalidCatalog(List<ContentIssue> issues)
    : issues = List.unmodifiable(issues);

  final List<ContentIssue> issues;

  @override
  String toString() => 'InvalidCatalog(${issues.length} issues)';
}

/// Decodes the catalog file format (ADR-0009) into typed values, then runs
/// [CatalogValidation]. Strict: unknown fields are errors, so a misspelt key
/// cannot silently drop an alias.
abstract final class CatalogDecoder {
  static const supportedFormat = 1;

  static const _statuses = {
    'draft': EditorialStatus.draft,
    'in_review': EditorialStatus.inReview,
    'published': EditorialStatus.published,
    'retired': EditorialStatus.retired,
    'development': EditorialStatus.development,
  };
  static const _difficulties = {
    'easy': Difficulty.easy,
    'medium': Difficulty.medium,
    'hard': Difficulty.hard,
  };
  static const _access = {'free': AccessStatus.free};
  static final _languageTag = RegExp(r'^[a-z]{2,3}(?:-[A-Za-z0-9]{2,8})*$');

  static CatalogDecoding decode(
    String source, {
    required ContentChannel channel,
  }) {
    final Object? json;
    try {
      json = jsonDecode(source);
    } on FormatException {
      // The exception text quotes the source; it is not kept (PRD §12).
      return InvalidCatalog(const [
        ContentIssue(r'$', ContentIssueKind.notJson),
      ]);
    }

    final issues = <ContentIssue>[];
    final root = JsonFields.object(json, r'$', issues);
    if (root == null) return InvalidCatalog(issues);
    root.allowOnly(const {'format', 'contentVersion', 'packs'});

    final format = root.integer('format');
    if (format != null && format != supportedFormat) {
      return InvalidCatalog([
        const ContentIssue('format', ContentIssueKind.unsupportedFormat),
      ]);
    }
    final contentVersion = root.integer('contentVersion');
    if (contentVersion != null && contentVersion < 1) {
      issues.add(
        const ContentIssue('contentVersion', ContentIssueKind.invalidValue),
      );
    }
    final packs = [
      for (final (index, value) in root.list('packs').indexed)
        ?_pack(JsonFields.object(value, 'packs[$index]', issues)),
    ];
    if (issues.isNotEmpty) return InvalidCatalog(issues);

    final catalog = ContentCatalog(
      contentVersion: contentVersion!,
      packs: packs,
    );
    final ruleIssues = CatalogValidation.validate(catalog, channel);
    return ruleIssues.isEmpty
        ? DecodedCatalog(catalog)
        : InvalidCatalog(ruleIssues);
  }

  static WordPack? _pack(JsonFields? fields) {
    if (fields == null) return null;
    fields.allowOnly(const {'id', 'title', 'words'});
    final id = fields.string('id');
    final title = fields.string('title');
    final words = [
      for (final (index, value) in fields.list('words').indexed)
        ?_word(fields.child(value, 'words[$index]')),
    ];
    if (id == null || title == null) return null;
    return WordPack(id: id, title: title, words: words);
  }

  static WordEntry? _word(JsonFields? fields) {
    if (fields == null) return null;
    fields.allowOnly(const {
      'id',
      'version',
      'canonical',
      'aliases',
      'category',
      'difficulty',
      'language',
      'region',
      'access',
      'status',
      'reviews',
    });
    final id = fields.string('id');
    final version = fields.integer('version');
    final canonical = fields.string('canonical');
    final aliases = fields.stringList('aliases', optional: true);
    final category = fields.string('category');
    final difficulty = fields.choice(
      'difficulty',
      _difficulties,
      optional: true,
    );
    final language = fields.string('language');
    if (language != null && !_languageTag.hasMatch(language)) {
      fields.invalid('language');
    }
    final region = fields.string('region', optional: true);
    final access = fields.choice('access', _access);
    final status = fields.choice('status', _statuses);
    final reviews = _reviews(fields.childObject('reviews', optional: true));

    if (id == null ||
        version == null ||
        canonical == null ||
        category == null ||
        language == null ||
        access == null ||
        status == null) {
      return null;
    }
    return WordEntry(
      id: id,
      version: version,
      canonical: canonical,
      aliases: aliases ?? const [],
      category: category,
      language: language,
      access: access,
      status: status,
      difficulty: difficulty,
      region: region,
      reviews: reviews,
    );
  }

  static WordReviews? _reviews(JsonFields? fields) {
    if (fields == null) return null;
    fields.allowOnly(const {'linguistic', 'editorial'});
    final linguistic = fields.string('linguistic');
    final editorial = fields.string('editorial');
    if (linguistic == null || editorial == null) return null;
    return WordReviews(linguistic: linguistic, editorial: editorial);
  }
}
