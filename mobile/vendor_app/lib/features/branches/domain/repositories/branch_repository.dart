import '../entities/branch.dart';

abstract class BranchRepository {
  Future<List<VendorBranch>> getBranches();
  Future<VendorBranch> createBranch(Map<String, dynamic> payload);
  Future<VendorBranch> updateBranch(int id, Map<String, dynamic> payload);
}
