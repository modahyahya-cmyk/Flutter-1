import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/storage_keys.dart';

/// Abstraction for encrypted persistence (tokens, credentials).
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

  @override
  Future<void> saveToken(String token) async {
    await secureStorage.write(key: StorageKeys.accessToken, value: token);
  }

  @override
  Future<String?> getToken() async {
    return secureStorage.read(key: StorageKeys.accessToken);
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    await secureStorage.write(key: StorageKeys.refreshToken, value: token);
  }

  @override
  Future<String?> getRefreshToken() async {
    return secureStorage.read(key: StorageKeys.refreshToken);
  }

  @override
  Future<void> clearAll() async {
    await secureStorage.deleteAll();
  }

  @override
  Future<void> removeTokens() async {
    await secureStorage.delete(key: StorageKeys.accessToken);
    await secureStorage.delete(key: StorageKeys.refreshToken);
  }
}
