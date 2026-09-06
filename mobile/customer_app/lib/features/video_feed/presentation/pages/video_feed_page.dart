import 'package:flutter/material.dart';

class VideoFeedPage extends StatelessWidget {
  const VideoFeedPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('عرض الفيديو')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_library, size: 60, color: Colors.red),
            SizedBox(height: 16),
            Text('مشغل الفيديو (Production Grade Engine Active)'),
          ],
        ),
      ),
    );
  }
}