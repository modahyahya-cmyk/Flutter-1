class InventoryItem {
  const InventoryItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.quantity,
    this.unit,
    this.minStockLevel = 0,
    this.price,
  });

  final int id;
  final String name;
  final String sku;
  final int quantity;
  final String? unit;
  final int minStockLevel;
  final double? price;

  bool get isLowStock => quantity <= minStockLevel;
  bool get isOutOfStock => quantity <= 0;

  Map<String, dynamic> toLocalJson() => {
        'id': id,
        'name': name,
        'sku': sku,
        'quantity': quantity,
        'unit': unit,
        'min_stock_level': minStockLevel,
        'price': price,
      };

  factory InventoryItem.fromLocalJson(Map<String, dynamic> json) => InventoryItem(
        id: json['id'] as int,
        name: json['name'] as String,
        sku: json['sku'] as String,
        quantity: json['quantity'] as int,
        unit: json['unit'] as String?,
        minStockLevel: json['min_stock_level'] as int? ?? 0,
        price: (json['price'] as num?)?.toDouble(),
      );
}
