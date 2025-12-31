import 'package:cloud_firestore/cloud_firestore.dart';

/// Model cho User
class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? photoURL;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserPreferences? preferences;
  final UserSubscription? subscription;
  final UserStats? stats;

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoURL,
    required this.createdAt,
    required this.updatedAt,
    this.preferences,
    this.subscription,
    this.stats,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoURL: data['photoURL'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      preferences: data['preferences'] != null
          ? UserPreferences.fromMap(data['preferences'])
          : null,
      subscription: data['subscription'] != null
          ? UserSubscription.fromMap(data['subscription'])
          : null,
      stats: data['stats'] != null
          ? UserStats.fromMap(data['stats'])
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      if (preferences != null) 'preferences': preferences!.toMap(),
      if (subscription != null) 'subscription': subscription!.toMap(),
      if (stats != null) 'stats': stats!.toMap(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoURL,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserPreferences? preferences,
    UserSubscription? subscription,
    UserStats? stats,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      preferences: preferences ?? this.preferences,
      subscription: subscription ?? this.subscription,
      stats: stats ?? this.stats,
    );
  }
}

class UserPreferences {
  final String theme; // 'dark' or 'light'
  final String language;
  final UserLocation? location;

  UserPreferences({
    this.theme = 'dark',
    this.language = 'en',
    this.location,
  });

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      theme: map['theme'] ?? 'dark',
      language: map['language'] ?? 'en',
      location: map['location'] != null
          ? UserLocation.fromMap(map['location'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'theme': theme,
      'language': language,
      if (location != null) 'location': location!.toMap(),
    };
  }
}

class UserLocation {
  final String city;
  final String country;
  final GeoPoint? coordinates;

  UserLocation({
    required this.city,
    required this.country,
    this.coordinates,
  });

  factory UserLocation.fromMap(Map<String, dynamic> map) {
    return UserLocation(
      city: map['city'] ?? '',
      country: map['country'] ?? '',
      coordinates: map['coordinates'] as GeoPoint?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'city': city,
      'country': country,
      if (coordinates != null) 'coordinates': coordinates,
    };
  }
}

class UserSubscription {
  final String type; // 'free' or 'premium'
  final DateTime? expiresAt;

  UserSubscription({
    this.type = 'free',
    this.expiresAt,
  });

  factory UserSubscription.fromMap(Map<String, dynamic> map) {
    return UserSubscription(
      type: map['type'] ?? 'free',
      expiresAt: (map['expiresAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      if (expiresAt != null) 'expiresAt': Timestamp.fromDate(expiresAt!),
    };
  }
}

class UserStats {
  final int totalPlayTime; // seconds
  final List<String> favoriteGenres;
  final int monthlyListeners;

  UserStats({
    this.totalPlayTime = 0,
    this.favoriteGenres = const [],
    this.monthlyListeners = 0,
  });

  factory UserStats.fromMap(Map<String, dynamic> map) {
    return UserStats(
      totalPlayTime: map['totalPlayTime'] ?? 0,
      favoriteGenres: List<String>.from(map['favoriteGenres'] ?? []),
      monthlyListeners: map['monthlyListeners'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalPlayTime': totalPlayTime,
      'favoriteGenres': favoriteGenres,
      'monthlyListeners': monthlyListeners,
    };
  }
}

