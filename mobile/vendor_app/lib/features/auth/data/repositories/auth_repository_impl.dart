import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/vendor_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<AuthSession> login(String identifier, String password) async {
    if (!await networkInfo.isConnected) {
      throw const NetworkException(message: 'No internet connection');
    }
    final response = await remoteDataSource.login(identifier, password);
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
  Future<VendorUser?> getCurrentUser() async {
    final token = await localDataSource.getAccessToken();
    if (token == null || token.isEmpty) return null;
    return localDataSource.getCachedUser();
  }
}
