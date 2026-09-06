class OrderItem {
  const OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
    this.variantId,
    this.variantName,
    this.image,
    this.options,
  });

  final int id;
  final int productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalAmount;
  final int? variantId;
  final String? variantName;
  final String? image;
  final Map<String, dynamic>? options;
}
