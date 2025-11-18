import 'package:flutter/material.dart';

/// Widget cho album card với tiêu đề
/// Sử dụng trong Recently played section
class AlbumCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final double size;

  const AlbumCard({
    super.key,
    required this.title,
    required this.imageUrl,
    this.size = 124,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.network(
            imageUrl,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: size,
                height: size,
                color: Colors.grey[800],
                child: Icon(
                  Icons.music_note,
                  color: Colors.grey,
                  size: size / 3,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: size,
          child: Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 11),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Widget cho large album card không có tiêu đề
/// Sử dụng trong Made for You section
class LargeAlbumCard extends StatelessWidget {
  final String imageUrl;
  final double size;

  const LargeAlbumCard({super.key, required this.imageUrl, this.size = 166});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.network(
        imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: size,
            height: size,
            color: Colors.grey[800],
            child: Icon(Icons.music_note, color: Colors.grey, size: size / 2.5),
          );
        },
      ),
    );
  }
}
