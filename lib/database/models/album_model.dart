import 'package:cloud_firestore/cloud_firestore.dart';

/// Model cho Album
class AlbumModel {
  final String id;
  final String title;
  final String artistId;
  final String artistName;
  final String? artworkUrl;
  final DateTime? releaseDate;
  final String? genre;
  final List<String> genres;
  final int totalTracks;
  final int duration; // total seconds
  final List<String> songIds;
  final int playCount;
  final int likeCount;
  final DateTime createdAt;
  final String? description;

  AlbumModel({
    required this.id,
    required this.title,
    required this.artistId,
    required this.artistName,
    this.artworkUrl,
    this.releaseDate,
    this.genre,
    this.genres = const [],
    this.totalTracks = 0,
    this.duration = 0,
    this.songIds = const [],
    this.playCount = 0,
    this.likeCount = 0,
    required this.createdAt,
    this.description,
  });

  factory AlbumModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AlbumModel(
      id: doc.id,
      title: data['title'] ?? '',
      artistId: data['artistId'] ?? '',
      artistName: data['artistName'] ?? '',
      artworkUrl: data['artworkUrl'],
      releaseDate: (data['releaseDate'] as Timestamp?)?.toDate(),
      genre: data['genre'],
      genres: List<String>.from(data['genres'] ?? []),
      totalTracks: data['totalTracks'] ?? 0,
      duration: data['duration'] ?? 0,
      songIds: List<String>.from(data['songIds'] ?? []),
      playCount: data['playCount'] ?? 0,
      likeCount: data['likeCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      description: data['description'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'artistId': artistId,
      'artistName': artistName,
      if (artworkUrl != null) 'artworkUrl': artworkUrl,
      if (releaseDate != null) 'releaseDate': Timestamp.fromDate(releaseDate!),
      if (genre != null) 'genre': genre,
      'genres': genres,
      'totalTracks': totalTracks,
      'duration': duration,
      'songIds': songIds,
      'playCount': playCount,
      'likeCount': likeCount,
      'createdAt': Timestamp.fromDate(createdAt),
      if (description != null) 'description': description,
    };
  }

  String get formattedDuration {
    final hours = duration ~/ 3600;
    final minutes = (duration % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  AlbumModel copyWith({
    String? id,
    String? title,
    String? artistId,
    String? artistName,
    String? artworkUrl,
    DateTime? releaseDate,
    String? genre,
    List<String>? genres,
    int? totalTracks,
    int? duration,
    List<String>? songIds,
    int? playCount,
    int? likeCount,
    DateTime? createdAt,
    String? description,
  }) {
    return AlbumModel(
      id: id ?? this.id,
      title: title ?? this.title,
      artistId: artistId ?? this.artistId,
      artistName: artistName ?? this.artistName,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      releaseDate: releaseDate ?? this.releaseDate,
      genre: genre ?? this.genre,
      genres: genres ?? this.genres,
      totalTracks: totalTracks ?? this.totalTracks,
      duration: duration ?? this.duration,
      songIds: songIds ?? this.songIds,
      playCount: playCount ?? this.playCount,
      likeCount: likeCount ?? this.likeCount,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
    );
  }
}

