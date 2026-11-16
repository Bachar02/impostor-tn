import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_tn/game/final_guess_matching.dart';
import 'package:impostor_tn/game/secret_word.dart';

import 'game_fixtures.dart';

// Synthetic Arabic fixture used only to exercise letter-level rules.
const _arabicFixture = SecretWord(
  wordId: 'fixture-arabic',
  category: 'fixture-category',
  canonical: 'قطة',
);

void main() {
  group('comparisonForm (D-01)', () {
    for (final (label, raw, expected) in [
      ('unchanged text', 'a b', 'a b'),
      ('outer spaces removed', '  a b  ', 'a b'),
      ('inner runs of spaces collapsed', 'a    b', 'a b'),
      ('outer and inner together', '   a   b   c ', 'a b c'),
      ('only spaces become empty', '     ', ''),
      ('empty stays empty', '', ''),
    ]) {
      test(label, () {
        expect(FinalGuessMatching.comparisonForm(raw), expected);
      });
    }
  });

  group('comparisonForm keeps characters D-30 leaves alone', () {
    // Strict interim reading: only U+0020 is a space; nothing is removed.
    for (final (label, raw) in [
      ('tab', '\ta'),
      ('no-break space', ' a'),
      ('zero-width joiner', 'a‍b'),
      ('right-to-left mark', '‏a'),
    ]) {
      test(label, () {
        expect(FinalGuessMatching.comparisonForm(raw), raw);
      });
    }
  });

  test('displayForm removes outer spaces only', () {
    expect(FinalGuessMatching.displayForm('  a   b  '), 'a   b');
  });

  group('matches', () {
    for (final (label, guess, expected) in [
      ('the canonical word', 'alpha', true),
      ('an alias', 'alfa', true),
      ('the canonical word with outer spaces', '  alpha ', true),
      ('different Latin case', 'Alpha', false),
      ('a near spelling that is not an alias', 'alph', false),
      ('an empty guess', '', false),
      ('a guess of spaces only', '   ', false),
      ('the word preceded by a tab', '\talpha', false),
    ]) {
      test('$label → $expected', () {
        expect(FinalGuessMatching.matches(guess, fixtureWord), expected);
      });
    }

    test('collapses inner spaces on both sides', () {
      const twoWords = SecretWord(
        wordId: 'fixture-two-words',
        category: 'fixture-category',
        canonical: 'alpha  beta',
      );
      expect(FinalGuessMatching.matches('alpha beta', twoWords), isTrue);
    });

    for (final (label, guess) in [
      ('a diacritic added', 'قِطة'),
      ('a tatweel added', 'قطـة'),
      ('ة written as ه', 'قطه'),
      ('ق written as ڨ', 'ڨطة'),
    ]) {
      test('does not fold Arabic variants: $label', () {
        expect(FinalGuessMatching.matches(guess, _arabicFixture), isFalse);
      });
    }

    test('accepts the exact Arabic fixture', () {
      expect(FinalGuessMatching.matches('قطة', _arabicFixture), isTrue);
    });
  });
}
