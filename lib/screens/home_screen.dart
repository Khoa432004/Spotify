import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';
import '../widgets/playlist_card.dart';
import '../widgets/album_card.dart';
import '../widgets/section_header.dart';
import 'concerts_screen.dart';
import 'search_screen.dart';
import 'library_screen.dart';
import 'firebase_test_screen.dart';

/// Màn hình Home - Hiển thị các playlist, album gần đây và đề xuất
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // URLs của các hình ảnh từ Figma
  static const String imgArtwork1 =
      "https://www.figma.com/api/mcp/asset/27e633bd-dcfd-4618-9353-1c1f708630fd";
  static const String imgArtwork2 =
      "https://www.figma.com/api/mcp/asset/40f03944-2e21-4e6a-b4fd-22d9f52ceed9";
  static const String imgArtwork3 =
      "https://www.figma.com/api/mcp/asset/dee2f9e3-2cdd-4964-ac62-93f5b708b13f";
  static const String imgReplace1 =
      "https://www.figma.com/api/mcp/asset/8fc854b1-2d3a-4b66-9245-0f08b291a416";
  static const String imgImage1 =
      "https://www.figma.com/api/mcp/asset/46a19ee9-04e8-4358-8c0d-56a6809c3855";
  static const String imgImage2 =
      "https://www.figma.com/api/mcp/asset/df8a5e8f-b0d0-4cea-9c8a-70239122cfd4";
  static const String imgImage3 =
      "https://www.figma.com/api/mcp/asset/3c74428e-23c3-4d4b-9758-55b3591f8b2d";
  static const String imgImage4 =
      "https://www.figma.com/api/mcp/asset/fc6b37e9-6047-487a-b8d1-b22ebf9a8b4f";

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
                            const Icon(
                              Icons.settings_outlined,
                              color: Colors.white,
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
                            imageUrl: playlist.artworkUrl ?? imgArtwork1,
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
                              imageUrl: album.artworkUrl ?? imgArtwork1,
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
                              imageUrl: album.artworkUrl ?? imgArtwork1,
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 100),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
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
