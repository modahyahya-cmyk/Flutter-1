import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/driver_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  final AuthRemoteDataSourceImpl remoteDataSource;
  final AuthLocalDataSourceImpl localDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<AuthSession> login(String phone, String password) async {
    if (!await networkInfo.isConnected) {
      throw const NetworkException(message: 'No internet connection');
    }
    final response = await remoteDataSource.login(phone, password);
    await localDataSource.saveTokens(response.accessToken, response.refreshToken);
    await localDataSource.cacheUser(response.user);
    return response.toSession();
  }

  @override
  Future<void> logout() async {
    try {
      await remoteDataSource.logout();
    } finally {
      await localDataSource.clear();
    }
  }

  @override
  Future<DriverUser?> getCurrentUser() async {
    final token = await localDataSource.getAccessToken();
    if (token == null || token.isEmpty) return null;
    return localDataSource.getCachedUser();
  }
}
