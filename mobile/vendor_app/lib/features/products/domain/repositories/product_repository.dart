import '../entities/product.dart';

abstract class ProductRepository {
  Future<List<VendorProduct>> getProducts();
  Future<VendorProduct> createProduct(Map<String, dynamic> payload);
  Future<VendorProduct> updateProduct(int id, Map<String, dynamic> payload);
  Future<void> deleteProduct(int id);
}
