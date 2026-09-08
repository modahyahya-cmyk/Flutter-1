import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../domain/entities/video.dart';

/// Full-screen playback for a feed [Video] via [VideoPlayerController].
class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({super.key, required this.video});

  final Video video;

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late final VideoPlayerController _controller;
  late final Future<void> _initialization;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.video.videoUrl),
    );
    _initialization = _controller.initialize().then((_) {
      if (mounted) setState(() => _initialized = true);
      _controller.setLooping(true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.video.title,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<void>(
                future: _initialization,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.videocam_off,
                              color: Colors.white54, size: 48),
                          SizedBox(height: 12),
                          Text('Video unavailable',
                              style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                    );
                  }
                  if (!_initialized) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    );
                  }
                  return Center(
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  );
                },
              ),
            ),
            if (_initialized) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    onPressed: _controller.value.isPlaying
                        ? _controller.pause
                        : _controller.play,
                    icon: Icon(
                      _controller.value.isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Slider(
                      value: _controller.value.position.inMilliseconds
                          .toDouble(),
                      max: _controller.value.duration.inMilliseconds
                          .toDouble() > 0
                          ? _controller.value.duration.inMilliseconds
                              .toDouble()
                          : 1,
                      onChanged: (value) => _controller.seekTo(
                        Duration(milliseconds: value.round()),
                      ),
                    ),
                  ),
                  Text(
                    '${_mmss(_controller.value.position)} / '
                    '${_mmss(_controller.value.duration)}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
              if (widget.video.vendorName != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    widget.video.vendorName!,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  String _mmss(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
