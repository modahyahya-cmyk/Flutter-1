import '../entities/product.dart';
import '../repositories/product_repository.dart';

class UpdateProductUseCase {
  UpdateProductUseCase({required this.repository});

  final ProductRepository repository;

  Future<VendorProduct> call(int id, Map<String, dynamic> payload) =>
      repository.updateProduct(id, payload);
}
