import 'package:flutter/material.dart';
import 'music_genre_screen.dart';
import 'search_results_screen.dart';
import 'home_screen.dart';
import 'library_screen.dart';

/// Màn hình Search - Hiển thị thanh tìm kiếm và các thể loại
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Header
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Search',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchResultsScreen(),
                      ),
                    );
                  },
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: TextField(
                      controller: _searchController,
                      readOnly: true,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 13.7,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Artists, songs. or podcasts',
                        hintStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 13.7,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.black,
                          size: 20,
                        ),
                        suffixIcon: Icon(
                          Icons.mic,
                          color: Colors.black,
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SearchResultsScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Your top genres Section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Your top genres',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildCategoryCard(
                        'Dance/\nElectronic',
                        const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF86B7AE), Color(0xFFA6E3D7)],
                        ),
                        'https://www.figma.com/api/mcp/asset/ae9540e6-a0ea-44cc-8a0a-b987cd3dbf73',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildCategoryCard(
                        'Rock',
                        const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFEC2137), Color(0xFFA80A1C)],
                        ),
                        'https://www.figma.com/api/mcp/asset/52c43718-e153-4b33-8a81-87b473d3b95d',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Popular podcast categories Section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Popular podcast categories',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildCategoryCard(
                        'YouTubers',
                        const LinearGradient(
                          colors: [Color(0xFF003068), Color(0xFF003068)],
                        ),
                        'https://www.figma.com/api/mcp/asset/84794e7a-f88d-469a-a553-64ee0c4ca3d1',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildCategoryCard(
                        'Comedy',
                        const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF822434), Color(0xFFF7CFD3)],
                        ),
                        'https://www.figma.com/api/mcp/asset/e2888b15-3622-4e96-83d4-241431df759b',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Browse all Section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Browse all',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildCategoryCard(
                            'Podcasts',
                            const LinearGradient(
                              colors: [Color(0xFFF4C915), Color(0xFFF4C915)],
                            ),
                            'https://www.figma.com/api/mcp/asset/0fbbee46-f0c5-4238-aff4-60f21d4cd0f8',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildCategoryCard(
                            'Charts',
                            const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFF1B7573), Color(0xFF0F4C4F)],
                            ),
                            'https://www.figma.com/api/mcp/asset/959c1066-09cc-4853-855b-a371914360fe',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildCategoryCard(
                            'Chillout',
                            const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFF9BC0C8), Color(0xFFC0D6D4)],
                            ),
                            'https://www.figma.com/api/mcp/asset/f1735998-6fe0-41e6-8a43-3cad44f9efb4',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildCategoryCard(
                            'Study\nJams',
                            const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFF5E7899), Color(0xFF99BACD)],
                            ),
                            'https://www.figma.com/api/mcp/asset/9aa2803b-98f7-42f7-94d2-c01b1322c897',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  /// Tạo Bottom Navigation Bar với style Spotify
  Widget _buildBottomNavigationBar() {
    return Container(
      height: 83,
      decoration: const BoxDecoration(color: Color(0xFF282828)),
      child: Column(
        children: [
          // Indicator bar ở trên - "Search" được chọn
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
                _buildNavItem(Icons.home, 'Home', 0),
                _buildNavItem(Icons.search, 'Search', 1),
                _buildNavItem(Icons.library_music, 'Your Library', 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Tạo từng navigation item
  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = index == 1; // "Search" is selected
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

  Widget _buildCategoryCard(String title, Gradient gradient, String imageUrl) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                MusicGenreScreen(genreName: title.replaceAll('\n', ' ')),
          ),
        );
      },
      child: Container(
        height: 104,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                ),
              ),
            ),
            // Artwork - Rotated image at bottom right
            Positioned(
              bottom: 0,
              right: -10,
              child: Transform.rotate(
                angle: 0.436, // 25 degrees in radians
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(color: Colors.white.withOpacity(0.1));
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
