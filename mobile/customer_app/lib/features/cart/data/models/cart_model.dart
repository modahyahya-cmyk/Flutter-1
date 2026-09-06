import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_item.dart';

class CartItemModel extends CartItem {
  const CartItemModel({
    required super.id,
    required super.productId,
    required super.quantity,
    required super.unitPrice,
    required super.totalAmount,
    super.variantId,
    super.options,
    super.productName,
    super.productImage,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final productJson = json['product'];
    final product = productJson is Map
        ? Map<String, dynamic>.from(productJson)
        : null;

    return CartItemModel(
      id: _asInt(json['id']),
      productId: _asInt(json['product_id']),
      variantId: _asNullableInt(
        json['variant_id'] ?? json['product_variant_id'],
      ),
      quantity: _asInt(json['quantity']),
      unitPrice: _asDouble(json['unit_price']),
      totalAmount: _asDouble(json['total_amount']),
      options: _asMap(json['options']),
      productName: product?['name']?.toString(),
      productImage:
          product?['thumbnail']?.toString() ??
          product?['main_image']?.toString(),
    );
  }
}

class CartModel extends Cart {
  const CartModel({
    required super.id,
    required super.items,
    super.subtotal,
    super.taxAmount,
    super.totalAmount,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];

    final items = rawItems is List
        ? rawItems
            .whereType<Map>()
            .map(
              (item) => CartItemModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList(growable: false)
        : const <CartItemModel>[];

    return CartModel(
      id: _asInt(json['id']),
      items: items,
      subtotal: _asDouble(json['subtotal']),
      taxAmount: _asDouble(json['tax_amount']),
      totalAmount: _asDouble(json['total_amount']),
    );
  }
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

int? _asNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

double _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0.0;
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return null;
}
