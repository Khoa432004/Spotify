import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'library_screen.dart';
import 'home_screen.dart';
import 'search_screen.dart';

/// Màn hình Podcasts - Hiển thị danh sách podcast episodes
class PodcastsScreen extends StatefulWidget {
  const PodcastsScreen({super.key});

  @override
  State<PodcastsScreen> createState() => _PodcastsScreenState();
}

class _PodcastsScreenState extends State<PodcastsScreen> {
  String _selectedTab = 'Episodes';

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

  final List<Map<String, dynamic>> _episodes = [
    {
      'title': '#250 - Joe Kisses Danny',
      'show': 'The Basement Yard',
      'date': 'YESTERDAY',
      'duration': '1HR 10MIN',
      'description':
          'On this episode, we dive into Danny\'s dream where Joe kissed him at a party...we also dive into the dark underworld of the Karens.',
      'artwork':
          'https://www.figma.com/api/mcp/asset/90f55eb4-d1e2-4d43-93e6-d422dd17e6a2',
    },
    {
      'title': '#249 - Danny Kisses Joe',
      'show': 'The Basement Yard',
      'date': 'YESTERDAY',
      'duration': '1HR 10MIN',
      'description':
          'On this episode, we dive into Danny\'s dream where Joe kissed him at a party...we also dive into the dark underworld of the Karens.',
      'artwork':
          'https://www.figma.com/api/mcp/asset/90f55eb4-d1e2-4d43-93e6-d422dd17e6a2',
    },
    {
      'title': '#248 - Kanye 2020',
      'show': 'The Basement Yard',
      'date': 'YESTERDAY',
      'duration': '1HR 10MIN',
      'description':
          'On this episode, we dive into Danny\'s dream where Joe kissed him at a party...we also dive into the dark underworld of the Karens.',
      'artwork':
          'https://www.figma.com/api/mcp/asset/90f55eb4-d1e2-4d43-93e6-d422dd17e6a2',
    },
  ];

  @override
  Widget build(BuildContext context) {
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
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LibraryScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Music',
                          style: TextStyle(
                            color: Color(0xFF7F7F7F),
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -1.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      const Text(
                        'Podcasts',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1.2,
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
                      // Episodes tab (active)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTab = 'Episodes';
                          });
                        },
                        child: Builder(
                          builder: (context) {
                            final textWidth = _getTextWidth(
                              'Episodes',
                              15.5,
                              -0.62,
                            );
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Episodes',
                                  style: TextStyle(
                                    color: _selectedTab == 'Episodes'
                                        ? Colors.white
                                        : const Color(0xFF7F7F7F),
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: -0.62,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (_selectedTab == 'Episodes')
                                  Container(
                                    width: textWidth,
                                    height: 2,
                                    color: const Color(0xFF57B560),
                                  )
                                else
                                  const SizedBox(width: 59, height: 2),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Downloads tab
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTab = 'Downloads';
                          });
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Downloads',
                              style: TextStyle(
                                color: Color(0xFF7F7F7F),
                                fontSize: 15.5,
                                fontWeight: FontWeight.w500,
                                letterSpacing: -0.62,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const SizedBox(width: 75, height: 2),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Shows tab
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTab = 'Shows';
                          });
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Shows',
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
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Yesterday label
                if (_selectedTab == 'Episodes') ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Yesterday',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                // Episode list
                if (_selectedTab == 'Episodes')
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: _episodes.length,
                      itemBuilder: (context, index) {
                        final episode = _episodes[index];
                        return _buildEpisodeCard(episode);
                      },
                    ),
                  )
                else
                  Expanded(
                    child: Center(
                      child: Text(
                        _selectedTab,
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    ),
                  ),
              ],
            ),
          ),
    );
  }

  Widget _buildEpisodeCard(Map<String, dynamic> episode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF282828),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Artwork
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: episode['artwork'] != null
                      ? Image.network(
                          episode['artwork']!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(color: Colors.grey[800]);
                          },
                        )
                      : Container(color: Colors.grey[800]),
                ),
              ),
              const SizedBox(width: 12),
              // Title and show
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      episode['title'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      episode['show'],
                      style: TextStyle(color: Colors.grey[400], fontSize: 11),
                    ),
                  ],
                ),
              ),
              // More icon
              Icon(Icons.more_horiz, color: Colors.grey[400], size: 20),
            ],
          ),
          const SizedBox(height: 12),
          // Description
          Text(
            episode['description'],
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 11,
              height: 1.1,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          // Play button and metadata
          Row(
            children: [
              // Play button
              Container(
                width: 31,
                height: 31,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Color(0xFF282828),
                  size: 15.2,
                ),
              ),
              const SizedBox(width: 12),
              // Date and duration
              Text(
                episode['date'],
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
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
                episode['duration'],
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.1,
                ),
              ),
              const Spacer(),
              // Icons
              Icon(Icons.check, color: Colors.grey[400], size: 25),
              const SizedBox(width: 16),
              Icon(Icons.download_outlined, color: Colors.grey[600], size: 25),
            ],
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
