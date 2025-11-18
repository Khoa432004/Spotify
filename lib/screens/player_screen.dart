import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'library_screen.dart';

/// Màn hình Player - Phát nhạc với controls
class PlayerScreen extends StatefulWidget {
  final String? songTitle;
  final String? artistName;
  final String? albumArt;

  const PlayerScreen({
    super.key,
    this.songTitle,
    this.artistName,
    this.albumArt,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  bool _isPlaying = true;
  bool _isLiked = true;
  bool _isShuffle = true;
  bool _isRepeat = false;
  double _currentPosition = 0.03;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      bottomNavigationBar: _buildBottomNavigationBar(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button (rotated)
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
                  const Text(
                        'Liked Songs',
                        style: TextStyle(
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
                      child: widget.albumArt != null
                          ? Image.network(
                              widget.albumArt!,
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
                          : Image.network(
                              'https://www.figma.com/api/mcp/asset/4b8fde28-6dc8-440a-932b-5a682dc084e9',
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
                              widget.songTitle ?? 'Only U (Real Quick)',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.99,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.artistName ?? 'Ownglow',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 15,
                                letterSpacing: -0.675,
                              ),
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
                            widthFactor: _currentPosition,
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
                            left: (_currentPosition * 366) - 6.5,
                            top: -4.5,
                            child: GestureDetector(
                              onHorizontalDragUpdate: (details) {
                                setState(() {
                                  final newPosition =
                                      (details.localPosition.dx / 366).clamp(
                                        0.0,
                                        1.0,
                                      );
                                  _currentPosition = newPosition;
                                });
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
                            '0:03',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            '-3:49',
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
                              color: _isShuffle
                                  ? const Color(0xFF57B560)
                                  : Colors.grey[400],
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _isShuffle = !_isShuffle;
                              });
                            },
                          ),
                          // Dot indicator
                          if (_isShuffle)
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
                        onPressed: () {},
                  ),
                  // Play/Pause button
                  GestureDetector(
                        onTap: () {
                          setState(() {
                            _isPlaying = !_isPlaying;
                          });
                        },
                        child: Container(
                          width: 63,
                          height: 63,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
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
                          onPressed: () {},
                        ),
                  ),
                  // Repeat button
                  IconButton(
                        icon: Icon(
                          _isRepeat ? Icons.repeat : Icons.repeat_one,
                          color: _isRepeat
                              ? Colors.grey[400]
                              : Colors.grey[400],
                          size: 22,
                        ),
                        onPressed: () {
                          setState(() {
                            _isRepeat = !_isRepeat;
                          });
                        },
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
