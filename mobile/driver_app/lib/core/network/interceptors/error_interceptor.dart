import 'package:dio/dio.dart';

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
