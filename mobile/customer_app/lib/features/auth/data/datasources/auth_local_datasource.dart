import '../../../../core/constants/storage_keys.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/storage/secure_storage.dart';
import '../models/user_model.dart';

/// Local data source for auth: persists the session token and a cached user.
class AuthLocalDataSource {
  AuthLocalDataSource({required this.localStorage, required this.secureStorage});

  final LocalStorage localStorage;
  final SecureStorage secureStorage;

  Future<void> saveTokens(AuthTokenPair tokens) async {
    await secureStorage.saveToken(tokens.accessToken);
    await secureStorage.saveRefreshToken(tokens.refreshToken);
  }

  Future<String?> getAccessToken() => secureStorage.getToken();

  Future<String?> getRefreshToken() => secureStorage.getRefreshToken();

  Future<void> cacheUser(UserModel user) async {
    await localStorage.saveJson(StorageKeys.cachedUser, user.toJson());
  }

  UserModel? getCachedUser() {
    final raw = localStorage.getJson(StorageKeys.cachedUser);
    if (raw == null) return null;
    return UserModel.fromJson(raw as Map<String, dynamic>);
  }

  Future<void> clear() async {
    await secureStorage.removeTokens();
    await localStorage.remove(StorageKeys.cachedUser);
  }
}

class AuthTokenPair {
  const AuthTokenPair({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;
}
