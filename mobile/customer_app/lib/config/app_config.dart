// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------------
/// WHITE-LABEL APPLICATION CONFIGURATION
/// ---------------------------------------------------------------------------
/// This is the SINGLE SOURCE OF TRUTH for all white-label configurations for
/// the customer app. Modifying this file rebrands the entire application.
///
/// STRICT REQUIREMENTS:
/// - NO hardcoded values outside this file
/// - ALL theme colors, API endpoints and feature flags must reference this file
/// - Type-safe with compile-time validation
/// ---------------------------------------------------------------------------
class AppConfig {
  AppConfig._();

  // =========================================================================
  // APPLICATION IDENTITY
  // =========================================================================
  static const String APP_NAME = 'VendorHub';
  static const String APP_TAGLINE = 'Multi-Vendor E-Commerce & Delivery';
  static const String APP_VERSION = '1.0.0';
  static const int APP_BUILD_NUMBER = 1;

  static const String COMPANY_NAME = 'VendorHub Technologies Inc.';
  static const String SUPPORT_EMAIL = 'support@vendorhub.com';
  static const String SUPPORT_PHONE = '+1-800-VENDORHUB';
  static const String PRIVACY_POLICY_URL = 'https://vendorhub.com/privacy';
  static const String TERMS_OF_SERVICE_URL = 'https://vendorhub.com/terms';

  // =========================================================================
  // API CONFIGURATION
  // =========================================================================
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
  static const int API_MAX_RETRY_ATTEMPTS = 3;

  // =========================================================================
  // BRANDING & THEME COLORS
  // =========================================================================
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

  static const Color TEXT_PRIMARY_LIGHT = Color(0xFF1F2937);
  static const Color TEXT_PRIMARY_DARK = Color(0xFFF9FAFB);
  static const Color TEXT_SECONDARY_LIGHT = Color(0xFF6B7280);
  static const Color TEXT_SECONDARY_DARK = Color(0xFF9CA3AF);

  // =========================================================================
  // TYPOGRAPHY
  // =========================================================================
  // 'Inter' is bundled in assets/fonts and registered in pubspec.yaml.
  static const String FONT_FAMILY = 'Inter';

  // =========================================================================
  // FEATURE FLAGS
  // =========================================================================
  static const bool FEATURE_VIDEO_COMMERCE = true;
  static const bool FEATURE_SUBSCRIPTIONS = true;
  static const bool FEATURE_MULTI_BRANCH = true;
  static const bool FEATURE_THERMAL_PRINTING = true;
  static const bool FEATURE_DRIVER_EARNINGS = true;
  static const bool FEATURE_CUSTOMER_REVIEWS = true;
  static const bool FEATURE_LIVE_CHAT = false;
  static const bool FEATURE_LOYALTY_POINTS = false;
  static const bool FEATURE_DARK_MODE = true;
  static const bool FEATURE_BIOMETRIC_AUTH = true;
  static const bool FEATURE_OFFLINE_MODE = true;

  // =========================================================================
  // MAP PROVIDER CONFIGURATION
  // =========================================================================
  static const MapProvider DEFAULT_MAP_PROVIDER = MapProvider.OPENSTREETMAP;

  static const String OSM_TILE_SERVER =
      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String OSM_ATTRIBUTION = '© OpenStreetMap contributors';

  static const String GOOGLE_MAPS_API_KEY = String.fromEnvironment(
    'GOOGLE_MAPS_KEY',
    defaultValue: '',
  );
  static const String MAPBOX_ACCESS_TOKEN = String.fromEnvironment(
    'MAPBOX_TOKEN',
    defaultValue: '',
  );
  static const String MAPBOX_STYLE_URL = 'mapbox://styles/mapbox/streets-v11';

  // =========================================================================
  // PAYMENT GATEWAY CONFIGURATION
  // =========================================================================
  static const PaymentGateway DEFAULT_PAYMENT_GATEWAY = PaymentGateway.STRIPE;

  static const String STRIPE_PUBLISHABLE_KEY = String.fromEnvironment(
    'STRIPE_KEY',
    defaultValue: '',
  );
  static const String PAYSTACK_PUBLIC_KEY = String.fromEnvironment(
    'PAYSTACK_KEY',
    defaultValue: '',
  );
  static const String RAZORPAY_KEY_ID = String.fromEnvironment(
    'RAZORPAY_KEY',
    defaultValue: '',
  );

  // =========================================================================
  // PUSH NOTIFICATION CONFIGURATION
  // =========================================================================
  static const NotificationProvider DEFAULT_NOTIFICATION_PROVIDER =
      NotificationProvider.FIREBASE;
  static const String FCM_SERVER_KEY = String.fromEnvironment(
    'FCM_KEY',
    defaultValue: '',
  );
  static const String ONESIGNAL_APP_ID = String.fromEnvironment(
    'ONESIGNAL_APP_ID',
    defaultValue: '',
  );

  // =========================================================================
  // SOCIAL LOGIN PROVIDERS
  // =========================================================================
  static const bool GOOGLE_LOGIN_ENABLED = true;
  static const bool FACEBOOK_LOGIN_ENABLED = true;
  static const bool APPLE_LOGIN_ENABLED = false;
  static const String GOOGLE_CLIENT_ID = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue: '',
  );
  static const String FACEBOOK_APP_ID = String.fromEnvironment(
    'FACEBOOK_APP_ID',
    defaultValue: '',
  );

  // =========================================================================
  // STORAGE & CACHE CONFIGURATION
  // =========================================================================
  static const String SECURE_STORAGE_PREFIX = 'vendorhub_secure_';
  static const String LOCAL_STORAGE_PREFIX = 'vendorhub_';
  static const Duration CACHE_EXPIRY_DURATION = Duration(hours: 24);
  static const int MAX_CACHE_SIZE_MB = 100;

  // =========================================================================
  // VIDEO COMMERCE CONFIGURATION
  // =========================================================================
  static const int MAX_VIDEO_DURATION_SECONDS = 60;
  static const int MAX_VIDEO_SIZE_MB = 50;
  static const bool AUTOPLAY_VIDEOS = true;
  static const bool MUTE_VIDEOS_BY_DEFAULT = false;
  static const double VIDEO_ASPECT_RATIO = 9 / 16;

  // =========================================================================
  // BUSINESS LOGIC CONFIGURATION
  // =========================================================================
  static const String DEFAULT_CURRENCY = 'USD';
  static const String CURRENCY_SYMBOL = '\$';
  static const CurrencyPosition CURRENCY_POSITION = CurrencyPosition.BEFORE;
  static const String DECIMAL_SEPARATOR = '.';
  static const String THOUSAND_SEPARATOR = ',';
  static const int DECIMAL_PLACES = 2;

  static const double PLATFORM_COMMISSION_RATE = 15.0;
  static const double MIN_ORDER_AMOUNT = 10.0;
  static const double BASE_DELIVERY_FEE = 5.0;
  static const double PER_KM_RATE = 0.5;
  static const int MAX_DELIVERY_RADIUS_KM = 20;

  // =========================================================================
  // VALIDATION RULES
  // =========================================================================
  static const int PASSWORD_MIN_LENGTH = 8;
  static const int OTP_LENGTH = 6;
  static const Duration OTP_EXPIRY_DURATION = Duration(minutes: 10);
  static const int MAX_LOGIN_ATTEMPTS = 5;
  static const Duration LOGIN_LOCKOUT_DURATION = Duration(minutes: 30);

  // =========================================================================
  // FILE UPLOAD CONSTRAINTS
  // =========================================================================
  static const List<String> ALLOWED_IMAGE_EXTENSIONS = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> ALLOWED_VIDEO_EXTENSIONS = ['mp4', 'mov', 'avi'];
  static const List<String> ALLOWED_DOCUMENT_EXTENSIONS = ['pdf', 'doc', 'docx'];
  static const int MAX_IMAGE_SIZE_MB = 10;
  static const int MAX_DOCUMENT_SIZE_MB = 5;

  // =========================================================================
  // LOCATION & GPS CONFIGURATION
  // =========================================================================
  static const Duration LOCATION_UPDATE_INTERVAL = Duration(seconds: 15);
  static const double LOCATION_ACCURACY_THRESHOLD_METERS = 50.0;
  static const Duration BACKGROUND_LOCATION_INTERVAL = Duration(minutes: 2);

  // =========================================================================
  // OFFLINE SYNC CONFIGURATION
  // =========================================================================
  static const Duration SYNC_INTERVAL = Duration(minutes: 5);
  static const int MAX_OFFLINE_QUEUE_SIZE = 100;
  static const Duration OFFLINE_DATA_RETENTION = Duration(days: 7);

  // =========================================================================
  // NETWORK CONFIGURATION
  // =========================================================================
  static const bool CERTIFICATE_PINNING_ENABLED = true;
  static const List<String> PINNED_CERTIFICATES = [];

  // =========================================================================
  // DEEP LINKING & UNIVERSAL LINKS
  // =========================================================================
  static const String DEEP_LINK_SCHEME = 'vendorhub';
  static const String UNIVERSAL_LINK_HOST = 'vendorhub.com';
  static const String DYNAMIC_LINK_PREFIX = 'https://vendorhub.page.link';

  // =========================================================================
  // APP STORE CONFIGURATION
  // =========================================================================
  static const String IOS_APP_ID = '123456789';
  static const String ANDROID_PACKAGE_NAME = 'com.vendorhub.customer';
  static const String PLAY_STORE_URL =
      'https://play.google.com/store/apps/details?id=$ANDROID_PACKAGE_NAME';
  static const String APP_STORE_URL = 'https://apps.apple.com/app/id$IOS_APP_ID';

  // =========================================================================
  // ANALYTICS & MONITORING
  // =========================================================================
  static const bool ANALYTICS_ENABLED = true;
  static const bool CRASH_REPORTING_ENABLED = true;
  static const bool PERFORMANCE_MONITORING_ENABLED = true;
  static const String GOOGLE_ANALYTICS_ID = String.fromEnvironment(
    'GA_ID',
    defaultValue: '',
  );
  static const String SENTRY_DSN = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: '',
  );

  // =========================================================================
  // DEBUG & DEVELOPMENT
  // =========================================================================
  static const bool DEBUG_MODE = bool.fromEnvironment(
    'DEBUG',
    defaultValue: false,
  );
  static const bool ENABLE_API_LOGGING = DEBUG_MODE;
  static const bool ENABLE_PERFORMANCE_OVERLAY = DEBUG_MODE;
  static const bool ENABLE_MOCK_DATA = false;

  // =========================================================================
  // HELPER METHODS
  // =========================================================================
  static String getApiUrl(String endpoint) {
    return '$BASE_API_URL/$endpoint'.replaceAll('//', '/').replaceFirst(':/', '://');
  }

  static bool isFeatureEnabled(String featureName) {
    switch (featureName.toUpperCase()) {
      case 'VIDEO_COMMERCE':
        return FEATURE_VIDEO_COMMERCE;
      case 'SUBSCRIPTIONS':
        return FEATURE_SUBSCRIPTIONS;
      case 'MULTI_BRANCH':
        return FEATURE_MULTI_BRANCH;
      case 'THERMAL_PRINTING':
        return FEATURE_THERMAL_PRINTING;
      case 'DRIVER_EARNINGS':
        return FEATURE_DRIVER_EARNINGS;
      case 'CUSTOMER_REVIEWS':
        return FEATURE_CUSTOMER_REVIEWS;
      case 'LIVE_CHAT':
        return FEATURE_LIVE_CHAT;
      case 'LOYALTY_POINTS':
        return FEATURE_LOYALTY_POINTS;
      case 'DARK_MODE':
        return FEATURE_DARK_MODE;
      case 'BIOMETRIC_AUTH':
        return FEATURE_BIOMETRIC_AUTH;
      case 'OFFLINE_MODE':
        return FEATURE_OFFLINE_MODE;
      default:
        return false;
    }
  }

  static String formatCurrency(double amount) {
    final formattedAmount = amount.toStringAsFixed(DECIMAL_PLACES)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}$THOUSAND_SEPARATOR',
        )
        .replaceAll('.', DECIMAL_SEPARATOR);

    return CURRENCY_POSITION == CurrencyPosition.BEFORE
        ? '$CURRENCY_SYMBOL$formattedAmount'
        : '$formattedAmount$CURRENCY_SYMBOL';
  }

  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidPassword(String password) {
    return password.length >= PASSWORD_MIN_LENGTH &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password);
  }

  static String getEnvironment() {
    if (BASE_API_URL.contains('localhost') || BASE_API_URL.contains('127.0.0.1')) {
      return 'Development';
    } else if (BASE_API_URL.contains('staging') || BASE_API_URL.contains('dev')) {
      return 'Staging';
    }
    return 'Production';
  }
}

// =============================================================================
// ENUMERATIONS
// =============================================================================
enum MapProvider { OPENSTREETMAP, GOOGLE_MAPS, MAPBOX }

enum PaymentGateway { STRIPE, PAYSTACK, RAZORPAY, PAYPAL }

enum NotificationProvider { FIREBASE, ONESIGNAL }

enum CurrencyPosition { BEFORE, AFTER }

enum UserRole { CUSTOMER, VENDOR, DRIVER, ADMIN }

enum OrderStatus {
  PENDING,
  CONFIRMED,
  PREPARING,
  READY_FOR_PICKUP,
  OUT_FOR_DELIVERY,
  DELIVERED,
  CANCELLED,
  REFUNDED,
}

enum PaymentStatus { PENDING, PROCESSING, COMPLETED, FAILED, REFUNDED }

enum DeliveryStatus { ASSIGNED, PICKED_UP, IN_TRANSIT, DELIVERED, FAILED }

// =============================================================================
// EXTENSION METHODS
// =============================================================================
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

  bool get isEnabled {
    switch (this) {
      case MapProvider.OPENSTREETMAP:
        return true;
      case MapProvider.GOOGLE_MAPS:
        return AppConfig.GOOGLE_MAPS_API_KEY.isNotEmpty;
      case MapProvider.MAPBOX:
        return AppConfig.MAPBOX_ACCESS_TOKEN.isNotEmpty;
    }
  }
}

extension PaymentGatewayExtension on PaymentGateway {
  String get name {
    switch (this) {
      case PaymentGateway.STRIPE:
        return 'Stripe';
      case PaymentGateway.PAYSTACK:
        return 'PayStack';
      case PaymentGateway.RAZORPAY:
        return 'Razorpay';
      case PaymentGateway.PAYPAL:
        return 'PayPal';
    }
  }

  bool get isEnabled {
    switch (this) {
      case PaymentGateway.STRIPE:
        return AppConfig.STRIPE_PUBLISHABLE_KEY.isNotEmpty;
      case PaymentGateway.PAYSTACK:
        return AppConfig.PAYSTACK_PUBLIC_KEY.isNotEmpty;
      case PaymentGateway.RAZORPAY:
        return AppConfig.RAZORPAY_KEY_ID.isNotEmpty;
      case PaymentGateway.PAYPAL:
        return false;
    }
  }
}

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.PENDING:
        return 'Pending';
      case OrderStatus.CONFIRMED:
        return 'Confirmed';
      case OrderStatus.PREPARING:
        return 'Preparing';
      case OrderStatus.READY_FOR_PICKUP:
        return 'Ready for Pickup';
      case OrderStatus.OUT_FOR_DELIVERY:
        return 'Out for Delivery';
      case OrderStatus.DELIVERED:
        return 'Delivered';
      case OrderStatus.CANCELLED:
        return 'Cancelled';
      case OrderStatus.REFUNDED:
        return 'Refunded';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.PENDING:
        return AppConfig.WARNING_COLOR;
      case OrderStatus.CONFIRMED:
      case OrderStatus.PREPARING:
      case OrderStatus.READY_FOR_PICKUP:
      case OrderStatus.OUT_FOR_DELIVERY:
        return AppConfig.INFO_COLOR;
      case OrderStatus.DELIVERED:
        return AppConfig.SUCCESS_COLOR;
      case OrderStatus.CANCELLED:
      case OrderStatus.REFUNDED:
        return AppConfig.ERROR_COLOR;
    }
  }
}
