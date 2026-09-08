import 'package:flutter/foundation.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/reset_session_usecase.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated }

class AuthController extends ChangeNotifier {
  AuthController({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.resetSessionUseCase,
  });

  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final ResetSessionUseCase resetSessionUseCase;

  AuthStatus status = AuthStatus.initial;
  User? user;
  Failure? failure;

  Future<void> login(String identifier, String password) async {
    _start();
    try {
      final session = await loginUseCase(identifier, password);
      user = session.user;
      status = AuthStatus.authenticated;
    } on Object catch (e) {
      failure = _map(e);
      status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phone,
  }) async {
    _start();
    try {
      final session = await registerUseCase(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        phone: phone,
      );
      user = session.user;
      status = AuthStatus.authenticated;
    } on Object catch (e) {
      failure = _map(e);
      status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> restoreSession() async {
    status = AuthStatus.loading;
    notifyListeners();

    try {
      user = await getCurrentUserUseCase()
          .timeout(const Duration(seconds: 10));
      status = user == null
          ? AuthStatus.unauthenticated
          : AuthStatus.authenticated;
    } on Object catch (e) {
      failure = _map(e);
      user = null;
      status = AuthStatus.unauthenticated;
    }

    notifyListeners();
  }

  Future<void> logout() async {
    await logoutUseCase();
    user = null;
    failure = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  /// Forced sign-out triggered by a 401/403 response: clears the local
  /// session only (no network call, since the access token is already
  /// invalid). The router's auth guard redirects the user to login.
  Future<void> forceLogout() async {
    await resetSessionUseCase();
    user = null;
    failure = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void clearFailure() {
    failure = null;
    notifyListeners();
  }

  void _start() {
    status = AuthStatus.loading;
    failure = null;
  }

  Failure _map(Object e) {
    if (e is AppException) return mapExceptionToFailure(e);
    return const Failure.unknown();
  }
}
