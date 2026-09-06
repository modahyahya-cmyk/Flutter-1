// test/widget_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:customer_app/main.dart'; // ensure this package name matches mobile/customer_app/pubspec.yaml
import 'package:shared_preferences/shared_preferences.dart';
import 'package:customer_app/config/dependency_injection.dart' as di;
import 'package:customer_app/core/storage/secure_storage.dart';

// lightweight in-memory secure storage used during tests
class FakeSecureStorage implements SecureStorage {
  final Map<String, String?> _storage = {};
  @override Future<void> clearAll() async => _storage.clear();
  @override Future<String?> getRefreshToken() async => _storage['refreshToken'];
  @override Future<String?> getToken() async => _storage['accessToken'];
  @override Future<void> removeTokens() async {
    _storage.remove('accessToken');
    _storage.remove('refreshToken');
  }
  @override Future<void> saveRefreshToken(String token) async => _storage['refreshToken'] = token;
  @override Future<void> saveToken(String token) async => _storage['accessToken'] = token;
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    final fakeSecureStorage = FakeSecureStorage();

    await di.setupDependencyInjection(
      sharedPreferencesOverride: await SharedPreferences.getInstance(),
      secureStorageOverride: fakeSecureStorage,
    );
  });

  tearDownAll(() async {
    await di.getIt.reset();
  });

  testWidgets('App builds', (WidgetTester tester) async {
    // Use the actual root widget defined in your app:
    await tester.pumpWidget(const VendorHubApp());

    // advance a couple frames instead of pumpAndSettle
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(VendorHubApp), findsOneWidget);
  });
}
