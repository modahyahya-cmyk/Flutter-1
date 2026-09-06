import '../entities/auth_session.dart';
import '../entities/driver_user.dart';

abstract class AuthRepository {
  Future<AuthSession> login(String phone, String password);
  Future<void> logout();
  Future<DriverUser?> getCurrentUser();
}
