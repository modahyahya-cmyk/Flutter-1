import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/earnings_summary_model.dart';

class EarningsRemoteDataSource {
  EarningsRemoteDataSource(this.apiClient);

  final ApiClient apiClient;

  Future<EarningsSummaryModel> getSummary() async {
    final data = await apiClient.get(ApiEndpoints.vendorEarnings);
    return EarningsSummaryModel.fromJson((data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }
}
