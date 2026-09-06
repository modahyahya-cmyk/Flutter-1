import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/branch_model.dart';

class BranchRemoteDataSource {
  BranchRemoteDataSource(this.apiClient);

  final ApiClient apiClient;

  Future<List<BranchModel>> getBranches() async {
    final data = await apiClient.get(ApiEndpoints.vendorBranches);
    return ((data as Map<String, dynamic>)['data'] as List).cast<Map<String, dynamic>>().map(BranchModel.fromJson).toList();
  }

  Future<BranchModel> create(Map<String, dynamic> payload) async {
    final data = await apiClient.post(ApiEndpoints.vendorBranches, data: payload);
    return BranchModel.fromJson((data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  Future<BranchModel> update(int id, Map<String, dynamic> payload) async {
    final data = await apiClient.put(ApiEndpoints.branchDetail(id), data: payload);
    return BranchModel.fromJson((data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }
}
