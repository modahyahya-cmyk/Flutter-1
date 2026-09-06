import 'package:get/get.dart';

import '../../../../core/utils/logger.dart';
import '../../domain/entities/driver_user.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated }

class AuthController extends GetxController {
  AuthController({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
  });

  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  final Rx<AuthStatus> status = AuthStatus.initial.obs;
  final Rxn<DriverUser> user = Rxn<DriverUser>();
  final RxString error = ''.obs;

  Future<void> login(String phone, String password) async {
    status.value = AuthStatus.loading;
    error.value = '';

    final result = await loginUseCase(phone, password);
    result.fold(
      (failure) {
        error.value = failure.message;
        status.value = AuthStatus.unauthenticated;
      },
      (session) {
        user.value = session.user;
        status.value = AuthStatus.authenticated;
        AppLogger.info('Driver logged in', data: {'user_id': session.user.id});
      },
    );
  }

  Future<void> restoreSession() async {
    status.value = AuthStatus.loading;
    final result = await getCurrentUserUseCase();
    result.fold(
      (failure) {
        status.value = AuthStatus.unauthenticated;
      },
      (currentUser) {
        if (currentUser == null) {
          status.value = AuthStatus.unauthenticated;
        } else {
          user.value = currentUser;
          status.value = AuthStatus.authenticated;
        }
      },
    );
  }

  Future<void> logout() async {
    final result = await logoutUseCase();
    result.fold(
      (failure) => AppLogger.error('Logout failed', data: {'error': failure.message}),
      (_) {
        user.value = null;
        status.value = AuthStatus.unauthenticated;
      },
    );
  }
}
