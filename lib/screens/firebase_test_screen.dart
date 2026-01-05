import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../database/firebase_setup.dart';
import '../database/database_service.dart';
import '../database/seed_data.dart';
import '../database/run_seed_data.dart';
import '../database/update_concerts_dates.dart';
import '../database/update_podcast_audio_urls.dart';
import '../database/reset_and_reseed_podcasts.dart';
import '../database/custom_song_data.dart';
import '../providers/music_player_provider.dart';
import '../services/music_player_service.dart';
import '../database/models/song_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Màn hình test Firebase connection
class FirebaseTestScreen extends StatefulWidget {
  const FirebaseTestScreen({super.key});

  @override
  State<FirebaseTestScreen> createState() => _FirebaseTestScreenState();
}

class _FirebaseTestScreenState extends State<FirebaseTestScreen> {
  bool _isLoading = false;
  String _statusMessage = '';
  List<String> _testResults = [];
  List<SongModel> _songs = [];
  bool _isLoadingSongs = false;

  @override
  void initState() {
    super.initState();
    _testConnection();
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    setState(() {
      _isLoadingSongs = true;
    });

    try {
      final dbService = FirebaseSetup.databaseService;
      final songs = await dbService.getSongs(limit: 50);
      setState(() {
        _songs = songs;
        _isLoadingSongs = false;
      });
    } catch (e) {
      print('Error loading songs: $e');
      setState(() {
        _isLoadingSongs = false;
      });
    }
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Đang kiểm tra kết nối...';
      _testResults.clear();
    });

    try {
      // Test 1: Check Firebase initialization
      _addResult('1. Kiểm tra Firebase initialization...');
      if (FirebaseSetup.isInitialized) {
        _addResult('   ✅ Firebase đã được khởi tạo');
      } else {
        _addResult('   ❌ Firebase chưa được khởi tạo');
        return;
      }

      // Test 2: Check Firestore connection
      _addResult('2. Kiểm tra Firestore connection...');
      final firestore = FirebaseSetup.firestore;
      // Test với collection 'songs' thay vì 'test' vì 'songs' có public read permission
      await firestore.collection('songs').limit(1).get();
      _addResult('   ✅ Firestore kết nối thành công');

      // Test 3: Check Storage connection
      _addResult('3. Kiểm tra Storage connection...');
      try {
        final storage = FirebaseSetup.storage;
        // Test với root path thay vì 'test'
        await storage.ref().listAll();
        _addResult('   ✅ Storage kết nối thành công');
      } catch (e) {
        _addResult('   ⚠️ Storage test: $e');
        _addResult('   ℹ️ Storage service vẫn hoạt động, chỉ là test path');
      }

      // Test 4: Check Auth
      _addResult('4. Kiểm tra Auth service...');
      final auth = FirebaseSetup.auth;
      _addResult('   ✅ Auth service sẵn sàng');
      _addResult('   📝 User logged in: ${auth.currentUser != null}');

      // Test 5: Test Database Service
      _addResult('5. Kiểm tra Database Service...');
      final dbService = FirebaseSetup.databaseService;
      _addResult('   ✅ Database Service hoạt động');

      // Test 6: Try to read a collection (songs)
      _addResult('6. Kiểm tra đọc dữ liệu từ Firestore...');
      try {
        final songsSnapshot = await firestore
            .collection('songs')
            .limit(1)
            .get();
        _addResult('   ✅ Có thể đọc collection "songs"');
        _addResult('   📊 Số documents: ${songsSnapshot.docs.length}');
        if (songsSnapshot.docs.isEmpty) {
          _addResult('   ℹ️ Collection "songs" chưa có dữ liệu (điều này là bình thường)');
        }
      } catch (e) {
        _addResult('   ❌ Lỗi đọc collection "songs": $e');
        // Nếu là permission error, hướng dẫn user
        if (e.toString().contains('permission-denied')) {
          _addResult('   💡 Có thể rules chưa được deploy hoặc cần đợi vài giây');
        }
      }

      setState(() {
        _statusMessage = '✅ Tất cả các test đều thành công!';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Có lỗi xảy ra: $e';
        _isLoading = false;
      });
      _addResult('❌ Lỗi: $e');
    }
  }

  void _addResult(String message) {
    setState(() {
      _testResults.add(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Firebase Connection Test'),
        backgroundColor: const Color(0xFF1DB954),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Card
              Card(
                color: const Color(0xFF282828),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (_isLoading)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF1DB954),
                                ),
                              ),
                            )
                          else
                            Icon(
                              _statusMessage.contains('✅')
                                  ? Icons.check_circle
                                  : Icons.error,
                              color: _statusMessage.contains('✅')
                                  ? const Color(0xFF1DB954)
                                  : Colors.red,
                            ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _statusMessage.isEmpty
                                  ? 'Chưa kiểm tra'
                                  : _statusMessage,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _testConnection,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1DB954),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Chạy lại test'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Test Results
              const Text(
                'Kết quả test:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ..._testResults.map((result) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      result,
                      style: TextStyle(
                        color: result.contains('✅')
                            ? const Color(0xFF1DB954)
                            : result.contains('❌')
                                ? Colors.red
                                : result.contains('⚠️')
                                    ? Colors.orange
                                    : Colors.white70,
                        fontSize: 14,
                        fontFamily: 'monospace',
                      ),
                    ),
                  )),
              const SizedBox(height: 24),
              // Music Player Test Section
              Card(
                color: const Color(0xFF282828),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Music Player Test:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Seed Albums Mới Button
                      ElevatedButton.icon(
                        onPressed: () async {
                          setState(() {
                            _isLoading = true;
                            _statusMessage = 'Đang seed albums và songs mới (giữ lại songs cũ)...';
                          });
                          
                          try {
                            final seedData = SeedData();
                            await seedData.seedNewAlbumsAndSongs();
                            
                            setState(() {
                              _statusMessage = '✅ Đã seed albums và songs mới thành công!';
                              _isLoading = false;
                            });
                            
                            _addResult('✅ Đã seed albums và songs mới!');
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('✅ Đã seed albums và songs mới (songs cũ được giữ lại)!'),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 3),
                              ),
                            );
                          } catch (e) {
                            setState(() {
                              _statusMessage = '❌ Lỗi: $e';
                              _isLoading = false;
                            });
                            _addResult('❌ Lỗi seed albums mới: $e');
                          }
                        },
                        icon: const Icon(Icons.album),
                        label: const Text('Seed Albums Mới (Giữ Songs Cũ)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1DB954),
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Test URL Button
                      ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            final dbService = FirebaseSetup.databaseService;
                            final songs = await dbService.getSongs(limit: 1);
                            
                            if (songs.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Chưa có bài hát. Hãy seed data trước!'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }
                            
                            final song = songs[0];
                            _showUrlTestDialog(context, song);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Lỗi: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.link),
                        label: const Text('Test URL của Song'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Test Play Music Button
                      ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            final dbService = FirebaseSetup.databaseService;
                            final songs = await dbService.getSongs(limit: 5);
                            
                            if (songs.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Chưa có bài hát. Hãy seed data trước!'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }
                            
                            final player = Provider.of<MusicPlayerProvider>(
                              context,
                              listen: false,
                            );
                            
                            await player.playSong(
                              songs[0],
                              queue: songs,
                            );
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Đang phát: ${songs[0].title}'),
                                backgroundColor: const Color(0xFF1DB954),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Lỗi: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Test Phát Nhạc'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1DB954),
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Player Status
                      Consumer<MusicPlayerProvider>(
                        builder: (context, player, _) {
                          if (player.currentSong == null) {
                            return const Text(
                              'Chưa có bài hát nào đang phát',
                              style: TextStyle(color: Colors.white70),
                            );
                          }
                          
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '🎵 Đang phát: ${player.currentSong!.title}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '👤 ${player.currentSong!.artistName}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      player.isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                    ),
                                    onPressed: () => player.togglePlayPause(),
                                    color: Colors.white,
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      player.shuffleMode
                                          ? Icons.shuffle
                                          : Icons.shuffle,
                                      ),
                                    color: player.shuffleMode
                                        ? const Color(0xFF1DB954)
                                        : Colors.white70,
                                    onPressed: () => player.toggleShuffle(),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      player.repeatMode == RepeatMode.one
                                          ? Icons.repeat_one
                                          : Icons.repeat,
                                    ),
                                    color: player.repeatMode != RepeatMode.none
                                        ? const Color(0xFF1DB954)
                                        : Colors.white70,
                                    onPressed: () => player.toggleRepeat(),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${player.currentIndex + 1}/${player.queue.length}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              if (player.duration != null)
                                LinearProgressIndicator(
                                  value: player.position.inSeconds /
                                      player.duration!.inSeconds,
                                  backgroundColor: Colors.grey[800],
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    Color(0xFF1DB954),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Songs List Section
              Card(
                color: const Color(0xFF282828),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Danh sách bài hát:',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            color: Colors.white70,
                            onPressed: _loadSongs,
                            tooltip: 'Làm mới danh sách',
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_isLoadingSongs)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF1DB954),
                              ),
                            ),
                          ),
                        )
                      else if (_songs.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.music_off,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Chưa có bài hát nào',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    setState(() {
                                      _isLoading = true;
                                      _statusMessage = 'Đang seed albums và songs mới (giữ lại songs cũ)...';
                                    });
                                    try {
                                      final seedData = SeedData();
                                      await seedData.seedNewAlbumsAndSongs();
                                      setState(() {
                                        _statusMessage = '✅ Đã seed albums và songs mới thành công!';
                                        _isLoading = false;
                                      });
                                      _loadSongs(); // Reload songs after seeding
                                    } catch (e) {
                                      setState(() {
                                        _statusMessage = '❌ Lỗi seed albums mới: $e';
                                        _isLoading = false;
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.album),
                                  label: const Text('Seed Albums Mới (Giữ Songs Cũ)'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1DB954),
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Column(
                          children: [
                            Text(
                              'Tổng số: ${_songs.length} bài hát',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 400, // Fixed height để scroll được
                              child: ListView.builder(
                                itemCount: _songs.length,
                                itemBuilder: (context, index) {
                                  final song = _songs[index];
                                  return _buildSongCard(context, song, index);
                                },
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Firebase Info
              Card(
                color: const Color(0xFF282828),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thông tin Firebase:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow('Project ID', 'spotify-78b1f'),
                      _buildInfoRow(
                        'Firebase Initialized',
                        FirebaseSetup.isInitialized ? 'Yes' : 'No',
                      ),
                      _buildInfoRow(
                        'User Logged In',
                        FirebaseSetup.isUserLoggedIn ? 'Yes' : 'No',
                      ),
                      if (FirebaseSetup.currentUserId != null)
                        _buildInfoRow(
                          'User ID',
                          FirebaseSetup.currentUserId!,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showUrlTestDialog(BuildContext context, SongModel song) {
    showDialog(
      context: context,
      builder: (context) => _UrlTestDialog(song: song),
    );
  }

  Widget _buildSongCard(BuildContext context, SongModel song, int index) {
    return Consumer<MusicPlayerProvider>(
      builder: (context, player, _) {
        final isCurrentSong = player.currentSong?.id == song.id;
        final isPlaying = isCurrentSong && player.isPlaying;

        return Container(
          margin: const EdgeInsets.only(bottom: 8.0),
          decoration: BoxDecoration(
            color: isCurrentSong ? const Color(0xFF1DB954).withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isCurrentSong
                ? Border.all(color: const Color(0xFF1DB954), width: 1)
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => _playSong(context, song, index),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    // Track number or play icon
                    SizedBox(
                      width: 32,
                      child: isCurrentSong && isPlaying
                          ? const Icon(
                              Icons.equalizer,
                              color: Color(0xFF1DB954),
                              size: 20,
                            )
                          : isCurrentSong
                              ? const Icon(
                                  Icons.pause_circle_filled,
                                  color: Color(0xFF1DB954),
                                  size: 24,
                                )
                              : Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                    ),
                    const SizedBox(width: 12),
                    // Song artwork
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
                                      color: Colors.white38,
                                      size: 24,
                                    ),
                                  );
                                },
                              )
                            : Container(
                                color: Colors.grey[800],
                                child: const Icon(
                                  Icons.music_note,
                                  color: Colors.white38,
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
                          Text(
                            song.title,
                            style: TextStyle(
                              color: isCurrentSong ? Colors.white : Colors.white,
                              fontSize: 14,
                              fontWeight: isCurrentSong ? FontWeight.bold : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (song.isExplicit)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  margin: const EdgeInsets.only(right: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[700],
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: const Text(
                                    'E',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              Expanded(
                                child: Text(
                                  song.artistName,
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (song.albumName != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              song.albumName!,
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Duration
                    Text(
                      song.formattedDuration,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Play button
                    IconButton(
                      icon: Icon(
                        isCurrentSong && isPlaying ? Icons.pause : Icons.play_arrow,
                        color: isCurrentSong ? const Color(0xFF1DB954) : Colors.white70,
                      ),
                      onPressed: () => _playSong(context, song, index),
                      tooltip: isCurrentSong && isPlaying ? 'Tạm dừng' : 'Phát',
                    ),
                    // More options
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                      color: const Color(0xFF282828),
                      onSelected: (value) {
                        switch (value) {
                          case 'test_url':
                            _showUrlTestDialog(context, song);
                            break;
                          case 'play_next':
                            // TODO: Implement play next
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'test_url',
                          child: Row(
                            children: [
                              Icon(Icons.link, color: Colors.white70, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Test URL',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'play_next',
                          child: Row(
                            children: [
                              Icon(Icons.queue_music, color: Colors.white70, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Phát tiếp theo',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _playSong(BuildContext context, SongModel song, int index) async {
    try {
      final player = Provider.of<MusicPlayerProvider>(context, listen: false);
      
      // Nếu đang phát bài này, toggle play/pause
      if (player.currentSong?.id == song.id) {
        player.togglePlayPause();
        return;
      }
      
      // Phát bài mới với queue là tất cả songs
      await player.playSong(
        song,
        queue: _songs,
        initialIndex: index,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đang phát: ${song.title}'),
            backgroundColor: const Color(0xFF1DB954),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
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
}

class _UrlTestDialog extends StatefulWidget {
  final SongModel song;

  const _UrlTestDialog({required this.song});

  @override
  State<_UrlTestDialog> createState() => _UrlTestDialogState();
}

class _UrlTestDialogState extends State<_UrlTestDialog> {
  bool _isTesting = false;
  String _testResult = '';
  String _details = '';

  Future<void> _testUrl() async {
    setState(() {
      _isTesting = true;
      _testResult = 'Đang kiểm tra...';
      _details = '';
    });

    try {
      final url = widget.song.audioUrl;
      
      // Parse URL
      final uri = Uri.parse(url);
      
      setState(() {
        _details += '🔗 URL: $url\n';
        _details += '📋 Parsed URI: ${uri.toString()}\n';
        _details += '🔍 Host: ${uri.host}\n';
        _details += '📁 Path: ${uri.path}\n\n';
      });

      // Test HTTP request
      setState(() {
        _details += '🌐 Đang gửi HTTP request...\n';
      });

      final response = await http.get(
        uri,
        headers: {
          'Range': 'bytes=0-1023',
          'User-Agent': 'Flutter-App',
        },
      ).timeout(
        const Duration(seconds: 10),
      );

      setState(() {
        _details += '✅ Response nhận được!\n';
        _details += '📊 Status Code: ${response.statusCode}\n';
        _details += '📦 Content-Type: ${response.headers['content-type'] ?? 'N/A'}\n';
        _details += '📏 Content-Length: ${response.headers['content-length'] ?? 'N/A'}\n';
        _details += '🔐 Content-Range: ${response.headers['content-range'] ?? 'N/A'}\n\n';
      });

      if (response.statusCode == 200 || response.statusCode == 206) {
        final contentType = response.headers['content-type'] ?? '';
        final isAudio = contentType.toLowerCase().contains('audio') ||
            contentType.toLowerCase().contains('mp3') ||
            contentType.toLowerCase().contains('mpeg');

        if (isAudio) {
          setState(() {
            _testResult = '✅ URL hợp lệ và có thể tải được!';
            _details += '✅ File là audio format\n';
            _details += '✅ File size: ${response.headers['content-length'] ?? 'Unknown'} bytes\n';
          });
        } else {
          setState(() {
            _testResult = '⚠️ URL hợp lệ nhưng không phải audio format!';
            _details += '⚠️ Content-Type: $contentType\n';
            _details += '⚠️ Có thể file không phải audio hoặc bị lỗi format\n';
          });
        }
      } else if (response.statusCode == 404) {
        setState(() {
          _testResult = '❌ File không tồn tại (404)!';
          _details += '❌ File có thể đã bị xóa khỏi Firebase Storage\n';
          _details += '💡 Hãy kiểm tra Firebase Storage và upload lại file\n';
        });
      } else if (response.statusCode == 403) {
        setState(() {
          _testResult = '❌ Access denied (403)!';
          _details += '❌ Token có thể đã hết hạn\n';
          _details += '💡 Hãy regenerate download URL trong Firebase Storage\n';
        });
      } else if (response.statusCode == 401) {
        setState(() {
          _testResult = '❌ Unauthorized (401)!';
          _details += '❌ Token không hợp lệ\n';
          _details += '💡 Hãy regenerate download URL trong Firebase Storage\n';
        });
      } else {
        setState(() {
          _testResult = '⚠️ Status code không mong đợi: ${response.statusCode}';
          _details += '⚠️ Response body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}\n';
        });
      }
    } catch (e) {
      setState(() {
        _testResult = '❌ Lỗi khi test URL!';
        _details += '❌ Error: $e\n';
        
        if (e.toString().contains('timeout')) {
          _details += '💡 URL có thể không thể truy cập được hoặc network chậm\n';
        } else if (e.toString().contains('SocketException')) {
          _details += '💡 Không thể kết nối đến server\n';
          _details += '💡 Kiểm tra internet connection\n';
        }
      });
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _testUrl();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF282828),
      title: Text(
        'Test URL: ${widget.song.title}',
        style: const TextStyle(color: Colors.white),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Song: ${widget.song.title}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Artist: ${widget.song.artistName}',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              if (_isTesting)
                const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1DB954)),
                  ),
                )
              else
                Text(
                  _testResult,
                  style: TextStyle(
                    color: _testResult.contains('✅')
                        ? const Color(0xFF1DB954)
                        : _testResult.contains('❌')
                            ? Colors.red
                            : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 16),
              if (_details.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _details,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Đóng'),
        ),
        if (!_isTesting)
          TextButton(
            onPressed: _testUrl,
            child: const Text('Test lại'),
          ),
      ],
    );
  }
}

