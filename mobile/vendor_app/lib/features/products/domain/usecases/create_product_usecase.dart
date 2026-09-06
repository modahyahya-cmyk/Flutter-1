import '../entities/product.dart';
import '../repositories/product_repository.dart';

class CreateProductUseCase {
  CreateProductUseCase({required this.repository});

  final ProductRepository repository;

  Future<VendorProduct> call(Map<String, dynamic> payload) => repository.createProduct(payload);
}
