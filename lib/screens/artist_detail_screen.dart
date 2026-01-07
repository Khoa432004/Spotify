import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/mini_player.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'library_screen.dart';
import 'liked_songs_screen.dart';
import 'player_screen.dart';
import 'artists_pick_screen.dart';
import 'upcoming_concerts_screen.dart';
import '../database/firebase_setup.dart';
import '../database/models/artist_model.dart';
import '../database/models/song_model.dart';
import '../providers/music_player_provider.dart';
import '../services/song_download_service.dart';
import '../widgets/download_progress_dialog.dart';

/// Màn hình chi tiết Artist - Hiển thị thông tin artist, popular songs, liked songs
class ArtistDetailScreen extends StatefulWidget {
  final String artistName;
  final String? artistImage;
  final String? artistId; // Optional: để fetch từ database

  const ArtistDetailScreen({
    super.key,
    required this.artistName,
    this.artistImage,
    this.artistId,
  });

  @override
  State<ArtistDetailScreen> createState() => _ArtistDetailScreenState();
}

class _ArtistDetailScreenState extends State<ArtistDetailScreen> {
  bool _showFixedTitle = false;
  ArtistModel? _artist;
  List<SongModel>? _songs;
  bool _isLoading = false;
  final SongDownloadService _downloadService = SongDownloadService();
  Set<String> _downloadingSongs = {};
  Set<String> _downloadedSongs = {};

  @override
  void initState() {
    super.initState();
    _loadArtistAndSongs();
    _checkDownloadedSongs();
  }

  Future<void> _checkDownloadedSongs() async {
    if (_songs == null) return;

    try {
      for (var song in _songs!) {
        final isDownloaded = await _downloadService.isSongDownloaded(song.id);
        if (isDownloaded) {
          setState(() {
            _downloadedSongs.add(song.id);
          });
        }
      }
    } catch (e) {
      print('❌ Lỗi khi kiểm tra downloaded songs: $e');
    }
  }

  Future<void> _loadArtistAndSongs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      ArtistModel? artist;

      // Nếu có artistId, dùng nó
      if (widget.artistId != null) {
        artist = await FirebaseSetup.databaseService.getArtist(
          widget.artistId!,
        );
      } else {
        // Nếu không, tìm theo tên
        artist = await FirebaseSetup.databaseService.findArtistByName(
          widget.artistName,
        );
      }

      if (artist != null) {
        setState(() {
          _artist = artist;
        });

        // Load songs của artist
        final songs = await FirebaseSetup.databaseService.getArtistSongs(
          artist.id,
          limit: 50,
        );

        setState(() {
          _songs = songs;
          _isLoading = false;
        });

        // Kiểm tra downloaded songs sau khi load
        _checkDownloadedSongs();
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Lỗi khi load artist và songs: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _playSong(SongModel song) async {
    final player = Provider.of<MusicPlayerProvider>(context, listen: false);

    try {
      // Kiểm tra xem đã download chưa, nếu có thì dùng local file
      String audioUrl = song.audioUrl;
      final isDownloaded = await _downloadService.isSongDownloaded(song.id);
      if (isDownloaded) {
        final localPath = await _downloadService.getLocalFilePath(song.id);
        audioUrl = localPath;
        print('📦 Phát từ local file: $localPath');
      }

      if (audioUrl.isEmpty) {
        throw Exception('Song không có audio URL');
      }

      final songToPlay = song.copyWith(audioUrl: audioUrl);

      // Nếu có queue (songs), phát với queue
      if (_songs != null && _songs!.isNotEmpty) {
        final updatedSongs = _songs!.map((s) async {
          final isSDownloaded = await _downloadService.isSongDownloaded(s.id);
          if (isSDownloaded) {
            final localPath = await _downloadService.getLocalFilePath(s.id);
            return s.copyWith(audioUrl: localPath);
          }
          return s;
        }).toList();

        final resolvedSongs = await Future.wait(updatedSongs);
        final index = resolvedSongs.indexWhere((s) => s.id == song.id);
        await player.playSong(
          songToPlay,
          queue: resolvedSongs,
          initialIndex: index,
        );
      } else {
        await player.playSong(songToPlay);
      }

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PlayerScreen()),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể phát nhạc: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      print('❌ Lỗi khi phát nhạc: $e');
    }
  }

  Future<void> _handleDownloadSong(SongModel song) async {
    // Nếu đã download, xóa nó
    if (_downloadedSongs.contains(song.id)) {
      await _deleteSong(song);
      return;
    }

    // Nếu đang download, không làm gì
    if (_downloadingSongs.contains(song.id)) {
      return;
    }

    setState(() {
      _downloadingSongs.add(song.id);
    });

    // Hiển thị progress dialog
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => DownloadProgressDialog(
        title: 'Đang tải xuống',
        subtitle: song.title,
        downloadTask: (onProgress) async {
          final localPath = await _downloadService.downloadSong(
            song,
            onProgress: onProgress,
          );
          final fileSize = await _downloadService.getFileSize(song.id);

          final userId = FirebaseSetup.currentUserId ?? 'guest_user';
          if (userId != 'guest_user') {
            try {
              await FirebaseSetup.databaseService.addSongDownload(
                userId,
                song.id,
                localPath,
                fileSize,
              );
            } catch (e) {
              print('⚠️ Không thể lưu vào Firestore: $e');
            }
          }
        },
        onSuccess: () {
          setState(() {
            _downloadingSongs.remove(song.id);
            _downloadedSongs.add(song.id);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Đã tải xuống thành công'),
              backgroundColor: Color(0xFF1DB954),
              duration: Duration(seconds: 2),
            ),
          );
        },
        onError: (error) {
          setState(() {
            _downloadingSongs.remove(song.id);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Lỗi khi tải xuống: $error'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        },
      ),
    );
  }

  Future<void> _deleteSong(SongModel song) async {
    try {
      final deleted = await _downloadService.deleteSong(song.id);

      if (deleted) {
        final userId = FirebaseSetup.currentUserId ?? 'guest_user';
        if (userId != 'guest_user') {
          try {
            final fileSize = await _downloadService.getFileSize(song.id);
            await FirebaseSetup.databaseService.removeSongDownload(
              userId,
              song.id,
              fileSize,
            );
          } catch (e) {
            print('⚠️ Không thể xóa khỏi Firestore: $e');
          }
        }

        setState(() {
          _downloadedSongs.remove(song.id);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🗑️ Đã xóa file đã tải'),
              backgroundColor: Colors.grey,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi khi xóa: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final artistName = widget.artistName;
    final monthlyListeners = _artist?.monthlyListeners ?? 1516018;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [const MiniPlayer(), _buildBottomNavigationBar(context)],
      ),
      body: Stack(
        children: [
          // Header with artist image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 408,
            child: Stack(
              children: [
                // Artist image background
                Positioned.fill(
                  child: Image.network(
                    'https://www.figma.com/api/mcp/asset/765a9423-4948-4200-aae0-7dd7d761f704',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(color: Colors.grey[900]!);
                    },
                  ),
                ),
                // Gradient overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.05),
                          Colors.black.withOpacity(0.27),
                        ],
                        stops: const [0.049, 0.27],
                      ),
                    ),
                  ),
                ),
                // Back button (always visible in header)
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.5),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                // Artist name (fixed at bottom of header)
                Positioned(
                  bottom: 0,
                  left: 15,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      artistName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 55,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.65,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content (scrollable)
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollUpdateNotification) {
                final shouldShow = notification.metrics.pixels > 300;
                if (shouldShow != _showFixedTitle) {
                  setState(() {
                    _showFixedTitle = shouldShow;
                  });
                }
              }
              return false;
            },
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 408),
                  // Controls section
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Monthly listeners
                        Text(
                          '${_formatNumber(monthlyListeners)} monthly listeners',
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 11.3,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.09,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Controls row
                        Row(
                          children: [
                            // Following button
                            Container(
                              width: 95,
                              height: 28,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: const Center(
                                child: Text(
                                  'FOLLOWING',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            // More icon with menu
                            PopupMenuButton<String>(
                              icon: Icon(
                                Icons.more_horiz,
                                color: Colors.grey[400],
                                size: 24,
                              ),
                              color: const Color(0xFF282828),
                              onSelected: (value) {
                                if (value == 'artists_pick') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ArtistsPickScreen(
                                        artistName: artistName,
                                      ),
                                    ),
                                  );
                                } else if (value == 'concerts') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          UpcomingConcertsScreen(
                                            artistName: artistName,
                                          ),
                                    ),
                                  );
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'artists_pick',
                                  child: const Text(
                                    'Artist\'s Pick',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'concerts',
                                  child: const Text(
                                    'Concerts',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            // Play & Shuffle
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // Play button
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const PlayerScreen(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 56,
                                    height: 56,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.play_arrow,
                                      color: Colors.black,
                                      size: 28,
                                    ),
                                  ),
                                ),
                                // Shuffle button
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF57B560),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.shuffle,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Liked songs section
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LikedSongsScreen(),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              // Liked songs image
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: 37.5,
                                    height: 37.5,
                                    decoration: const BoxDecoration(
                                      color: Colors.grey,
                                      shape: BoxShape.circle,
                                    ),
                                    child: ClipOval(
                                      child: Image.network(
                                        'https://www.figma.com/api/mcp/asset/1d407621-3269-42ec-ae11-273867afae43',
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Container(
                                                color: Colors.grey[800]!,
                                              );
                                            },
                                      ),
                                    ),
                                  ),
                                  // Like icon overlay
                                  Positioned(
                                    bottom: -2,
                                    right: -2,
                                    child: Container(
                                      width: 19,
                                      height: 19,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF1DB954),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.favorite,
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              // Liked songs info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Liked songs',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          '30 songs',
                                          style: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 11.4,
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
                                        Text(
                                          artistName,
                                          style: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 11.4,
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
                        const SizedBox(height: 40),
                        // Popular section
                        const Text(
                          'Popular',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Loading indicator
                        if (_isLoading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        // Popular songs list from database
                        else if (_songs != null && _songs!.isNotEmpty)
                          ...List.generate(_songs!.length, (index) {
                            final song = _songs![index];
                            return GestureDetector(
                              onTap: () => _playSong(song),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Row(
                                  children: [
                                    // Number
                                    SizedBox(
                                      width: 22,
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Artwork
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
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _formatPlayCount(song.playCount),
                                            style: TextStyle(
                                              color: Colors.grey[400],
                                              fontSize: 11.8,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // More icon with download menu
                                    PopupMenuButton<String>(
                                      icon: Icon(
                                        Icons.more_horiz,
                                        color: Colors.grey[400],
                                        size: 20,
                                      ),
                                      color: const Color(0xFF282828),
                                      onSelected: (value) {
                                        if (value == 'download') {
                                          _handleDownloadSong(song);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          value: 'download',
                                          child: Row(
                                            children: [
                                              Icon(
                                                _downloadedSongs.contains(
                                                      song.id,
                                                    )
                                                    ? Icons.download_done
                                                    : Icons.download,
                                                color:
                                                    _downloadedSongs.contains(
                                                      song.id,
                                                    )
                                                    ? const Color(0xFF1DB954)
                                                    : Colors.white,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                _downloadedSongs.contains(
                                                      song.id,
                                                    )
                                                    ? 'Đã tải xuống'
                                                    : 'Tải xuống',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          })
                        // Empty state
                        else if (!_isLoading &&
                            (_songs == null || _songs!.isEmpty))
                          Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Center(
                              child: Text(
                                'Chưa có bài hát nào',
                                style: TextStyle(color: Colors.grey[400]),
                              ),
                            ),
                          ),
                        const SizedBox(height: 100), // Space for bottom nav
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Fixed title bar (appears when scrolling - must be last in Stack to be on top)
          IgnorePointer(
            ignoring: !_showFixedTitle,
            child: AnimatedOpacity(
              opacity: _showFixedTitle ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: SafeArea(
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF121212).withOpacity(0.95),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          artistName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _formatPlayCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
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
