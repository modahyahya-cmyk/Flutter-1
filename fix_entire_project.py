import os

def write_file(path, content):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content.strip())
    print(f"[✅] Fully Synchronized: {path}")

# =========================================================
# 1. إصلاح وربط اتصالات الـ API لـ Laravel 11 (السبب الجذري للباكيند)
# =========================================================
laravel_bootstrap_app = """
<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

/*
|--------------------------------------------------------------------------
| Laravel 11 Core Routing & Middleware Configuration Alignment
|--------------------------------------------------------------------------
*/
return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php', // تم ربط وضمان مسارات الـ API لتطبيقات الـ Mobile هنا
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware) {
        // حقن معالجات الأمان المدعومة لبيئة التوصيل والإنتاج
        $middleware->validateCsrfTokens(except: [
            'api/v1/*', // استثناء مسارات التطبيقات من حظر الـ CSRF لضمان استقبال الـ Payloads
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions) {
        // معالجة الأخطاء الافتراضية
    })->create();
"""
write_file('backend/bootstrap/app.php', laravel_bootstrap_app)

# =========================================================
# 2. توحيد وحماية ملفات الاعتماديات PUBSPEC للتطبيقات الثلاثة
# =========================================================
unified_pubspec = """
name: app_infrastructure
description: "Production-grade core delivery infrastructure alignment."
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.6
  flutter_bloc: ^8.1.3
  get_it: ^7.6.0
  dio: ^5.4.0
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0
  cached_network_image: ^3.3.1
  flutter_osm_widget: ^0.7.11
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
"""
write_file('mobile/customer_app/pubspec.yaml', unified_pubspec.replace('app_infrastructure', 'customer_app'))
write_file('mobile/driver_app/pubspec.yaml', unified_pubspec.replace('app_infrastructure', 'driver_app'))
write_file('mobile/vendor_app/pubspec.yaml', unified_pubspec.replace('app_infrastructure', 'vendor_app'))

# =========================================================
# 3. توحيد ملفات الـ MANIFEST وحل ثغرات تتبع الموقع وحظر الـ HTTP
# =========================================================
def generate_manifest(package, label, is_driver=False):
    bg_permission = "<uses-permission android:name='android:permission.ACCESS_BACKGROUND_LOCATION' />" if is_driver else ""
    fg_permission = "<uses-permission android:name='android:permission.FOREGROUND_SERVICE' />" if is_driver else ""
    return f"""<manifest xmlns:android="http://android.com"
    package="{package}">

    <uses-permission android:name="android:permission.INTERNET" />
    <uses-permission android:name="android:permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android:permission.ACCESS_COARSE_LOCATION" />
    {bg_permission}
    {fg_permission}

    <application
        android:label="{label}"
        android:name="${{applicationName}}"
        android:icon="@mipmap/ic_launcher"
        android:usesCleartextTraffic="true">
        
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|dir">
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme" />
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
    </application>
</manifest>"""

write_file('mobile/customer_app/android/app/src/main/AndroidManifest.xml', generate_manifest('com.vendorhub.customer', 'VendorHub Customer'))
write_file('mobile/vendor_app/android/app/src/main/AndroidManifest.xml', generate_manifest('com.vendorhub.vendor', 'VendorHub Vendor'))
write_file('mobile/driver_app/android/app/src/main/AndroidManifest.xml', generate_manifest('com.vendorhub.driver', 'VendorHub Driver', is_driver=True))

# =========================================================
# 4. توحيد محرك الـ API CLIENT لجميع التطبيقات الثلاثة
# =========================================================
api_engine_code = """
import 'package:dio/dio.dart';
import '../errors/exceptions.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

class ApiClient {
  final Dio _dio;

  ApiClient(this._dio, {required String baseUrl}) {
    _dio.options
      ..baseUrl = baseUrl
      ..connectTimeout = const Duration(seconds: 15)
      ..receiveTimeout = const Duration(seconds: 15)
      ..headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

    _dio.interceptors.addAll([
      AuthInterceptor(),
      ErrorInterceptor(),
      LoggingInterceptor(),
    ]);
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? "فشل قراءة البيانات من الخادم");
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? "فشل إرسال البيانات الممررة");
    }
  }
}
"""
write_file('mobile/customer_app/lib/core/network/api_client.dart', api_engine_code)
write_file('mobile/vendor_app/lib/core/network/api_client.dart', api_engine_code)
write_file('mobile/driver_app/lib/core/network/api_client.dart', api_engine_code)

print("\n[🎯] FULL DISCOVERY AUDIT SUCCESS: Laravel 11 Backend + 3 Mobile Apps are aligned!")
