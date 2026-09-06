import 'package:flutter/material.dart';

import 'app_config.dart';

/// Builds the white-label light & dark themes entirely from [AppConfig].
class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppConfig.PRIMARY_COLOR,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppConfig.PRIMARY_COLOR,
      secondary: AppConfig.SECONDARY_COLOR,
      surface: AppConfig.SURFACE_LIGHT,
      error: AppConfig.ERROR_COLOR,
    );

    return _base(scheme, background: AppConfig.BACKGROUND_LIGHT);
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppConfig.PRIMARY_COLOR,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppConfig.PRIMARY_COLOR,
      secondary: AppConfig.SECONDARY_COLOR,
      surface: AppConfig.SURFACE_DARK,
      error: AppConfig.ERROR_COLOR,
    );

    return _base(scheme, background: AppConfig.BACKGROUND_DARK);
  }

  static ThemeData _base(ColorScheme scheme, {required Color background}) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      fontFamily: AppConfig.FONT_FAMILY,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConfig.PRIMARY_COLOR,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface.withValues(alpha: 0.6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppConfig.PRIMARY_COLOR,
            width: 2,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
