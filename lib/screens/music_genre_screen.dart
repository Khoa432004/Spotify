import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'library_screen.dart';

/// Màn hình Music Genre - Hiển thị chi tiết thể loại nhạc
class MusicGenreScreen extends StatelessWidget {
  final String genreName;
  final Color? genreColor;

  const MusicGenreScreen({super.key, required this.genreName, this.genreColor});

  @override
  Widget build(BuildContext context) {
    // Tags
    final List<String> tags = [
      'DJ',
      'House',
      'Techno',
      'Electronica & Chill',
      'Bass',
      'Di...',
    ];

    // Popular playlists
    final List<Map<String, dynamic>> playlists = [
      {
        'name': 'mint',
        'followers': '5,553,688',
        'artwork':
            'https://www.figma.com/api/mcp/asset/1ca5a461-2e1c-4a15-9061-fbf5b98e3f82',
      },
      {
        'name': 'Happy Beats',
        'followers': '1,308,612',
        'artwork':
            'https://www.figma.com/api/mcp/asset/6cebb5cb-28f1-4f80-9ece-89d849556c58',
      },
      {
        'name': 'mint',
        'followers': '5,553,688',
        'artwork':
            'https://www.figma.com/api/mcp/asset/23af4c82-680b-41bb-a5f4-2aab0cb470c4',
      },
      {
        'name': 'Happy Beats',
        'followers': '1,308,612',
        'artwork':
            'https://www.figma.com/api/mcp/asset/44b15ff0-70ae-4afd-95be-bdca082bf693',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      bottomNavigationBar: _buildBottomNavigationBar(context),
      body: Stack(
        children: [
          // Header with gradient overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 255,
            child: Stack(
              children: [
                // Background image
                Positioned.fill(
                  child: Image.network(
                    'https://www.figma.com/api/mcp/asset/07eb24e3-fdf9-4cc2-a4a9-321cc7941fb1',
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
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          const Color(0xFF121212).withOpacity(0.0),
                          const Color(0xFF121212).withOpacity(1.0),
                        ],
                        stops: const [0.0, 0.309],
                      ),
                    ),
                  ),
                ),
                // Back button - đặt sau cùng để đảm bảo hiển thị trên cùng
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(13.0),
                    child: Material(
                      color: Colors.transparent,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ),
                // Genre info
                Positioned(
                  bottom: 0,
                  left: 16,
                  right: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Genre name
                      Text(
                        genreName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.96,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Description
                      Text(
                        'Playlists, DJ mixes and podcasts',
                        style: TextStyle(color: Colors.grey[400], fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Content
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 255),
                // Tags section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    height: 32,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: tags.length,
                      itemBuilder: (context, index) {
                        final tag = tags[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            right: index < tags.length - 1 ? 12.0 : 0,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFF43454B),
                              ),
                              borderRadius: BorderRadius.circular(23),
                            ),
                            child: Center(
                              child: Text(
                                tag,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Popular playlists section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Popular playlists',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Playlists grid (2 columns)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.83,
                            ),
                        itemCount: playlists.length,
                        itemBuilder: (context, index) {
                          final playlist = playlists[index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Artwork
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[800],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: playlist['artwork'] != null
                                        ? Image.network(
                                            playlist['artwork']!,
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
                              ),
                              const SizedBox(height: 8),
                              // Playlist name
                              Text(
                                playlist['name']!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              // Followers
                              Row(
                                children: [
                                  Text(
                                    playlist['followers']!,
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 11,
                                      letterSpacing: 0.715,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'FOLLOWERS',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
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
