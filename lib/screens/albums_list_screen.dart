import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'album_detail_screen.dart';
import 'artists_list_screen.dart';
import 'library_screen.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'podcasts_screen.dart';

/// Màn hình danh sách Albums trong Library
class AlbumsListScreen extends StatelessWidget {
  const AlbumsListScreen({super.key});

  // Helper function to calculate text width
  static double _getTextWidth(
    String text,
    double fontSize,
    double letterSpacing,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          letterSpacing: letterSpacing,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    return textPainter.width;
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> albums = [
      {
        'name': 'Dive',
        'artist': 'Tycho',
        'imageUrl':
            'https://www.figma.com/api/mcp/asset/a52fb990-2fc6-4036-b2a2-af1d9b89e7e9',
      },
      {
        'name': 'Presence',
        'artist': 'Petit Biscuit',
        'imageUrl':
            'https://www.figma.com/api/mcp/asset/b4e13d4d-0b14-4c6d-923b-88fd31f8b52f',
      },
      {
        'name': 'What You Don\'t See',
        'artist': 'The Story So Far',
        'imageUrl':
            'https://www.figma.com/api/mcp/asset/fb7fd739-5bce-4424-a0f3-6e82ba0c0ef0',
      },
      {
        'name': 'Awake',
        'artist': 'Illenium',
        'imageUrl':
            'https://www.figma.com/api/mcp/asset/f392827a-dd59-4d5e-83e8-f5b996ee346b',
      },
      {
        'name': 'Days To Come',
        'artist': 'Seven Lions',
        'imageUrl':
            'https://www.figma.com/api/mcp/asset/0bac6d60-0494-4f6d-b7db-4d563c56bb11',
      },
      {
        'name': 'Shapeshifter',
        'artist': 'Knuckle Puck',
        'imageUrl':
            'https://www.figma.com/api/mcp/asset/1b2d200b-f11d-48f7-a026-cf208a8c68ea',
      },
      {
        'name': 'Awake',
        'artist': 'Tycho',
        'imageUrl':
            'https://www.figma.com/api/mcp/asset/8b7cb5c5-4936-4612-ad8a-190441bb2362',
      },
      {
        'name': 'Mothership',
        'artist': 'Dance Gavin Dance',
        'imageUrl':
            'https://www.figma.com/api/mcp/asset/15392f0e-5fe6-4805-8544-7653b59e1e37',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      bottomNavigationBar: _buildBottomNavigationBar(context),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Large tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: Row(
                children: [
                  const Text(
                    'Music',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1.2,
                    ),
                  ),
                  const SizedBox(width: 24),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PodcastsScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Podcasts',
                      style: TextStyle(
                        color: Color(0xFF7F7F7F),
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 13),

            // Small tabs with indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 17.0),
              child: Row(
                children: [
                  // Playlists tab
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Playlists',
                        style: TextStyle(
                          color: Color(0xFF7F7F7F),
                          fontSize: 15.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.62,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const SizedBox(width: 87, height: 2),
                    ],
                  ),
                  const SizedBox(width: 24),
                  // Artists tab
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ArtistsListScreen(),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Artists',
                          style: TextStyle(
                            color: Color(0xFF7F7F7F),
                            fontSize: 15.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.62,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const SizedBox(width: 43, height: 2),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Albums tab (active)
                  Builder(
                    builder: (context) {
                      final textWidth = _getTextWidth('Albums', 15.5, -0.62);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Albums',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.62,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: textWidth,
                            height: 2,
                            color: const Color(0xFF57B560),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Search bar
            Container(
              color: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 17.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF282828),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          Icon(
                            Icons.search,
                            color: Colors.grey[400],
                            size: 15.4,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Find in albums',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.23,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF282828),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: Text(
                        'Filters',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.23,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Album list
            Expanded(
              child: ListView.builder(
                clipBehavior: Clip.hardEdge,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: albums.length,
                itemBuilder: (context, index) {
                  final album = albums[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AlbumDetailScreen(
                              albumName: album['name']!,
                              artistName: album['artist']!,
                              albumArt: album['imageUrl'],
                            ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          // Album artwork
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: album['imageUrl'] != null
                                  ? Image.network(
                                      album['imageUrl']!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey[800],
                                            );
                                          },
                                    )
                                  : Container(color: Colors.grey[800]),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Album info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  album['name']!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.28,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  album['artist']!,
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
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
          // Indicator bar ở trên - "Your Library" được chọn
          Container(
            height: 5,
            margin: const EdgeInsets.only(left: 314, right: 54, top: 5),
            width: 61,
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
