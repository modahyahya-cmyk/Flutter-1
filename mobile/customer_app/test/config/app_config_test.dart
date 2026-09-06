import 'package:customer_app/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConfig.isValidEmail', () {
    test('rejects invalid emails', () {
      expect(AppConfig.isValidEmail(''), isFalse);
      expect(AppConfig.isValidEmail('plain'), isFalse);
      expect(AppConfig.isValidEmail('a@b'), isFalse);
      expect(AppConfig.isValidEmail('a@.com'), isFalse);
    });

    test('accepts valid emails', () {
      expect(AppConfig.isValidEmail('user@example.com'), isTrue);
      expect(AppConfig.isValidEmail('test.user@sub.domain.org'), isTrue);
    });
  });

  group('AppConfig.isValidPassword', () {
    test('requires 8+ chars with upper, lower and digit', () {
      expect(AppConfig.isValidPassword('abcdefgh'), isFalse);
      expect(AppConfig.isValidPassword('ABCDEFGH'), isFalse);
      expect(AppConfig.isValidPassword('abcdef1'), isFalse);
      expect(AppConfig.isValidPassword('Abcdefg'), isFalse); // no digit
      expect(AppConfig.isValidPassword('Abcdef12'), isTrue);
    });
  });

  group('AppConfig.formatCurrency', () {
    // CURRENCY_POSITION == BEFORE, symbol == '$' (defaults).
    test('formats thousands with separators and fixed decimals', () {
      expect(AppConfig.formatCurrency(1234567.5), r'$1,234,567.50');
      expect(AppConfig.formatCurrency(1000), r'$1,000.00');
      expect(AppConfig.formatCurrency(0), r'$0.00');
    });
  });
}
