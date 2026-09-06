/// Lightweight application logger used across the driver app.
///
/// Output is gated on [AppConfig.DEBUG_MODE] so release builds stay quiet.
/// Swap the body for a full logger (e.g. `logger`, Firebase Analytics) by
/// editing this single file.
library;

import 'dart:developer' as developer;

import '../../config/app_config.dart';

class AppLogger {
  AppLogger._();

  static const String _tag = 'DriverApp';

  static void debug(String message, {Object? data}) =>
      _log(LogLevel.debug, message, data: data);

  static void info(String message, {Object? data}) =>
      _log(LogLevel.info, message, data: data);

  static void warning(String message, {Object? data}) =>
      _log(LogLevel.warning, message, data: data);

  static void error(String message, {Object? error, Object? data}) =>
      _log(LogLevel.error, message, data: data, error: error);

  static void _log(LogLevel level, String message, {Object? data, Object? error}) {
    if (!AppConfig.DEBUG_MODE) {
      // Keep a hook so release builds can forward to a remote logger later.
      return;
    }

    final suffix = switch (level) {
      LogLevel.debug => '',
      LogLevel.info => '',
      LogLevel.warning => ' — WARN',
      LogLevel.error => ' — ERROR',
    };

    var line = '[$_tag] $message$suffix';
    if (data != null) line += ' | data=$data';
    if (error != null) line += ' | error=$error';

    switch (level) {
      case LogLevel.debug:
        developer.log(line, name: _tag);
      case LogLevel.info:
        developer.log(line, name: _tag);
      case LogLevel.warning:
        developer.log(line, name: _tag, level: 900);
      case LogLevel.error:
        developer.log(line, name: _tag, level: 1000, error: error);
    }
  }
}

enum LogLevel { debug, info, warning, error }
