import '../../../../core/constants/storage_keys.dart';
import '../../../../core/storage/local_storage.dart';
import '../../domain/entities/cart.dart';
import '../models/cart_model.dart';

/// Offline cache for the cart so the previous state survives app restarts and
/// brief connectivity loss.
class CartLocalDataSource {
  CartLocalDataSource({required this.localStorage});

  final LocalStorage localStorage;

  Future<void> cacheCart(Cart cart) async {
    await localStorage.saveJson(StorageKeys.cachedCart, _toJson(cart));
  }

  Cart? getCachedCart() {
    final raw = localStorage.getJson(StorageKeys.cachedCart);
    if (raw == null) return null;
    return _fromJson(raw as Map<String, dynamic>);
  }

  Future<void> clear() async {
    await localStorage.remove(StorageKeys.cachedCart);
  }

  Map<String, dynamic> _toJson(Cart cart) => {
        'id': cart.id,
        'subtotal': cart.subtotal,
        'tax_amount': cart.taxAmount,
        'total_amount': cart.totalAmount,
        'items': cart.items
            .map((i) => {
                  'id': i.id,
                  'product_id': i.productId,
                  'variant_id': i.variantId,
                  'quantity': i.quantity,
                  'unit_price': i.unitPrice,
                  'total_amount': i.totalAmount,
                  'product': {
                    'name': i.productName,
                    'thumbnail': i.productImage,
                  },
                })
            .toList(),
      };

  Cart _fromJson(Map<String, dynamic> json) => CartModel.fromJson(json);
}
