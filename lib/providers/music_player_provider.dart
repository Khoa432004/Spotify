import 'package:flutter/foundation.dart';
import '../services/music_player_service.dart';
import '../database/models/song_model.dart';

/// Provider cho Music Player Service
/// Quản lý state và notify listeners khi có thay đổi
class MusicPlayerProvider extends ChangeNotifier {
  final MusicPlayerService _service = MusicPlayerService();
  
  // Getters
  SongModel? get currentSong => _service.currentSong;
  List<SongModel> get queue => _service.queue;
  bool get shuffleMode => _service.shuffleMode;
  RepeatMode get repeatMode => _service.repeatMode;
  bool get isPlaying => _service.isPlaying;
  Duration get position => _service.position;
  Duration? get duration => _service.duration;
  int get currentIndex => _service.currentIndex;
  
  // Streams
  Stream<Duration> get positionStream => _service.positionStream;
  Stream<Duration?> get durationStream => _service.durationStream;
  Stream<bool> get playingStream => _service.playingStream;
  
  MusicPlayerProvider() {
    // Listen to player state changes
    _service.playingStream.listen((_) {
      notifyListeners();
    });
    
    // Listen to position updates (optional - có thể tắt để giảm notify)
    _service.positionStream.listen((position) {
      // Chỉ notify mỗi giây để tránh rebuild quá nhiều
      if (position.inSeconds % 1 == 0) {
        notifyListeners();
      }
    });
  }
  
  /// Phát một bài hát
  Future<void> playSong(
    SongModel song, {
    List<SongModel>? queue,
    int? initialIndex,
  }) async {
    try {
      await _service.playSong(song, queue: queue, initialIndex: initialIndex);
      notifyListeners();
    } catch (e) {
      print('❌ Lỗi trong Provider: $e');
      // Có thể thêm error handling ở đây để hiển thị snackbar hoặc dialog
      rethrow;
    }
  }
  
  /// Toggle play/pause
  Future<void> togglePlayPause() async {
    await _service.togglePlayPause();
    notifyListeners();
  }
  
  /// Next song
  Future<void> nextSong() async {
    await _service.nextSong();
    notifyListeners();
  }
  
  /// Previous song
  Future<void> previousSong() async {
    await _service.previousSong();
    notifyListeners();
  }
  
  /// Toggle shuffle
  void toggleShuffle() {
    _service.toggleShuffle();
    notifyListeners();
  }
  
  /// Toggle repeat
  void toggleRepeat() {
    _service.toggleRepeat();
    notifyListeners();
  }
  
  /// Seek to position
  Future<void> seek(Duration position) async {
    await _service.seek(position);
    notifyListeners();
  }
  
  /// Set volume
  Future<void> setVolume(double volume) async {
    await _service.setVolume(volume);
  }
  
  /// Stop playback
  Future<void> stop() async {
    await _service.stop();
    notifyListeners();
  }
  
  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}

