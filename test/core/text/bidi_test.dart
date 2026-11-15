import 'package:flutter_test/flutter_test.dart';
import 'package:impostor_tn/core/text/bidi.dart';

void main() {
  test('ltrIsolate wraps text in LRI … PDI and keeps the content intact', () {
    final wrapped = ltrIsolate('4–12');
    expect(wrapped.codeUnits.first, 0x2066);
    expect(wrapped.codeUnits.last, 0x2069);
    expect(wrapped.substring(1, wrapped.length - 1), '4–12');
  });

  test('directionIsolate wraps text in FSI … PDI', () {
    final wrapped = directionIsolate('Salma');
    expect(wrapped.codeUnits.first, 0x2068);
    expect(wrapped.codeUnits.last, 0x2069);
    expect(wrapped.substring(1, wrapped.length - 1), 'Salma');
  });

  test('empty input still produces a balanced isolate pair', () {
    expect(ltrIsolate('').codeUnits, [0x2066, 0x2069]);
    expect(directionIsolate('').codeUnits, [0x2068, 0x2069]);
  });
}
