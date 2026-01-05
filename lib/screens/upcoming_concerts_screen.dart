import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'library_screen.dart';
import 'concerts_screen.dart';
import '../database/database.dart';
import '../database/models/concert_model.dart';
import '../database/constants.dart';

/// Màn hình Upcoming Concerts - Hiển thị concerts sắp tới của một artist
class UpcomingConcertsScreen extends StatefulWidget {
  final String artistName;

  const UpcomingConcertsScreen({super.key, this.artistName = 'Tycho'});

  @override
  State<UpcomingConcertsScreen> createState() => _UpcomingConcertsScreenState();
}

class _UpcomingConcertsScreenState extends State<UpcomingConcertsScreen> {
  final DatabaseService _dbService = DatabaseService();
  List<ConcertModel> _nearLocationConcerts = [];
  List<ConcertModel> _otherLocationConcerts = [];
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
          .where('status', isEqualTo: 'upcoming')
          .limit(10)
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
      final allConcerts = await _dbService.getUpcomingConcerts(
        artistId: null,
        limit: 100,
      );

      final artistConcerts = allConcerts
          .where(
            (c) =>
                c.artistName.toLowerCase() == widget.artistName.toLowerCase(),
          )
          .toList();

      _nearLocationConcerts = artistConcerts
          .where(
            (c) => c.venue.city.toLowerCase() == _currentLocation.toLowerCase(),
          )
          .toList();

      _otherLocationConcerts = artistConcerts
          .where(
            (c) => c.venue.city.toLowerCase() != _currentLocation.toLowerCase(),
          )
          .toList();

      _nearLocationConcerts.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      _otherLocationConcerts.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    } catch (e) {
      setState(() {
        _nearLocationConcerts = [];
        _otherLocationConcerts = [];
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
      'Morrison',
      'Pelham',
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
    return '${weekdays[dateTime.weekday % 7]}, ${dateTime.hour == 0
        ? '12'
        : dateTime.hour > 12
        ? (dateTime.hour - 12).toString()
        : dateTime.hour.toString()} ${dateTime.hour >= 12 ? 'PM' : 'AM'}';
  }

  String _formatDay(DateTime dateTime) {
    return dateTime.day.toString();
  }

  String _formatMonth(DateTime dateTime) {
    final months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return months[dateTime.month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      bottomNavigationBar: _buildBottomNavigationBar(context),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 88,
              decoration: const BoxDecoration(color: Color(0xFF191919)),
              child: Row(
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
                  Expanded(
                    child: Center(
                      child: Text(
                        widget.artistName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Near $_currentLocation',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_nearLocationConcerts.isEmpty)
                      Text(
                        'This artist has no upcoming concerts near $_currentLocation.',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      )
                    else
                      ...List.generate(_nearLocationConcerts.length, (index) {
                        final concert = _nearLocationConcerts[index];
                        return _buildConcertCard(concert);
                      }),
                    const SizedBox(height: 16),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _showLocationDialog,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
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
                      ),
                    ),
                    const SizedBox(height: 48),
                    const Text(
                      'Other Locations',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      ...List.generate(_otherLocationConcerts.length, (index) {
                        final concert = _otherLocationConcerts[index];
                        return _buildConcertCard(concert);
                      }),
                    const SizedBox(height: 32),
                    Text(
                      'To see more concerts by artists you love',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
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

  Widget _buildConcertCard(ConcertModel concert) {
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
                    _formatDay(concert.dateTime),
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
                      _formatMonth(concert.dateTime),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  concert.title,
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
                      _formatDate(concert.dateTime),
                      style: TextStyle(color: Colors.grey[400], fontSize: 11.3),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
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
                        style: TextStyle(color: Colors.grey[400], fontSize: 11),
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
