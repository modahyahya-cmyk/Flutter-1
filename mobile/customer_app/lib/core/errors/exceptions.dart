/// Application-layer exception hierarchy.
///
/// These represent *exceptions* thrown from data sources / repository calls,
/// to be converted by the presentation layer into user-facing [Failure]s.
library;

class AppException implements Exception {
  const AppException({this.message = 'An unexpected error occurred', this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ServerException extends AppException {
  const ServerException({super.message = 'A server error occurred', super.statusCode});
}

class NetworkException extends AppException {
  const NetworkException({super.message = 'A network error occurred'});
}

class BadRequestException extends AppException {
  const BadRequestException({super.message = 'Bad request', super.statusCode});
}

class UnauthorizedException extends AppException {
  const UnauthorizedException({super.message = 'Unauthorized', super.statusCode});
}

class ForbiddenException extends AppException {
  const ForbiddenException({super.message = 'Forbidden', super.statusCode});
}

class NotFoundException extends AppException {
  const NotFoundException({super.message = 'Resource not found', super.statusCode});
}

class ValidationException extends AppException {
  const ValidationException({
    super.message = 'Validation failed',
    this.errors = const {},
    super.statusCode,
  });

  final Map<String, List<String>> errors;
}

class RateLimitException extends AppException {
  const RateLimitException({super.message = 'Too many requests', super.statusCode});
}

class CancelledException extends AppException {
  const CancelledException({super.message = 'Request cancelled'});
}
