import 'package:flutter/foundation.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/vendor_user.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated }

class AuthController extends ChangeNotifier {
  AuthController({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
  });

  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  AuthStatus status = AuthStatus.initial;
  VendorUser? user;
  Failure? failure;

  Future<void> login(String identifier, String password) async {
    status = AuthStatus.loading;
    failure = null;
    notifyListeners();

    try {
      final session = await loginUseCase(identifier, password);
      user = session.user;
      status = AuthStatus.authenticated;
    } on AppException catch (e) {
      failure = mapExceptionToFailure(e);
      status = AuthStatus.unauthenticated;
    } catch (_) {
      failure = const Failure.unknown();
      status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> restoreSession() async {
    status = AuthStatus.loading;
    notifyListeners();
    try {
      user = await getCurrentUserUseCase();
      status = user == null ? AuthStatus.unauthenticated : AuthStatus.authenticated;
    } catch (_) {
      status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await logoutUseCase();
    user = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void clearFailure() {
    failure = null;
    notifyListeners();
  }
}
