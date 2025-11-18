import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'library_screen.dart';
import 'concerts_screen.dart';

/// Màn hình Upcoming Concerts - Hiển thị concerts sắp tới của một artist
class UpcomingConcertsScreen extends StatelessWidget {
  final String artistName;

  const UpcomingConcertsScreen({super.key, this.artistName = 'Tycho'});

  final List<Map<String, String>> _otherLocationConcerts = const [
    {
      'venue': 'STS9 with Tycho and Chrome Sparks at Red Roc...',
      'date': 'Sat, 5 PM',
      'location': 'Red Rocks Amphitheatre, Morrison',
      'day': '25',
      'month': 'JUL',
    },
    {
      'venue': 'Rescheduled - III Points',
      'date': 'Fri. 8 PM',
      'location': 'Mana Wynwood, Miami',
      'day': '16',
      'month': 'OCT',
    },
    {
      'venue': 'Tycho with Com Truise at The Caverns (Decemb...',
      'date': 'Sat, 8 PM',
      'location': 'The Caverns, Pelham',
      'day': '5',
      'month': 'DEC',
    },
    {
      'venue': 'Backwoods at Mulberry Mountain 2021',
      'date': 'Thu, 2 PM',
      'location': 'Mulberry Mountain Lodging and Events, Ozark',
      'day': '29',
      'month': 'APR',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      bottomNavigationBar: _buildBottomNavigationBar(context),
      body: SafeArea(
        child: Column(
          children: [
                // Header
                Container(
                  height: 88,
                  decoration: const BoxDecoration(color: Color(0xFF191919)),
                  child: Row(
                    children: [
                      // Back button
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
                      // Title
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Tycho',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // Balance space
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Near Los Angeles section
                        const Text(
                          'Near Los Angeles',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'This artist has no upcoming concerts near Los Angeles.',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        // Change Location button
                        Container(
                          width: 170,
                          height: 28,
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
                        const SizedBox(height: 48),
                        // Other Locations section
                        const Text(
                          'Other Locations',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Concert list
                        ...List.generate(_otherLocationConcerts.length, (
                          index,
                        ) {
                          final concert = _otherLocationConcerts[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Row(
                              children: [
                                // Calendar icon
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    // Date box
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(4),
                                          topRight: Radius.circular(4),
                                          bottomLeft: Radius.circular(4),
                                          bottomRight: Radius.circular(4),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          concert['day']!,
                                          style: const TextStyle(
                                            color: Color(0xFF282828),
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Month box
                                    Positioned(
                                      top: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        height: 15,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFBC3033),
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(4),
                                            topRight: Radius.circular(4),
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            concert['month']!,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                // Concert info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        concert['venue']!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.5,
                                          letterSpacing: -0.2175,
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
                                              fontSize: 11.3,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
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
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 32),
                        // More concerts section
                        Text(
                          'To see more concerts by artists you love',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        // Browse All Concerts button
                        Container(
                          width: 196,
                          height: 28,
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFF414141)),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ConcertsScreen(),
                                ),
                              );
                            },
                            child: const Center(
                              child: Text(
                                'BROWSE ALL CONCERTS',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 100), // Space for bottom nav
                      ],
                    ),
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
