import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'library_screen.dart';
import 'artist_detail_screen.dart';
import 'album_detail_screen.dart';

/// Màn hình Search Results - Hiển thị recent searches và keyboard
class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({super.key});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _recentSearches = [
    {
      'type': 'artist',
      'title': 'Tycho',
      'subtitle': 'Artist',
      'imageUrl':
          'https://www.figma.com/api/mcp/asset/a47c2ff4-b3cf-440f-8b5b-8cb424b2bf5c',
    },
    {
      'type': 'song',
      'title': 'Heart in the Pipes (KAUF Remix)',
      'subtitle': 'Song • Tony Castles, Kauf',
      'imageUrl':
          'https://www.figma.com/api/mcp/asset/0dd4dc44-1c83-4972-b6fa-aca4c81ca552',
    },
    {
      'type': 'song',
      'title': 'Slow Poison',
      'subtitle': 'Song • The Bravery',
      'imageUrl':
          'https://www.figma.com/api/mcp/asset/0ae7ef33-8c99-4f9c-84f3-69b04305c89f',
    },
    {
      'type': 'song',
      'title': 'Things I Can\'t Change',
      'subtitle': 'Song • The Story So Far',
      'imageUrl':
          'https://www.figma.com/api/mcp/asset/ffcad60c-15fc-4e83-8795-3111cb53cc82',
    },
    {
      'type': 'song',
      'title': 'Body',
      'subtitle': 'Song • Loud Luxury',
      'imageUrl':
          'https://www.figma.com/api/mcp/asset/4d27235a-5492-4c85-b781-36bdf7de6424',
    },
    {
      'type': 'song',
      'title': 'Sunflower (ft. Swae Lee)',
      'subtitle': 'Song • Post Malone, Swae Lee',
      'imageUrl':
          'https://www.figma.com/api/mcp/asset/0308a125-16de-41ac-b0c5-355541985321',
    },
    {
      'type': 'song',
      'title': 'You',
      'subtitle': 'Song • Galantis',
      'imageUrl':
          'https://www.figma.com/api/mcp/asset/74d55079-4c93-497c-860a-99d305e644d9',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _removeSearchItem(int index) {
    setState(() {
      _recentSearches.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Column(
            children: [
              // Header
              Container(
                height: 88,
                decoration: const BoxDecoration(color: Color(0xFF191919)),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    child: Row(
                      children: [
                        // Search bar
                        Expanded(
                          child: Container(
                            height: 28,
                            decoration: BoxDecoration(
                              color: const Color(0xFF242424),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 22),
                                Icon(
                                  Icons.search,
                                  color: Colors.white,
                                  size: 15,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.5,
                                      letterSpacing: -0.29,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: 'Search',
                                      hintStyle: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.5,
                                        letterSpacing: -0.29,
                                      ),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 6,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Cancel button
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.white, fontSize: 11),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Camera icon
                        IconButton(
                          icon: Icon(
                            Icons.camera_alt_outlined,
                            color: Colors.white,
                            size: 23,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Content with mic button overlay
              Expanded(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            // Recent searches title
                            const Text(
                              'Recent searches',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Recent searches list
                            ...List.generate(_recentSearches.length, (index) {
                              final item = _recentSearches[index];
                              if (item['type'] == 'artist') {
                                return _buildArtistItem(index);
                              } else if (item['type'] == 'song') {
                                return _buildSongItem(index);
                              }
                              return const SizedBox.shrink();
                            }),
                            const SizedBox(height: 120), // Space for mic button
                          ],
                        ),
                      ),
                    ),
                    // Mic button
                    Positioned(
                      right: 16,
                      bottom: 140,
                      child: Container(
                        width: 59,
                        height: 59,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.mic,
                            color: Color(0xFFBC3033),
                            size: 30,
                          ),
                          onPressed: () {},
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildArtistItem(int index) {
    final item = _recentSearches[index];
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ArtistDetailScreen(artistName: item['title']!),
            ),
          );
        },
        child: Row(
          children: [
            // Artist image (circular)
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: item['imageUrl'] != null
                    ? Image.network(
                        item['imageUrl']!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(color: Colors.grey[800]!);
                        },
                      )
                    : Container(color: Colors.grey[800]),
              ),
            ),
            const SizedBox(width: 12),
            // Artist info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title']!,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['subtitle']!,
                    style: TextStyle(color: Colors.grey[400], fontSize: 11),
                  ),
                ],
              ),
            ),
            // Close button
            IconButton(
              icon: Icon(Icons.close, color: Colors.grey[400], size: 15),
              onPressed: () {
                _removeSearchItem(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSongItem(int index) {
    final item = _recentSearches[index];
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GestureDetector(
        onTap: () {
          // Navigate to song detail or album
          final artistName = item['subtitle']
              .toString()
              .replaceAll('Song • ', '')
              .split(',')[0]
              .trim();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AlbumDetailScreen(
                albumName: item['title']!,
                artistName: artistName,
                albumArt: item['imageUrl'],
              ),
            ),
          );
        },
        child: Row(
          children: [
            // Song artwork (square)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(4),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: item['imageUrl'] != null
                    ? Image.network(
                        item['imageUrl']!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(color: Colors.grey[800]!);
                        },
                      )
                    : Container(color: Colors.grey[800]),
              ),
            ),
            const SizedBox(width: 12),
            // Song info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title']!,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['subtitle']!,
                    style: TextStyle(color: Colors.grey[400], fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Close button
            IconButton(
              icon: Icon(Icons.close, color: Colors.grey[400], size: 15),
              onPressed: () {
                _removeSearchItem(index);
              },
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
          // Already on search screen
          Navigator.pop(context);
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
