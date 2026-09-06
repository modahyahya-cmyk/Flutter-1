import 'package:flutter/material.dart';

class VideoActionsWidget extends StatelessWidget {
  const VideoActionsWidget({
    super.key,
    required this.liked,
    required this.likes,
    required this.onLike,
    required this.onShare,
  });

  final bool liked;
  final int likes;
  final VoidCallback onLike;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionButton(
          icon: liked ? Icons.favorite : Icons.favorite_border,
          color: liked ? Colors.red : Colors.white,
          label: likes.toString(),
          onTap: onLike,
        ),
        const SizedBox(height: 16),
        _ActionButton(
          icon: Icons.share_outlined,
          color: Colors.white,
          label: 'Share',
          onTap: onShare,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.color, required this.label, required this.onTap});

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}
