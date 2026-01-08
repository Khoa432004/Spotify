import 'package:flutter/material.dart';
import '../widgets/mini_player.dart';
import 'liked_songs_screen.dart';
import 'albums_list_screen.dart';
import 'artists_list_screen.dart';
import 'podcasts_screen.dart';
import 'downloads_screen.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'artist_detail_screen.dart';
import '../database/firebase_setup.dart';
import '../database/models/artist_model.dart';

/// Màn hình Library - Hiển thị thư viện cá nhân với playlists, artists, albums
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String _selectedFilter = 'Playlists';

  // Danh sách các bộ lọc
  final List<String> _filters = ['Playlists', 'Artists', 'Albums', 'Podcasts', 'Downloads'];

  // Dữ liệu mẫu cho playlists
  final List<Map<String, String>> _playlists = [
    {'title': 'Liked Songs', 'subtitle': '127 songs', 'icon': 'favorite'},
    {
      'title': 'Chill Vibes',
      'subtitle': 'Playlist • 45 songs',
      'icon': 'playlist',
    },
    {
      'title': 'Workout Mix',
      'subtitle': 'Playlist • 32 songs',
      'icon': 'playlist',
    },
    {
      'title': 'Study Focus',
      'subtitle': 'Playlist • 68 songs',
      'icon': 'playlist',
    },
    {
      'title': 'Road Trip',
      'subtitle': 'Playlist • 54 songs',
      'icon': 'playlist',
    },
    {
      'title': 'Party Hits',
      'subtitle': 'Playlist • 89 songs',
      'icon': 'playlist',
    },
  ];

  // Dữ liệu cho artists
  List<ArtistModel> _artists = [];
  bool _isLoadingArtists = false;

  @override
  void initState() {
    super.initState();
    _loadArtists();
  }

  Future<void> _loadArtists() async {
    final userId = FirebaseSetup.currentUserId;
    if (userId == null) return;

    setState(() {
      _isLoadingArtists = true;
    });

    try {
      final artists = await FirebaseSetup.databaseService.getLikedArtists(userId);
      setState(() {
        _artists = artists;
        _isLoadingArtists = false;
      });
    } catch (e) {
      print('Error loading artists: $e');
      setState(() {
        _isLoadingArtists = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header với icon và title
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Avatar/Icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Title
                  const Text(
                    'Your Library',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  // Search icon
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () {},
                  ),
                  // Add icon
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // Filter chips
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = filter == _selectedFilter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });

                        // Navigate to corresponding screen only for some filters
                        if (filter == 'Albums') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AlbumsListScreen(),
                            ),
                          );
                        } else if (filter == 'Artists') {
                          // Artists will be shown in the same screen
                          _loadArtists();
                        } else if (filter == 'Podcasts') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PodcastsScreen(),
                            ),
                          );
                        } else if (filter == 'Downloads') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DownloadsScreen(),
                            ),
                          );
                        }
                      },
                      backgroundColor: Colors.grey[900],
                      selectedColor: const Color(0xFF1DB954),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      checkmarkColor: Colors.black,
                      side: BorderSide.none,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // Sort button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Icon(Icons.swap_vert, color: Colors.grey[400], size: 20),
                  const SizedBox(width: 4),
                  Text(
                    'Recently played',
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // List of playlists or artists based on selected filter
            Expanded(
              child: _selectedFilter == 'Artists'
                  ? _buildArtistsList()
                  : _buildPlaylistsList(),
            ),
          ],
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
  }

  /// Tạo Bottom Navigation Bar với style Spotify
  Widget _buildBottomNavigationBar() {
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

  Widget _buildLibraryItem({
    required String title,
    required String subtitle,
    bool isLikedSongs = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          // Thumbnail
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isLikedSongs ? const Color(0xFF1DB954) : Colors.grey[800],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              isLikedSongs ? Icons.favorite : Icons.music_note,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 12),
          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build playlists list
  Widget _buildPlaylistsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: _playlists.length,
      itemBuilder: (context, index) {
        final playlist = _playlists[index];
        final isLikedSongs = playlist['icon'] == 'favorite';
        return GestureDetector(
          onTap: isLikedSongs
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LikedSongsScreen(),
                    ),
                  );
                }
              : null,
          child: _buildLibraryItem(
            title: playlist['title']!,
            subtitle: playlist['subtitle']!,
            isLikedSongs: isLikedSongs,
          ),
        );
      },
    );
  }

  /// Build artists list
  Widget _buildArtistsList() {
    if (_isLoadingArtists) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF1DB954),
        ),
      );
    }

    if (_artists.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_outline,
                size: 64,
                color: Colors.grey[600],
              ),
              const SizedBox(height: 16),
              Text(
                'No artists yet',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Follow artists to see them here',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: _artists.length,
      itemBuilder: (context, index) {
        final artist = _artists[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ArtistDetailScreen(
                  artistName: artist.name,
                  artistImage: artist.imageUrl,
                  artistId: artist.id,
                ),
              ),
            );
          },
          child: _buildArtistItem(artist),
        );
      },
    );
  }

  /// Build artist item
  Widget _buildArtistItem(ArtistModel artist) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          // Artist image
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(4),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: artist.imageUrl != null && artist.imageUrl!.isNotEmpty
                  ? Image.network(
                      artist.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[800],
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 32,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[800],
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Artist name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  artist.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Artist',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
