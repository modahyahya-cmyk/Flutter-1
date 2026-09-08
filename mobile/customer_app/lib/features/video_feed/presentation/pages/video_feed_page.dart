import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../config/dependency_injection.dart';
import '../../domain/entities/video.dart';
import '../controllers/video_feed_controller.dart';
import '../widgets/video_actions_widget.dart';
import 'video_player_page.dart';

/// Video commerce feed: real videos from the backend with like / share
/// actions and playback via [VideoPlayerPage].
class VideoFeedPage extends StatefulWidget {
  const VideoFeedPage({super.key});

  @override
  State<VideoFeedPage> createState() => _VideoFeedPageState();
}

class _VideoFeedPageState extends State<VideoFeedPage> {
  VideoFeedController get _controller => getIt<VideoFeedController>();

  @override
  void initState() {
    super.initState();
    _controller.loadFirstPage();
  }

  // NOTE: VideoFeedController is a getIt-managed app-lifetime singleton, so
  // it is intentionally NOT disposed here (disposing a singleton from a
  // page would break revisits to the feed).

  Future<void> _share(Video video) async {
    await _controller.share(video.id);
    await Clipboard.setData(ClipboardData(text: video.videoUrl));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Video link copied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Videos')),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading && _controller.videos.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_controller.videos.isEmpty && _controller.failure != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text(
                      _controller.failure?.message ?? 'Failed to load videos',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _controller.loadFirstPage,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (_controller.videos.isEmpty) {
            return const Center(
              child: Text('No videos yet. Check back soon.'),
            );
          }

          return RefreshIndicator(
            onRefresh: _controller.loadFirstPage,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _controller.videos.length + 1,
              itemBuilder: (context, index) {
                if (index >= _controller.videos.length) {
                  return _controller.isLoadingMore
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : const SizedBox.shrink();
                }

                final video = _controller.videos[index];

                // Infinite scroll: fetch the next page once the last item
                // is on screen. Deferred to a post-frame callback so the
                // controller mutation never happens during build.
                if (index == _controller.videos.length - 1 &&
                    !_controller.isLoadingMore) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) _controller.loadMore();
                  });
                }

                return _VideoCard(
                  video: video,
                  liked: _controller.isLiked(video.id),
                  onPlay: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => VideoPlayerPage(video: video),
                    ),
                  ),
                  onLike: () => _controller.toggleLike(video.id),
                  onShare: () => _share(video),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  const _VideoCard({
    required this.video,
    required this.liked,
    required this.onPlay,
    required this.onLike,
    required this.onShare,
  });

  final Video video;
  final bool liked;
  final VoidCallback onPlay;
  final VoidCallback onLike;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (video.thumbnailUrl != null)
                  CachedNetworkImage(
                    imageUrl: video.thumbnailUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    errorWidget: (_, _, _) => const ColoredBox(
                      color: Colors.black87,
                      child: Center(
                        child: Icon(Icons.movie,
                            color: Colors.white54, size: 40),
                      ),
                    ),
                  )
                else
                  const ColoredBox(
                    color: Colors.black87,
                    child: Center(
                      child: Icon(Icons.movie, color: Colors.white54, size: 40),
                    ),
                  ),
                Center(
                  child: IconButton.filledTonal(
                    onPressed: onPlay,
                    iconSize: 40,
                    icon: const Icon(Icons.play_arrow),
                    tooltip: 'Play',
                  ),
                ),
                // Like / share overlay (white icons by design).
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: VideoActionsWidget(
                      liked: liked,
                      likes: video.likesCount,
                      onLike: onLike,
                      onShare: onShare,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (video.vendorName != null)
                  Text(
                    video.vendorName!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                if (video.description != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      video.description!,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  '${video.viewsCount} views · ${video.likesCount} likes',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
