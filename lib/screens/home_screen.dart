import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/firebase_setup.dart';
import '../providers/home_provider.dart';
import '../widgets/playlist_card.dart';
import '../widgets/album_card.dart';
import '../widgets/section_header.dart';
import '../widgets/mini_player.dart';
import '../providers/music_player_provider.dart';
import 'concerts_screen.dart';
import 'search_screen.dart';
import 'library_screen.dart';
import 'firebase_test_screen.dart';
import 'album_detail_screen.dart';
import 'artist_songs_screen.dart';

/// Màn hình Home - Hiển thị các playlist, album gần đây và đề xuất
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Placeholder image khi không có artwork
  static const String defaultArtwork =
      "https://i.scdn.co/image/ab67616d0000b273bb54dde68cd23e2a268ae0f5";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Consumer<HomeProvider>(
            builder: (context, homeProvider, child) {
              if (homeProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Bar
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ConcertsScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Concerts',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.cloud_done,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const FirebaseTestScreen(),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.logout,
                                color: Colors.white,
                              ),
                              onPressed: () async {
                                // Sign out
                                try {
                                  await FirebaseSetup.auth.signOut();
                                } catch (e) {
                                  // ignore
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Good Afternoon Section
                  const SectionHeader(title: 'Good afternoon', fontSize: 24),
                  const SizedBox(height: 16),

                  // Quick Access Grid
                  if (homeProvider.quickAccessPlaylists.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: homeProvider.quickAccessPlaylists.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio:
                                  3, // Adjust aspect ratio for card shape
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                        itemBuilder: (context, index) {
                          final playlist =
                              homeProvider.quickAccessPlaylists[index];
                          return PlaylistCard(
                            title: playlist.title,
                            imageUrl: playlist.artworkUrl ?? defaultArtwork,
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 32),

                  // Recently Played Section
                  if (homeProvider.recentlyPlayedAlbums.isNotEmpty) ...[
                    const SectionHeader(title: 'Recently played'),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 170,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: homeProvider.recentlyPlayedAlbums.length,
                        itemBuilder: (context, index) {
                          final album =
                              homeProvider.recentlyPlayedAlbums[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: AlbumCard(
                              title: album.title,
                              imageUrl: album.artworkUrl ?? defaultArtwork,
                              albumId: album.id,
                              artistName: album.artistName,
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
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Made for You Section
                  if (homeProvider.madeForYouAlbums.isNotEmpty) ...[
                    const SectionHeader(title: 'Made for You'),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 190,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: homeProvider.madeForYouAlbums.length,
                        itemBuilder: (context, index) {
                          final album = homeProvider.madeForYouAlbums[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: LargeAlbumCard(
                              imageUrl: album.artworkUrl ?? defaultArtwork,
                              albumId: album.id,
                              title: album.title,
                              artistName: album.artistName,
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
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Artists for Made for You
                    if (homeProvider.madeForYouArtists.isNotEmpty) ...[
                      const SectionHeader(title: 'More from these artists'),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: homeProvider.madeForYouArtists.length,
                          itemBuilder: (context, aIndex) {
                            final artist = homeProvider.madeForYouArtists[aIndex];
                            return Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ArtistSongsScreen(artist: artist),
                                    ),
                                  );
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 88,
                                      height: 88,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.grey[800],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: artist.imageUrl != null
                                            ? Image.network(artist.imageUrl!, fit: BoxFit.cover)
                                            : const Icon(Icons.person, color: Colors.white38, size: 40),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    SizedBox(
                                      width: 88,
                                      child: Text(
                                        artist.name,
                                        style: const TextStyle(color: Colors.white, fontSize: 12),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],

                  const SizedBox(height: 100),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(),
          _buildBottomNavigationBar(context),
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
          // Indicator bar ở trên - "Home" được chọn
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
    final isSelected = index == 0; // "Home" is selected
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
