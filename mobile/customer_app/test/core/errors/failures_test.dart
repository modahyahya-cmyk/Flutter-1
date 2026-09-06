import 'package:customer_app/core/errors/exceptions.dart';
import 'package:customer_app/core/errors/failures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mapExceptionToFailure', () {
    test('maps networking to NO_CONNECTION', () {
      final f = mapExceptionToFailure(const NetworkException(message: 'No internet connection'));
      expect(f.code, 'NO_CONNECTION');
      expect(f.message, 'No internet connection. Please check your network.');
    });

    test('maps server to SERVER', () {
      final f = mapExceptionToFailure(const ServerException(message: 'boom'));
      expect(f.code, 'SERVER');
    });

    test('maps validation including field errors', () {
      final f = mapExceptionToFailure(
        ValidationException(
          message: 'Invalid input',
          errors: const {'email': ['invalid']},
        ),
      );
      expect(f.code, 'VALIDATION');
      expect(f.fieldErrors, {'email': ['invalid']});
    });

    test('maps unknown to UNKNOWN', () {
      final f = mapExceptionToFailure(const AppException(message: 'x'));
      expect(f.code, 'UNKNOWN');
    });
  });

  group('mapFailureToMessage', () {
    test('returns the failure message verbatim', () {
      expect(mapFailureToMessage(const Failure.unknown()), 'Something went wrong. Please try again.');
      expect(mapFailureToMessage(const Failure('hi', code: 'X')), 'hi');
    });
  });
}
