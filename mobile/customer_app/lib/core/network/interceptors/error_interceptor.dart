import 'package:dio/dio.dart';

/// Normalises 401 responses so the caller can decide on a token-refresh or
/// session-expiry flow without special-casing per endpoint.
class ErrorInterceptor extends Interceptor {
  ErrorInterceptor({this.onUnauthorized});

  final Future<void> Function()? onUnauthorized;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401 && onUnauthorized != null) {
      onUnauthorized!();
    }
    handler.next(err);
  }
}
