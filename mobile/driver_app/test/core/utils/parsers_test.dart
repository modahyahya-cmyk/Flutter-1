import 'package:flutter_test/flutter_test.dart';

import 'package:driver_app/core/utils/parsers.dart';

void main() {
  group('Parsers.doubleOf', () {
    test('parses numeric values', () {
      expect(Parsers.doubleOf(12), 12.0);
      expect(Parsers.doubleOf(12.5), 12.5);
    });

    test('parses numeric strings', () {
      expect(Parsers.doubleOf('12.5'), 12.5);
    });

    test('returns zero for null and invalid values', () {
      expect(Parsers.doubleOf(null), 0.0);
      expect(Parsers.doubleOf('invalid'), 0.0);
      expect(Parsers.doubleOf(const Object()), 0.0);
    });
  });

  group('Parsers.intOf', () {
    test('parses numeric values', () {
      expect(Parsers.intOf(12), 12);
      expect(Parsers.intOf(12.9), 12);
    });

    test('parses integer strings', () {
      expect(Parsers.intOf('42'), 42);
    });

    test('returns zero for null and invalid values', () {
      expect(Parsers.intOf(null), 0);
      expect(Parsers.intOf('invalid'), 0);
      expect(Parsers.intOf(const Object()), 0);
    });
  });

  group('Parsers nullable helpers', () {
    test('doubleOrNull preserves null', () {
      expect(Parsers.doubleOrNull(null), isNull);
      expect(Parsers.doubleOrNull('invalid'), isNull);
      expect(Parsers.doubleOrNull('12.5'), 12.5);
    });

    test('intOrNull preserves null', () {
      expect(Parsers.intOrNull(null), isNull);
      expect(Parsers.intOrNull('invalid'), isNull);
      expect(Parsers.intOrNull('42'), 42);
    });

    test('dateTimeOrNull parses valid dates defensively', () {
      final value = Parsers.dateTimeOrNull('2026-01-02T03:04:05Z');

      expect(value, isNotNull);
      expect(value!.toUtc().year, 2026);
      expect(value.toUtc().month, 1);
      expect(value.toUtc().day, 2);
    });

    test('dateTimeOrNull returns null for invalid input', () {
      expect(Parsers.dateTimeOrNull(null), isNull);
      expect(Parsers.dateTimeOrNull('invalid'), isNull);
      expect(Parsers.dateTimeOrNull(const Object()), isNull);
    });
  });
}
