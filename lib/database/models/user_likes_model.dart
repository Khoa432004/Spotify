import 'package:cloud_firestore/cloud_firestore.dart';

/// Model cho User Likes
class UserLikesModel {
  final String userId;
  final List<String> likedSongs;
  final List<String> likedAlbums;
  final List<String> likedArtists;
  final List<String> likedPlaylists;
  final DateTime updatedAt;

  UserLikesModel({
    required this.userId,
    this.likedSongs = const [],
    this.likedAlbums = const [],
    this.likedArtists = const [],
    this.likedPlaylists = const [],
    required this.updatedAt,
  });

  factory UserLikesModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserLikesModel(
      userId: data['userId'] ?? doc.id,
      likedSongs: List<String>.from(data['likedSongs'] ?? []),
      likedAlbums: List<String>.from(data['likedAlbums'] ?? []),
      likedArtists: List<String>.from(data['likedArtists'] ?? []),
      likedPlaylists: List<String>.from(data['likedPlaylists'] ?? []),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'likedSongs': likedSongs,
      'likedAlbums': likedAlbums,
      'likedArtists': likedArtists,
      'likedPlaylists': likedPlaylists,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  UserLikesModel copyWith({
    String? userId,
    List<String>? likedSongs,
    List<String>? likedAlbums,
    List<String>? likedArtists,
    List<String>? likedPlaylists,
    DateTime? updatedAt,
  }) {
    return UserLikesModel(
      userId: userId ?? this.userId,
      likedSongs: likedSongs ?? this.likedSongs,
      likedAlbums: likedAlbums ?? this.likedAlbums,
      likedArtists: likedArtists ?? this.likedArtists,
      likedPlaylists: likedPlaylists ?? this.likedPlaylists,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

