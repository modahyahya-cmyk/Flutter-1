import '../../domain/entities/auth_session.dart';
import '../../domain/entities/user.dart';

/// Domain boundary for authentication. Implementations combine remote + local
/// data sources and network availability.
abstract class AuthRepository {
  Future<AuthSession> login(String identifier, String password);

  Future<AuthSession> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phone,
  });

  Future<void> logout();

  /// Clears only the locally persisted session (tokens + cached user).
  /// Network-free — used for a forced sign-out on 401/403.
  Future<void> clearSession();

  Future<User?> getCurrentUser();
}
