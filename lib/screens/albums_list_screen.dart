import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../widgets/mini_player.dart';
import 'album_detail_screen.dart';
import 'artists_list_screen.dart';
import 'library_screen.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'podcasts_screen.dart';
import '../database/firebase_setup.dart';
import '../database/models/album_model.dart';

/// Màn hình danh sách Albums trong Library
class AlbumsListScreen extends StatefulWidget {
  const AlbumsListScreen({super.key});

  @override
  State<AlbumsListScreen> createState() => _AlbumsListScreenState();
}

class _AlbumsListScreenState extends State<AlbumsListScreen> {
  List<AlbumModel> _albums = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadAlbums();
  }

  Future<void> _loadAlbums() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final albums = await FirebaseSetup.databaseService.getAlbums(limit: 100);
      setState(() {
        _albums = albums;
        _isLoading = false;
      });
      print('📀 Loaded ${albums.length} albums from database');
    } catch (e) {
      print('❌ Lỗi khi load albums: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<AlbumModel> get _filteredAlbums {
    if (_searchQuery.isEmpty) {
      return _albums;
    }
    final query = _searchQuery.toLowerCase();
    return _albums.where((album) {
      return album.title.toLowerCase().contains(query) ||
          album.artistName.toLowerCase().contains(query);
    }).toList();
  }

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
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [const MiniPlayer(), _buildBottomNavigationBar(context)],
      ),
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
                          Expanded(
                            child: TextField(
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.23,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Find in albums',
                                hintStyle: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.23,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                              },
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredAlbums.isEmpty
                  ? Center(
                      child: Text(
                        _searchQuery.isEmpty
                            ? 'Chưa có album nào'
                            : 'Không tìm thấy album',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    )
                  : ListView.builder(
                      clipBehavior: Clip.hardEdge,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: _filteredAlbums.length,
                      itemBuilder: (context, index) {
                        final album = _filteredAlbums[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AlbumDetailScreen(
                                    albumName: album.title,
                                    artistName: album.artistName,
                                    albumArt: album.artworkUrl,
                                    albumId: album
                                        .id, // Truyền albumId để load songs
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
                                    child: album.artworkUrl != null
                                        ? Image.network(
                                            album.artworkUrl!,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        album.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -0.28,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        album.artistName,
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
