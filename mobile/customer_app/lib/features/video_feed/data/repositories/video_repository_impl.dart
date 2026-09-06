import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/video.dart';
import '../../domain/repositories/video_repository.dart';
import '../datasources/video_remote_datasource.dart';

class VideoRepositoryImpl implements VideoRepository {
  VideoRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  final VideoRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<List<Video>> getVideos({int page = 1}) async {
    if (!await networkInfo.isConnected) {
      throw const NetworkException(message: 'No internet connection');
    }
    return remoteDataSource.getVideos(page: page);
  }

  @override
  Future<bool> likeVideo(int videoId, {required bool liked}) async {
    if (!await networkInfo.isConnected) {
      throw const NetworkException(message: 'No internet connection');
    }
    return remoteDataSource.like(videoId, liked: liked);
  }

  @override
  Future<bool> shareVideo(int videoId) async {
    return remoteDataSource.share(videoId);
  }
}
