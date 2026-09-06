import '../entities/branch.dart';
import '../repositories/branch_repository.dart';

class UpdateBranchUseCase {
  UpdateBranchUseCase({required this.repository});

  final BranchRepository repository;

  Future<VendorBranch> call(int id, Map<String, dynamic> payload) =>
      repository.updateBranch(id, payload);
}
