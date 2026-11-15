// Every Arabic string carries an explicit review status so provisional copy
// can never be mistaken for approved copy (PRD §13, DECISIONS.md D-07).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final arb = jsonDecode(
    File('lib/l10n/app_ar.arb').readAsStringSync(),
  ) as Map<String, dynamic>;
  final keys = arb.keys.where((k) => !k.startsWith('@')).toList();
  // Arabic-Indic (U+0660-0669) and Eastern Arabic-Indic (U+06F0-06F9) digits.
  final easternDigits = RegExp(
    '[${String.fromCharCode(0x0660)}-${String.fromCharCode(0x0669)}'
    '${String.fromCharCode(0x06F0)}-${String.fromCharCode(0x06F9)}]',
  );
  final status = RegExp(r'^\[(REVIEW|APPROVED)\] \S');

  test('the template locale is Arabic', () {
    expect(arb['@@locale'], 'ar');
  });

  test('every string has a description starting with its review status', () {
    expect(keys, isNotEmpty);
    for (final key in keys) {
      final meta = arb['@$key'];
      expect(meta, isA<Map<String, dynamic>>(), reason: '@$key is missing');
      final description = (meta as Map<String, dynamic>)['description'];
      expect(description, isA<String>(), reason: '@$key has no description');
      expect(
        status.hasMatch(description as String),
        isTrue,
        reason: '@$key must start with [REVIEW] or [APPROVED]',
      );
    }
  });

  test('no metadata entry is orphaned', () {
    final metaKeys = arb.keys
        .where((k) => k.startsWith('@') && !k.startsWith('@@'))
        .map((k) => k.substring(1));
    expect(metaKeys.toSet().difference(keys.toSet()), isEmpty);
  });

  test('strings use Arabic punctuation and Western digits', () {
    for (final key in keys) {
      final value = arb[key] as String;
      expect(value.contains('?'), isFalse, reason: '$key: use ؟');
      expect(value.contains(','), isFalse, reason: '$key: use ،');
      expect(
        easternDigits.hasMatch(value),
        isFalse,
        reason: '$key: use Western digits',
      );
    }
  });
}
