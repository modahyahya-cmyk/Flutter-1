import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/cart_model.dart';

class CartRemoteDataSource {
  CartRemoteDataSource(this.apiClient);

  final ApiClient apiClient;

  Future<CartModel> getCart() async {
    final data = await apiClient.get(ApiEndpoints.cart);
    final json = _extractData(data);
    return CartModel.fromJson(json);
  }

  Future<CartItemModel> add({
    required int productId,
    required int quantity,
    int? variantId,
  }) async {
    final data = await apiClient.post(
      ApiEndpoints.cartItems,
      data: {
        'product_id': productId,
        'quantity': quantity,
        if (variantId != null) 'product_variant_id': variantId,
      },
    );

    final json = _extractData(data);

    if (_looksLikeCartItem(json)) {
      return CartItemModel.fromJson(json);
    }

    final cart = CartModel.fromJson(json);

    if (cart.items.isEmpty) {
      throw StateError(
        'Cart API returned a cart without items after adding product.',
      );
    }

    final item = cart.items.last;

    return CartItemModel(
      id: item.id,
      productId: item.productId,
      quantity: item.quantity,
      unitPrice: item.unitPrice,
      totalAmount: item.totalAmount,
      variantId: item.variantId,
      options: item.options,
      productName: item.productName,
      productImage: item.productImage,
    );
  }

  Future<void> update(int cartItemId, int quantity) async {
    await apiClient.put(
      ApiEndpoints.cartItem(cartItemId),
      data: {'quantity': quantity},
    );
  }

  Future<void> remove(int cartItemId) async {
    await apiClient.delete(
      ApiEndpoints.cartItem(cartItemId),
    );
  }

  Future<void> clear() async {
    await apiClient.delete(
      ApiEndpoints.cart,
    );
  }

  Map<String, dynamic> _extractData(dynamic response) {
    if (response is Map<String, dynamic>) {
      final data = response['data'];

      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }

      return response;
    }

    throw FormatException(
      'Invalid cart API response: ${response.runtimeType}',
    );
  }

  bool _looksLikeCartItem(Map<String, dynamic> json) {
    return json.containsKey('product_id') &&
        json.containsKey('quantity') &&
        (json.containsKey('unit_price') ||
            json.containsKey('total_amount'));
  }
}
