class Video {
  const Video({
    required this.id,
    required this.title,
    required this.videoUrl,
    this.description,
    this.thumbnailUrl,
    this.likesCount = 0,
    this.viewsCount = 0,
    this.productId,
    this.vendorName,
  });

  final int id;
  final String title;
  final String videoUrl;
  final String? description;
  final String? thumbnailUrl;
  final int likesCount;
  final int viewsCount;
  final int? productId;
  final String? vendorName;
}
