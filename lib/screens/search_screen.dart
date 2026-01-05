import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/search_provider.dart';
import '../widgets/mini_player.dart';
import 'music_genre_screen.dart';
import 'search_results_screen.dart';
import 'home_screen.dart';
import 'library_screen.dart';

/// Màn hình Search - Hiển thị thanh tìm kiếm và các thể loại động từ database
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load available genres từ database khi màn hình mở
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SearchProvider>().loadAvailableGenres();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Helper: Lấy gradient cho genre
  Gradient _getGradientForGenre(String genre) {
    final gradients = {
      'Electronic': const LinearGradient(
        colors: [Color(0xFF86B7AE), Color(0xFFA6E3D7)],
      ),
      'Rock': const LinearGradient(
        colors: [Color(0xFFEC2137), Color(0xFFA80A1C)],
      ),
      'Pop': const LinearGradient(
        colors: [Color(0xFF003068), Color(0xFF005AA7)],
      ),
      'Hip-Hop': const LinearGradient(
        colors: [Color(0xFF822434), Color(0xFFF7CFD3)],
      ),
      'R&B': const LinearGradient(
        colors: [Color(0xFFF4C915), Color(0xFFE39500)],
      ),
      'Folk': const LinearGradient(
        colors: [Color(0xFF1B7573), Color(0xFF0F4C4F)],
      ),
      'Alternative': const LinearGradient(
        colors: [Color(0xFF9BC0C8), Color(0xFFC0D6D4)],
      ),
      'V-Pop': const LinearGradient(
        colors: [Color(0xFF5E7899), Color(0xFF99BACD)],
      ),
    };
    return gradients[genre] ??
        const LinearGradient(colors: [Color(0xFF1DB954), Color(0xFF0D7A33)]);
  }

  // Helper: Lấy image cho genre
  String _getImageForGenre(String genre) {
    // Sử dụng các hình ảnh có sẵn
    return 'https://www.figma.com/api/mcp/asset/ae9540e6-a0ea-44cc-8a0a-b987cd3dbf73';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, child) {
        final availableGenres = searchProvider.availableGenres;

        // Lấy top genres (lấy 2 đầu tiên nếu có)
        final topGenres = availableGenres.take(2).toList();

        // Lấy popular genres (tiếp theo 2 genres)
        final popularGenres = availableGenres.skip(2).take(2).toList();

        // Lấy browse all genres (còn lại)
        final browseGenres = availableGenres.skip(4).take(4).toList();

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
                                builder: (context) =>
                                    const SearchResultsScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Loading state
                  if (availableGenres.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF1DB954),
                        ),
                      ),
                    ),

                  // Your top genres Section (nếu có genres)
                  if (topGenres.isNotEmpty) ...[
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
                          if (topGenres.isNotEmpty)
                            Expanded(
                              child: _buildCategoryCard(
                                topGenres[0],
                                _getGradientForGenre(topGenres[0]),
                                _getImageForGenre(topGenres[0]),
                              ),
                            ),
                          if (topGenres.length > 1) ...[
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildCategoryCard(
                                topGenres[1],
                                _getGradientForGenre(topGenres[1]),
                                _getImageForGenre(topGenres[1]),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Popular music genres Section (nếu có)
                  if (popularGenres.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Popular music genres',
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
                          if (popularGenres.isNotEmpty)
                            Expanded(
                              child: _buildCategoryCard(
                                popularGenres[0],
                                _getGradientForGenre(popularGenres[0]),
                                _getImageForGenre(popularGenres[0]),
                              ),
                            ),
                          if (popularGenres.length > 1) ...[
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildCategoryCard(
                                popularGenres[1],
                                _getGradientForGenre(popularGenres[1]),
                                _getImageForGenre(popularGenres[1]),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Browse all Section (nếu có)
                  if (browseGenres.isNotEmpty) ...[
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
                          // First row
                          Row(
                            children: [
                              if (browseGenres.isNotEmpty)
                                Expanded(
                                  child: _buildCategoryCard(
                                    browseGenres[0],
                                    _getGradientForGenre(browseGenres[0]),
                                    _getImageForGenre(browseGenres[0]),
                                  ),
                                ),
                              if (browseGenres.length > 1) ...[
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildCategoryCard(
                                    browseGenres[1],
                                    _getGradientForGenre(browseGenres[1]),
                                    _getImageForGenre(browseGenres[1]),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          // Second row (nếu có đủ genres)
                          if (browseGenres.length > 2) ...[
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                if (browseGenres.length > 2)
                                  Expanded(
                                    child: _buildCategoryCard(
                                      browseGenres[2],
                                      _getGradientForGenre(browseGenres[2]),
                                      _getImageForGenre(browseGenres[2]),
                                    ),
                                  ),
                                if (browseGenres.length > 3) ...[
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildCategoryCard(
                                      browseGenres[3],
                                      _getGradientForGenre(browseGenres[3]),
                                      _getImageForGenre(browseGenres[3]),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const MiniPlayer(),
              _buildBottomNavigationBar(),
            ],
          ),
        );
      },
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
            builder: (context) => MusicGenreScreen(genreName: title),
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
