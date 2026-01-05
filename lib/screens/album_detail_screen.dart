import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/mini_player.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'library_screen.dart';
import 'player_screen.dart';
import '../database/firebase_setup.dart';
import '../database/models/song_model.dart';
import '../providers/music_player_provider.dart';
import '../services/song_download_service.dart';
import '../widgets/download_progress_dialog.dart';

/// Màn hình chi tiết Album
class AlbumDetailScreen extends StatefulWidget {
  final String albumName;
  final String artistName;
  final String? albumArt;
  final String? albumId; // Optional: để fetch từ database

  const AlbumDetailScreen({
    super.key,
    required this.albumName,
    required this.artistName,
    this.albumArt,
    this.albumId,
  });

  @override
  State<AlbumDetailScreen> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends State<AlbumDetailScreen> {
  List<SongModel>? _songs;
  bool _isLoading = false;
  final SongDownloadService _downloadService = SongDownloadService();
  Set<String> _downloadingSongs = {}; // Track songs đang download
  Set<String> _downloadedSongs = {}; // Track songs đã download
  bool _isDownloadingAlbum = false;

  @override
  void initState() {
    super.initState();
    _loadSongs();
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

  Future<void> _loadSongs() async {
    if (widget.albumId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final songs = await FirebaseSetup.databaseService
          .getAlbumSongs(widget.albumId!);
      setState(() {
        _songs = songs;
        _isLoading = false;
      });
      // Kiểm tra downloaded songs sau khi load
      _checkDownloadedSongs();
    } catch (e) {
      print('❌ Lỗi khi load songs: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _playSong(SongModel song, {bool shuffle = false}) async {
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

      // Tạo song với local path nếu đã download
      final songToPlay = song.copyWith(audioUrl: audioUrl);

      // Nếu có queue (songs), phát với queue
      if (_songs != null && _songs!.isNotEmpty) {
        // Cập nhật audioUrl cho tất cả songs trong queue nếu đã download
        final updatedSongs = _songs!.map((s) async {
          final isSDownloaded = await _downloadService.isSongDownloaded(s.id);
          if (isSDownloaded) {
            final localPath = await _downloadService.getLocalFilePath(s.id);
            return s.copyWith(audioUrl: localPath);
          }
          return s;
        }).toList();
        
        // Wait for all futures
        final resolvedSongs = await Future.wait(updatedSongs);
        final index = resolvedSongs.indexWhere((s) => s.id == song.id);
        await player.playSong(songToPlay, queue: resolvedSongs, initialIndex: index);

        // Nếu shuffle được yêu cầu, bật shuffle
        if (shuffle && !player.shuffleMode) {
          player.toggleShuffle();
        }
      } else {
        // Nếu không có queue, chỉ phát bài này
        await player.playSong(songToPlay);
      }

      // Navigate to player screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PlayerScreen()),
      );
    } catch (e) {
      // Hiển thị lỗi cho user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Không thể phát nhạc: ${e.toString().contains('404') || e.toString().contains('not found') ? 'File audio không tồn tại' : e.toString()}',
            ),
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
          // Download song với progress callback
          final localPath = await _downloadService.downloadSong(
            song,
            onProgress: onProgress,
          );
          final fileSize = await _downloadService.getFileSize(song.id);

          // Lưu vào Firestore nếu có user
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
      // Xóa file local
      final deleted = await _downloadService.deleteSong(song.id);

      if (deleted) {
        // Xóa khỏi Firestore nếu có user
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

  Future<void> _handleDownloadAlbum() async {
    if (_songs == null || _songs!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không có bài hát nào để tải xuống'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Kiểm tra xem album đã được download chưa
    final userId = FirebaseSetup.currentUserId ?? 'guest_user';
    bool isAlbumDownloaded = false;
    if (userId != 'guest_user' && widget.albumId != null) {
      isAlbumDownloaded = await FirebaseSetup.databaseService.isAlbumDownloaded(
        userId,
        widget.albumId!,
      );
    }

    if (isAlbumDownloaded) {
      // Xóa album
      if (widget.albumId != null && userId != 'guest_user') {
        await FirebaseSetup.databaseService.removeAlbumDownload(
          userId,
          widget.albumId!,
        );
      }
      // Xóa tất cả songs
      for (var song in _songs!) {
        if (_downloadedSongs.contains(song.id)) {
          await _deleteSong(song);
        }
      }
      return;
    }

    setState(() {
      _isDownloadingAlbum = true;
    });

    // Hiển thị progress dialog cho album download
    final songsToDownload = _songs!
        .where((s) => !_downloadedSongs.contains(s.id))
        .toList();

    if (songsToDownload.isEmpty) {
      setState(() {
        _isDownloadingAlbum = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tất cả bài hát đã được tải xuống'),
          backgroundColor: Colors.grey,
        ),
      );
      return;
    }

    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => DownloadProgressDialog(
        title: 'Đang tải xuống album',
        subtitle: '${songsToDownload.length} bài hát',
        downloadTask: (onProgress) async {
          int successCount = 0;
          for (int i = 0; i < songsToDownload.length; i++) {
            final song = songsToDownload[i];
            try {
              // Download song với progress riêng cho từng bài
              final localPath = await _downloadService.downloadSong(
                song,
                onProgress: (songProgress) {
                  // Tính progress tổng thể cho album
                  final totalProgress =
                      (i + songProgress) / songsToDownload.length;
                  onProgress(totalProgress);
                },
              );
              final fileSize = await _downloadService.getFileSize(song.id);

              // Lưu vào Firestore nếu có user
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

              setState(() {
                _downloadedSongs.add(song.id);
              });
              successCount++;
            } catch (e) {
              print('❌ Lỗi khi download song ${song.id}: $e');
              // Continue với các songs khác
            }
          }

          // Lưu album vào Firestore nếu có user
          if (widget.albumId != null && userId != 'guest_user') {
            try {
              final songIds = _songs!.map((s) => s.id).toList();
              await FirebaseSetup.databaseService.addAlbumDownload(
                userId,
                widget.albumId!,
                songIds,
              );
            } catch (e) {
              print('⚠️ Không thể lưu album vào Firestore: $e');
            }
          }

          if (successCount < songsToDownload.length) {
            throw Exception(
              'Chỉ tải xuống được $successCount/${songsToDownload.length} bài hát',
            );
          }
        },
        onSuccess: () {
          setState(() {
            _isDownloadingAlbum = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '✅ Đã tải xuống ${songsToDownload.length} bài hát thành công',
              ),
              backgroundColor: const Color(0xFF1DB954),
              duration: const Duration(seconds: 3),
            ),
          );
        },
        onError: (error) {
          setState(() {
            _isDownloadingAlbum = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Lỗi khi tải xuống album: $error'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Fallback tracks data nếu không có songs từ database
    final List<Map<String, String>> fallbackTracks = [
      {'title': 'Creation Comes Alive', 'artist': 'Petit Biscuit, SONIA'},
      {'title': 'Problems', 'artist': 'Petit Biscuit, Lido'},
      {'title': 'Follow Me', 'artist': 'Petit Biscuit,'},
      {'title': 'Beam', 'artist': 'Petit Biscuit'},
      {'title': 'Break Up', 'artist': 'Petit Biscuit'},
    ];

    // Sử dụng songs từ database nếu có, nếu không dùng fallback
    final hasSongs = _songs != null && _songs!.isNotEmpty;
    final displaySongs = hasSongs ? _songs! : null;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(),
          _buildBottomNavigationBar(context),
        ],
      ),
      body: Stack(
        children: [
          // Gradient fade background
          Positioned(
            top: -228,
            left: -137,
            child: Container(
              width: 594,
              height: 594,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [Colors.grey.withOpacity(0.3), Colors.transparent],
                ),
              ),
              child: Image.network(
                'https://www.figma.com/api/mcp/asset/2be3c887-4aa4-4afd-8d47-0e3b39063ec7',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // Back button
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 24),
                    // Album artwork (centered)
                    Center(
                      child: Container(
                        width: 272,
                        height: 272,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.55),
                              blurRadius: 65,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: widget.albumArt != null
                              ? Image.network(
                                  widget.albumArt!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[800],
                                      child: const Icon(
                                        Icons.album,
                                        size: 100,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                )
                              : (hasSongs && displaySongs!.isNotEmpty && displaySongs[0].artworkUrl != null)
                                  ? Image.network(
                                      displaySongs[0].artworkUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey[800],
                                          child: const Icon(
                                            Icons.album,
                                            size: 100,
                                            color: Colors.grey,
                                          ),
                                        );
                                      },
                                    )
                                  : Image.network(
                                      'https://www.figma.com/api/mcp/asset/6b9b70b4-d79d-4f74-bafd-487d17a98564',
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey[800],
                                          child: const Icon(
                                            Icons.album,
                                            size: 100,
                                            color: Colors.grey,
                                          ),
                                        );
                                      },
                                    ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Album name
                    Text(
                      widget.albumName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.72,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Artist with avatar
                    Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey,
                          ),
                          child: ClipOval(
                            child: Image.network(
                              'https://www.figma.com/api/mcp/asset/0a3481eb-95f6-4a48-8666-86356a603e7b',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(color: Colors.grey[800]!);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.artistName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11.3,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Album • Year
                    Row(
                      children: [
                        Text(
                          'Album',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 9,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Container(
                            width: 1.8,
                            height: 1.8,
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Text(
                          '2017',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Controls
                    Row(
                      children: [
                        // Like icon
                        IconButton(
                          icon: const Icon(Icons.favorite_border),
                          color: Colors.white,
                          iconSize: 26,
                          onPressed: () {},
                        ),
                        const SizedBox(width: 8),
                        // Download icon
                        IconButton(
                          icon: _isDownloadingAlbum
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF1DB954),
                                    ),
                                  ),
                                )
                              : Icon(
                                  widget.albumId != null &&
                                          _songs != null &&
                                          _songs!.isNotEmpty &&
                                          _songs!.every((s) =>
                                              _downloadedSongs.contains(s.id))
                                      ? Icons.download_done
                                      : Icons.download_outlined,
                                  color: widget.albumId != null &&
                                          _songs != null &&
                                          _songs!.isNotEmpty &&
                                          _songs!.every((s) =>
                                              _downloadedSongs.contains(s.id))
                                      ? const Color(0xFF1DB954)
                                      : Colors.grey[400],
                                  size: 24,
                                ),
                          onPressed: _handleDownloadAlbum,
                        ),
                        const SizedBox(width: 8),
                        // More icon
                        IconButton(
                          icon: const Icon(Icons.more_horiz),
                          color: Colors.grey[400],
                          iconSize: 24,
                          onPressed: () {},
                        ),
                        const Spacer(),
                        // Play button
                        GestureDetector(
                          onTap: () {
                            if (hasSongs && displaySongs!.isNotEmpty) {
                              _playSong(displaySongs[0]);
                            } else {
                              // Fallback: navigate to player screen (no song to play)
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PlayerScreen(),
                                ),
                              );
                            }
                          },
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: const BoxDecoration(
                              color: Color(0xFF1DB954),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Shuffle button (small)
                        GestureDetector(
                          onTap: () {
                            if (hasSongs && displaySongs!.isNotEmpty) {
                              _playSong(displaySongs[0], shuffle: true);
                            }
                          },
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.shuffle,
                              color: Color(0xFF57B560),
                              size: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Loading indicator
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    // Track list
                    else if (hasSongs)
                      ...List.generate(displaySongs!.length, (index) {
                        final song = displaySongs[index];
                        return GestureDetector(
                          onTap: () => _playSong(song),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Row(
                              children: [
                                // Download icon
                                GestureDetector(
                                  onTap: () => _handleDownloadSong(song),
                                  child: _downloadingSongs.contains(song.id)
                                      ? const SizedBox(
                                          width: 13,
                                          height: 13,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 1.5,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              Color(0xFF1DB954),
                                            ),
                                          ),
                                        )
                                      : Icon(
                                          _downloadedSongs.contains(song.id)
                                              ? Icons.download_done
                                              : Icons.download,
                                          color: _downloadedSongs.contains(
                                                  song.id)
                                              ? const Color(0xFF1DB954)
                                              : Colors.grey[400],
                                          size: 13,
                                        ),
                                ),
                                const SizedBox(width: 12),
                                // Track info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                        song.artistName,
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Duration
                                Text(
                                  song.formattedDuration,
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // More icon
                                IconButton(
                                  icon: Icon(
                                    Icons.more_horiz,
                                    color: Colors.grey[400],
                                    size: 20,
                                  ),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ),
                        );
                      })
                    // Fallback tracks
                    else
                      ...List.generate(fallbackTracks.length, (index) {
                        final track = fallbackTracks[index];
                        return GestureDetector(
                          onTap: () {
                            // Fallback: navigate to player screen (no song to play)
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PlayerScreen(),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Row(
                              children: [
                                // Download icon
                                Icon(
                                  Icons.download,
                                  color: Colors.grey[400],
                                  size: 13,
                                ),
                                const SizedBox(width: 12),
                                // Track info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        track['title']!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        track['artist']!,
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // More icon
                                IconButton(
                                  icon: Icon(
                                    Icons.more_horiz,
                                    color: Colors.grey[400],
                                    size: 20,
                                  ),
                                  onPressed: () {},
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
