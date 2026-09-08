import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../config/app_config.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (AppConfig.ENABLE_API_LOGGING) _log('[REQ] ${options.method} ${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (AppConfig.ENABLE_API_LOGGING) _log('[RES] ${response.statusCode} ${response.requestOptions.path}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (AppConfig.ENABLE_API_LOGGING) _log('[ERR] ${err.response?.statusCode} ${err.requestOptions.path}');
    handler.next(err);
  }

  void _log(String message) {
    // debugPrint is the sanctioned logging path in Flutter (no avoid_print
    // lint, respects the Flutter logging framework in all build modes).
    debugPrint(message);
  }
}
