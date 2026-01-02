import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'constants.dart';
import 'models/user_model.dart';
import 'models/song_model.dart';
import 'models/album_model.dart';
import 'models/artist_model.dart';
import 'models/playlist_model.dart';
import 'models/concert_model.dart';
import 'models/podcast_model.dart';

/// Service class để quản lý tất cả các operations với Firestore và Storage
class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ==================== USER OPERATIONS ====================

  /// Lấy thông tin user
  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _firestore
          .collection(FirestoreCollections.users)
          .doc(userId)
          .get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  /// Tạo hoặc cập nhật user
  Future<void> setUser(UserModel user) async {
    try {
      await _firestore
          .collection(FirestoreCollections.users)
          .doc(user.id)
          .set(user.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      print('Error setting user: $e');
      rethrow;
    }
  }

  /// Stream user data
  Stream<UserModel?> streamUser(String userId) {
    return _firestore
        .collection(FirestoreCollections.users)
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  // ==================== SONG OPERATIONS ====================

  /// Lấy song theo ID
  Future<SongModel?> getSong(String songId) async {
    try {
      final doc = await _firestore
          .collection(FirestoreCollections.songs)
          .doc(songId)
          .get();
      if (doc.exists) {
        return SongModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting song: $e');
      return null;
    }
  }

  /// Lấy danh sách songs
  Future<List<SongModel>> getSongs({
    String? genre,
    String? artistId,
    String? albumId,
    int limit = 20,
    String? startAfter,
  }) async {
    try {
      Query query = _firestore.collection(FirestoreCollections.songs);

      if (genre != null) {
        query = query.where('genres', arrayContains: genre);
      }
      if (artistId != null) {
        query = query.where('artistId', isEqualTo: artistId);
      }
      if (albumId != null) {
        query = query.where('albumId', isEqualTo: albumId);
      }

      query = query.orderBy('popularity', descending: true).limit(limit);

      if (startAfter != null) {
        final startAfterDoc =
            await _firestore.collection(FirestoreCollections.songs).doc(startAfter).get();
        query = query.startAfterDocument(startAfterDoc);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => SongModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting songs: $e');
      return [];
    }
  }

  /// Tìm kiếm songs
  Future<List<SongModel>> searchSongs(String query, {int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection(FirestoreCollections.songs)
          .where('tags', arrayContainsAny: query.toLowerCase().split(' '))
          .limit(limit)
          .get();

      // Also search by title (case-insensitive)
      final titleSnapshot = await _firestore
          .collection(FirestoreCollections.songs)
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThan: query + 'z')
          .limit(limit)
          .get();

      final allDocs = {...snapshot.docs, ...titleSnapshot.docs};
      return allDocs.map((doc) => SongModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error searching songs: $e');
      return [];
    }
  }

  /// Stream songs
  Stream<List<SongModel>> streamSongs({String? genre, String? artistId}) {
    Query query = _firestore.collection(FirestoreCollections.songs);

    if (genre != null) {
      query = query.where('genres', arrayContains: genre);
    }
    if (artistId != null) {
      query = query.where('artistId', isEqualTo: artistId);
    }

    return query
        .orderBy('popularity', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SongModel.fromFirestore(doc))
            .toList());
  }

  // ==================== ALBUM OPERATIONS ====================

  /// Lấy album theo ID
  Future<AlbumModel?> getAlbum(String albumId) async {
    try {
      final doc = await _firestore
          .collection(FirestoreCollections.albums)
          .doc(albumId)
          .get();
      if (doc.exists) {
        return AlbumModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting album: $e');
      return null;
    }
  }

  /// Lấy danh sách albums
  Future<List<AlbumModel>> getAlbums({
    String? artistId,
    String? genre,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore.collection(FirestoreCollections.albums);

      if (artistId != null) {
        query = query.where('artistId', isEqualTo: artistId);
      }
      if (genre != null) {
        query = query.where('genres', arrayContains: genre);
      }

      final snapshot = await query
          .orderBy('releaseDate', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => AlbumModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting albums: $e');
      return [];
    }
  }

  /// Lấy songs trong album
  Future<List<SongModel>> getAlbumSongs(String albumId) async {
    try {
      final album = await getAlbum(albumId);
      if (album == null || album.songIds.isEmpty) {
        return [];
      }

      // Firestore 'in' query limit is 10, so we need to batch
      final List<SongModel> songs = [];
      for (int i = 0; i < album.songIds.length; i += 10) {
        final batch = album.songIds.sublist(
          i,
          i + 10 > album.songIds.length ? album.songIds.length : i + 10,
        );
        final snapshot = await _firestore
            .collection(FirestoreCollections.songs)
            .where(FieldPath.documentId, whereIn: batch)
            .get();
        songs.addAll(
          snapshot.docs.map((doc) => SongModel.fromFirestore(doc)).toList(),
        );
      }

      // Sort by trackNumber
      songs.sort((a, b) => (a.trackNumber ?? 0).compareTo(b.trackNumber ?? 0));
      return songs;
    } catch (e) {
      print('Error getting album songs: $e');
      return [];
    }
  }

  // ==================== ARTIST OPERATIONS ====================

  /// Lấy artist theo ID
  Future<ArtistModel?> getArtist(String artistId) async {
    try {
      final doc = await _firestore
          .collection(FirestoreCollections.artists)
          .doc(artistId)
          .get();
      if (doc.exists) {
        return ArtistModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting artist: $e');
      return null;
    }
  }

  /// Lấy danh sách artists
  Future<List<ArtistModel>> getArtists({int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection(FirestoreCollections.artists)
          .orderBy('monthlyListeners', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => ArtistModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting artists: $e');
      return [];
    }
  }

  /// Lấy songs của artist
  Future<List<SongModel>> getArtistSongs(String artistId, {int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection(FirestoreCollections.songs)
          .where('artistId', isEqualTo: artistId)
          .orderBy('popularity', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => SongModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting artist songs: $e');
      return [];
    }
  }

  // ==================== PLAYLIST OPERATIONS ====================

  /// Lấy playlist theo ID
  Future<PlaylistModel?> getPlaylist(String playlistId) async {
    try {
      final doc = await _firestore
          .collection(FirestoreCollections.playlists)
          .doc(playlistId)
          .get();
      if (doc.exists) {
        return PlaylistModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting playlist: $e');
      return null;
    }
  }

  /// Lấy playlists của user
  Future<List<PlaylistModel>> getUserPlaylists(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(FirestoreCollections.playlists)
          .where('ownerId', isEqualTo: userId)
          .orderBy('updatedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => PlaylistModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting user playlists: $e');
      return [];
    }
  }

  /// Tạo playlist mới
  Future<String> createPlaylist(PlaylistModel playlist) async {
    try {
      final docRef = await _firestore
          .collection(FirestoreCollections.playlists)
          .add(playlist.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error creating playlist: $e');
      rethrow;
    }
  }

  // ==================== USER LIKES OPERATIONS ====================

  /// Lấy liked songs của user
  Future<List<String>> getLikedSongs(String userId) async {
    try {
      final doc = await _firestore
          .collection(FirestoreCollections.userLikes)
          .doc(userId)
          .get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return List<String>.from(data['likedSongs'] ?? []);
      }
      return [];
    } catch (e) {
      print('Error getting liked songs: $e');
      return [];
    }
  }

  /// Thêm/xóa liked song
  Future<void> toggleLikeSong(String userId, String songId, bool isLiked) async {
    try {
      final docRef = _firestore
          .collection(FirestoreCollections.userLikes)
          .doc(userId);

      if (isLiked) {
        await docRef.set({
          'userId': userId,
          'likedSongs': FieldValue.arrayUnion([songId]),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else {
        await docRef.set({
          'likedSongs': FieldValue.arrayRemove([songId]),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print('Error toggling like song: $e');
      rethrow;
    }
  }

  // ==================== CONCERT OPERATIONS ====================

  /// Lấy upcoming concerts
  Future<List<ConcertModel>> getUpcomingConcerts({
    String? artistId,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore.collection(FirestoreCollections.concerts)
          .where('status', isEqualTo: 'upcoming')
          .limit(100);

      final snapshot = await query.get();
      var concerts = <ConcertModel>[];
      
      for (var doc in snapshot.docs) {
        try {
          final concert = ConcertModel.fromFirestore(doc);
          concerts.add(concert);
        } catch (e) {
          // Skip invalid concerts
        }
      }

      if (artistId != null) {
        concerts = concerts.where((c) => c.artistId == artistId).toList();
      }

      concerts.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      return concerts.take(limit).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<ConcertModel>> getConcertsByLocation({
    required String city,
    int limit = 50,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(FirestoreCollections.concerts)
          .where('status', isEqualTo: 'upcoming')
          .limit(100)
          .get();

      final filtered = <ConcertModel>[];
      for (var doc in snapshot.docs) {
        try {
          final concert = ConcertModel.fromFirestore(doc);
          final isInCity = concert.venue.city.toLowerCase() == city.toLowerCase();
          if (isInCity) {
            filtered.add(concert);
          }
        } catch (e) {
          // Skip invalid concerts
        }
      }
      
      filtered.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      return filtered.take(20).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<ConcertModel>> getRecommendedConcerts({
    int limit = 20,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(FirestoreCollections.concerts)
          .where('status', isEqualTo: 'upcoming')
          .limit(100)
          .get();

      final concerts = <ConcertModel>[];
      for (var doc in snapshot.docs) {
        try {
          final concert = ConcertModel.fromFirestore(doc);
          concerts.add(concert);
        } catch (e) {
          // Skip invalid concerts
        }
      }
      
      concerts.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      return concerts.take(limit).toList();
    } catch (e) {
      return [];
    }
  }

  /// Tạo notification cho concert sắp tới
  Future<void> createConcertNotification({
    required String userId,
    required String concertId,
    required ConcertModel concert,
    DateTime? scheduledFor,
  }) async {
    try {
      final notificationData = {
        'userId': userId,
        'type': NotificationType.concertReminder.value,
        'title': 'Concert Reminder: ${concert.artistName}',
        'message': '${concert.title} is coming up on ${_formatConcertDate(concert.dateTime)} at ${concert.venue.name}',
        'imageUrl': concert.imageUrl,
        'actionUrl': '/concerts/$concertId',
        'read': false,
        'data': {
          'concertId': concertId,
          'artistName': concert.artistName,
          'venue': concert.venue.name,
          'dateTime': Timestamp.fromDate(concert.dateTime),
        },
        'createdAt': FieldValue.serverTimestamp(),
        if (scheduledFor != null) 'scheduledFor': Timestamp.fromDate(scheduledFor),
      };

      await _firestore
          .collection(FirestoreCollections.notifications)
          .add(notificationData);
    } catch (e) {
      print('Error creating concert notification: $e');
      rethrow;
    }
  }

  String _formatConcertDate(DateTime dateTime) {
    final months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    final weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return '${weekdays[dateTime.weekday % 7]}, ${dateTime.day} ${months[dateTime.month - 1]}';
  }

  // ==================== PODCAST OPERATIONS ====================

  /// Lấy podcast theo ID
  Future<PodcastModel?> getPodcast(String podcastId) async {
    try {
      final doc = await _firestore
          .collection(FirestoreCollections.podcasts)
          .doc(podcastId)
          .get();
      if (doc.exists) {
        return PodcastModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting podcast: $e');
      return null;
    }
  }

  /// Lấy danh sách podcasts
  Future<List<PodcastModel>> getPodcasts({
    String? category,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore.collection(FirestoreCollections.podcasts);

      if (category != null) {
        query = query.where('categories', arrayContains: category);
      }

      final snapshot = await query
          .orderBy('followerCount', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => PodcastModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting podcasts: $e');
      return [];
    }
  }

  /// Lấy episodes của podcast
  Future<List<PodcastEpisodeModel>> getPodcastEpisodes(String podcastId) async {
    try {
      final snapshot = await _firestore
          .collection(FirestoreCollections.podcastEpisodes)
          .where('podcastId', isEqualTo: podcastId)
          .orderBy('episodeNumber', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => PodcastEpisodeModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting podcast episodes: $e');
      return [];
    }
  }

  /// Lấy recent podcast episodes (tất cả podcasts)
  Future<List<PodcastEpisodeModel>> getRecentPodcastEpisodes({
    int limit = 20,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(FirestoreCollections.podcastEpisodes)
          .orderBy('releaseDate', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => PodcastEpisodeModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting recent podcast episodes: $e');
      return [];
    }
  }

  // ==================== STORAGE OPERATIONS ====================

  /// Upload audio data (Uint8List)
  /// Use this for web or when you have binary data
  Future<String> uploadAudioData(Uint8List data, String fileName) async {
    try {
      final ref = _storage.ref().child('${StoragePaths.audioSongs}/$fileName');
      await ref.putData(data);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading audio data: $e');
      rethrow;
    }
  }

  /// Get download URL
  Future<String> getDownloadUrl(String path) async {
    try {
      return await _storage.ref(path).getDownloadURL();
    } catch (e) {
      print('Error getting download URL: $e');
      rethrow;
    }
  }
}

