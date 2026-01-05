import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;
import '../database/models/song_model.dart';

/// Repeat mode cho music player
enum RepeatMode {
  none, // Không lặp
  all,  // Lặp lại cả playlist
  one,  // Lặp lại 1 bài
}

/// Service quản lý music playback với shuffle và repeat
class MusicPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // State
  SongModel? _currentSong;
  List<SongModel> _queue = [];
  List<SongModel> _originalQueue = [];
  List<SongModel> _shuffledQueue = [];
  int _currentIndex = -1;
  bool _shuffleMode = false;
  RepeatMode _repeatMode = RepeatMode.none;
  
  // Streams
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<bool> get playingStream => _audioPlayer.playingStream;
  
  // Getters
  SongModel? get currentSong => _currentSong;
  List<SongModel> get queue => _shuffleMode ? _shuffledQueue : _originalQueue;
  bool get shuffleMode => _shuffleMode;
  RepeatMode get repeatMode => _repeatMode;
  bool get isPlaying => _audioPlayer.playing;
  Duration get position => _audioPlayer.position;
  Duration? get duration => _audioPlayer.duration;
  int get currentIndex => _currentIndex;
  
  MusicPlayerService() {
    // Listen to player state changes
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _handleSongCompleted();
      }
    });
  }
  
  /// Phát một bài hát với optional queue
  Future<void> playSong(
    SongModel song, {
    List<SongModel>? queue,
    int? initialIndex,
  }) async {
    try {
      // Validate audio URL
      if (song.audioUrl.isEmpty) {
        throw Exception('Audio URL is empty for song: ${song.title}');
      }
      
      // Validate URL format - cho phép cả HTTP và file path
      final uri = Uri.tryParse(song.audioUrl);
      final isLocalFile = song.audioUrl.startsWith('/') || song.audioUrl.startsWith('file://');
      final isHttpUrl = uri != null && uri.hasScheme && (uri.scheme.startsWith('http'));
      
      if (!isLocalFile && !isHttpUrl) {
        throw Exception('Invalid audio URL format: ${song.audioUrl}');
      }
      
      _currentSong = song;
      
      if (queue != null && queue.isNotEmpty) {
        _originalQueue = List.from(queue);
        _shuffledQueue = List.from(queue)..shuffle();
        
        // Tìm index của bài hát hiện tại
        if (initialIndex != null) {
          _currentIndex = initialIndex;
        } else {
          _currentIndex = _originalQueue.indexWhere((s) => s.id == song.id);
          if (_currentIndex == -1) {
            _currentIndex = 0;
          }
        }
      } else {
        // Nếu không có queue, tạo queue chỉ có bài này
        _originalQueue = [song];
        _shuffledQueue = [song];
        _currentIndex = 0;
      }
      
      print('🎵 Đang tải: ${song.title}');
      print('🔗 URL: ${song.audioUrl}');
      
      // Normalize URL (decode if needed)
      String normalizedUrl = song.audioUrl;
      try {
        // Thử decode URL nếu có ký tự encoded
        final decoded = Uri.decodeComponent(song.audioUrl);
        if (decoded != song.audioUrl) {
          // Re-encode properly
          final uri = Uri.parse(song.audioUrl);
          normalizedUrl = uri.toString();
        }
      } catch (e) {
        // Nếu không decode được, dùng URL gốc
        normalizedUrl = song.audioUrl;
      }
      
      // Test URL accessibility trước khi load vào player (chỉ cho HTTP URLs)
      if (!isLocalFile) {
        print('🔍 Đang kiểm tra URL...');
        print('📋 Normalized URL: $normalizedUrl');
        try {
        // Thử GET với range request (như audio player sẽ làm)
        final uri = Uri.parse(normalizedUrl);
        final response = await http.get(
          uri,
          headers: {
            'Range': 'bytes=0-1023', // Chỉ request first 1KB để test
            'User-Agent': 'Flutter-App',
          },
        ).timeout(
          const Duration(seconds: 8),
        );
        
        print('📊 HTTP Response Status: ${response.statusCode}');
        print('📊 Response Headers: ${response.headers}');
        
        if (response.statusCode == 404) {
          throw Exception(
            'Audio file not found (404).\n'
            'The file might have been deleted from Firebase Storage.\n'
            'Please upload the file again or check the file path.\n'
            'URL: $normalizedUrl'
          );
        } else if (response.statusCode == 403) {
          throw Exception(
            'Access denied (403).\n'
            'The Firebase Storage token may have expired.\n'
            'Please regenerate the download URL in Firebase Storage.\n'
            'You may also need to check Firebase Storage security rules.'
          );
        } else if (response.statusCode == 401) {
          throw Exception(
            'Unauthorized (401).\n'
            'The Firebase Storage token is invalid or expired.\n'
            'Please regenerate the download URL in Firebase Storage.'
          );
        } else if (response.statusCode == 206 || response.statusCode == 200) {
          // 206 = Partial Content (OK for range requests)
          // 200 = OK
          final contentType = response.headers['content-type'] ?? 'unknown';
          print('✅ URL is accessible (${response.statusCode})');
          print('✅ Content-Type: $contentType');
          
          if (!contentType.toLowerCase().contains('audio') && 
              !contentType.toLowerCase().contains('mp3') &&
              !contentType.toLowerCase().contains('mpeg')) {
            print('⚠️ Warning: Content-Type is not audio: $contentType');
            // Continue anyway, might still work
          }
        } else {
          print('⚠️ URL returned unexpected status code: ${response.statusCode}');
          if (response.body.isNotEmpty) {
            final preview = response.body.length > 200 
                ? '${response.body.substring(0, 200)}...' 
                : response.body;
            print('⚠️ Response body preview: $preview');
          }
          // Continue anyway, might still work for audio streaming
        }
      } catch (e) {
        // Kiểm tra nếu là timeout hoặc network error
        final errorStr = e.toString().toLowerCase();
        if (errorStr.contains('404') || errorStr.contains('not found')) {
          throw Exception(
            'Audio file not found (404).\n'
            'The file might have been deleted from Firebase Storage.\n'
            'Please upload the file again or check the file path.\n'
            'Error: $e'
          );
        } else if (errorStr.contains('403') || errorStr.contains('forbidden')) {
          throw Exception(
            'Access denied (403).\n'
            'The Firebase Storage token may have expired.\n'
            'Please regenerate the download URL in Firebase Storage.\n'
            'Error: $e'
          );
        } else if (errorStr.contains('timeout') || errorStr.contains('timed out')) {
          print('⚠️ URL test timeout, but continuing anyway: $e');
          // Continue - có thể network chậm nhưng file vẫn có thể tải được
        } else {
          print('⚠️ URL test failed, but continuing: $e');
          // Continue - có thể HEAD không được hỗ trợ nhưng GET vẫn work
        }
      }
      } // End if (!isLocalFile)
      
      // Set audio source với timeout và better error handling
      print('🎵 Đang load audio source vào player...');
      print('🔗 Final URL/Path: $normalizedUrl');
      
      try {
        // Sử dụng setFilePath cho local file, setUrl cho HTTP URL
        if (isLocalFile) {
          // Loại bỏ file:// prefix nếu có
          final filePath = normalizedUrl.replaceFirst('file://', '');
          final file = File(filePath);
          
          if (!await file.exists()) {
            throw Exception('Local file not found: $filePath');
          }
          
          await _audioPlayer.setFilePath(filePath).timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print('⏱️ Timeout khi set audio file path');
              throw Exception('Timeout loading audio file.');
            },
          );
          print('📁 Đang phát từ local file');
        } else {
          await _audioPlayer.setUrl(
            normalizedUrl,
            headers: {
              'User-Agent': 'Flutter-App',
              'Accept': '*/*',
            },
          ).timeout(
            const Duration(seconds: 20),
            onTimeout: () {
              print('⏱️ Timeout khi set audio source sau 20 giây');
              throw Exception('Timeout loading audio URL. URL might be invalid or unreachable.');
            },
          );
        }
        
        print('✅ Audio source đã được set thành công');
        
        // Wait để player initialize và load metadata
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Kiểm tra processing state
        final state = _audioPlayer.processingState;
        print('📊 Processing State: $state');
        print('📊 Duration: ${_audioPlayer.duration}');
        print('📊 Position: ${_audioPlayer.position}');
        
        // Kiểm tra nếu state vẫn là idle sau khi setUrl (có nghĩa là không load được)
        if (state == ProcessingState.idle) {
          // Đợi thêm một chút để xem có load được không
          await Future.delayed(const Duration(milliseconds: 500));
          final newState = _audioPlayer.processingState;
          if (newState == ProcessingState.idle && _audioPlayer.duration == null) {
            throw Exception(
              'Cannot load audio source.\n'
              'The file might not be a valid audio file, the URL is invalid, '
              'or the file format is not supported.\n'
              'Please check:\n'
              '1. The file exists in Firebase Storage\n'
              '2. The file is a valid MP3/audio file\n'
              '3. The download URL token has not expired\n'
              'Processing State: $newState'
            );
          }
        }
        
        // Kiểm tra duration sau khi đợi một chút
        if (_audioPlayer.duration == null && state != ProcessingState.loading) {
          // Đợi thêm nếu đang loading
          if (state == ProcessingState.loading || state == ProcessingState.buffering) {
            await Future.delayed(const Duration(seconds: 2));
          }
          
          if (_audioPlayer.duration == null) {
            throw Exception(
              'Cannot determine audio duration.\n'
              'The file might not be a valid audio file or the URL is invalid.\n'
              'Please verify the file exists and is accessible in Firebase Storage.\n'
              'State: ${_audioPlayer.processingState}'
            );
          }
        }
        
      } catch (e, stackTrace) {
        print('❌ Error khi set audio source:');
        print('   Error type: ${e.runtimeType}');
        print('   Error: $e');
        print('   StackTrace: $stackTrace');
        
        final errorString = e.toString().toLowerCase();
        
        if (errorString.contains('404') || 
            errorString.contains('not found') || 
            errorString.contains('file not found')) {
          throw Exception(
            'Audio file not found (404).\n'
            'The file might have been deleted or the URL is invalid.\n'
            'Please check the file in Firebase Storage.\n'
            'URL: $normalizedUrl'
          );
        } else if (errorString.contains('403') || errorString.contains('forbidden')) {
          throw Exception(
            'Access denied (403).\n'
            'The Firebase Storage token may have expired.\n'
            'Please regenerate the download URL in Firebase Storage.'
          );
        } else if (errorString.contains('timeout') || errorString.contains('timed out')) {
          throw Exception(
            'Timeout loading audio (20 seconds).\n'
            'Please check your internet connection and try again.\n'
            'The file might be too large or the connection is slow.'
          );
        } else if (errorString.contains('source error') || 
                   errorString.contains('(0)') ||
                   errorString.contains('processing failed') ||
                   errorString.contains('cannot determine')) {
          throw Exception(
            'Cannot load audio source.\n'
            'The file might be corrupted, in an unsupported format, '
            'or the URL is invalid.\n'
            'Please verify:\n'
            '1. The file exists in Firebase Storage\n'
            '2. The file is a valid MP3/audio file\n'
            '3. The download URL token has not expired\n'
            'You can test the URL using the "Test URL" button.\n'
            'Error: $e'
          );
        } else if (errorString.contains('network') || errorString.contains('connection')) {
          throw Exception(
            'Network error.\n'
            'Please check your internet connection and try again.'
          );
        } else {
          throw Exception(
            'Failed to load audio.\n'
            'Error: $e\n'
            'Please check if the file exists and is accessible.'
          );
        }
      }
      
      // Apply repeat mode
      _applyRepeatMode();
      
      // Play
      await _audioPlayer.play();
      
      print('▶️ Đang phát: ${song.title}');
    } catch (e) {
      print('❌ Lỗi khi phát nhạc: $e');
      print('   Song: ${song.title}');
      print('   URL: ${song.audioUrl}');
      rethrow;
    }
  }
  
  /// Pause/Resume
  Future<void> togglePlayPause() async {
    try {
      if (_audioPlayer.playing) {
        await _audioPlayer.pause();
        print('⏸️ Đã tạm dừng');
      } else {
        await _audioPlayer.play();
        print('▶️ Đã tiếp tục phát');
      }
    } catch (e) {
      print('❌ Lỗi khi toggle play/pause: $e');
    }
  }
  
  /// Phát bài tiếp theo
  Future<void> nextSong() async {
    if (queue.isEmpty) return;
    
    final activeQueue = _shuffleMode ? _shuffledQueue : _originalQueue;
    
    if (_repeatMode == RepeatMode.one) {
      // Lặp lại bài hiện tại
      await _playAtIndex(_currentIndex);
      return;
    }
    
    // Tìm index tiếp theo trong queue hiện tại
    int nextIndex = _getNextIndex(activeQueue);
    
    if (nextIndex == -1) {
      // Hết queue, kiểm tra repeat mode
      if (_repeatMode == RepeatMode.all) {
        // Reset về đầu
        nextIndex = 0;
      } else {
        // Dừng phát
        await _audioPlayer.stop();
        return;
      }
    }
    
    await _playAtIndex(nextIndex);
  }
  
  /// Phát bài trước đó
  Future<void> previousSong() async {
    if (queue.isEmpty) return;
    
    final activeQueue = _shuffleMode ? _shuffledQueue : _originalQueue;
    
    // Tìm index bài trước
    int prevIndex = _getPreviousIndex(activeQueue);
    
    if (prevIndex == -1) {
      // Quay lại cuối nếu repeat all
      if (_repeatMode == RepeatMode.all) {
        prevIndex = activeQueue.length - 1;
      } else {
        // Quay lại đầu bài hiện tại
        await _audioPlayer.seek(Duration.zero);
        return;
      }
    }
    
    await _playAtIndex(prevIndex);
  }
  
  /// Toggle shuffle mode
  void toggleShuffle() {
    _shuffleMode = !_shuffleMode;
    
    if (_shuffleMode) {
      // Tạo shuffled queue: giữ nguyên bài hiện tại, shuffle các bài còn lại
      _shuffledQueue = List.from(_originalQueue);
      
      // Tìm và tách bài hiện tại ra
      final currentSongId = _currentSong?.id;
      if (currentSongId != null && _currentIndex >= 0 && _currentIndex < _shuffledQueue.length) {
        // Remove bài hiện tại khỏi queue
        final currentSong = _shuffledQueue.removeAt(_currentIndex);
        
        // Shuffle các bài còn lại
        _shuffledQueue.shuffle();
        
        // Thêm bài hiện tại vào đầu
        _shuffledQueue.insert(0, currentSong);
        _currentIndex = 0;
      } else {
        // Nếu không tìm thấy bài hiện tại, shuffle toàn bộ
        _shuffledQueue.shuffle();
        // Tìm lại index của bài hiện tại trong shuffled queue
        if (currentSongId != null) {
          final index = _shuffledQueue.indexWhere((s) => s.id == currentSongId);
          if (index != -1) {
            final current = _shuffledQueue.removeAt(index);
            _shuffledQueue.insert(0, current);
            _currentIndex = 0;
          } else {
            _currentIndex = 0;
          }
        } else {
          _currentIndex = 0;
        }
      }
      
      print('🔀 Shuffle: ON (${_shuffledQueue.length} bài)');
    } else {
      // Restore original queue và tìm lại index của bài hiện tại
      if (_currentSong != null) {
        _currentIndex = _originalQueue.indexWhere(
          (s) => s.id == _currentSong!.id,
        );
        if (_currentIndex == -1) {
          _currentIndex = 0;
        }
      } else {
        _currentIndex = 0;
      }
      print('🔀 Shuffle: OFF');
    }
  }
  
  /// Toggle repeat mode: none -> all -> one -> none
  void toggleRepeat() {
    switch (_repeatMode) {
      case RepeatMode.none:
        _repeatMode = RepeatMode.all;
        print('🔁 Repeat: ALL');
        break;
      case RepeatMode.all:
        _repeatMode = RepeatMode.one;
        print('🔁 Repeat: ONE');
        break;
      case RepeatMode.one:
        _repeatMode = RepeatMode.none;
        print('🔁 Repeat: OFF');
        break;
    }
    _applyRepeatMode();
  }
  
  /// Seek to position
  Future<void> seek(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      print('❌ Lỗi khi seek: $e');
    }
  }
  
  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
  }
  
  /// Stop playback
  Future<void> stop() async {
    await _audioPlayer.stop();
    _currentSong = null;
    _currentIndex = -1;
  }
  
  /// Dispose resources
  void dispose() {
    _audioPlayer.dispose();
  }
  
  // ========== Private Methods ==========
  
  /// Apply repeat mode to audio player
  void _applyRepeatMode() {
    switch (_repeatMode) {
      case RepeatMode.none:
        _audioPlayer.setLoopMode(LoopMode.off);
        break;
      case RepeatMode.all:
        _audioPlayer.setLoopMode(LoopMode.all);
        break;
      case RepeatMode.one:
        _audioPlayer.setLoopMode(LoopMode.one);
        break;
    }
  }
  
  /// Phát bài tại index
  Future<void> _playAtIndex(int index) async {
    final activeQueue = _shuffleMode ? _shuffledQueue : _originalQueue;
    
    if (index < 0 || index >= activeQueue.length) {
      print('⚠️ Index không hợp lệ: $index');
      return;
    }
    
    _currentIndex = index;
    final song = activeQueue[index];
    await playSong(song, queue: activeQueue, initialIndex: index);
  }
  
  /// Tìm index tiếp theo
  int _getNextIndex(List<SongModel> queue) {
    if (queue.isEmpty) return -1;
    
    final nextIndex = _currentIndex + 1;
    if (nextIndex < queue.length) {
      return nextIndex;
    }
    return -1; // Hết queue
  }
  
  /// Tìm index bài trước
  int _getPreviousIndex(List<SongModel> queue) {
    if (queue.isEmpty) return -1;
    
    final prevIndex = _currentIndex - 1;
    if (prevIndex >= 0) {
      return prevIndex;
    }
    return -1; // Đã ở đầu
  }
  
  /// Xử lý khi bài hát phát xong
  void _handleSongCompleted() {
    if (_repeatMode == RepeatMode.one) {
      // Đã được xử lý bởi LoopMode.one
      return;
    }
    
    if (_repeatMode == RepeatMode.all) {
      // Đã được xử lý bởi LoopMode.all
      return;
    }
    
    // RepeatMode.none - tự động next
    nextSong();
  }
}

