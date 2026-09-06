import '../../domain/entities/video.dart';

abstract class VideoRepository {
  Future<List<Video>> getVideos({int page = 1});
  Future<bool> likeVideo(int videoId, {required bool liked});
  Future<bool> shareVideo(int videoId);
}
