import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'library_screen.dart';
import 'upcoming_concerts_screen.dart';

/// Màn hình Concerts - Hiển thị danh sách concerts được đề xuất
class ConcertsScreen extends StatelessWidget {
  const ConcertsScreen({super.key});

  // Recommended concerts data
  final List<Map<String, dynamic>> _concerts = const [
    {
      'artist': 'blink-182, Simple Plan and grandson',
      'date': 'Thu, Jul 16',
      'location': 'Harris Park',
      'imageUrl':
          'https://www.figma.com/api/mcp/asset/62f56cdb-e4b9-4089-964d-9722575a049a',
    },
    {
      'artist': 'Louis The Child, Jai Wolf and MEMBA',
      'date': 'Fri, Aug 7',
      'location': 'Masonic Temple',
      'imageUrl':
          'https://www.figma.com/api/mcp/asset/b4f2745e-5d71-43eb-9c37-25cd46fca191',
    },
    {
      'artist': 'Jimmy Eat World, The Front Bottoms and Tur...',
      'date': 'Fri, Aug 21',
      'location': 'The Fillmore',
      'imageUrl':
          'https://www.figma.com/api/mcp/asset/fb659422-87f8-4108-8abe-2a2569f5af93',
    },
    {
      'artist': 'Lane 8 and Sultan + Shepard',
      'date': 'Fri, Aug 21',
      'location': 'Majestic Theatre',
      'imageUrl':
          'https://www.figma.com/api/mcp/asset/b6c6f85e-919a-434a-98e6-6cd52a7b8718',
    },
    {
      'artist': 'Luttrell',
      'date': 'Thu, Aug 27',
      'location': 'Magic Stick',
      'imageUrl':
          'https://www.figma.com/api/mcp/asset/40cae6cb-e0c6-447f-a785-8660aea92061',
    },
    {
      'artist': 'Marshmello',
      'date': 'Wed, Sep 9',
      'location': 'Masonic Temple Theatre',
      'imageUrl':
          'https://www.figma.com/api/mcp/asset/871b2985-22e8-4b21-a514-29b6e966566b',
    },
    {
      'artist': 'RAC and Hotel Garuda',
      'date': 'Sat, Sep 12',
      'location': 'El Club',
      'imageUrl':
          'https://www.figma.com/api/mcp/asset/51e022cf-6593-40f3-939d-d8f5b01214b1',
    },
    {
      'artist': 'Galantis',
      'date': 'Sat, Sep 19',
      'location': 'Ford Field',
      'imageUrl':
          'https://www.figma.com/api/mcp/asset/154c32ba-d172-4389-95be-72ca39370e96',
    },
    {
      'artist': 'Foo Fighters',
      'date': 'Thu,Jul 16',
      'location': 'Harris Park',
      'imageUrl':
          'https://www.figma.com/api/mcp/asset/aac6d9dd-a5c5-44af-8728-9d0cb8f0a82c',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      bottomNavigationBar: _buildBottomNavigationBar(context),
      body: Stack(
        children: [
          // Header with gradient overlay
          Positioned(
            top: -60,
            left: -8,
            right: -8,
            height: 347,
            child: Stack(
              children: [
                // Background image with opacity
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.35,
                    child: Image.network(
                      'https://www.figma.com/api/mcp/asset/e1546a57-654e-49b6-b453-0f9d73cf5608',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(color: Colors.grey[900]!);
                      },
                    ),
                  ),
                ),
                // Gradient overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          const Color(0xFF121212).withOpacity(1.0),
                          const Color(0xFF121212).withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),
                // Header content
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 13.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60),
                        // Back button - đặt ở đây để đảm bảo hiển thị trên cùng
                        Row(
                          children: [
                            Material(
                              color: Colors.transparent,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                        const SizedBox(height: 32),
                        // Title
                        const Text(
                          'Concerts',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -1.1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Location
                        const Text(
                          'Los Angeles',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            letterSpacing: 0.26,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Change Location button
                        Container(
                          width: 156,
                          height: 24,
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFF414141)),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Center(
                            child: Text(
                              'CHANGE LOCATION',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 287),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Recommended For You section
                        const Text(
                          'Recommended For You',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.77,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Concert list
                        ...List.generate(_concerts.length, (index) {
                          final concert = _concerts[index];
                          return GestureDetector(
                            onTap: () {
                              // Navigate to concert detail or upcoming concerts
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UpcomingConcertsScreen(
                                    artistName: concert['artist']
                                        .toString()
                                        .split(',')[0]
                                        .trim(),
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Row(
                                children: [
                                  // Artist image
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey,
                                    ),
                                    child: ClipOval(
                                      child: concert['imageUrl'] != null
                                          ? Image.network(
                                              concert['imageUrl']!,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    return Container(
                                                      color: Colors.grey[800]!,
                                                    );
                                                  },
                                            )
                                          : Container(color: Colors.grey[800]),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Concert info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          concert['artist']!,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            letterSpacing: 0.042,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              concert['date']!,
                                              style: TextStyle(
                                                color: Colors.grey[400],
                                                fontSize: 11,
                                                letterSpacing: 0.33,
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 3,
                                                  ),
                                              child: Container(
                                                width: 3,
                                                height: 3,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[400],
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                concert['location']!,
                                                style: TextStyle(
                                                  color: Colors.grey[400],
                                                  fontSize: 11,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Arrow
                                  Transform.rotate(
                                    angle: 3.14159, // 180 degrees
                                    child: Icon(
                                      Icons.arrow_back,
                                      color: Colors.grey[400],
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 100), // Space for bottom nav
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
