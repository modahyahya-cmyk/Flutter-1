import '../repositories/video_repository.dart';

class ShareVideoUseCase {
  ShareVideoUseCase({required this.repository});

  final VideoRepository repository;

  Future<bool> call(int videoId) => repository.shareVideo(videoId);
}
