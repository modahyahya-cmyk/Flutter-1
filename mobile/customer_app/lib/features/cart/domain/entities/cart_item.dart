/// A single line item in the cart.
class CartItem {
  const CartItem({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
    this.variantId,
    this.options,
    this.productName,
    this.productImage,
  });

  final int id;
  final int productId;
  final int? variantId;
  final int quantity;
  final double unitPrice;
  final double totalAmount;
  final Map<String, dynamic>? options;
  final String? productName;
  final String? productImage;
}
