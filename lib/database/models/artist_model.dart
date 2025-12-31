import 'package:cloud_firestore/cloud_firestore.dart';

/// Model cho Artist
class ArtistModel {
  final String id;
  final String name;
  final String? imageUrl;
  final String? bio;
  final List<String> genres;
  final int monthlyListeners;
  final int followerCount;
  final List<String> albumIds;
  final List<String> songIds;
  final bool verified;
  final DateTime createdAt;
  final ArtistSocialLinks? socialLinks;

  ArtistModel({
    required this.id,
    required this.name,
    this.imageUrl,
    this.bio,
    this.genres = const [],
    this.monthlyListeners = 0,
    this.followerCount = 0,
    this.albumIds = const [],
    this.songIds = const [],
    this.verified = false,
    required this.createdAt,
    this.socialLinks,
  });

  factory ArtistModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ArtistModel(
      id: doc.id,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'],
      bio: data['bio'],
      genres: List<String>.from(data['genres'] ?? []),
      monthlyListeners: data['monthlyListeners'] ?? 0,
      followerCount: data['followerCount'] ?? 0,
      albumIds: List<String>.from(data['albumIds'] ?? []),
      songIds: List<String>.from(data['songIds'] ?? []),
      verified: data['verified'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      socialLinks: data['socialLinks'] != null
          ? ArtistSocialLinks.fromMap(data['socialLinks'])
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (bio != null) 'bio': bio,
      'genres': genres,
      'monthlyListeners': monthlyListeners,
      'followerCount': followerCount,
      'albumIds': albumIds,
      'songIds': songIds,
      'verified': verified,
      'createdAt': Timestamp.fromDate(createdAt),
      if (socialLinks != null) 'socialLinks': socialLinks!.toMap(),
    };
  }

  String get formattedMonthlyListeners {
    if (monthlyListeners >= 1000000) {
      return '${(monthlyListeners / 1000000).toStringAsFixed(1)}M';
    } else if (monthlyListeners >= 1000) {
      return '${(monthlyListeners / 1000).toStringAsFixed(1)}K';
    }
    return monthlyListeners.toString();
  }

  ArtistModel copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? bio,
    List<String>? genres,
    int? monthlyListeners,
    int? followerCount,
    List<String>? albumIds,
    List<String>? songIds,
    bool? verified,
    DateTime? createdAt,
    ArtistSocialLinks? socialLinks,
  }) {
    return ArtistModel(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      bio: bio ?? this.bio,
      genres: genres ?? this.genres,
      monthlyListeners: monthlyListeners ?? this.monthlyListeners,
      followerCount: followerCount ?? this.followerCount,
      albumIds: albumIds ?? this.albumIds,
      songIds: songIds ?? this.songIds,
      verified: verified ?? this.verified,
      createdAt: createdAt ?? this.createdAt,
      socialLinks: socialLinks ?? this.socialLinks,
    );
  }
}

class ArtistSocialLinks {
  final String? website;
  final String? instagram;
  final String? twitter;

  ArtistSocialLinks({
    this.website,
    this.instagram,
    this.twitter,
  });

  factory ArtistSocialLinks.fromMap(Map<String, dynamic> map) {
    return ArtistSocialLinks(
      website: map['website'],
      instagram: map['instagram'],
      twitter: map['twitter'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (website != null) 'website': website,
      if (instagram != null) 'instagram': instagram,
      if (twitter != null) 'twitter': twitter,
    };
  }
}

