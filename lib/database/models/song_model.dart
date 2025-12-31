import 'package:cloud_firestore/cloud_firestore.dart';

/// Model cho Song
class SongModel {
  final String id;
  final String title;
  final String artistId;
  final String artistName;
  final String? albumId;
  final String? albumName;
  final int duration; // seconds
  final String? genre;
  final List<String> genres;
  final String audioUrl;
  final String? artworkUrl;
  final DateTime? releaseDate;
  final int playCount;
  final int likeCount;
  final DateTime createdAt;
  final bool isExplicit;
  final int? trackNumber;
  final int popularity; // 0-100
  final List<String> tags;

  SongModel({
    required this.id,
    required this.title,
    required this.artistId,
    required this.artistName,
    this.albumId,
    this.albumName,
    required this.duration,
    this.genre,
    this.genres = const [],
    required this.audioUrl,
    this.artworkUrl,
    this.releaseDate,
    this.playCount = 0,
    this.likeCount = 0,
    required this.createdAt,
    this.isExplicit = false,
    this.trackNumber,
    this.popularity = 0,
    this.tags = const [],
  });

  factory SongModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SongModel(
      id: doc.id,
      title: data['title'] ?? '',
      artistId: data['artistId'] ?? '',
      artistName: data['artistName'] ?? '',
      albumId: data['albumId'],
      albumName: data['albumName'],
      duration: data['duration'] ?? 0,
      genre: data['genre'],
      genres: List<String>.from(data['genres'] ?? []),
      audioUrl: data['audioUrl'] ?? '',
      artworkUrl: data['artworkUrl'],
      releaseDate: (data['releaseDate'] as Timestamp?)?.toDate(),
      playCount: data['playCount'] ?? 0,
      likeCount: data['likeCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isExplicit: data['isExplicit'] ?? false,
      trackNumber: data['trackNumber'],
      popularity: data['popularity'] ?? 0,
      tags: List<String>.from(data['tags'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'artistId': artistId,
      'artistName': artistName,
      if (albumId != null) 'albumId': albumId,
      if (albumName != null) 'albumName': albumName,
      'duration': duration,
      if (genre != null) 'genre': genre,
      'genres': genres,
      'audioUrl': audioUrl,
      if (artworkUrl != null) 'artworkUrl': artworkUrl,
      if (releaseDate != null) 'releaseDate': Timestamp.fromDate(releaseDate!),
      'playCount': playCount,
      'likeCount': likeCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'isExplicit': isExplicit,
      if (trackNumber != null) 'trackNumber': trackNumber,
      'popularity': popularity,
      'tags': tags,
    };
  }

  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  SongModel copyWith({
    String? id,
    String? title,
    String? artistId,
    String? artistName,
    String? albumId,
    String? albumName,
    int? duration,
    String? genre,
    List<String>? genres,
    String? audioUrl,
    String? artworkUrl,
    DateTime? releaseDate,
    int? playCount,
    int? likeCount,
    DateTime? createdAt,
    bool? isExplicit,
    int? trackNumber,
    int? popularity,
    List<String>? tags,
  }) {
    return SongModel(
      id: id ?? this.id,
      title: title ?? this.title,
      artistId: artistId ?? this.artistId,
      artistName: artistName ?? this.artistName,
      albumId: albumId ?? this.albumId,
      albumName: albumName ?? this.albumName,
      duration: duration ?? this.duration,
      genre: genre ?? this.genre,
      genres: genres ?? this.genres,
      audioUrl: audioUrl ?? this.audioUrl,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      releaseDate: releaseDate ?? this.releaseDate,
      playCount: playCount ?? this.playCount,
      likeCount: likeCount ?? this.likeCount,
      createdAt: createdAt ?? this.createdAt,
      isExplicit: isExplicit ?? this.isExplicit,
      trackNumber: trackNumber ?? this.trackNumber,
      popularity: popularity ?? this.popularity,
      tags: tags ?? this.tags,
    );
  }
}

