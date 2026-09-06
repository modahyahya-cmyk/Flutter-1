import '../../domain/entities/video.dart';
import '../repositories/video_repository.dart';

class GetVideosUseCase {
  GetVideosUseCase({required this.repository});

  final VideoRepository repository;

  Future<List<Video>> call({int page = 1}) => repository.getVideos(page: page);
}
