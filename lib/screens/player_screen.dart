import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'library_screen.dart';
import '../providers/music_player_provider.dart';
import '../services/music_player_service.dart';

/// Màn hình Player - Phát nhạc với controls
class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  bool _isLiked = false;

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicPlayerProvider>(
      builder: (context, player, child) {
        final song = player.currentSong;
        
        // Nếu không có bài hát nào đang phát, hiển thị empty state
        if (song == null) {
          return Scaffold(
            backgroundColor: const Color(0xFF1A1A1A),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.music_off,
                    color: Colors.grey,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có bài hát nào đang phát',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Quay lại'),
                  ),
                ],
              ),
            ),
          );
        }

        final duration = player.duration ?? Duration.zero;
        final position = player.position;
        final progress = duration.inMilliseconds > 0
            ? position.inMilliseconds / duration.inMilliseconds
            : 0.0;

        return Scaffold(
          backgroundColor: const Color(0xFF1A1A1A),
          bottomNavigationBar: _buildBottomNavigationBar(context),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                  const SizedBox(height: 40),
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button
                      Transform.rotate(
                        angle: 1.5708, // 90 degrees
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 23,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      // Playlist name
                      Text(
                        song.albumName ?? 'Now Playing',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // More icon
                      IconButton(
                        icon: const Icon(
                          Icons.more_horiz,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // Album artwork
                  Container(
                    width: 366,
                    height: 366,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: song.artworkUrl != null
                          ? Image.network(
                              song.artworkUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[800],
                                  child: const Icon(
                                    Icons.music_note,
                                    size: 100,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: Colors.grey[800],
                              child: const Icon(
                                Icons.music_note,
                                size: 100,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Song info
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.99,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              song.artistName,
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 15,
                                letterSpacing: -0.675,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Like button
                      IconButton(
                        icon: Icon(
                          _isLiked ? Icons.favorite : Icons.favorite_border,
                          color: _isLiked
                              ? const Color(0xFF57B560)
                              : Colors.grey[400],
                          size: 24,
                        ),
                        onPressed: () {
                          setState(() {
                            _isLiked = !_isLiked;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Timeline
                  Column(
                    children: [
                      // Progress bar
                      Stack(
                        children: [
                          Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[700],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: progress.clamp(0.0, 1.0),
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          // Scrubber
                          Positioned(
                            left: (progress.clamp(0.0, 1.0) * 366) - 6.5,
                            top: -4.5,
                            child: GestureDetector(
                              onHorizontalDragUpdate: (details) {
                                final newProgress =
                                    (details.localPosition.dx / 366).clamp(0.0, 1.0);
                                final newPosition = Duration(
                                  milliseconds: (duration.inMilliseconds * newProgress).round(),
                                );
                                player.seek(newPosition);
                              },
                              child: Container(
                                width: 13,
                                height: 13,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Time labels
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(position),
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            '-${_formatDuration(duration - position)}',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Shuffle button
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.shuffle,
                              color: player.shuffleMode
                                  ? const Color(0xFF57B560)
                                  : Colors.grey[400],
                              size: 20,
                            ),
                            onPressed: () => player.toggleShuffle(),
                          ),
                          // Dot indicator
                          if (player.shuffleMode)
                            Positioned(
                              bottom: 0,
                              left: 17,
                              child: Container(
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF57B560),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                      // Previous button
                      IconButton(
                        icon: const Icon(
                          Icons.skip_previous,
                          color: Colors.white,
                          size: 35,
                        ),
                        onPressed: () => player.previousSong(),
                      ),
                      // Play/Pause button
                      GestureDetector(
                        onTap: () => player.togglePlayPause(),
                        child: Container(
                          width: 63,
                          height: 63,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            player.isPlaying ? Icons.pause : Icons.play_arrow,
                            color: const Color(0xFF181718),
                            size: 32,
                          ),
                        ),
                      ),
                      // Next button
                      Transform.rotate(
                        angle: 3.14159, // 180 degrees
                        child: IconButton(
                          icon: const Icon(
                            Icons.skip_previous,
                            color: Colors.white,
                            size: 35,
                          ),
                          onPressed: () => player.nextSong(),
                        ),
                      ),
                      // Repeat button
                      IconButton(
                        icon: Icon(
                          player.repeatMode == RepeatMode.one
                              ? Icons.repeat_one
                              : Icons.repeat,
                          color: player.repeatMode != RepeatMode.none
                              ? const Color(0xFF57B560)
                              : Colors.grey[400],
                          size: 22,
                        ),
                        onPressed: () => player.toggleRepeat(),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Bottom controls
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Devices icon
                        IconButton(
                          icon: const Icon(
                            Icons.devices,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () {},
                        ),
                        // Queue icon
                        IconButton(
                          icon: const Icon(
                            Icons.queue_music,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Tạo Bottom Navigation Bar với style Spotify
  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      height: 83,
      decoration: const BoxDecoration(color: Color(0xFF282828)),
      child: Column(
        children: [
          // Indicator bar ở trên - không có tab nào được chọn trong player
          Container(
            height: 5,
            margin: const EdgeInsets.only(left: 133, right: 133, top: 5),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          // Navigation items
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(context, Icons.home, 'Home', 0),
                _buildNavItem(context, Icons.search, 'Search', 1),
                _buildNavItem(context, Icons.library_music, 'Your Library', 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Tạo từng navigation item
  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    int index,
  ) {
    return InkWell(
      onTap: () {
        // Navigate to the corresponding screen
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SearchScreen()),
          );
        } else if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LibraryScreen()),
          );
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: const Color(0xFFB3B3B3),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFB3B3B3),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
