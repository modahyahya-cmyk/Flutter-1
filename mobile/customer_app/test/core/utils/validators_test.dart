import 'package:customer_app/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators.email', () {
    test('rejects null / empty', () {
      expect(Validators.email(null), 'Email is required');
      expect(Validators.email(''), 'Email is required');
      expect(Validators.email('   '), 'Email is required');
    });

    test('rejects malformed emails', () {
      expect(Validators.email('not-an-email'), isNotNull);
      expect(Validators.email('a@b'), isNotNull);
      expect(Validators.email('a@.com'), isNotNull);
      expect(Validators.email('a b@c.com'), isNotNull);
    });

    test('accepts a valid email', () {
      expect(Validators.email('user@example.com'), isNull);
      expect(Validators.email('  user@example.com  '), isNull);
    });
  });

  group('Validators.password', () {
    test('rejects null / empty', () {
      expect(Validators.password(null), 'Password is required');
      expect(Validators.password(''), 'Password is required');
    });

    test('rejects short / weak passwords (<8, no digit, no upper, no lower)', () {
      expect(Validators.password('abc'), isNotNull);
      expect(Validators.password('abcdefgh'), isNotNull, reason: 'no digits');
      expect(Validators.password('ABCDEF1'), isNotNull, reason: 'no lowercase');
      expect(Validators.password('abcdef1'), isNotNull, reason: 'no uppercase');
      expect(Validators.password('abcDEF123'), isNull);
    });
  });

  group('Validators.required', () {
    test('rejects empty and returns custom field name', () {
      expect(Validators.required(null), 'This field is required');
      expect(Validators.required(''), 'This field is required');
      expect(Validators.required('', 'Name'), 'Name is required');
    });

    test('accepts non-empty', () {
      expect(Validators.required('x'), isNull);
    });
  });

  group('Validators.optionalPhone', () {
    test('accepts empty values', () {
      expect(Validators.optionalPhone(null), isNull);
      expect(Validators.optionalPhone(''), isNull);
    });

    test('accepts a valid length phone and rejects too-short', () {
      expect(Validators.optionalPhone('1234567'), isNull);
      expect(Validators.optionalPhone('123456'), isNotNull);
    });
  });
}
