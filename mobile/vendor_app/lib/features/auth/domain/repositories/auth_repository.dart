import '../entities/auth_session.dart';
import '../entities/vendor_user.dart';

abstract class AuthRepository {
  Future<AuthSession> login(String identifier, String password);
  Future<void> logout();
  Future<VendorUser?> getCurrentUser();
}
