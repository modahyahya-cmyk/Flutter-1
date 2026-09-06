import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class SecureStorage {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> saveRefreshToken(String token);
  Future<String?> getRefreshToken();
  Future<void> clearAll();
  Future<void> removeTokens();
}

class SecureStorageImpl implements SecureStorage {
  SecureStorageImpl({required this.secureStorage});

  final FlutterSecureStorage secureStorage;

  static const _tokenKey = 'auth_access_token';
  static const _refreshKey = 'auth_refresh_token';

  @override
  Future<void> saveToken(String token) => secureStorage.write(key: _tokenKey, value: token);

  @override
  Future<String?> getToken() => secureStorage.read(key: _tokenKey);

  @override
  Future<void> saveRefreshToken(String token) => secureStorage.write(key: _refreshKey, value: token);

  @override
  Future<String?> getRefreshToken() => secureStorage.read(key: _refreshKey);

  @override
  Future<void> removeTokens() async {
    await secureStorage.delete(key: _tokenKey);
    await secureStorage.delete(key: _refreshKey);
  }

  @override
  Future<void> clearAll() async {
    await removeTokens();
  }
}
