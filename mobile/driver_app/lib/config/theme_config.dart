import 'package:flutter/material.dart';

import 'app_config.dart';

class DriverAppTheme {
  DriverAppTheme._();

  static ThemeData light() => _base(Brightness.light, AppConfig.BACKGROUND_LIGHT);
  static ThemeData dark() => _base(Brightness.dark, AppConfig.BACKGROUND_DARK);

  static ThemeData _base(Brightness brightness, Color background) {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppConfig.PRIMARY_COLOR,
      brightness: brightness,
    ).copyWith(primary: AppConfig.PRIMARY_COLOR, secondary: AppConfig.SUCCESS_COLOR);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      fontFamily: AppConfig.FONT_FAMILY,
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
