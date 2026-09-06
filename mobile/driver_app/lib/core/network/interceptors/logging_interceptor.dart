import 'dart:io';

import 'package:dio/dio.dart';

import '../../../config/app_config.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _log('→ ${options.method.toUpperCase()} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _log('← ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _log('✗ ${err.response?.statusCode} ${err.requestOptions.uri} — ${err.message}');
    handler.next(err);
  }

  void _log(String message) {
    if (!AppConfig.ENABLE_API_LOGGING) return;
    const tag = 'DriverApp:HTTP';
    if (_supportsAnsiColor) {
      stdout.writeln('\x1B[2m[$tag]\x1B[0m $message');
    } else {
      stdout.writeln('[$tag] $message');
    }
  }

  bool get _supportsAnsiColor => Platform.environment['TERM']?.toLowerCase() != 'dumb';
}
