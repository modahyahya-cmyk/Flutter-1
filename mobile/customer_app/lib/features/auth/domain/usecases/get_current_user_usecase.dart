import '../../domain/entities/user.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  GetCurrentUserUseCase({required this.repository});

  final AuthRepository repository;

  Future<User?> call() => repository.getCurrentUser();
}
