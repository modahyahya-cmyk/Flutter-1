import '../../domain/entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts({Map<String, dynamic>? filters});

  Future<Product> getProductDetail(int id);
}
