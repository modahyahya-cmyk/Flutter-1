// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------------
/// WHITE-LABEL APPLICATION CONFIGURATION — DRIVER APP
/// ---------------------------------------------------------------------------
/// Single source of truth for the driver app branding & settings.
/// ---------------------------------------------------------------------------
class AppConfig {
  AppConfig._();

  // Identity
  static const String APP_NAME = 'VendorHub Driver';
  static const String COMPANY_NAME = 'VendorHub Technologies Inc.';

  // API
  static const String BASE_API_URL = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://api.vendorhub.com/api/v1',
  );
  static const String WEBSOCKET_URL = String.fromEnvironment(
    'WEBSOCKET_URL',
    defaultValue: 'wss://api.vendorhub.com',
  );
  static const Duration API_CONNECTION_TIMEOUT = Duration(seconds: 30);
  static const Duration API_RECEIVE_TIMEOUT = Duration(seconds: 30);

  // Debug & development
  static const bool DEBUG_MODE = bool.fromEnvironment('DEBUG', defaultValue: false);
  static const bool ENABLE_API_LOGGING = DEBUG_MODE;
  static const bool ENABLE_PERFORMANCE_OVERLAY = DEBUG_MODE;
  static const bool ENABLE_MOCK_DATA = false;

  // Colors
  static const Color PRIMARY_COLOR = Color(0xFF6366F1);
  static const Color SECONDARY_COLOR = Color(0xFFEC4899);
  static const Color SUCCESS_COLOR = Color(0xFF10B981);
  static const Color WARNING_COLOR = Color(0xFFF59E0B);
  static const Color ERROR_COLOR = Color(0xFFEF4444);
  static const Color INFO_COLOR = Color(0xFF3B82F6);
  static const Color BACKGROUND_LIGHT = Color(0xFFFAFAFA);
  static const Color BACKGROUND_DARK = Color(0xFF121212);

  // Typography
  static const String FONT_FAMILY = 'Inter';

  // Feature flags
  static const bool FEATURE_DRIVER_EARNINGS = true;
  static const bool FEATURE_OFFLINE_MODE = true;
  static const bool FEATURE_LIVE_TRACKING = true;
  static const bool FEATURE_DARK_MODE = true;

  // Map
  static const MapProvider DEFAULT_MAP_PROVIDER = MapProvider.OPENSTREETMAP;
  static const String OSM_TILE_SERVER =
      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String OSM_ATTRIBUTION = '© OpenStreetMap contributors';
  static const String GOOGLE_MAPS_API_KEY =
      String.fromEnvironment('GOOGLE_MAPS_KEY', defaultValue: '');

  // Currency
  static const String DEFAULT_CURRENCY = 'USD';
  static const String CURRENCY_SYMBOL = '\$';
  static const int DECIMAL_PLACES = 2;

  // Offline sync
  static const Duration SYNC_INTERVAL = Duration(minutes: 5);
  static const int MAX_OFFLINE_QUEUE_SIZE = 100;
  static const Duration OFFLINE_DATA_RETENTION = Duration(days: 7);

  // Location
  static const Duration LOCATION_UPDATE_INTERVAL = Duration(seconds: 15);
  static const double LOCATION_ACCURACY_THRESHOLD_METERS = 50.0;
  static const Duration BACKGROUND_LOCATION_INTERVAL = Duration(minutes: 2);

  static String getApiUrl(String endpoint) =>
      '$BASE_API_URL/$endpoint'.replaceAll('//', '/').replaceFirst(':/', '://');

  static String formatCurrency(double amount) =>
      '$CURRENCY_SYMBOL${amount.toStringAsFixed(DECIMAL_PLACES)}';
}

enum MapProvider { OPENSTREETMAP, GOOGLE_MAPS, MAPBOX }

extension MapProviderExtension on MapProvider {
  String get name {
    switch (this) {
      case MapProvider.OPENSTREETMAP:
        return 'OpenStreetMap';
      case MapProvider.GOOGLE_MAPS:
        return 'Google Maps';
      case MapProvider.MAPBOX:
        return 'Mapbox';
    }
  }
}
