# White-Label Guide

Every app is branded from a **single file**:

| App | Config file |
|-----|-------------|
| Customer | `mobile/customer_app/lib/config/app_config.dart` |
| Vendor | `mobile/vendor_app/lib/config/app_config.dart` |
| Driver | `mobile/driver_app/lib/config/app_config.dart` |

## What you can change

```dart
static const String APP_NAME = 'YourAppName';        // app display name
static const String COMPANY_NAME = 'Your Company';    // legal / company name
static const String SUPPORT_EMAIL = 'you@company.com';

static const String BASE_API_URL = 'https://api.yourdomain.com/api/v1';

static const Color PRIMARY_COLOR = Color(0xFF6366F1); // theme seed
static const Color SECONDARY_COLOR = Color(0xFFEC4899);
static const Color SUCCESS_COLOR = Color(0xFF10B981);
static const Color ERROR_COLOR = Color(0xFFEF4444);

static const String FONT_FAMILY = 'Inter';            // bundled font family
static const String DEFAULT_CURRENCY = 'USD';         // display currency
static const String CURRENCY_SYMBOL = '\$';

static const MapProvider DEFAULT_MAP_PROVIDER = MapProvider.OPENSTREETMAP;
```

## Changing branding assets

1. Replace the app logo/icon assets under `assets/images/` and `assets/icons/`.
2. Update the Android launcher icon and iOS app icon.
3. Change the app label in `android/app/src/main/AndroidManifest.xml` and
   `ios/Runner/Info.plist`.
4. Update `applicationId` / `CFBundleIdentifier`.

## Feature flags

Toggle optional behavior without editing feature code:

```dart
static const bool FEATURE_THERMAL_PRINTING = true;
static const bool FEATURE_MULTI_BRANCH = true;
static const bool FEATURE_OFFLINE_MODE = true;
static const bool FEATURE_LIVE_TRACKING = true;
static const bool FEATURE_DARK_MODE = true;
```

## Builds / integration

Build-time `--dart-define` values can override `BASE_API_URL` and the Google
Maps key, e.g.:

```bash
flutter build apk --release --flavor production \
  --dart-define=API_URL=https://api.yourdomain.com/api/v1
google_maps_key: --dart-define=GOOGLE_MAPS_KEY=...
```
