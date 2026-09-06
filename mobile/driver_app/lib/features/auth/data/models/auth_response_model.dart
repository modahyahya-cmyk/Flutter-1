import '../../domain/entities/auth_session.dart';
import 'driver_user_model.dart';

class AuthResponseModel {
  const AuthResponseModel({required this.accessToken, required this.refreshToken, required this.user});

  final String accessToken;
  final String refreshToken;
  final DriverUserModel user;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      user: DriverUserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  AuthSession toSession() => AuthSession(accessToken: accessToken, refreshToken: refreshToken, user: user);
}
