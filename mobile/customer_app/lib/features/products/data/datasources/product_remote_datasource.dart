import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/product_model.dart';

class ProductRemoteDataSource {
  ProductRemoteDataSource(this.apiClient);

  final ApiClient apiClient;

  Future<List<ProductModel>> getProducts({Map<String, dynamic>? filters}) async {
    final data = await apiClient.get(ApiEndpoints.products, queryParameters: filters);
    final list = ((data as Map<String, dynamic>)['data'] as List).cast<Map<String, dynamic>>();

    return list.map(ProductModel.fromJson).toList();
  }

  Future<List<ProductModel>> getFeatured() async {
    final data = await apiClient.get(ApiEndpoints.featuredProducts);
    final list = (data as Map<String, dynamic>)['data'] as List;
    return list.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ProductModel> getProductDetail(int id) async {
    final data = await apiClient.get(ApiEndpoints.productDetail(id));
    final product = (data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return ProductModel.fromJson(product);
  }
}
