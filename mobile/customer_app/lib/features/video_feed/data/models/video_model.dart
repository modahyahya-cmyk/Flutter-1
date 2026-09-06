import '../../domain/entities/video.dart';

class VideoModel extends Video {
  const VideoModel({
    required super.id,
    required super.title,
    required super.videoUrl,
    super.description,
    super.thumbnailUrl,
    super.likesCount,
    super.viewsCount,
    super.productId,
    super.vendorName,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    final vendor = json['vendor'] as Map<String, dynamic>?;
    return VideoModel(
      id: json['id'] as int,
      title: json['title'] as String,
      videoUrl: json['video_url'] as String,
      description: json['description'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String? ?? json['cover_url'] as String?,
      likesCount: json['likes_count'] as int? ?? 0,
      viewsCount: json['views_count'] as int? ?? 0,
      productId: json['product_id'] as int?,
      vendorName: vendor?['business_name'] as String?,
    );
  }
}
