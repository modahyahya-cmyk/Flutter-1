import '../entities/branch.dart';
import '../repositories/branch_repository.dart';

class CreateBranchUseCase {
  CreateBranchUseCase({required this.repository});

  final BranchRepository repository;

  Future<VendorBranch> call(Map<String, dynamic> payload) => repository.createBranch(payload);
}
