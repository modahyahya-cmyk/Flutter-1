import '../entities/vendor_user.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  GetCurrentUserUseCase({required this.repository});

  final AuthRepository repository;

  Future<VendorUser?> call() => repository.getCurrentUser();
}
