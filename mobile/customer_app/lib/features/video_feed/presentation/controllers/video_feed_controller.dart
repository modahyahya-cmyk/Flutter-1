import 'package:flutter/foundation.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/video.dart';
import '../../domain/usecases/get_videos_usecase.dart';
import '../../domain/usecases/like_video_usecase.dart';
import '../../domain/usecases/share_video_usecase.dart';

class VideoFeedController extends ChangeNotifier {
  VideoFeedController({
    required this.getVideosUseCase,
    required this.likeVideoUseCase,
    required this.shareVideoUseCase,
  });

  final GetVideosUseCase getVideosUseCase;
  final LikeVideoUseCase likeVideoUseCase;
  final ShareVideoUseCase shareVideoUseCase;

  bool isLoading = false;
  bool isLoadingMore = false;
  int page = 1;
  List<Video> videos = [];
  final Set<int> _liked = {};
  Failure? failure;

  Future<void> loadFirstPage() async {
    isLoading = true;
    failure = null;
    page = 1;
    notifyListeners();

    try {
      videos = await getVideosUseCase(page: page);
    } on AppException catch (e) {
      failure = mapExceptionToFailure(e);
    } catch (_) {
      failure = const Failure.unknown();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (isLoadingMore) return;
    isLoadingMore = true;
    final next = page + 1;

    try {
      final more = await getVideosUseCase(page: next);
      videos.addAll(more);
      page = next;
    } on AppException {
      // Swallow pagination failures; existing items remain usable.
    }
    isLoadingMore = false;
    notifyListeners();
  }

  bool isLiked(int videoId) => _liked.contains(videoId);

  Future<void> toggleLike(int videoId) async {
    final liked = !_liked.contains(videoId);
    if (liked) {
      _liked.add(videoId);
    } else {
      _liked.remove(videoId);
    }
    notifyListeners();

    try {
      await likeVideoUseCase(videoId, liked: liked);
    } on AppException catch (e) {
      failure = mapExceptionToFailure(e);
      notifyListeners();
    }
  }

  Future<void> share(int videoId) async {
    await shareVideoUseCase(videoId);
  }
}
