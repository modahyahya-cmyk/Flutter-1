import '../../domain/entities/cart.dart';
import '../repositories/cart_repository.dart';

class RemoveFromCartUseCase {
  RemoveFromCartUseCase({required this.repository});

  final CartRepository repository;

  Future<Cart> call(int cartItemId) => repository.removeItem(cartItemId);
}
