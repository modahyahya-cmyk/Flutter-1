class VendorProduct {
  const VendorProduct({
    required this.id,
    required this.name,
    required this.price,
    this.slug,
    this.description,
    this.shortDescription,
    this.thumbnail,
    this.status = 'active',
    this.stockQuantity,
    this.categoryId,
    this.isFeatured = false,
    this.sku,
  });

  final int id;
  final String name;
  final double price;
  final String? slug;
  final String? description;
  final String? shortDescription;
  final String? thumbnail;
  final String status;
  final int? stockQuantity;
  final int? categoryId;
  final bool isFeatured;
  final String? sku;

  bool get isActive => status == 'active';

  static const List<String> editableFields = [
    'name', 'price', 'description', 'short_description', 'status',
    'stock_quantity', 'is_featured', 'sku',
  ];
}
