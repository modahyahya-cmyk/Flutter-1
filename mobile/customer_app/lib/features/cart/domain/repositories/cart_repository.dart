import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_item.dart';

abstract class CartRepository {
  Future<Cart> getCart();
  Future<CartItem> addItem(int productId, int quantity, {int? variantId});
  Future<CartItem> updateItem(int cartItemId, int quantity);
  Future<Cart> removeItem(int cartItemId);
  Future<Cart> clearCart();
}
