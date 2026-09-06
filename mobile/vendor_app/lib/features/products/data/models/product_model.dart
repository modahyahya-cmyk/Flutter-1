import '../../../../core/utils/parsers.dart';
import '../../domain/entities/product.dart';

class ProductModel extends VendorProduct {
  const ProductModel({
    required super.id,
    required super.name,
    required super.price,
    super.slug,
    super.description,
    super.shortDescription,
    super.thumbnail,
    super.status,
    super.stockQuantity,
    super.categoryId,
    super.isFeatured,
    super.sku,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int,
      name: json['name'] as String,
      price: Parsers.doubleOf(json['price']),
      slug: json['slug'] as String?,
      description: json['description'] as String?,
      shortDescription: json['short_description'] as String?,
      thumbnail: json['thumbnail'] as String?,
      status: json['status'] as String? ?? 'active',
      stockQuantity: Parsers.intOrNull(json['stock_quantity']),
      categoryId: Parsers.intOrNull(json['category_id']),
      isFeatured: json['is_featured'] as bool? ?? false,
      sku: json['sku'] as String?,
    );
  }
}
