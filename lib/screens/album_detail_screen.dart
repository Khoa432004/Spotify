import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'library_screen.dart';
import 'player_screen.dart';

/// Màn hình chi tiết Album
class AlbumDetailScreen extends StatelessWidget {
  final String albumName;
  final String artistName;
  final String? albumArt;

  const AlbumDetailScreen({
    super.key,
    required this.albumName,
    required this.artistName,
    this.albumArt,
  });

  @override
  Widget build(BuildContext context) {
    // Tracks data
    final List<Map<String, String>> tracks = [
      {'title': 'Creation Comes Alive', 'artist': 'Petit Biscuit, SONIA'},
      {'title': 'Problems', 'artist': 'Petit Biscuit, Lido'},
      {'title': 'Follow Me', 'artist': 'Petit Biscuit,'},
      {'title': 'Beam', 'artist': 'Petit Biscuit'},
      {'title': 'Break Up', 'artist': 'Petit Biscuit'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      bottomNavigationBar: _buildBottomNavigationBar(context),
      body: Stack(
        children: [
          // Gradient fade background
          Positioned(
            top: -228,
            left: -137,
            child: Container(
              width: 594,
              height: 594,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [Colors.grey.withOpacity(0.3), Colors.transparent],
                ),
              ),
              child: Image.network(
                'https://www.figma.com/api/mcp/asset/2be3c887-4aa4-4afd-8d47-0e3b39063ec7',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // Back button
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 24),
                    // Album artwork (centered)
                    Center(
                      child: Container(
                        width: 272,
                        height: 272,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.55),
                              blurRadius: 65,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: albumArt != null
                              ? Image.network(
                                  albumArt!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[800],
                                      child: const Icon(
                                        Icons.album,
                                        size: 100,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                )
                              : Image.network(
                                  'https://www.figma.com/api/mcp/asset/6b9b70b4-d79d-4f74-bafd-487d17a98564',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[800],
                                      child: const Icon(
                                        Icons.album,
                                        size: 100,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Album name
                    Text(
                      albumName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.72,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Artist with avatar
                    Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey,
                          ),
                          child: ClipOval(
                            child: Image.network(
                              'https://www.figma.com/api/mcp/asset/0a3481eb-95f6-4a48-8666-86356a603e7b',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(color: Colors.grey[800]!);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          artistName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11.3,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Album • Year
                    Row(
                      children: [
                        Text(
                          'Album',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 9,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Container(
                            width: 1.8,
                            height: 1.8,
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Text(
                          '2017',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Controls
                    Row(
                      children: [
                        // Like icon
                        IconButton(
                          icon: const Icon(Icons.favorite_border),
                          color: Colors.white,
                          iconSize: 26,
                          onPressed: () {},
                        ),
                        const SizedBox(width: 8),
                        // Download icon
                        IconButton(
                          icon: const Icon(Icons.download_outlined),
                          color: Colors.grey[400],
                          iconSize: 24,
                          onPressed: () {},
                        ),
                        const SizedBox(width: 8),
                        // More icon
                        IconButton(
                          icon: const Icon(Icons.more_horiz),
                          color: Colors.grey[400],
                          iconSize: 24,
                          onPressed: () {},
                        ),
                        const Spacer(),
                        // Play button
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlayerScreen(
                                  songTitle: tracks.isNotEmpty
                                      ? tracks[0]['title']
                                      : null,
                                  artistName: tracks.isNotEmpty
                                      ? tracks[0]['artist']
                                      : artistName,
                                  albumArt: albumArt,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: const BoxDecoration(
                              color: Color(0xFF1DB954),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Shuffle button (small)
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.shuffle,
                            color: Color(0xFF57B560),
                            size: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Track list
                    ...List.generate(tracks.length, (index) {
                      final track = tracks[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlayerScreen(
                                songTitle: track['title'],
                                artistName: track['artist'],
                                albumArt: albumArt,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Row(
                            children: [
                              // Download icon
                              Icon(
                                Icons.download,
                                color: Colors.grey[400],
                                size: 13,
                              ),
                              const SizedBox(width: 12),
                              // Track info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      track['title']!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      track['artist']!,
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 11,
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
