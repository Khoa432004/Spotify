import 'package:cloud_firestore/cloud_firestore.dart';

/// Model cho User Downloads
class UserDownloadsModel {
  final String userId;
  final List<DownloadedSong> downloadedSongs;
  final List<DownloadedAlbum> downloadedAlbums;
  final List<DownloadedPlaylist> downloadedPlaylists;
  final int storageUsed; // bytes
  final DateTime updatedAt;

  UserDownloadsModel({
    required this.userId,
    this.downloadedSongs = const [],
    this.downloadedAlbums = const [],
    this.downloadedPlaylists = const [],
    this.storageUsed = 0,
    required this.updatedAt,
  });

  factory UserDownloadsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserDownloadsModel(
      userId: data['userId'] ?? doc.id,
      downloadedSongs: (data['downloadedSongs'] as List?)
              ?.map((e) => DownloadedSong.fromMap(e))
              .toList() ??
          [],
      downloadedAlbums: (data['downloadedAlbums'] as List?)
              ?.map((e) => DownloadedAlbum.fromMap(e))
              .toList() ??
          [],
      downloadedPlaylists: (data['downloadedPlaylists'] as List?)
              ?.map((e) => DownloadedPlaylist.fromMap(e))
              .toList() ??
          [],
      storageUsed: data['storageUsed'] ?? 0,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'downloadedSongs': downloadedSongs.map((e) => e.toMap()).toList(),
      'downloadedAlbums': downloadedAlbums.map((e) => e.toMap()).toList(),
      'downloadedPlaylists': downloadedPlaylists.map((e) => e.toMap()).toList(),
      'storageUsed': storageUsed,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  String get formattedStorageUsed {
    if (storageUsed >= 1073741824) {
      return '${(storageUsed / 1073741824).toStringAsFixed(2)} GB';
    } else if (storageUsed >= 1048576) {
      return '${(storageUsed / 1048576).toStringAsFixed(2)} MB';
    } else if (storageUsed >= 1024) {
      return '${(storageUsed / 1024).toStringAsFixed(2)} KB';
    }
    return '$storageUsed B';
  }

  UserDownloadsModel copyWith({
    String? userId,
    List<DownloadedSong>? downloadedSongs,
    List<DownloadedAlbum>? downloadedAlbums,
    List<DownloadedPlaylist>? downloadedPlaylists,
    int? storageUsed,
    DateTime? updatedAt,
  }) {
    return UserDownloadsModel(
      userId: userId ?? this.userId,
      downloadedSongs: downloadedSongs ?? this.downloadedSongs,
      downloadedAlbums: downloadedAlbums ?? this.downloadedAlbums,
      downloadedPlaylists: downloadedPlaylists ?? this.downloadedPlaylists,
      storageUsed: storageUsed ?? this.storageUsed,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class DownloadedSong {
  final String songId;
  final DateTime downloadedAt;
  final String localPath;

  DownloadedSong({
    required this.songId,
    required this.downloadedAt,
    required this.localPath,
  });

  factory DownloadedSong.fromMap(Map<String, dynamic> map) {
    return DownloadedSong(
      songId: map['songId'] ?? '',
      downloadedAt: (map['downloadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      localPath: map['localPath'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'songId': songId,
      'downloadedAt': Timestamp.fromDate(downloadedAt),
      'localPath': localPath,
    };
  }
}

class DownloadedAlbum {
  final String albumId;
  final DateTime downloadedAt;
  final List<String> songIds;

  DownloadedAlbum({
    required this.albumId,
    required this.downloadedAt,
    this.songIds = const [],
  });

  factory DownloadedAlbum.fromMap(Map<String, dynamic> map) {
    return DownloadedAlbum(
      albumId: map['albumId'] ?? '',
      downloadedAt: (map['downloadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      songIds: List<String>.from(map['songIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'albumId': albumId,
      'downloadedAt': Timestamp.fromDate(downloadedAt),
      'songIds': songIds,
    };
  }
}

class DownloadedPlaylist {
  final String playlistId;
  final DateTime downloadedAt;

  DownloadedPlaylist({
    required this.playlistId,
    required this.downloadedAt,
  });

  factory DownloadedPlaylist.fromMap(Map<String, dynamic> map) {
    return DownloadedPlaylist(
      playlistId: map['playlistId'] ?? '',
      downloadedAt: (map['downloadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'playlistId': playlistId,
      'downloadedAt': Timestamp.fromDate(downloadedAt),
    };
  }
}

