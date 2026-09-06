import '../../domain/entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  RegisterUseCase({required this.repository});

  final AuthRepository repository;

  Future<AuthSession> call({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phone,
  }) {
    return repository.register(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      phone: phone,
    );
  }
}
