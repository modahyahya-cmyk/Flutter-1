import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/video_model.dart';

class VideoRemoteDataSource {
  VideoRemoteDataSource(this.apiClient);

  final ApiClient apiClient;

  Future<List<VideoModel>> getVideos({int page = 1}) async {
    final data = await apiClient.get(ApiEndpoints.videos, queryParameters: {'page': page});
    final list = ((data as Map<String, dynamic>)['data'] as List).cast<Map<String, dynamic>>();
    return list.map(VideoModel.fromJson).toList();
  }

  Future<bool> like(int videoId, {required bool liked}) async {
    await apiClient.get(ApiEndpoints.videoLike(videoId), queryParameters: {'liked': liked});
    return true;
  }

  Future<bool> share(int videoId) async {
    // Share is driven natively; the server records the event when configured.
    return true;
  }
}
