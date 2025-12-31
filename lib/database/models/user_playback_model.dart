import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants.dart';

/// Model cho User Playback State
class UserPlaybackModel {
  final String userId;
  final CurrentSong? currentSong;
  final List<String> queue;
  final bool shuffleMode;
  final RepeatMode repeatMode;
  final List<PlayHistoryItem> recentlyPlayed;
  final List<PlayHistoryItem> playHistory;

  UserPlaybackModel({
    required this.userId,
    this.currentSong,
    this.queue = const [],
    this.shuffleMode = false,
    this.repeatMode = RepeatMode.none,
    this.recentlyPlayed = const [],
    this.playHistory = const [],
  });

  factory UserPlaybackModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserPlaybackModel(
      userId: data['userId'] ?? doc.id,
      currentSong: data['currentSong'] != null
          ? CurrentSong.fromMap(data['currentSong'])
          : null,
      queue: List<String>.from(data['queue'] ?? []),
      shuffleMode: data['shuffleMode'] ?? false,
      repeatMode: RepeatModeExtension.fromString(data['repeatMode'] ?? 'none'),
      recentlyPlayed: (data['recentlyPlayed'] as List?)
              ?.map((e) => PlayHistoryItem.fromMap(e))
              .toList() ??
          [],
      playHistory: (data['playHistory'] as List?)
              ?.map((e) => PlayHistoryItem.fromMap(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      if (currentSong != null) 'currentSong': currentSong!.toMap(),
      'queue': queue,
      'shuffleMode': shuffleMode,
      'repeatMode': repeatMode.value,
      'recentlyPlayed': recentlyPlayed.map((e) => e.toMap()).toList(),
      'playHistory': playHistory.map((e) => e.toMap()).toList(),
    };
  }

  UserPlaybackModel copyWith({
    String? userId,
    CurrentSong? currentSong,
    List<String>? queue,
    bool? shuffleMode,
    RepeatMode? repeatMode,
    List<PlayHistoryItem>? recentlyPlayed,
    List<PlayHistoryItem>? playHistory,
  }) {
    return UserPlaybackModel(
      userId: userId ?? this.userId,
      currentSong: currentSong ?? this.currentSong,
      queue: queue ?? this.queue,
      shuffleMode: shuffleMode ?? this.shuffleMode,
      repeatMode: repeatMode ?? this.repeatMode,
      recentlyPlayed: recentlyPlayed ?? this.recentlyPlayed,
      playHistory: playHistory ?? this.playHistory,
    );
  }
}

class CurrentSong {
  final String songId;
  final int position; // seconds
  final bool isPlaying;
  final DateTime startedAt;

  CurrentSong({
    required this.songId,
    required this.position,
    required this.isPlaying,
    required this.startedAt,
  });

  factory CurrentSong.fromMap(Map<String, dynamic> map) {
    return CurrentSong(
      songId: map['songId'] ?? '',
      position: map['position'] ?? 0,
      isPlaying: map['isPlaying'] ?? false,
      startedAt: (map['startedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'songId': songId,
      'position': position,
      'isPlaying': isPlaying,
      'startedAt': Timestamp.fromDate(startedAt),
    };
  }
}

class PlayHistoryItem {
  final String songId;
  final String? albumId;
  final String? artistId;
  final DateTime playedAt;
  final int duration; // seconds listened

  PlayHistoryItem({
    required this.songId,
    this.albumId,
    this.artistId,
    required this.playedAt,
    required this.duration,
  });

  factory PlayHistoryItem.fromMap(Map<String, dynamic> map) {
    return PlayHistoryItem(
      songId: map['songId'] ?? '',
      albumId: map['albumId'],
      artistId: map['artistId'],
      playedAt: (map['playedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      duration: map['duration'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'songId': songId,
      if (albumId != null) 'albumId': albumId,
      if (artistId != null) 'artistId': artistId,
      'playedAt': Timestamp.fromDate(playedAt),
      'duration': duration,
    };
  }
}

