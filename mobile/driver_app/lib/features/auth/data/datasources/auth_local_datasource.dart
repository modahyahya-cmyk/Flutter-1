import '../../../../core/constants/storage_keys.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/storage/secure_storage.dart';
import '../models/driver_user_model.dart';

class AuthLocalDataSourceImpl {
  AuthLocalDataSourceImpl({required this.localStorage, required this.secureStorage});

  final LocalStorage localStorage;
  final SecureStorage secureStorage;

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await secureStorage.saveToken(accessToken);
    await secureStorage.saveRefreshToken(refreshToken);
  }

  Future<String?> getAccessToken() => secureStorage.getToken();

  Future<void> cacheUser(DriverUserModel user) async {
    await localStorage.saveJson(StorageKeys.cachedUser, user.toJson());
  }

  DriverUserModel? getCachedUser() {
    final raw = localStorage.getJson(StorageKeys.cachedUser);
    if (raw == null) return null;
    return DriverUserModel.fromJson(raw as Map<String, dynamic>);
  }

  Future<void> clear() async {
    await secureStorage.removeTokens();
    await localStorage.remove(StorageKeys.cachedUser);
  }
}
