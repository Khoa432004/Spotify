import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'artist_detail_screen.dart';
import 'albums_list_screen.dart';
import 'library_screen.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'podcasts_screen.dart';

/// Màn hình danh sách Artists trong Library
class ArtistsListScreen extends StatelessWidget {
  const ArtistsListScreen({super.key});

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
    final List<Map<String, String>> artists = [
      {
        'name': 'Petit Biscuit',
        'imageUrl':
            'https://www.figma.com/api/mcp/asset/e1272905-8bc8-4944-bbb5-311a910a7286',
      },
      {
        'name': 'The Story So Far',
        'imageUrl':
            'https://www.figma.com/api/mcp/asset/b0237a2b-ec32-42ef-b90e-5a62f872702d',
      },
      {
        'name': 'Seven Lions',
        'imageUrl':
            'https://www.figma.com/api/mcp/asset/d82bd64d-3735-4fd2-bbc9-bafe9baea7ac',
      },
      {
        'name': 'Illenium',
        'imageUrl':
            'https://www.figma.com/api/mcp/asset/cb3e5ab0-2490-4437-8d47-194c602b3441',
      },
      {
        'name': 'Galantis',
        'imageUrl':
            'https://www.figma.com/api/mcp/asset/26fb86f2-0089-4275-abb2-aaa02dcf9446',
      },
      {
        'name': 'San Holo',
        'imageUrl':
            'https://www.figma.com/api/mcp/asset/f1941f48-5c7c-4ba3-ba28-a7c062a32aef',
      },
      {
        'name': 'MitiS',
        'imageUrl':
            'https://www.figma.com/api/mcp/asset/5ab5de2c-7d09-4283-be98-9eae9e0574f5',
      },
      {
        'name': 'Dance Gavin Dance',
        'imageUrl':
            'https://www.figma.com/api/mcp/asset/617365dd-f9f8-4faf-8f79-e8e42fe15267',
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
                padding: const EdgeInsets.symmetric(horizontal: 13.0),
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                      // Artists tab (active)
                      Builder(
                        builder: (context) {
                          final textWidth = _getTextWidth(
                            'Artists',
                            15.5,
                            -0.62,
                          );
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Artists',
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
                      const SizedBox(width: 24),
                      // Albums tab
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AlbumsListScreen(),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Albums',
                              style: TextStyle(
                                color: Color(0xFF7F7F7F),
                                fontSize: 15.5,
                                fontWeight: FontWeight.w500,
                                letterSpacing: -0.62,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const SizedBox(width: 47, height: 2),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              // Search bar
              Container(
                color: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                              const SizedBox(width: 24),
                              Icon(
                                Icons.search,
                                color: Colors.grey[400],
                                size: 15.4,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Find in artists',
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
                        width: 64,
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
              // Artist list
              Expanded(
                child: ListView.builder(
                    clipBehavior: Clip.hardEdge,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: artists.length,
                    itemBuilder: (context, index) {
                      final artist = artists[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ArtistDetailScreen(
                                  artistName: artist['name']!,
                                ),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              // Artist image
                              Container(
                                width: 65,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Colors.grey[800],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: artist['imageUrl'] != null
                                      ? Image.network(
                                          artist['imageUrl']!,
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
                              // Artist name
                              Text(
                                artist['name']!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: -0.45,
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
