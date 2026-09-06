import 'package:equatable/equatable.dart';

import 'driver_user.dart';

class AuthSession extends Equatable {
  const AuthSession({required this.accessToken, required this.refreshToken, required this.user});

  final String accessToken;
  final String refreshToken;
  final DriverUser user;

  @override
  List<Object?> get props => [accessToken, refreshToken, user];
}
