import 'package:flutter/material.dart';

/// Widget cho playlist card (Good afternoon section)
/// Hiển thị một card nhỏ với hình ảnh bên trái và tiêu đề bên phải
class PlaylistCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String? playlistId;
  final VoidCallback? onTap;

  const PlaylistCard({
    super.key, 
    required this.title, 
    required this.imageUrl,
    this.playlistId,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF282828),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                bottomLeft: Radius.circular(4),
              ),
              child: Image.network(
                imageUrl,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 56,
                    height: 56,
                    color: Colors.grey[800],
                    child: const Icon(Icons.music_note, color: Colors.grey),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            // Title
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
