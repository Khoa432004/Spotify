import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_player_provider.dart';
import '../screens/player_screen.dart';

/// Mini Player widget hiển thị ở bottom khi có bài đang phát
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicPlayerProvider>(
      builder: (context, player, child) {
        final song = player.currentSong;
        
        // Không hiển thị nếu không có bài hát
        if (song == null) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PlayerScreen()),
            );
          },
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF181818),
              border: Border(
                top: BorderSide(
                  color: Colors.grey[800]!,
                  width: 0.5,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  // Album artwork
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: song.artworkUrl != null && song.artworkUrl!.isNotEmpty
                        ? _buildArtwork(song.artworkUrl!)
                        : Container(
                            width: 48,
                            height: 48,
                            color: Colors.grey[800],
                            child: const Icon(
                              Icons.music_note,
                              color: Colors.grey,
                              size: 24,
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  // Song info
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          song.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          song.artistName,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Controls
                  Row(
                    children: [
                      // Device icon
                      IconButton(
                        icon: Icon(
                          Icons.devices,
                          color: Colors.grey[400],
                          size: 20,
                        ),
                        onPressed: () {},
                      ),
                      // Play/Pause button
                      IconButton(
                        icon: Icon(
                          player.isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: () => player.togglePlayPause(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Build artwork widget - hỗ trợ cả network và local file
  Widget _buildArtwork(String artworkUrl) {
    // Kiểm tra xem có phải local file không
    final isLocalFile = artworkUrl.startsWith('/') || 
                        artworkUrl.startsWith('file://') ||
                        !artworkUrl.startsWith('http');
    
    if (isLocalFile) {
      // Loại bỏ file:// prefix nếu có
      final filePath = artworkUrl.replaceFirst('file://', '');
      final file = File(filePath);
      
      if (file.existsSync()) {
        return Image.file(
          file,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 48,
              height: 48,
              color: Colors.grey[800],
              child: const Icon(
                Icons.music_note,
                color: Colors.grey,
                size: 24,
              ),
            );
          },
        );
      } else {
        // File không tồn tại, hiển thị placeholder
        return Container(
          width: 48,
          height: 48,
          color: Colors.grey[800],
          child: const Icon(
            Icons.music_note,
            color: Colors.grey,
            size: 24,
          ),
        );
      }
    } else {
      // Network image
      return Image.network(
        artworkUrl,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 48,
            height: 48,
            color: Colors.grey[800],
            child: const Icon(
              Icons.music_note,
              color: Colors.grey,
              size: 24,
            ),
          );
        },
      );
    }
  }
}

