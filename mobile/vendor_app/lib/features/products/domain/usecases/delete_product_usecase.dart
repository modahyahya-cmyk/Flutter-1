import '../repositories/product_repository.dart';

class DeleteProductUseCase {
  DeleteProductUseCase({required this.repository});

  final ProductRepository repository;

  Future<void> call(int id) => repository.deleteProduct(id);
}
