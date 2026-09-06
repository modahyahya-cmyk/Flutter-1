import os

def write_file(path, content):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content.strip())
    print(f"[✅] Created/Updated: {path}")

# 1. تحديث pubspec.yaml لتطبيق العميل
customer_pubspec = """
name: customer_app
description: "A secure production-grade delivery customer application."
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
write_file('mobile/customer_app/pubspec.yaml', customer_pubspec)

# 2. تحديث AndroidManifest.xml لتطبيق السائق
driver_manifest = """
<manifest xmlns:android="http://android.com"
    package="com.vendorhub.driver">

    <uses-permission android:name="android:permission.INTERNET" />
    <uses-permission android:name="android:permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android:permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android:permission.ACCESS_BACKGROUND_LOCATION" />
    <uses-permission android:name="android:permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android:permission.FOREGROUND_SERVICE_LOCATION" />
    <uses-permission android:name="android:permission.WAKE_LOCK" />

    <application
        android:label="VendorHub Driver"
        android:name="${applicationName}"
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
</manifest>
"""
write_file('mobile/driver_app/android/app/src/main/AndroidManifest.xml', driver_manifest)

# 3. تحديث api_client.dart لتطبيق العميل
api_client = """
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
write_file('mobile/customer_app/lib/core/network/api_client.dart', api_client)

# 4. تحديث order_model.dart لتطبيق العميل
order_model = """
import '../../../orders/domain/entities/order.dart';

class OrderModel extends Order {
  const OrderModel({
    required super.id,
    required super.status,
    required super.totalAmount,
    required super.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'PENDING',
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString()) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'total_amount': totalAmount,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
"""
write_file('mobile/customer_app/lib/features/orders/data/models/order_model.dart', order_model)
