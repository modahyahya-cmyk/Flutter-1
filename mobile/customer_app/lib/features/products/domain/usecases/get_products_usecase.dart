import '../../domain/entities/product.dart';
import '../repositories/product_repository.dart';

class GetProductsUseCase {
  GetProductsUseCase({required this.repository});

  final ProductRepository repository;

  Future<List<Product>> call({Map<String, dynamic>? filters}) =>
      repository.getProducts(filters: filters);
}
