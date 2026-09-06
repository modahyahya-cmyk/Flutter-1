import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.price,
    super.slug,
    super.description,
    super.shortDescription,
    super.thumbnail,
    super.images,
    super.vendorId,
    super.categoryId,
    super.rating,
    super.stockQuantity,
    super.formattedPrice,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      slug: json['slug'] as String?,
      description: json['description'] as String?,
      shortDescription: json['short_description'] as String?,
      thumbnail: json['thumbnail'] as String?,
      images: (json['images'] as List?)?.cast<String>() ?? const [],
      vendorId: json['vendor_id'] as int?,
      categoryId: json['category_id'] as int?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      stockQuantity: json['stock_quantity'] as int?,
      formattedPrice: json['formatted_price'] as String?,
    );
  }
}
