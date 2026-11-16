import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_tn/features/setup/application/player_names.dart';
import 'package:impostor_tn/game/game_rules.dart';

// Placeholder names chosen for the rules; not content.

void main() {
  group('normalize (D-15)', () {
    for (final (raw, expected) in [
      ('  Sami  ', 'Sami'),
      ('Sami   Ben', 'Sami Ben'),
      ('Sami\tBen', 'Sami Ben'),
      ('Sami  Ben', 'Sami Ben'),
      ('سامي   بن', 'سامي بن'),
    ]) {
      test('"$raw" → "$expected"', () {
        expect(PlayerNames.normalize(raw), expected);
      });
    }
  });

  group('length in user-perceived characters', () {
    test('a letter with shadda and a vowel counts once', () {
      // ش + shadda (U+0651) + fatha (U+064E): three code points, one character.
      expect(PlayerNames.length('شَّ'), 1);
    });

    test('an emoji family counts once', () {
      expect(PlayerNames.length('👨‍👩‍👧'), 1);
    });

    test('exactly ${GameRules.maxNameLength} is accepted, one more is not', () {
      final atLimit = 'ب' * GameRules.maxNameLength;

      expect(PlayerNames.check(atLimit, const []), isNull);
      expect(PlayerNames.check('$atLimitب', const []), NameProblem.tooLong);
    });

    test('combining marks do not use up the limit', () {
      final marked = 'بّ' * GameRules.maxNameLength;

      expect(PlayerNames.check(marked, const []), isNull);
    });

    test('spaces collapsed before counting', () {
      final name = '${'a' * 8}     ${'b' * 7}';

      expect(PlayerNames.check(name, const []), isNull);
    });
  });

  group('problems', () {
    test('empty after trimming', () {
      expect(PlayerNames.check('   ', const []), NameProblem.empty);
    });

    for (final (name, other) in [
      ('Sami', 'sami'),
      ('SAMI', 'Sami'),
      (' Sami ', 'Sami'),
      ('Sami  Ben', 'sami ben'),
      ('Élodie', 'élodie'),
      ('سامي', 'سامي'),
    ]) {
      test('"$name" duplicates "$other"', () {
        expect(PlayerNames.check(name, [other]), NameProblem.duplicate);
      });
    }

    for (final (name, other) in [
      ('Sami', 'Sammi'),
      ('سامي', 'سامى'),
      ('Σάμι', 'σάμι'),
    ]) {
      test('"$name" does not duplicate "$other"', () {
        expect(PlayerNames.check(name, [other]), isNull);
      });
    }
  });

  test('allValid finds a duplicate anywhere in the list', () {
    expect(PlayerNames.allValid(['A', 'B', 'C', 'b']), isFalse);
    expect(PlayerNames.allValid(['A', 'B', 'C', 'D']), isTrue);
  });
}
