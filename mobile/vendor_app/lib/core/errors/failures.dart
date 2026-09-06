/// Domain-layer failure types for the vendor app.
library;

import 'exceptions.dart';

class Failure {
  const Failure(this.message, {this.code, this.fieldErrors = const {}});

  const Failure.unknown()
      : this('Something went wrong. Please try again.', code: 'UNKNOWN');

  const Failure.noConnection()
      : this('No internet connection. Please check your network.', code: 'NO_CONNECTION');

  const Failure.server()
      : this('A server error occurred. Please try again later.', code: 'SERVER');

  final String message;
  final String? code;
  final Map<String, List<String>> fieldErrors;

  @override
  String toString() => message;
}

Failure mapExceptionToFailure(AppException exception) {
  if (exception is NetworkException) return Failure.noConnection();
  if (exception is ServerException) return Failure.server();
  if (exception is ValidationException) {
    return Failure(exception.message, code: 'VALIDATION', fieldErrors: exception.errors);
  }
  if (exception is UnauthorizedException) return Failure(exception.message, code: 'UNAUTHORIZED');
  if (exception is ForbiddenException) return Failure(exception.message, code: 'FORBIDDEN');
  if (exception is NotFoundException) return Failure(exception.message, code: 'NOT_FOUND');
  if (exception is RateLimitException) return Failure(exception.message, code: 'RATE_LIMIT');
  if (exception is BadRequestException) return Failure(exception.message, code: 'BAD_REQUEST');
  return Failure(exception.message, code: 'UNKNOWN');
}

String mapFailureToMessage(Failure failure) => failure.message;
