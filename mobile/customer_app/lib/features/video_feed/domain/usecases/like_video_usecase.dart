import '../repositories/video_repository.dart';

class LikeVideoUseCase {
  LikeVideoUseCase({required this.repository});

  final VideoRepository repository;

  Future<bool> call(int videoId, {required bool liked}) => repository.likeVideo(videoId, liked: liked);
}
