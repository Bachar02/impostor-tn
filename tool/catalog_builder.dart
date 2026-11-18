import 'dart:convert';

import 'package:impostor_tn/data/content/catalog_decoder.dart';
import 'package:impostor_tn/game/content/content_eligibility.dart';

/// Builds `assets/content/catalog.json` from the editable word list
/// `content/words.tsv` (ADR-0009 format, unchanged).
///
/// The list holds only what an editor changes: pack, label, word id, word,
/// spelling variants. Everything else comes from the existing catalog, so
/// review state is never invented or lost:
/// - a new pack or word starts `in_review`;
/// - an existing word keeps its status, reviews and metadata; if its text
///   changes, its `version` is raised, and a reviewed word goes back to
///   `in_review` without its reviews (the new text was not reviewed);
/// - the same applies to a changed pack label;
/// - an id that disappears is an error: ids are never reused (retire a word
///   instead);
/// - `contentVersion` is raised whenever the packs change.
/// The result is validated with the app's own decoder before it is used.
sealed class CatalogBuild {
  const CatalogBuild();
}

final class BuiltCatalog extends CatalogBuild {
  const BuiltCatalog(this.json, {required this.changed});

  /// The complete file content, ending with a newline.
  final String json;

  /// Whether it differs from the existing catalog.
  final bool changed;
}

/// Problems, by line number or id. Never quotes word text.
final class CatalogBuildFailed extends CatalogBuild {
  const CatalogBuildFailed(this.errors);

  final List<String> errors;
}

const wordListHeader = 'pack_id\tlabel\tword_id\tword\tvariants';

CatalogBuild buildCatalog({
  required String wordList,
  required String existingCatalog,
}) {
  final errors = <String>[];
  final rows = _parse(wordList, errors);
  final existing = jsonDecode(existingCatalog) as Map<String, Object?>;
  final oldPacks = {
    for (final pack in existing['packs']! as List<Object?>)
      (pack! as Map<String, Object?>)['id']! as String:
          pack as Map<String, Object?>,
  };
  final oldWords = {
    for (final pack in oldPacks.values)
      for (final word in pack['words']! as List<Object?>)
        (word! as Map<String, Object?>)['id']! as String:
            word as Map<String, Object?>,
  };

  // Packs in order of first appearance; one label per pack.
  final order = <String>[];
  final labels = <String, String>{};
  final wordsOf = <String, List<_Row>>{};
  final wordIds = <String>{};
  for (final row in rows) {
    if (!wordIds.add(row.wordId)) {
      errors.add('line ${row.line}: word id ${row.wordId} is used twice');
    }
    final label = labels[row.packId];
    if (label == null) {
      order.add(row.packId);
      labels[row.packId] = row.label;
    } else if (label != row.label) {
      errors.add(
        'line ${row.line}: pack ${row.packId} has a different label than '
        'its first row (one label per pack)',
      );
    }
    (wordsOf[row.packId] ??= []).add(row);
  }
  for (final id in oldPacks.keys) {
    if (!labels.containsKey(id)) {
      errors.add('pack $id is missing: ids are never removed or reused');
    }
  }
  for (final id in oldWords.keys) {
    if (!wordIds.contains(id)) {
      errors.add('word $id is missing: ids are never removed or reused');
    }
  }
  if (errors.isNotEmpty) return CatalogBuildFailed(errors);

  final packs = [
    for (final packId in order)
      _pack(packId, labels[packId]!, wordsOf[packId]!, oldPacks, oldWords),
  ];
  final changed = jsonEncode(packs) != jsonEncode(existing['packs']);
  final oldVersion = existing['contentVersion']! as int;
  final json =
      '${const JsonEncoder.withIndent('  ').convert({'format': CatalogDecoder.supportedFormat, 'contentVersion': changed ? oldVersion + 1 : oldVersion, 'packs': packs})}\n';

  // The app's own rules decide; development channel, because content in
  // review is part of the file (a release build hides it, D-42).
  final decoding = CatalogDecoder.decode(
    json,
    channel: ContentChannel.development,
  );
  if (decoding case InvalidCatalog(:final issues)) {
    return CatalogBuildFailed([
      for (final issue in issues) _locate(issue.toString(), packs),
    ]);
  }
  return BuiltCatalog(json, changed: changed);
}

final class _Row {
  const _Row(
    this.line,
    this.packId,
    this.label,
    this.wordId,
    this.word,
    this.variants,
  );

  final int line;
  final String packId;
  final String label;
  final String wordId;
  final String word;
  final List<String> variants;
}

List<_Row> _parse(String text, List<String> errors) {
  final rows = <_Row>[];
  var headerSeen = false;
  final lines = text.replaceFirst('﻿', '').split('\n');
  for (var i = 0; i < lines.length; i++) {
    final number = i + 1;
    final line = lines[i].replaceAll('\r', '');
    if (line.trim().isEmpty || line.startsWith('#')) continue;
    if (!headerSeen) {
      if (line.trim() != wordListHeader) {
        errors.add('line $number: expected the header "$wordListHeader"');
        return rows;
      }
      headerSeen = true;
      continue;
    }
    final cells = line.split('\t').map((c) => c.trim()).toList();
    if (cells.length < 4 || cells.length > 5) {
      errors.add('line $number: expected 5 tab-separated columns');
      continue;
    }
    if (cells.take(4).any((c) => c.isEmpty)) {
      errors.add('line $number: pack_id, label, word_id and word are needed');
      continue;
    }
    final variants = cells.length == 5
        ? [
            for (final v in cells[4].split('|'))
              if (v.trim().isNotEmpty) v.trim(),
          ]
        : <String>[];
    rows.add(_Row(number, cells[0], cells[1], cells[2], cells[3], variants));
  }
  if (!headerSeen) errors.add('the header line "$wordListHeader" is missing');
  return rows;
}

Map<String, Object?> _pack(
  String id,
  String label,
  List<_Row> rows,
  Map<String, Map<String, Object?>> oldPacks,
  Map<String, Map<String, Object?>> oldWords,
) {
  final old = oldPacks[id];
  final keepReview = old != null && old['title'] == label;
  return {
    'id': id,
    'title': label,
    'labelStatus': keepReview ? old['labelStatus'] : 'in_review',
    if (keepReview && old.containsKey('labelReview'))
      'labelReview': old['labelReview'],
    'words': [for (final row in rows) _word(row, label, oldWords[row.wordId])],
  };
}

Map<String, Object?> _word(_Row row, String label, Map<String, Object?>? old) {
  if (old == null) {
    return {
      'id': row.wordId,
      'version': 1,
      'canonical': row.word,
      'aliases': row.variants,
      'category': label,
      'language': 'aeb-Arab',
      'access': 'free',
      'status': 'in_review',
    };
  }
  final same =
      old['canonical'] == row.word &&
      jsonEncode(old['aliases']) == jsonEncode(row.variants) &&
      old['category'] == label;
  final reviewed = old['status'] == 'published';
  final resetReview = !same && reviewed;
  return {
    'id': row.wordId,
    'version': same ? old['version'] : (old['version']! as int) + 1,
    'canonical': row.word,
    'aliases': row.variants,
    'category': label,
    if (old.containsKey('difficulty')) 'difficulty': old['difficulty'],
    'language': old['language'],
    if (old.containsKey('region')) 'region': old['region'],
    'access': old['access'],
    'status': resetReview ? 'in_review' : old['status'],
    if (!resetReview && old.containsKey('reviews')) 'reviews': old['reviews'],
  };
}

/// Turns `packs[2].words[5].aliases[1]: kind` into `p03-w06 …` so an
/// editor can find the row. Ids, not word text.
String _locate(String issue, List<Map<String, Object?>> packs) {
  final match = RegExp(r'^packs\[(\d+)\](?:\.words\[(\d+)\])?')
      .firstMatch(issue);
  if (match == null) return issue;
  final pack = packs[int.parse(match.group(1)!)];
  final wordIndex = match.group(2);
  final where = wordIndex == null
      ? 'pack ${pack['id']}'
      : 'word ${((pack['words']! as List<Object?>)[int.parse(wordIndex)]! as Map<String, Object?>)['id']}';
  return '$where: $issue';
}
