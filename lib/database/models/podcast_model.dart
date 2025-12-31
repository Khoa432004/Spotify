import 'package:cloud_firestore/cloud_firestore.dart';

/// Model cho Podcast
class PodcastModel {
  final String id;
  final String title;
  final String? description;
  final String hostId;
  final String hostName;
  final String? imageUrl;
  final String? category;
  final List<String> categories;
  final List<String> episodeIds;
  final int followerCount;
  final int totalEpisodes;
  final DateTime createdAt;
  final List<String> tags;

  PodcastModel({
    required this.id,
    required this.title,
    this.description,
    required this.hostId,
    required this.hostName,
    this.imageUrl,
    this.category,
    this.categories = const [],
    this.episodeIds = const [],
    this.followerCount = 0,
    this.totalEpisodes = 0,
    required this.createdAt,
    this.tags = const [],
  });

  factory PodcastModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PodcastModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'],
      hostId: data['hostId'] ?? '',
      hostName: data['hostName'] ?? '',
      imageUrl: data['imageUrl'],
      category: data['category'],
      categories: List<String>.from(data['categories'] ?? []),
      episodeIds: List<String>.from(data['episodeIds'] ?? []),
      followerCount: data['followerCount'] ?? 0,
      totalEpisodes: data['totalEpisodes'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      tags: List<String>.from(data['tags'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      if (description != null) 'description': description,
      'hostId': hostId,
      'hostName': hostName,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (category != null) 'category': category,
      'categories': categories,
      'episodeIds': episodeIds,
      'followerCount': followerCount,
      'totalEpisodes': totalEpisodes,
      'createdAt': Timestamp.fromDate(createdAt),
      'tags': tags,
    };
  }

  PodcastModel copyWith({
    String? id,
    String? title,
    String? description,
    String? hostId,
    String? hostName,
    String? imageUrl,
    String? category,
    List<String>? categories,
    List<String>? episodeIds,
    int? followerCount,
    int? totalEpisodes,
    DateTime? createdAt,
    List<String>? tags,
  }) {
    return PodcastModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      hostId: hostId ?? this.hostId,
      hostName: hostName ?? this.hostName,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      categories: categories ?? this.categories,
      episodeIds: episodeIds ?? this.episodeIds,
      followerCount: followerCount ?? this.followerCount,
      totalEpisodes: totalEpisodes ?? this.totalEpisodes,
      createdAt: createdAt ?? this.createdAt,
      tags: tags ?? this.tags,
    );
  }
}

/// Model cho Podcast Episode
class PodcastEpisodeModel {
  final String id;
  final String podcastId;
  final String title;
  final String? description;
  final int episodeNumber;
  final int duration; // seconds
  final String audioUrl;
  final String? artworkUrl;
  final DateTime? releaseDate;
  final int playCount;
  final int likeCount;
  final bool isExplicit;
  final DateTime createdAt;

  PodcastEpisodeModel({
    required this.id,
    required this.podcastId,
    required this.title,
    this.description,
    required this.episodeNumber,
    required this.duration,
    required this.audioUrl,
    this.artworkUrl,
    this.releaseDate,
    this.playCount = 0,
    this.likeCount = 0,
    this.isExplicit = false,
    required this.createdAt,
  });

  factory PodcastEpisodeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PodcastEpisodeModel(
      id: doc.id,
      podcastId: data['podcastId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'],
      episodeNumber: data['episodeNumber'] ?? 0,
      duration: data['duration'] ?? 0,
      audioUrl: data['audioUrl'] ?? '',
      artworkUrl: data['artworkUrl'],
      releaseDate: (data['releaseDate'] as Timestamp?)?.toDate(),
      playCount: data['playCount'] ?? 0,
      likeCount: data['likeCount'] ?? 0,
      isExplicit: data['isExplicit'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'podcastId': podcastId,
      'title': title,
      if (description != null) 'description': description,
      'episodeNumber': episodeNumber,
      'duration': duration,
      'audioUrl': audioUrl,
      if (artworkUrl != null) 'artworkUrl': artworkUrl,
      if (releaseDate != null) 'releaseDate': Timestamp.fromDate(releaseDate!),
      'playCount': playCount,
      'likeCount': likeCount,
      'isExplicit': isExplicit,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  String get formattedDuration {
    final hours = duration ~/ 3600;
    final minutes = (duration % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}HR ${minutes}MIN';
    }
    return '${minutes}MIN';
  }

  PodcastEpisodeModel copyWith({
    String? id,
    String? podcastId,
    String? title,
    String? description,
    int? episodeNumber,
    int? duration,
    String? audioUrl,
    String? artworkUrl,
    DateTime? releaseDate,
    int? playCount,
    int? likeCount,
    bool? isExplicit,
    DateTime? createdAt,
  }) {
    return PodcastEpisodeModel(
      id: id ?? this.id,
      podcastId: podcastId ?? this.podcastId,
      title: title ?? this.title,
      description: description ?? this.description,
      episodeNumber: episodeNumber ?? this.episodeNumber,
      duration: duration ?? this.duration,
      audioUrl: audioUrl ?? this.audioUrl,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      releaseDate: releaseDate ?? this.releaseDate,
      playCount: playCount ?? this.playCount,
      likeCount: likeCount ?? this.likeCount,
      isExplicit: isExplicit ?? this.isExplicit,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

