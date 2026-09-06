import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  LoginUseCase({required this.repository});

  final AuthRepository repository;

  Future<AuthSession> call(String identifier, String password) => repository.login(identifier, password);
}
