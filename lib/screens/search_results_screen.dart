import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/search_provider.dart';
import '../providers/music_player_provider.dart';
import '../widgets/mini_player.dart';
import 'home_screen.dart';
import 'library_screen.dart';
import 'artist_detail_screen.dart';
import 'album_detail_screen.dart';
import 'player_screen.dart';

/// Màn hình Search Results - Hiển thị kết quả tìm kiếm và lịch sử
class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({super.key});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query, SearchProvider searchProvider) {
    if (query.trim().isNotEmpty) {
      searchProvider.searchAll(query);
    } else {
      searchProvider.clearResults();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, child) {
        final hasQuery = _searchController.text.isNotEmpty;
        final showResults = hasQuery && searchProvider.hasResults;
        final showRecentSearches =
            !hasQuery && searchProvider.recentSearches.isNotEmpty;

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
                                const Icon(
                                  Icons.search,
                                  color: Colors.white,
                                  size: 15,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    autofocus: true,
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
                                    onChanged: (value) {
                                      _performSearch(value, searchProvider);
                                    },
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
                          icon: const Icon(
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
              // Content
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

                            // Loading state
                            if (searchProvider.isLoading)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(32.0),
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF1DB954),
                                  ),
                                ),
                              ),

                            // Recent searches
                            if (showRecentSearches) ...[
                              const Text(
                                'Recent searches',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ...List.generate(
                                searchProvider.recentSearches.length,
                                (index) {
                                  final item =
                                      searchProvider.recentSearches[index];
                                  if (item['type'] == 'artist') {
                                    return _buildArtistItem(
                                      item,
                                      index,
                                      searchProvider,
                                    );
                                  } else {
                                    return _buildSongItem(
                                      item,
                                      index,
                                      searchProvider,
                                    );
                                  }
                                },
                              ),
                            ],

                            // Search results
                            if (showResults && !searchProvider.isLoading) ...[
                              // Songs section
                              if (searchProvider.songs.isNotEmpty) ...[
                                const Text(
                                  'Songs',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ...searchProvider.songs.take(5).map((song) {
                                  return _buildSongResultItem(
                                    song,
                                    searchProvider,
                                  );
                                }),
                                const SizedBox(height: 24),
                              ],

                              // Artists section
                              if (searchProvider.artists.isNotEmpty) ...[
                                const Text(
                                  'Artists',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ...searchProvider.artists.take(3).map((artist) {
                                  return _buildArtistResultItem(
                                    artist,
                                    searchProvider,
                                  );
                                }),
                                const SizedBox(height: 24),
                              ],

                              // Albums section
                              if (searchProvider.albums.isNotEmpty) ...[
                                const Text(
                                  'Albums',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ...searchProvider.albums.take(3).map((album) {
                                  return _buildAlbumResultItem(
                                    album,
                                    searchProvider,
                                  );
                                }),
                                const SizedBox(height: 24),
                              ],

                              // Playlists section
                              if (searchProvider.playlists.isNotEmpty) ...[
                                const Text(
                                  'Playlists',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ...searchProvider.playlists.take(3).map((
                                  playlist,
                                ) {
                                  return _buildPlaylistResultItem(playlist);
                                }),
                              ],
                            ],

                            // Empty state
                            if (hasQuery &&
                                !searchProvider.hasResults &&
                                !searchProvider.isLoading)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(32.0),
                                  child: Text(
                                    'No results found',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),

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
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const MiniPlayer(),
              _buildBottomNavigationBar(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildArtistItem(
    Map<String, dynamic> item,
    int index,
    SearchProvider searchProvider,
  ) {
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
                searchProvider.removeFromRecentSearches(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSongItem(
    Map<String, dynamic> item,
    int index,
    SearchProvider searchProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GestureDetector(
        onTap: () {
          // Navigate based on type
          if (item['type'] == 'album') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AlbumDetailScreen(
                  albumName: item['title']!,
                  artistName: item['subtitle']!
                      .replaceAll('Album • ', '')
                      .split(',')[0]
                      .trim(),
                  albumArt: item['imageUrl'],
                ),
              ),
            );
          }
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
                searchProvider.removeFromRecentSearches(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSongResultItem(song, SearchProvider searchProvider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GestureDetector(
        onTap: () async {
          searchProvider.addToRecentSearches(
            searchProvider.createRecentSearchFromSong(song),
          );
          // Play song
          final player = Provider.of<MusicPlayerProvider>(context, listen: false);
          try {
            await player.playSong(song, queue: searchProvider.songs, initialIndex: searchProvider.songs.indexOf(song));
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
        },
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(4),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: song.artworkUrl != null
                    ? Image.network(
                        song.artworkUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(color: Colors.grey[800]!);
                        },
                      )
                    : Container(color: Colors.grey[800]),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    song.artistName,
                    style: TextStyle(color: Colors.grey[400], fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArtistResultItem(artist, SearchProvider searchProvider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GestureDetector(
        onTap: () {
          searchProvider.addToRecentSearches(
            searchProvider.createRecentSearchFromArtist(artist),
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ArtistDetailScreen(artistName: artist.name),
            ),
          );
        },
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: artist.imageUrl != null
                    ? Image.network(
                        artist.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(color: Colors.grey[800]!);
                        },
                      )
                    : Container(color: Colors.grey[800]),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    artist.name,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Artist',
                    style: TextStyle(color: Colors.grey[400], fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlbumResultItem(album, SearchProvider searchProvider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GestureDetector(
        onTap: () {
          searchProvider.addToRecentSearches(
            searchProvider.createRecentSearchFromAlbum(album),
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AlbumDetailScreen(
                albumName: album.title,
                artistName: album.artistName,
                albumArt: album.artworkUrl,
              ),
            ),
          );
        },
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
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
                        errorBuilder: (context, error, stackTrace) {
                          return Container(color: Colors.grey[800]!);
                        },
                      )
                    : Container(color: Colors.grey[800]),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    album.title,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Album • ${album.artistName}',
                    style: TextStyle(color: Colors.grey[400], fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylistResultItem(playlist) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GestureDetector(
        onTap: () {
          // Navigate to playlist detail
        },
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(4),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: playlist.artworkUrl != null
                    ? Image.network(
                        playlist.artworkUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(color: Colors.grey[800]!);
                        },
                      )
                    : Container(color: Colors.grey[800]),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist.title,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Playlist',
                    style: TextStyle(color: Colors.grey[400], fontSize: 11),
                  ),
                ],
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
