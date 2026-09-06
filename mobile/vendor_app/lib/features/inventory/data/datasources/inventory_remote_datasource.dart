import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';

class InventoryRemoteDataSource {
  InventoryRemoteDataSource(this.apiClient);

  final ApiClient apiClient;

  Future<List<Map<String, dynamic>>> fetchInventory() async {
    final data = await apiClient.get(ApiEndpoints.vendorProducts);
    return ((data as Map<String, dynamic>)['data'] as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> adjustStock(int id, int delta, {String? reason}) async {
    final data = await apiClient.post(
      ApiEndpoints.productDetail(id).replaceFirst(RegExp(r'$'), '/stock'),
    );
    return data as Map<String, dynamic>;
  }
}
