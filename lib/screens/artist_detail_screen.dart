import 'package:flutter/material.dart';
import '../widgets/mini_player.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'library_screen.dart';
import 'liked_songs_screen.dart';
import 'player_screen.dart';
import 'artists_pick_screen.dart';
import 'upcoming_concerts_screen.dart';

/// Màn hình chi tiết Artist - Hiển thị thông tin artist, popular songs, liked songs
class ArtistDetailScreen extends StatelessWidget {
  final String artistName;
  final String? artistImage;

  const ArtistDetailScreen({
    super.key,
    required this.artistName,
    this.artistImage,
  });

  @override
  Widget build(BuildContext context) {
    // Popular songs data
    final List<Map<String, dynamic>> popularSongs = [
      {
        'title': 'Awake',
        'playCount': '59,847,265',
        'artwork':
            'https://www.figma.com/api/mcp/asset/d69c7a90-7949-40e4-afd9-f9e57f1bd6eb',
      },
      {
        'title': 'A Walk',
        'playCount': '35,778,569',
        'artwork':
            'https://www.figma.com/api/mcp/asset/1beb2832-fe33-4e26-803d-29152a1feb0c',
      },
      {
        'title': 'Hours',
        'playCount': '16,479,598',
        'artwork':
            'https://www.figma.com/api/mcp/asset/1beb2832-fe33-4e26-803d-29152a1feb0c',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(),
          _buildBottomNavigationBar(context),
        ],
      ),
      body: Stack(
        children: [
          // Header with artist image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 408,
            child: Stack(
              children: [
                // Artist image background
                Positioned.fill(
                  child: Image.network(
                    'https://www.figma.com/api/mcp/asset/765a9423-4948-4200-aae0-7dd7d761f704',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(color: Colors.grey[900]!);
                    },
                  ),
                ),
                // Gradient overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.05),
                          Colors.black.withOpacity(0.27),
                        ],
                        stops: const [0.049, 0.27],
                      ),
                    ),
                  ),
                ),
                // Back button
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.5),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                // Artist name
                Positioned(
                  bottom: 0,
                  left: 15,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      artistName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 55,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.65,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 408),
                // Controls section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Monthly listeners
                      Text(
                        '1,516,018 monthly listeners',
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 11.3,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.09,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Controls row
                      Row(
                        children: [
                          // Following button
                          Container(
                            width: 95,
                            height: 28,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: const Center(
                              child: Text(
                                'FOLLOWING',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          // More icon with menu
                          PopupMenuButton<String>(
                            icon: Icon(
                              Icons.more_horiz,
                              color: Colors.grey[400],
                              size: 24,
                            ),
                            color: const Color(0xFF282828),
                            onSelected: (value) {
                              if (value == 'artists_pick') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ArtistsPickScreen(
                                      artistName: artistName,
                                    ),
                                  ),
                                );
                              } else if (value == 'concerts') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        UpcomingConcertsScreen(
                                          artistName: artistName,
                                        ),
                                  ),
                                );
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'artists_pick',
                                child: const Text(
                                  'Artist\'s Pick',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              PopupMenuItem(
                                value: 'concerts',
                                child: const Text(
                                  'Concerts',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          // Play & Shuffle
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // Play button
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const PlayerScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 56,
                                  height: 56,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.play_arrow,
                                    color: Colors.black,
                                    size: 28,
                                  ),
                                ),
                              ),
                              // Shuffle button
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF57B560),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.shuffle,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Liked songs section
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LikedSongsScreen(),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            // Liked songs image
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 37.5,
                                  height: 37.5,
                                  decoration: const BoxDecoration(
                                    color: Colors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                  child: ClipOval(
                                    child: Image.network(
                                      'https://www.figma.com/api/mcp/asset/1d407621-3269-42ec-ae11-273867afae43',
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey[800]!,
                                            );
                                          },
                                    ),
                                  ),
                                ),
                                // Like icon overlay
                                Positioned(
                                  bottom: -2,
                                  right: -2,
                                  child: Container(
                                    width: 19,
                                    height: 19,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF1DB954),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.favorite,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            // Liked songs info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Liked songs',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        '30 songs',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 11.4,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 3,
                                        ),
                                        child: Container(
                                          width: 3,
                                          height: 3,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[400],
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        artistName,
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 11.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Arrow
                            Transform.rotate(
                              angle: 3.14159, // 180 degrees
                              child: Icon(
                                Icons.arrow_back,
                                color: Colors.grey[400],
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Popular section
                      const Text(
                        'Popular',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Popular songs list
                      ...List.generate(popularSongs.length, (index) {
                        final song = popularSongs[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PlayerScreen(),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Row(
                              children: [
                                // Number
                                SizedBox(
                                  width: 22,
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Artwork
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[800],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: song['artwork'] != null
                                        ? Image.network(
                                            song['artwork']!,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return Container(
                                                    color: Colors.grey[800]!,
                                                  );
                                                },
                                          )
                                        : Container(color: Colors.grey[800]),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Song info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        song['title']!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        song['playCount']!,
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 11.8,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // More icon
                                IconButton(
                                  icon: Icon(
                                    Icons.more_horiz,
                                    color: Colors.grey[400],
                                    size: 20,
                                  ),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 100), // Space for bottom nav
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
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
          // Indicator bar ở trên - "Your Library" được chọn
          Container(
            height: 5,
            margin: const EdgeInsets.only(left: 133, right: 133, top: 5),
            width: 148,
            decoration: BoxDecoration(
              color: Colors.white,
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
    final isSelected = index == 2; // "Your Library" is selected
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
            color: isSelected ? Colors.white : const Color(0xFFB3B3B3),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFFB3B3B3),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
