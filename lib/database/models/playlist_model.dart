import 'package:cloud_firestore/cloud_firestore.dart';

/// Model cho Playlist
class PlaylistModel {
  final String id;
  final String title;
  final String? description;
  final String ownerId; // userId or "system"
  final bool isPublic;
  final String? artworkUrl;
  final List<String> songIds;
  final int followerCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? genre;
  final List<String> tags;

  PlaylistModel({
    required this.id,
    required this.title,
    this.description,
    required this.ownerId,
    this.isPublic = true,
    this.artworkUrl,
    this.songIds = const [],
    this.followerCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.genre,
    this.tags = const [],
  });

  factory PlaylistModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PlaylistModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'],
      ownerId: data['ownerId'] ?? '',
      isPublic: data['isPublic'] ?? true,
      artworkUrl: data['artworkUrl'],
      songIds: List<String>.from(data['songIds'] ?? []),
      followerCount: data['followerCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      genre: data['genre'],
      tags: List<String>.from(data['tags'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      if (description != null) 'description': description,
      'ownerId': ownerId,
      'isPublic': isPublic,
      if (artworkUrl != null) 'artworkUrl': artworkUrl,
      'songIds': songIds,
      'followerCount': followerCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      if (genre != null) 'genre': genre,
      'tags': tags,
    };
  }

  PlaylistModel copyWith({
    String? id,
    String? title,
    String? description,
    String? ownerId,
    bool? isPublic,
    String? artworkUrl,
    List<String>? songIds,
    int? followerCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? genre,
    List<String>? tags,
  }) {
    return PlaylistModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      isPublic: isPublic ?? this.isPublic,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      songIds: songIds ?? this.songIds,
      followerCount: followerCount ?? this.followerCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      genre: genre ?? this.genre,
      tags: tags ?? this.tags,
    );
  }
}

