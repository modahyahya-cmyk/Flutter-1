import '../entities/branch.dart';
import '../repositories/branch_repository.dart';

class GetBranchesUseCase {
  GetBranchesUseCase({required this.repository});

  final BranchRepository repository;

  Future<List<VendorBranch>> call() => repository.getBranches();
}
