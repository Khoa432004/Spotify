import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/search_provider.dart';
import '../providers/music_player_provider.dart';
import '../widgets/mini_player.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'library_screen.dart';
import 'player_screen.dart';
import 'album_detail_screen.dart';

/// Màn hình Music Genre - Hiển thị chi tiết thể loại nhạc
class MusicGenreScreen extends StatefulWidget {
  final String genreName;
  final Color? genreColor;

  const MusicGenreScreen({super.key, required this.genreName, this.genreColor});

  @override
  State<MusicGenreScreen> createState() => _MusicGenreScreenState();
}

class _MusicGenreScreenState extends State<MusicGenreScreen> {
  @override
  void initState() {
    super.initState();
    // Load data by genre
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final searchProvider = context.read<SearchProvider>();
      searchProvider.searchByGenre(widget.genreName);
    });
  }

  Future<void> _playSong(BuildContext context, dynamic song, List<dynamic> queue, int index) async {
    final player = Provider.of<MusicPlayerProvider>(context, listen: false);
    try {
      await player.playSong(song, queue: queue.cast(), initialIndex: index);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PlayerScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể phát nhạc: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tags related to genre
    final List<String> tags = [
      'Popular',
      'New Releases',
      'Top Charts',
      'Playlists',
      'Artists',
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
          onPressed: () {
            print('🔙 AppBar back button pressed!');
            Navigator.pop(context);
          },
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(),
          _buildBottomNavigationBar(context),
        ],
      ),
      body: Consumer<SearchProvider>(
        builder: (context, searchProvider, child) {
          return Stack(
            children: [
              // Content
              SingleChildScrollView(
                child: Column(
                  children: [
                    // Header gradient
                    Container(
                      height: 255,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            widget.genreColor?.withOpacity(0.8) ??
                                const Color(0xFF1DB954).withOpacity(0.8),
                            const Color(0xFF121212),
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.genreName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.96,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${searchProvider.songs.length} songs, ${searchProvider.albums.length} albums',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Loading state
                    if (searchProvider.isLoading)
                      const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF1DB954),
                          ),
                        ),
                      ),

                    // Tags section
                    if (!searchProvider.isLoading) ...[
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

                      // Popular songs section
                      if (searchProvider.songs.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Popular Songs',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ...searchProvider.songs.take(10).toList().asMap().entries.map((entry) {
                                final index = entry.key;
                                final song = entry.value;
                                return GestureDetector(
                                  onTap: () => _playSong(context, song, searchProvider.songs, index),
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 12.0),
                                    child: Row(
                                      children: [
                                        // Artwork
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[800],
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            child: song.artworkUrl != null
                                                ? Image.network(
                                                    song.artworkUrl!,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) {
                                                          return Container(
                                                            color:
                                                                Colors.grey[800]!,
                                                          );
                                                        },
                                                  )
                                                : Container(
                                                    color: Colors.grey[800],
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Song info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                song.title,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                song.artistName,
                                                style: TextStyle(
                                                  color: Colors.grey[400],
                                                  fontSize: 11,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        // More button
                                        IconButton(
                                          icon: Icon(
                                            Icons.more_vert,
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
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],

                      // Albums section
                      if (searchProvider.albums.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Popular Albums',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
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
                                itemCount: searchProvider.albums.length > 6
                                    ? 6
                                    : searchProvider.albums.length,
                                itemBuilder: (context, index) {
                                  final album = searchProvider.albums[index];
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AlbumDetailScreen(
                                            albumName: album.title,
                                            artistName: album.artistName,
                                            albumArt: album.artworkUrl,
                                            albumId: album.id,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Artwork
                                        Expanded(
                                          child: Container(
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[800],
                                              borderRadius: BorderRadius.circular(
                                                4,
                                              ),
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(
                                                4,
                                              ),
                                              child: album.artworkUrl != null
                                                  ? Image.network(
                                                      album.artworkUrl!,
                                                      fit: BoxFit.cover,
                                                      errorBuilder:
                                                          (
                                                            context,
                                                            error,
                                                            stackTrace,
                                                          ) {
                                                            return Container(
                                                              color: Colors
                                                                  .grey[800]!,
                                                            );
                                                          },
                                                    )
                                                  : Container(
                                                      color: Colors.grey[800],
                                                    ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        // Album name
                                        Text(
                                          album.title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        // Artist name
                                        Text(
                                          album.artistName,
                                          style: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 11,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],

                    // Empty state
                    if (!searchProvider.isLoading &&
                        searchProvider.songs.isEmpty &&
                        searchProvider.albums.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Center(
                          child: Text(
                            'No content available for ${widget.genreName}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 100), // Space for bottom nav
                  ],
                ),
              ),
            ],
          );
        },
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
