import '../../domain/entities/auth_session.dart';
import 'user_model.dart';

/// Raw API payload for authentication: `{access_token, refresh_token, user}`.
class AuthResponseModel {
  const AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final UserModel user;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  AuthSession toSession() {
    return AuthSession(accessToken: accessToken, refreshToken: refreshToken, user: user);
  }
}
