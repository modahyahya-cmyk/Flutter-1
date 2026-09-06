<?php

declare(strict_types=1);

return [
    /*
    |--------------------------------------------------------------------------
    | WHITE-LABEL APPLICATION CONFIGURATION
    |--------------------------------------------------------------------------
    | This is the SINGLE SOURCE OF TRUTH for all white-label configuration.
    | Modifying this file (or the env vars it reads) rebrands the entire
    | application ecosystem: backend + customer/vendor/driver apps.
    */

    'app_name' => env('APP_NAME', 'VendorHub'),
    'app_tagline' => env('APP_TAGLINE', 'Multi-Vendor E-Commerce & Delivery Platform'),
    'company_name' => env('COMPANY_NAME', 'VendorHub Technologies Inc.'),
    'support_email' => env('SUPPORT_EMAIL', 'support@vendorhub.com'),
    'support_phone' => env('SUPPORT_PHONE', '+1-800-VENDORHUB'),

    /*
    |--------------------------------------------------------------------------
    | Branding & Theme
    |--------------------------------------------------------------------------
    */
    'branding' => [
        'primary_color' => env('BRAND_PRIMARY_COLOR', '#6366F1'),
        'secondary_color' => env('BRAND_SECONDARY_COLOR', '#EC4899'),
        'accent_color' => env('BRAND_ACCENT_COLOR', '#F59E0B'),
        'logo_url' => env('BRAND_LOGO_URL', 'https://api.vendorhub.com/assets/logo.png'),
        'favicon_url' => env('BRAND_FAVICON_URL', 'https://api.vendorhub.com/assets/favicon.ico'),
    ],

    /*
    |--------------------------------------------------------------------------
    | Feature Flags
    |--------------------------------------------------------------------------
    */
    'features' => [
        'enable_video_commerce' => (bool) env('FEATURE_VIDEO_COMMERCE', true),
        'enable_subscriptions' => (bool) env('FEATURE_SUBSCRIPTIONS', true),
        'enable_multi_branch' => (bool) env('FEATURE_MULTI_BRANCH', true),
        'enable_thermal_printing' => (bool) env('FEATURE_THERMAL_PRINTING', true),
        'enable_driver_earnings_ledger' => (bool) env('FEATURE_DRIVER_EARNINGS', true),
        'enable_vendor_verification' => (bool) env('FEATURE_VENDOR_VERIFICATION', true),
        'enable_customer_reviews' => (bool) env('FEATURE_CUSTOMER_REVIEWS', true),
        'enable_live_chat' => (bool) env('FEATURE_LIVE_CHAT', false),
        'enable_loyalty_points' => (bool) env('FEATURE_LOYALTY_POINTS', false),
    ],

    /*
    |--------------------------------------------------------------------------
    | Payment Gateway Configuration
    |--------------------------------------------------------------------------
    */
    'payment_gateways' => [
        'default' => env('DEFAULT_PAYMENT_GATEWAY', 'stripe'),

        'stripe' => [
            'enabled' => (bool) env('STRIPE_ENABLED', true),
            'public_key' => env('STRIPE_PUBLIC_KEY', ''),
            'secret_key' => env('STRIPE_SECRET_KEY', ''),
            'webhook_secret' => env('STRIPE_WEBHOOK_SECRET', ''),
        ],

        'paystack' => [
            'enabled' => (bool) env('PAYSTACK_ENABLED', false),
            'public_key' => env('PAYSTACK_PUBLIC_KEY', ''),
            'secret_key' => env('PAYSTACK_SECRET_KEY', ''),
        ],

        'razorpay' => [
            'enabled' => (bool) env('RAZORPAY_ENABLED', false),
            'key_id' => env('RAZORPAY_KEY_ID', ''),
            'key_secret' => env('RAZORPAY_KEY_SECRET', ''),
        ],

        'paypal' => [
            'enabled' => (bool) env('PAYPAL_ENABLED', false),
            'client_id' => env('PAYPAL_CLIENT_ID', ''),
            'secret' => env('PAYPAL_SECRET', ''),
            'mode' => env('PAYPAL_MODE', 'sandbox'),
        ],
    ],

    /*
    |--------------------------------------------------------------------------
    | Notification Services
    |--------------------------------------------------------------------------
    */
    'notifications' => [
        'default_channel' => env('DEFAULT_NOTIFICATION_CHANNEL', 'firebase'),

        'firebase' => [
            'enabled' => (bool) env('FIREBASE_ENABLED', true),
            'credentials_path' => env('FIREBASE_CREDENTIALS', storage_path('app/firebase-credentials.json')),
        ],

        'onesignal' => [
            'enabled' => (bool) env('ONESIGNAL_ENABLED', false),
            'app_id' => env('ONESIGNAL_APP_ID', ''),
            'rest_api_key' => env('ONESIGNAL_REST_API_KEY', ''),
        ],

        'twilio_sms' => [
            'enabled' => (bool) env('TWILIO_ENABLED', false),
            'account_sid' => env('TWILIO_ACCOUNT_SID', ''),
            'auth_token' => env('TWILIO_AUTH_TOKEN', ''),
            'from_number' => env('TWILIO_FROM_NUMBER', ''),
        ],
    ],

    /*
    |--------------------------------------------------------------------------
    | Map & Geolocation Configuration
    |--------------------------------------------------------------------------
    */
    'maps' => [
        'default_provider' => env('MAP_PROVIDER', 'openstreetmap'),

        'openstreetmap' => [
            'enabled' => true,
            'tile_server' => env('OSM_TILE_SERVER', 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png'),
            'attribution' => '© OpenStreetMap contributors',
        ],

        'google_maps' => [
            'enabled' => (bool) env('GOOGLE_MAPS_ENABLED', false),
            'api_key' => env('GOOGLE_MAPS_API_KEY', ''),
        ],

        'mapbox' => [
            'enabled' => (bool) env('MAPBOX_ENABLED', false),
            'access_token' => env('MAPBOX_ACCESS_TOKEN', ''),
            'style_url' => env('MAPBOX_STYLE_URL', 'mapbox://styles/mapbox/streets-v11'),
        ],
    ],

    /*
    |--------------------------------------------------------------------------
    | Business Logic Configuration
    |--------------------------------------------------------------------------
    */
    'business' => [
        'commission_rate' => (float) env('PLATFORM_COMMISSION_RATE', 15.0),
        'delivery_fee_type' => env('DELIVERY_FEE_TYPE', 'distance'),
        'base_delivery_fee' => (float) env('BASE_DELIVERY_FEE', 5.0),
        'per_km_rate' => (float) env('PER_KM_RATE', 0.5),
        'min_order_amount' => (float) env('MIN_ORDER_AMOUNT', 10.0),
        'max_delivery_radius' => (int) env('MAX_DELIVERY_RADIUS', 20),
        'auto_assign_driver' => (bool) env('AUTO_ASSIGN_DRIVER', true),
        'vendor_approval_required' => (bool) env('VENDOR_APPROVAL_REQUIRED', true),
        'driver_approval_required' => (bool) env('DRIVER_APPROVAL_REQUIRED', true),
    ],

    /*
    |--------------------------------------------------------------------------
    | Security & Rate Limiting
    |--------------------------------------------------------------------------
    */
    'security' => [
        'rate_limit_per_minute' => (int) env('API_RATE_LIMIT', 60),
        'jwt_ttl' => (int) env('JWT_TTL', 1440),
        'jwt_refresh_ttl' => (int) env('JWT_REFRESH_TTL', 20160),
        'password_min_length' => (int) env('PASSWORD_MIN_LENGTH', 8),
        'require_email_verification' => (bool) env('REQUIRE_EMAIL_VERIFICATION', true),
        'require_phone_verification' => (bool) env('REQUIRE_PHONE_VERIFICATION', false),
        'allowed_file_extensions' => ['jpg', 'jpeg', 'png', 'gif', 'pdf', 'mp4', 'mov'],
        'max_file_size_mb' => (int) env('MAX_FILE_SIZE_MB', 10),
    ],

    /*
    |--------------------------------------------------------------------------
    | Storage & CDN Configuration
    |--------------------------------------------------------------------------
    */
    'storage' => [
        'default_driver' => env('FILESYSTEM_DRIVER', 'local'),

        's3' => [
            'key' => env('AWS_ACCESS_KEY_ID', ''),
            'secret' => env('AWS_SECRET_ACCESS_KEY', ''),
            'region' => env('AWS_DEFAULT_REGION', 'us-east-1'),
            'bucket' => env('AWS_BUCKET', ''),
        ],

        'digitalocean' => [
            'key' => env('DO_SPACES_KEY', ''),
            'secret' => env('DO_SPACES_SECRET', ''),
            'region' => env('DO_SPACES_REGION', 'nyc3'),
            'bucket' => env('DO_SPACES_BUCKET', ''),
        ],

        'cdn_url' => env('CDN_URL'),
    ],

    /*
    |--------------------------------------------------------------------------
    | Email Configuration
    |--------------------------------------------------------------------------
    */
    'email' => [
        'from_address' => env('MAIL_FROM_ADDRESS', 'noreply@vendorhub.com'),
        'from_name' => env('MAIL_FROM_NAME', 'VendorHub'),
    ],

    /*
    |--------------------------------------------------------------------------
    | Video Commerce Configuration
    |--------------------------------------------------------------------------
    */
    'video_commerce' => [
        'max_video_duration_seconds' => (int) env('MAX_VIDEO_DURATION', 60),
        'max_video_size_mb' => (int) env('MAX_VIDEO_SIZE_MB', 50),
        'video_encoding_queue' => env('VIDEO_ENCODING_QUEUE', 'high-priority'),
        'autoplay_videos' => (bool) env('AUTOPLAY_VIDEOS', true),
    ],

    /*
    |--------------------------------------------------------------------------
    | Currency & Localization
    |--------------------------------------------------------------------------
    */
    'localization' => [
        'default_currency' => env('DEFAULT_CURRENCY', 'USD'),
        'currency_symbol' => env('CURRENCY_SYMBOL', '$'),
        'currency_position' => env('CURRENCY_POSITION', 'before'),
        'decimal_separator' => env('DECIMAL_SEPARATOR', '.'),
        'thousand_separator' => env('THOUSAND_SEPARATOR', ','),
        'default_timezone' => env('APP_TIMEZONE', 'UTC'),
        'default_locale' => env('APP_LOCALE', 'en'),
        'supported_locales' => ['en', 'es', 'fr', 'de', 'ar'],
    ],
];
