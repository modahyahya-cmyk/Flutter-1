// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------------
/// WHITE-LABEL APPLICATION CONFIGURATION — VENDOR APP
/// ---------------------------------------------------------------------------
/// Single source of truth for the vendor app branding & settings. Rebrand the
/// whole app by editing this file (and its peers in customer/driver apps).
/// ---------------------------------------------------------------------------
class AppConfig {
  AppConfig._();

  // Identity
  static const String APP_NAME = 'VendorHub Vendor';
  static const String COMPANY_NAME = 'VendorHub Technologies Inc.';
  static const String SUPPORT_EMAIL = 'support@vendorhub.com';

  // API
  static const String BASE_API_URL = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://api.vendorhub.com/api/v1',
  );
  static const Duration API_CONNECTION_TIMEOUT = Duration(seconds: 30);

  // Colors
  static const Color PRIMARY_COLOR = Color(0xFF6366F1);
  static const Color SECONDARY_COLOR = Color(0xFFEC4899);
  static const Color ACCENT_COLOR = Color(0xFFF59E0B);
  static const Color SUCCESS_COLOR = Color(0xFF10B981);
  static const Color WARNING_COLOR = Color(0xFFF59E0B);
  static const Color ERROR_COLOR = Color(0xFFEF4444);
  static const Color INFO_COLOR = Color(0xFF3B82F6);
  static const Color BACKGROUND_LIGHT = Color(0xFFFAFAFA);
  static const Color BACKGROUND_DARK = Color(0xFF121212);
  static const Color SURFACE_LIGHT = Color(0xFFFFFFFF);
  static const Color SURFACE_DARK = Color(0xFF1E1E1E);

  // Typography
  static const String FONT_FAMILY = 'Inter';

  // Feature flags
  static const bool FEATURE_MULTI_BRANCH = true;
  static const bool FEATURE_THERMAL_PRINTING = true;
  static const bool FEATURE_DRIVER_EARNINGS = true;
  static const bool FEATURE_DARK_MODE = true;

  // Currency
  static const String DEFAULT_CURRENCY = 'USD';
  static const String CURRENCY_SYMBOL = '\$';
  static const CurrencyPosition CURRENCY_POSITION = CurrencyPosition.BEFORE;
  static const int DECIMAL_PLACES = 2;

  // Business
  static const double PLATFORM_COMMISSION_RATE = 15.0;

  // Thermal printer
  static const int THERMAL_PRINTER_PAPER_WIDTH_MM = 58;
  static const int THERMAL_PRINTER_CHARS_PER_LINE = 32;
  static const Duration PRINTER_CONNECTION_TIMEOUT = Duration(seconds: 10);
  static const int PRINTER_MAX_RETRY_ATTEMPTS = 3;

  // Deep link
  static const String DEEP_LINK_SCHEME = 'vendorhub-vendor';

  // Debug & development
  static const bool DEBUG_MODE = bool.fromEnvironment('DEBUG', defaultValue: false);
  static const bool ENABLE_API_LOGGING = DEBUG_MODE;
  static const bool ENABLE_PERFORMANCE_OVERLAY = DEBUG_MODE;
  static const bool ENABLE_MOCK_DATA = false;

  static bool isFeatureEnabled(String name) {
    switch (name.toUpperCase()) {
      case 'MULTI_BRANCH':
        return FEATURE_MULTI_BRANCH;
      case 'THERMAL_PRINTING':
        return FEATURE_THERMAL_PRINTING;
      case 'DRIVER_EARNINGS':
        return FEATURE_DRIVER_EARNINGS;
      case 'DARK_MODE':
        return FEATURE_DARK_MODE;
      default:
        return false;
    }
  }

  static String getApiUrl(String endpoint) =>
      '$BASE_API_URL/$endpoint'.replaceAll('//', '/').replaceFirst(':/', '://');

  static String formatCurrency(double amount) {
    final formatted = amount.toStringAsFixed(DECIMAL_PLACES);
    return CURRENCY_POSITION == CurrencyPosition.BEFORE
        ? '$CURRENCY_SYMBOL$formatted'
        : '$formatted$CURRENCY_SYMBOL';
  }
}

enum CurrencyPosition { BEFORE, AFTER }

extension CurrencyPositionExtension on CurrencyPosition {
  String get name => this == CurrencyPosition.BEFORE ? 'before' : 'after';
}
