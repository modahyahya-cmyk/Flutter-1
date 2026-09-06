import '../../domain/entities/cart_item.dart';
import '../repositories/cart_repository.dart';

class AddToCartUseCase {
  AddToCartUseCase({required this.repository});

  final CartRepository repository;

  Future<CartItem> call(int productId, int quantity, {int? variantId}) {
    return repository.addItem(productId, quantity, variantId: variantId);
  }
}
