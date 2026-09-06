import '../../domain/entities/product.dart';
import '../repositories/product_repository.dart';

class GetProductDetailUseCase {
  GetProductDetailUseCase({required this.repository});

  final ProductRepository repository;

  Future<Product> call(int id) => repository.getProductDetail(id);
}
