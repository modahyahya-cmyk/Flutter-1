import 'user.dart';

/// Successful authentication result: a bearer session plus the signed-in user.
class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final User user;
}
