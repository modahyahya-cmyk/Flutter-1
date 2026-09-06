/// Domain-layer failure types for the driver app.
library;

import 'exceptions.dart';

class Failure {
  const Failure(this.message, {this.code, this.fieldErrors = const {}});

  const Failure.unknown()
      : this('Something went wrong. Please try again.', code: 'UNKNOWN');

  const Failure.noConnection()
      : this('You are offline. Changes will sync when connected.', code: 'NO_CONNECTION');

  const Failure.server()
      : this('A server error occurred. Please try again later.', code: 'SERVER');

  const Failure.notFound()
      : this('The requested item was not found.', code: 'NOT_FOUND');

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
  if (exception is NotFoundException) return Failure.notFound();
  if (exception is RateLimitException) return Failure(exception.message, code: 'RATE_LIMIT');
  if (exception is BadRequestException) return Failure(exception.message, code: 'BAD_REQUEST');
  if (exception is OfflineException) return Failure.noConnection();
  return Failure(exception.message, code: 'UNKNOWN');
}

String mapFailureToMessage(Failure failure) => failure.message;
