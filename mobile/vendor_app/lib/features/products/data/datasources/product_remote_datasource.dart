import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/product_model.dart';

class ProductRemoteDataSource {
  ProductRemoteDataSource(this.apiClient);

  final ApiClient apiClient;

  Future<List<ProductModel>> getProducts() async {
    final data = await apiClient.get(ApiEndpoints.vendorProducts);
    final list = ((data as Map<String, dynamic>)['data'] as List).cast<Map<String, dynamic>>();
    return list.map(ProductModel.fromJson).toList();
  }

  Future<ProductModel> create(Map<String, dynamic> payload) async {
    final data = await apiClient.post(ApiEndpoints.vendorProducts, data: payload);
    return ProductModel.fromJson((data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  Future<ProductModel> update(int id, Map<String, dynamic> payload) async {
    final data = await apiClient.put(ApiEndpoints.productDetail(id), data: payload);
    return ProductModel.fromJson((data as Map<String, dynamic>)['data'] as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    await apiClient.delete(ApiEndpoints.productDetail(id));
  }
}
