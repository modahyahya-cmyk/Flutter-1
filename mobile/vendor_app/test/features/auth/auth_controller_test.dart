import 'package:flutter_test/flutter_test.dart';
import 'package:vendor_app/features/auth/domain/entities/auth_session.dart';
import 'package:vendor_app/features/auth/domain/entities/vendor_user.dart';
import 'package:vendor_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:vendor_app/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:vendor_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:vendor_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:vendor_app/features/auth/presentation/controllers/auth_controller.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<AuthSession> login(String identifier, String password) {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {}

  @override
  Future<VendorUser?> getCurrentUser() async => null;
}

class FakeLoginUseCase extends LoginUseCase {
  FakeLoginUseCase(this.handler)
      : super(repository: _FakeAuthRepository());

  final Future<AuthSession> Function(String identifier, String password) handler;

  @override
  Future<AuthSession> call(String identifier, String password) {
    return handler(identifier, password);
  }
}

class FakeLogoutUseCase extends LogoutUseCase {
  FakeLogoutUseCase(this.handler)
      : super(repository: _FakeAuthRepository());

  final Future<void> Function() handler;

  @override
  Future<void> call() => handler();
}

class FakeGetCurrentUserUseCase extends GetCurrentUserUseCase {
  FakeGetCurrentUserUseCase(this.handler)
      : super(repository: _FakeAuthRepository());

  final Future<VendorUser?> Function() handler;

  @override
  Future<VendorUser?> call() => handler();
}

void main() {
  test('restoreSession sets unauthenticated when no user exists', () async {
    final controller = AuthController(
      loginUseCase: FakeLoginUseCase((_, __) async {
        throw UnimplementedError();
      }),
      logoutUseCase: FakeLogoutUseCase(() async {}),
      getCurrentUserUseCase: FakeGetCurrentUserUseCase(() async => null),
    );

    await controller.restoreSession();

    expect(controller.status, AuthStatus.unauthenticated);
    expect(controller.user, isNull);
    expect(controller.failure, isNull);
  });

  test('restoreSession sets authenticated when user exists', () async {
    const user = VendorUser(
      id: 1,
      email: 'vendor@example.com',
      firstName: 'Test',
      lastName: 'Vendor',
    );

    final controller = AuthController(
      loginUseCase: FakeLoginUseCase((_, __) async {
        throw UnimplementedError();
      }),
      logoutUseCase: FakeLogoutUseCase(() async {}),
      getCurrentUserUseCase: FakeGetCurrentUserUseCase(() async => user),
    );

    await controller.restoreSession();

    expect(controller.status, AuthStatus.authenticated);
    expect(controller.user, same(user));
  });

  test('login sets authenticated status and user on success', () async {
    const user = VendorUser(
      id: 1,
      email: 'vendor@example.com',
      firstName: 'Test',
      lastName: 'Vendor',
    );

    final session = AuthSession(
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
      user: user,
    );

    String? receivedIdentifier;
    String? receivedPassword;

    final controller = AuthController(
      loginUseCase: FakeLoginUseCase((identifier, password) async {
        receivedIdentifier = identifier;
        receivedPassword = password;
        return session;
      }),
      logoutUseCase: FakeLogoutUseCase(() async {}),
      getCurrentUserUseCase: FakeGetCurrentUserUseCase(() async => null),
    );

    await controller.login('vendor@example.com', 'password');

    expect(receivedIdentifier, 'vendor@example.com');
    expect(receivedPassword, 'password');
    expect(controller.status, AuthStatus.authenticated);
    expect(controller.user, same(user));
    expect(controller.failure, isNull);
  });

  test('login sets unauthenticated status and failure on application error', () async {
    final controller = AuthController(
      loginUseCase: FakeLoginUseCase((_, __) async {
        throw Exception('login failed');
      }),
      logoutUseCase: FakeLogoutUseCase(() async {}),
      getCurrentUserUseCase: FakeGetCurrentUserUseCase(() async => null),
    );

    await controller.login('vendor@example.com', 'wrong-password');

    expect(controller.status, AuthStatus.unauthenticated);
    expect(controller.user, isNull);
    expect(controller.failure, isNotNull);
  });

  test('logout clears the authenticated user and updates status', () async {
    var logoutCalled = false;

    final controller = AuthController(
      loginUseCase: FakeLoginUseCase((_, __) async {
        throw UnimplementedError();
      }),
      logoutUseCase: FakeLogoutUseCase(() async {
        logoutCalled = true;
      }),
      getCurrentUserUseCase: FakeGetCurrentUserUseCase(() async => null),
    );

    await controller.logout();

    expect(logoutCalled, isTrue);
    expect(controller.status, AuthStatus.unauthenticated);
    expect(controller.user, isNull);
  });
}
