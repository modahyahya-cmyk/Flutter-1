/// Core [Product] entity.
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    this.slug,
    this.description,
    this.shortDescription,
    this.thumbnail,
    this.images = const [],
    this.vendorId,
    this.categoryId,
    this.rating = 0,
    this.stockQuantity,
    this.formattedPrice,
  });

  final int id;
  final String name;
  final double price;
  final String? slug;
  final String? description;
  final String? shortDescription;
  final String? thumbnail;
  final List<String> images;
  final int? vendorId;
  final int? categoryId;
  final double rating;
  final int? stockQuantity;
  final String? formattedPrice;

  String get primaryImage =>
      (thumbnail != null && thumbnail!.isNotEmpty) ? thumbnail! : (images.isNotEmpty ? images.first : '');
}
