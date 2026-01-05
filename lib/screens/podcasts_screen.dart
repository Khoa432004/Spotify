import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'library_screen.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'player_screen.dart';
import '../database/database.dart';
import '../database/firebase_setup.dart';
import '../database/models/podcast_model.dart';
import '../database/models/song_model.dart';
import '../providers/music_player_provider.dart';
import '../services/podcast_download_service.dart';

/// Màn hình Podcasts - Hiển thị danh sách podcast episodes
class PodcastsScreen extends StatefulWidget {
  const PodcastsScreen({super.key});

  @override
  State<PodcastsScreen> createState() => _PodcastsScreenState();
}

class _PodcastsScreenState extends State<PodcastsScreen> {
  String _selectedTab = 'Episodes';
  final DatabaseService _dbService = DatabaseService();
  final PodcastDownloadService _downloadService = PodcastDownloadService();
  List<PodcastEpisodeModel> _episodes = [];
  bool _isLoading = true;
  Set<String> _downloadingEpisodes = {}; // Track episodes đang download
  Set<String> _downloadedEpisodes = {}; // Track episodes đã download

  @override
  void initState() {
    super.initState();
    _loadEpisodes();
    _checkDownloadedEpisodes();
  }

  Future<void> _checkDownloadedEpisodes() async {
    try {
      for (var episode in _episodes) {
        final isDownloaded = await _downloadService.isEpisodeDownloaded(
          episode.id,
        );
        if (isDownloaded) {
          setState(() {
            _downloadedEpisodes.add(episode.id);
          });
        }
      }
    } catch (e) {
      print('❌ Lỗi khi kiểm tra downloaded episodes: $e');
    }
  }

  Future<void> _loadEpisodes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final episodes = await _dbService.getRecentPodcastEpisodes(limit: 20);
      setState(() {
        _episodes = episodes;
      });
      // Kiểm tra downloaded episodes sau khi load
      _checkDownloadedEpisodes();
    } catch (e) {
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return 'YESTERDAY';
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'TODAY';
    } else if (difference.inDays == 1) {
      return 'YESTERDAY';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} DAYS AGO';
    } else {
      return '${difference.inDays ~/ 7} WEEKS AGO';
    }
  }

  Future<void> _playEpisode(PodcastEpisodeModel episode) async {
    try {
      final player = Provider.of<MusicPlayerProvider>(context, listen: false);

      // Kiểm tra xem đã download chưa, nếu có thì dùng local file
      String audioUrl = episode.audioUrl;
      final isDownloaded = await _downloadService.isEpisodeDownloaded(
        episode.id,
      );
      if (isDownloaded) {
        final localPath = await _downloadService.getLocalFilePath(episode.id);
        audioUrl = localPath;
        print('📦 Phát từ local file: $localPath');
      }

      if (audioUrl.isEmpty) {
        throw Exception('Podcast episode không có audio URL');
      }

      final uri = Uri.tryParse(audioUrl);
      // Cho phép file:// URI nếu là local file
      if (uri == null || (!uri.hasScheme)) {
        throw Exception('Audio URL không hợp lệ: $audioUrl');
      }

      final song = SongModel(
        id: episode.id,
        title: episode.title,
        artistId: episode.podcastId,
        artistName: 'Podcast',
        duration: episode.duration,
        audioUrl: audioUrl,
        artworkUrl: episode.artworkUrl,
        createdAt: episode.createdAt,
      );

      await player.playSong(song);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PlayerScreen()),
      );
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Không thể phát podcast';
        if (e.toString().contains('404') ||
            e.toString().contains('not found')) {
          errorMessage = 'File audio không tồn tại. Vui lòng kiểm tra lại URL.';
        } else if (e.toString().contains('network') ||
            e.toString().contains('connection')) {
          errorMessage = 'Lỗi kết nối mạng. Vui lòng thử lại.';
        } else {
          errorMessage = 'Lỗi: ${e.toString()}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _handleDownload(PodcastEpisodeModel episode) async {
    // Nếu đã download, xóa nó
    if (_downloadedEpisodes.contains(episode.id)) {
      await _deleteEpisode(episode);
      return;
    }

    // Nếu đang download, không làm gì
    if (_downloadingEpisodes.contains(episode.id)) {
      return;
    }

    try {
      setState(() {
        _downloadingEpisodes.add(episode.id);
      });

      // Download episode
      final localPath = await _downloadService.downloadEpisode(episode);
      final fileSize = await _downloadService.getFileSize(episode.id);

      // Lưu vào Firestore nếu có user
      final userId = FirebaseSetup.currentUserId ?? 'guest_user';
      if (userId != 'guest_user') {
        try {
          await _dbService.addPodcastEpisodeDownload(
            userId,
            episode.id,
            episode.podcastId,
            localPath,
            fileSize,
          );
        } catch (e) {
          print('⚠️ Không thể lưu vào Firestore: $e');
        }
      }

      setState(() {
        _downloadingEpisodes.remove(episode.id);
        _downloadedEpisodes.add(episode.id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Đã tải xuống thành công'),
            backgroundColor: Color(0xFF1DB954),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _downloadingEpisodes.remove(episode.id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi khi tải xuống: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _deleteEpisode(PodcastEpisodeModel episode) async {
    try {
      // Xóa file local
      final deleted = await _downloadService.deleteEpisode(episode.id);

      if (deleted) {
        // Xóa khỏi Firestore nếu có user
        final userId = FirebaseSetup.currentUserId ?? 'guest_user';
        if (userId != 'guest_user') {
          try {
            final fileSize = await _downloadService.getFileSize(episode.id);
            await _dbService.removePodcastEpisodeDownload(
              userId,
              episode.id,
              fileSize,
            );
          } catch (e) {
            print('⚠️ Không thể xóa khỏi Firestore: $e');
          }
        }

        setState(() {
          _downloadedEpisodes.remove(episode.id);
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

  static double _getTextWidth(
    String text,
    double fontSize,
    double letterSpacing,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          letterSpacing: letterSpacing,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    return textPainter.width;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      bottomNavigationBar: _buildBottomNavigationBar(context),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Large tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LibraryScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Music',
                      style: TextStyle(
                        color: Color(0xFF7F7F7F),
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  const Text(
                    'Podcasts',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 13),
            // Small tabs with indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTab = 'Episodes';
                      });
                    },
                    child: Builder(
                      builder: (context) {
                        final textWidth = _getTextWidth(
                          'Episodes',
                          15.5,
                          -0.62,
                        );
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Episodes',
                              style: TextStyle(
                                color: _selectedTab == 'Episodes'
                                    ? Colors.white
                                    : const Color(0xFF7F7F7F),
                                fontSize: 15.5,
                                fontWeight: FontWeight.w500,
                                letterSpacing: -0.62,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (_selectedTab == 'Episodes')
                              Container(
                                width: textWidth,
                                height: 2,
                                color: const Color(0xFF57B560),
                              )
                            else
                              const SizedBox(width: 59, height: 2),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 24),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTab = 'Downloads';
                      });
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Downloads',
                          style: TextStyle(
                            color: Color(0xFF7F7F7F),
                            fontSize: 15.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.62,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const SizedBox(width: 75, height: 2),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTab = 'Shows';
                      });
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Shows',
                          style: TextStyle(
                            color: Color(0xFF7F7F7F),
                            fontSize: 15.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.62,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const SizedBox(width: 43, height: 2),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_selectedTab == 'Episodes') ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Yesterday',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (_selectedTab == 'Episodes')
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _episodes.isEmpty
                    ? Center(
                        child: Text(
                          'No episodes available',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: _episodes.length,
                        itemBuilder: (context, index) {
                          final episode = _episodes[index];
                          return _buildEpisodeCard(episode);
                        },
                      ),
              )
            else
              Expanded(
                child: Center(
                  child: Text(
                    _selectedTab,
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEpisodeCard(PodcastEpisodeModel episode) {
    String showName = 'Unknown Show';
    if (episode.podcastId.isNotEmpty) {
      showName = 'The Basement Yard';
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF282828),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: episode.artworkUrl != null
                      ? Image.network(
                          episode.artworkUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(color: Colors.grey[800]);
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
                      episode.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      showName,
                      style: TextStyle(color: Colors.grey[400], fontSize: 11),
                    ),
                  ],
                ),
              ),
              Icon(Icons.more_horiz, color: Colors.grey[400], size: 20),
            ],
          ),
          const SizedBox(height: 12),
          if (episode.description != null)
            Text(
              episode.description!,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 11,
                height: 1.1,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: () => _playEpisode(episode),
                child: Container(
                  width: 31,
                  height: 31,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Color(0xFF282828),
                    size: 15.2,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _formatDate(episode.releaseDate),
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
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
                episode.formattedDuration,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.1,
                ),
              ),
              const Spacer(),
              // Icons
              Icon(Icons.check, color: Colors.grey[400], size: 25),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () => _handleDownload(episode),
                child: _downloadingEpisodes.contains(episode.id)
                    ? const SizedBox(
                        width: 25,
                        height: 25,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF1DB954),
                          ),
                        ),
                      )
                    : Icon(
                        _downloadedEpisodes.contains(episode.id)
                            ? Icons.download_done
                            : Icons.download_outlined,
                        color: _downloadedEpisodes.contains(episode.id)
                            ? const Color(0xFF1DB954)
                            : Colors.grey[600],
                        size: 25,
                      ),
              ),
            ],
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
