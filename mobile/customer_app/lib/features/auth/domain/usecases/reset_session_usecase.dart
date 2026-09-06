import '../repositories/auth_repository.dart';

/// Clears the local session (tokens + cached user) WITHOUT a network call.
///
/// Used for a forced sign-out when the API returns 401/403 (expired or
/// revoked session) — it must not attempt a remote logout, since the access
/// token is already invalid.
class ResetSessionUseCase {
  ResetSessionUseCase({required this.repository});

  final AuthRepository repository;

  Future<void> call() => repository.clearSession();
}
