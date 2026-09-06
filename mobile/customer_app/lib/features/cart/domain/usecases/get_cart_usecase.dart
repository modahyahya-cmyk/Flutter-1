import '../../domain/entities/cart.dart';
import '../repositories/cart_repository.dart';

class GetCartUseCase {
  GetCartUseCase({required this.repository});

  final CartRepository repository;

  Future<Cart> call() => repository.getCart();
}
