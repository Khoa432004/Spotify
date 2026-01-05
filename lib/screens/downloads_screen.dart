import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/mini_player.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'library_screen.dart';
import 'player_screen.dart';
import '../database/database.dart';
import '../database/models/podcast_model.dart';
import '../database/models/song_model.dart';
import '../providers/music_player_provider.dart';
import '../services/podcast_download_service.dart';
import '../services/song_download_service.dart';

/// Màn hình Downloads - Hiển thị tất cả nhạc và podcast đã download
class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  String _selectedTab = 'Music';
  final DatabaseService _dbService = DatabaseService();
  final PodcastDownloadService _podcastDownloadService =
      PodcastDownloadService();
  final SongDownloadService _songDownloadService = SongDownloadService();

  List<PodcastEpisodeModel> _downloadedEpisodes = [];
  List<SongModel> _downloadedSongs = [];
  bool _isLoadingEpisodes = false;
  bool _isLoadingSongs = false;

  @override
  void initState() {
    super.initState();
    _loadDownloadedEpisodes();
    _loadDownloadedSongs();
  }

  Future<void> _loadDownloadedEpisodes() async {
    setState(() {
      _isLoadingEpisodes = true;
    });

    try {
      final downloadedIds =
          await _podcastDownloadService.getDownloadedEpisodeIds();

      if (downloadedIds.isEmpty) {
        setState(() {
          _downloadedEpisodes = [];
          _isLoadingEpisodes = false;
        });
        return;
      }

      final episodes = <PodcastEpisodeModel>[];
      for (var episodeId in downloadedIds) {
        try {
          final episode = await _dbService.getPodcastEpisode(episodeId);
          if (episode != null) {
            // Cập nhật audioUrl thành local path
            final localPath =
                await _podcastDownloadService.getLocalFilePath(episodeId);
            episodes.add(episode.copyWith(audioUrl: localPath));
          }
        } catch (e) {
          print('⚠️ Không thể load episode $episodeId: $e');
        }
      }

      setState(() {
        _downloadedEpisodes = episodes;
        _isLoadingEpisodes = false;
      });
    } catch (e) {
      print('❌ Lỗi khi load downloaded episodes: $e');
      setState(() {
        _isLoadingEpisodes = false;
      });
    }
  }

  Future<void> _loadDownloadedSongs() async {
    setState(() {
      _isLoadingSongs = true;
    });

    try {
      final downloadedIds = await _songDownloadService.getDownloadedSongIds();

      if (downloadedIds.isEmpty) {
        setState(() {
          _downloadedSongs = [];
          _isLoadingSongs = false;
        });
        return;
      }

      final songs = <SongModel>[];
      for (var songId in downloadedIds) {
        try {
          // Lấy song từ database
          final songDoc = await _dbService.getSong(songId);
          if (songDoc != null) {
            // Cập nhật audioUrl thành local path
            final localPath =
                await _songDownloadService.getLocalFilePath(songId);
            songs.add(songDoc.copyWith(audioUrl: localPath));
          }
        } catch (e) {
          print('⚠️ Không thể load song $songId: $e');
        }
      }

      setState(() {
        _downloadedSongs = songs;
        _isLoadingSongs = false;
      });
    } catch (e) {
      print('❌ Lỗi khi load downloaded songs: $e');
      setState(() {
        _isLoadingSongs = false;
      });
    }
  }

  Future<void> _playDownloadedEpisode(PodcastEpisodeModel episode) async {
    try {
      final player = Provider.of<MusicPlayerProvider>(context, listen: false);

      // Đảm bảo dùng local file
      final localPath =
          await _podcastDownloadService.getLocalFilePath(episode.id);
      final file = File(localPath);

      if (!await file.exists()) {
        throw Exception('File đã tải xuống không tồn tại. Vui lòng tải lại.');
      }

      final song = SongModel(
        id: episode.id,
        title: episode.title,
        artistId: episode.podcastId,
        artistName: 'Podcast',
        albumName: 'Podcast Episode',
        duration: episode.duration,
        audioUrl: localPath,
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi khi phát: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _playDownloadedSong(SongModel song) async {
    try {
      final player = Provider.of<MusicPlayerProvider>(context, listen: false);

      // Đảm bảo dùng local file
      final localPath = await _songDownloadService.getLocalFilePath(song.id);
      final file = File(localPath);

      if (!await file.exists()) {
        throw Exception('File đã tải xuống không tồn tại. Vui lòng tải lại.');
      }

      final songToPlay = song.copyWith(audioUrl: localPath);
      await player.playSong(songToPlay);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PlayerScreen()),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi khi phát: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [const MiniPlayer(), _buildBottomNavigationBar(context)],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Downloads',
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
            const SizedBox(height: 16),
            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTab = 'Music';
                      });
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Music',
                          style: TextStyle(
                            color: _selectedTab == 'Music'
                                ? Colors.white
                                : const Color(0xFF7F7F7F),
                            fontSize: 15.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.62,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_selectedTab == 'Music')
                          Container(
                            width: 50,
                            height: 2,
                            color: const Color(0xFF57B560),
                          )
                        else
                          const SizedBox(width: 50, height: 2),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTab = 'Podcasts';
                      });
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Podcasts',
                          style: TextStyle(
                            color: _selectedTab == 'Podcasts'
                                ? Colors.white
                                : const Color(0xFF7F7F7F),
                            fontSize: 15.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.62,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_selectedTab == 'Podcasts')
                          Container(
                            width: 70,
                            height: 2,
                            color: const Color(0xFF57B560),
                          )
                        else
                          const SizedBox(width: 70, height: 2),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Content
            Expanded(
              child: _selectedTab == 'Music'
                  ? _buildMusicDownloads()
                  : _buildPodcastDownloads(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMusicDownloads() {
    if (_isLoadingSongs) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_downloadedSongs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.download_outlined,
              color: Colors.grey[600],
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có bài hát nào được tải xuống',
              style: TextStyle(color: Colors.grey[400]),
            ),
            const SizedBox(height: 8),
            Text(
              'Tải xuống bài hát để nghe offline',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: _downloadedSongs.length,
      itemBuilder: (context, index) {
        final song = _downloadedSongs[index];
        return _buildDownloadedSongCard(song);
      },
    );
  }

  Widget _buildPodcastDownloads() {
    if (_isLoadingEpisodes) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_downloadedEpisodes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.download_outlined,
              color: Colors.grey[600],
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có episode nào được tải xuống',
              style: TextStyle(color: Colors.grey[400]),
            ),
            const SizedBox(height: 8),
            Text(
              'Tải xuống episodes để nghe offline',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: _downloadedEpisodes.length,
      itemBuilder: (context, index) {
        final episode = _downloadedEpisodes[index];
        return _buildDownloadedEpisodeCard(episode);
      },
    );
  }

  Widget _buildDownloadedSongCard(SongModel song) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF282828),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF1DB954).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Artwork
          Container(
            width: 56,
            height: 56,
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
                        return Container(
                          color: Colors.grey[800],
                          child: const Icon(
                            Icons.music_note,
                            color: Colors.grey,
                            size: 24,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[800],
                      child: const Icon(
                        Icons.music_note,
                        color: Colors.grey,
                        size: 24,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Song info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        song.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Offline indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1DB954).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'OFFLINE',
                        style: TextStyle(
                          color: Color(0xFF1DB954),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  song.artistName,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Play button
          GestureDetector(
            onTap: () => _playDownloadedSong(song),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Color(0xFF282828),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadedEpisodeCard(PodcastEpisodeModel episode) {
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
        border: Border.all(
          color: const Color(0xFF1DB954).withOpacity(0.3),
          width: 1,
        ),
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            episode.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        // Offline indicator
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1DB954).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'OFFLINE',
                            style: TextStyle(
                              color: Color(0xFF1DB954),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      showName,
                      style: TextStyle(color: Colors.grey[400], fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: () => _playDownloadedEpisode(episode),
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
          // Indicator bar ở trên
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

