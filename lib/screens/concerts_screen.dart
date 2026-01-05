import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'library_screen.dart';
import 'upcoming_concerts_screen.dart';
import '../database/database.dart';
import '../database/models/concert_model.dart';
import '../database/constants.dart';

/// Màn hình Concerts - Hiển thị danh sách concerts được đề xuất
class ConcertsScreen extends StatefulWidget {
  const ConcertsScreen({super.key});

  @override
  State<ConcertsScreen> createState() => _ConcertsScreenState();
}

class _ConcertsScreenState extends State<ConcertsScreen> {
  final DatabaseService _dbService = DatabaseService();
  List<ConcertModel> _concerts = [];
  bool _isLoading = true;
  String _currentLocation = 'Los Angeles';

  @override
  void initState() {
    super.initState();
    _checkFirestoreData();
    _loadConcerts();
  }

  Future<void> _checkFirestoreData() async {
    try {
      await FirebaseFirestore.instance
          .collection(FirestoreCollections.concerts)
          .limit(5)
          .get();
    } catch (e) {
      // Silent check
    }
  }

  Future<void> _loadConcerts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<ConcertModel> concerts;
      if (_currentLocation.isNotEmpty && _currentLocation != 'All Locations') {
        print('🎵 Đang load concerts cho location: $_currentLocation');
        concerts = await _dbService.getConcertsByLocation(
          city: _currentLocation,
          limit: 100,
        );
        print('🎵 Đã load ${concerts.length} concerts từ location: $_currentLocation');
        if (concerts.isEmpty) {
          print('⚠️ Không có concerts ở $_currentLocation, load recommended concerts');
          concerts = await _dbService.getRecommendedConcerts(limit: 100);
          print('🎵 Đã load ${concerts.length} recommended concerts');
        }
      } else {
        print('🎵 Đang load recommended concerts (All Locations)');
        concerts = await _dbService.getRecommendedConcerts(limit: 100);
        print('🎵 Đã load ${concerts.length} recommended concerts');
      }

      setState(() {
        _concerts = concerts;
      });
      print('✅ UI đã được cập nhật với ${_concerts.length} concerts');
    } catch (e, stackTrace) {
      print('❌ Lỗi khi load concerts: $e');
      print('📋 Stack trace: $stackTrace');
      setState(() {
        _concerts = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showLocationDialog() async {
    final locations = [
      'Los Angeles',
      'New York',
      'Miami',
      'San Francisco',
      'Chicago',
      'Detroit',
      'Madison',
      'All Locations',
    ];

    final selected = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF282828),
        title: const Text(
          'Change Location',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: locations.map((location) {
              final isSelected = _currentLocation == location;
              return ListTile(
                title: Text(
                  location,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF1DB954) : Colors.white,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                onTap: () => Navigator.pop(context, location),
              );
            }).toList(),
          ),
        ),
      ),
    );

    if (selected != null && selected != _currentLocation) {
      setState(() {
        _currentLocation = selected;
      });
      await _loadConcerts();
    }
  }

  String _formatDate(DateTime dateTime) {
    final weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${weekdays[dateTime.weekday % 7]}, ${months[dateTime.month - 1]} ${dateTime.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      bottomNavigationBar: _buildBottomNavigationBar(context),
      body: Stack(
        children: [
          Positioned(
            top: -60,
            left: -8,
            right: -8,
            height: 347,
            child: Stack(
              children: [
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
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 13.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60),
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
                        Text(
                          _currentLocation == 'All Locations'
                              ? 'All Locations'
                              : _currentLocation,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            letterSpacing: 0.26,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _showLocationDialog,
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              width: 156,
                              height: 24,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFF414141),
                                ),
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
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
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
                        if (_isLoading)
                          const Center(child: CircularProgressIndicator())
                        else
                          ...List.generate(_concerts.length, (index) {
                            final concert = _concerts[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        UpcomingConcertsScreen(
                                          artistName: concert.artistName,
                                        ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey,
                                      ),
                                      child: ClipOval(
                                        child: concert.imageUrl != null
                                            ? Image.network(
                                                concert.imageUrl!,
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
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            concert.title,
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
                                                _formatDate(concert.dateTime),
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
                                                  '${concert.venue.name}, ${concert.venue.city}',
                                                  style: TextStyle(
                                                    color: Colors.grey[400],
                                                    fontSize: 11,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Transform.rotate(
                                      angle: 3.14159,
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
