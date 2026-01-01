import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'firebase_setup.dart';
import 'models/song_model.dart';
import 'models/album_model.dart';
import 'models/artist_model.dart';
import 'models/playlist_model.dart';
import 'models/concert_model.dart';
import 'models/podcast_model.dart';
import 'constants.dart';

/// Script để seed dummy data vào Firestore
class SeedData {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Sample audio URLs - Mix từ nhiều nguồn để tránh 404
  static final List<String> _sampleAudioUrls = [
    // SoundHelix samples (nếu còn hoạt động)
    'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
    'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
    'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
    'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
    'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
    'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',
    'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3',
    'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3',
    'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-9.mp3',
    'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-10.mp3',
    // File examples backup
    'https://file-examples.com/storage/fe68c26fa14a72743a1f73d/2017/11/file_example_MP3_700KB.mp3',
    'https://file-examples.com/storage/fe68c26fa14a72743a1f73d/2017/11/file_example_MP3_1MG.mp3',
    // Internet Archive backup
    'https://archive.org/download/testmp3testfile/mpthreetest.mp3',
  ];
  
  /// Lấy sample audio URL theo index (circular)
  static String _getSampleAudioUrl(int index) {
    return _sampleAudioUrls[index % _sampleAudioUrls.length];
  }

  /// Chạy tất cả seed functions
  Future<void> seedAll() async {
    print('🌱 Bắt đầu seed data...');
    
    try {
      // Seed theo thứ tự: Artists -> Albums -> Songs -> Playlists -> Genres -> Concerts -> Podcasts
      await seedArtists();
      await seedAlbums();
      await seedSongs();
      await seedPlaylists();
      await seedGenres();
      await seedConcerts();
      await seedPodcasts();
      
      print('✅ Seed data hoàn tất!');
    } catch (e) {
      print('❌ Lỗi khi seed data: $e');
      rethrow;
    }
  }

  /// Seed Artists
  Future<void> seedArtists() async {
    print('📝 Đang seed artists...');
    
    final artists = [
      {
        'name': 'Taylor Swift',
        'imageUrl': 'https://i.scdn.co/image/ab6761610000e5eb9e3a5c0e5e8e8e8e8e8e8e8e8',
        'bio': 'American singer-songwriter',
        'genres': ['Pop', 'Country', 'Rock'],
        'monthlyListeners': 85000000,
        'followerCount': 50000000,
        'verified': true,
      },
      {
        'name': 'Ed Sheeran',
        'imageUrl': 'https://i.scdn.co/image/ab6761610000e5eb9e3a5c0e5e8e8e8e8e8e8e8e8',
        'bio': 'English singer-songwriter',
        'genres': ['Pop', 'Folk', 'Acoustic'],
        'monthlyListeners': 95000000,
        'followerCount': 60000000,
        'verified': true,
      },
      {
        'name': 'The Weeknd',
        'imageUrl': 'https://i.scdn.co/image/ab6761610000e5eb9e3a5c0e5e8e8e8e8e8e8e8e8',
        'bio': 'Canadian singer-songwriter',
        'genres': ['R&B', 'Pop', 'Hip-Hop'],
        'monthlyListeners': 100000000,
        'followerCount': 70000000,
        'verified': true,
      },
      {
        'name': 'Billie Eilish',
        'imageUrl': 'https://i.scdn.co/image/ab6761610000e5eb9e3a5c0e5e8e8e8e8e8e8e8e8',
        'bio': 'American singer-songwriter',
        'genres': ['Pop', 'Alternative', 'Indie'],
        'monthlyListeners': 80000000,
        'followerCount': 45000000,
        'verified': true,
      },
      {
        'name': 'Post Malone',
        'imageUrl': 'https://i.scdn.co/image/ab6761610000e5eb9e3a5c0e5e8e8e8e8e8e8e8e8',
        'bio': 'American rapper and singer',
        'genres': ['Hip-Hop', 'Pop', 'Rock'],
        'monthlyListeners': 90000000,
        'followerCount': 55000000,
        'verified': true,
      },
    ];

    final List<String> artistIds = [];
    
    for (var artistData in artists) {
      final docRef = await _firestore
          .collection(FirestoreCollections.artists)
          .add({
        ...artistData,
        'albumIds': [],
        'songIds': [],
        'createdAt': FieldValue.serverTimestamp(),
      });
      artistIds.add(docRef.id);
      print('  ✅ Đã tạo artist: ${artistData['name']} (${docRef.id})');
    }
    
    print('✅ Đã seed ${artists.length} artists');
  }

  /// Seed Albums
  Future<void> seedAlbums() async {
    print('📝 Đang seed albums...');
    
    // Lấy artist IDs
    final artistsSnapshot = await _firestore
        .collection(FirestoreCollections.artists)
        .limit(5)
        .get();
    
    if (artistsSnapshot.docs.isEmpty) {
      print('⚠️ Chưa có artists, bỏ qua albums');
      return;
    }
    
    final artistIds = artistsSnapshot.docs.map((doc) => doc.id).toList();
    final artistNames = artistsSnapshot.docs
        .map((doc) => doc.data()['name'] as String)
        .toList();
    
    final albums = [
      {
        'title': 'Midnights',
        'artistId': artistIds[0],
        'artistName': artistNames[0],
        'artworkUrl': 'https://i.scdn.co/image/ab67616d0000b273bb54dde68cd23e2a268ae0f5',
        'releaseDate': Timestamp.fromDate(DateTime(2022, 10, 21)),
        'genre': 'Pop',
        'genres': ['Pop', 'Alternative'],
        'totalTracks': 13,
        'duration': 2700,
        'songIds': [],
        'playCount': 50000000,
        'likeCount': 2000000,
        'description': 'The tenth studio album by Taylor Swift',
      },
      {
        'title': 'Divide',
        'artistId': artistIds[1],
        'artistName': artistNames[1],
        'artworkUrl': 'https://i.scdn.co/image/ab67616d0000b273bb54dde68cd23e2a268ae0f5',
        'releaseDate': Timestamp.fromDate(DateTime(2017, 3, 3)),
        'genre': 'Pop',
        'genres': ['Pop', 'Folk'],
        'totalTracks': 12,
        'duration': 2400,
        'songIds': [],
        'playCount': 80000000,
        'likeCount': 3000000,
        'description': 'Third studio album by Ed Sheeran',
      },
      {
        'title': 'After Hours',
        'artistId': artistIds[2],
        'artistName': artistNames[2],
        'artworkUrl': 'https://i.scdn.co/image/ab67616d0000b273bb54dde68cd23e2a268ae0f5',
        'releaseDate': Timestamp.fromDate(DateTime(2020, 3, 20)),
        'genre': 'R&B',
        'genres': ['R&B', 'Pop'],
        'totalTracks': 14,
        'duration': 3600,
        'songIds': [],
        'playCount': 120000000,
        'likeCount': 5000000,
        'description': 'Fourth studio album by The Weeknd',
      },
      {
        'title': 'Happier Than Ever',
        'artistId': artistIds[3],
        'artistName': artistNames[3],
        'artworkUrl': 'https://i.scdn.co/image/ab67616d0000b273bb54dde68cd23e2a268ae0f5',
        'releaseDate': Timestamp.fromDate(DateTime(2021, 7, 30)),
        'genre': 'Pop',
        'genres': ['Pop', 'Alternative'],
        'totalTracks': 16,
        'duration': 3300,
        'songIds': [],
        'playCount': 70000000,
        'likeCount': 2500000,
        'description': 'Second studio album by Billie Eilish',
      },
      {
        'title': 'Hollywood\'s Bleeding',
        'artistId': artistIds[4],
        'artistName': artistNames[4],
        'artworkUrl': 'https://i.scdn.co/image/ab67616d0000b273bb54dde68cd23e2a268ae0f5',
        'releaseDate': Timestamp.fromDate(DateTime(2019, 9, 6)),
        'genre': 'Hip-Hop',
        'genres': ['Hip-Hop', 'Pop', 'Rock'],
        'totalTracks': 17,
        'duration': 3900,
        'songIds': [],
        'playCount': 150000000,
        'likeCount': 6000000,
        'description': 'Third studio album by Post Malone',
      },
    ];

    final List<String> albumIds = [];
    
    for (var albumData in albums) {
      final docRef = await _firestore
          .collection(FirestoreCollections.albums)
          .add({
        ...albumData,
        'createdAt': FieldValue.serverTimestamp(),
      });
      albumIds.add(docRef.id);
      print('  ✅ Đã tạo album: ${albumData['title']} (${docRef.id})');
    }
    
    print('✅ Đã seed ${albums.length} albums');
  }

  /// Seed Songs
  Future<void> seedSongs() async {
    print('📝 Đang seed songs...');
    
    // Lấy albums và artists
    final albumsSnapshot = await _firestore
        .collection(FirestoreCollections.albums)
        .limit(5)
        .get();
    
    if (albumsSnapshot.docs.isEmpty) {
      print('⚠️ Chưa có albums, bỏ qua songs');
      return;
    }
    
    final albums = albumsSnapshot.docs;
    final List<String> allSongIds = [];
    
    for (var albumDoc in albums) {
      final albumData = albumDoc.data();
      final albumId = albumDoc.id;
      final artistId = albumData['artistId'] as String;
      final artistName = albumData['artistName'] as String;
      final albumName = albumData['title'] as String;
      final genre = albumData['genre'] as String? ?? 'Pop';
      final genres = List<String>.from(albumData['genres'] ?? []);
      
      // Tạo 5-7 songs cho mỗi album
      final songTitles = [
        'Track 1',
        'Track 2',
        'Track 3',
        'Track 4',
        'Track 5',
      ];
      
      final List<String> albumSongIds = [];
      
      for (int i = 0; i < songTitles.length; i++) {
        final songData = {
          'title': '${songTitles[i]} - ${albumName}',
          'artistId': artistId,
          'artistName': artistName,
          'albumId': albumId,
          'albumName': albumName,
          'duration': 180 + (i * 30), // 3-5 minutes
          'genre': genre,
          'genres': genres,
          // Sử dụng multiple sample audio URLs để tránh 404
          'audioUrl': _getSampleAudioUrl(i),
          'artworkUrl': albumData['artworkUrl'],
          'releaseDate': albumData['releaseDate'],
          'playCount': 1000000 + (i * 100000),
          'likeCount': 50000 + (i * 5000),
          'isExplicit': i % 3 == 0,
          'trackNumber': i + 1,
          'popularity': 70 + (i * 5),
          'tags': [
            songTitles[i].toLowerCase(),
            albumName.toLowerCase(),
            artistName.toLowerCase(),
            ...genres.map((g) => g.toLowerCase()),
          ],
          'createdAt': FieldValue.serverTimestamp(),
        };
        
        final songRef = await _firestore
            .collection(FirestoreCollections.songs)
            .add(songData);
        
        albumSongIds.add(songRef.id);
        allSongIds.add(songRef.id);
      }
      
      // Update album với songIds
      await albumDoc.reference.update({
        'songIds': albumSongIds,
        'totalTracks': albumSongIds.length,
      });
      
      // Update artist với songIds
      await _firestore
          .collection(FirestoreCollections.artists)
          .doc(artistId)
          .update({
        'songIds': FieldValue.arrayUnion(albumSongIds),
        'albumIds': FieldValue.arrayUnion([albumId]),
      });
      
      print('  ✅ Đã tạo ${albumSongIds.length} songs cho album: $albumName');
    }
    
    print('✅ Đã seed ${allSongIds.length} songs');
  }

  /// Seed Playlists
  Future<void> seedPlaylists() async {
    print('📝 Đang seed playlists...');
    
    // Lấy songs
    final songsSnapshot = await _firestore
        .collection(FirestoreCollections.songs)
        .limit(20)
        .get();
    
    if (songsSnapshot.docs.isEmpty) {
      print('⚠️ Chưa có songs, bỏ qua playlists');
      return;
    }
    
    final songIds = songsSnapshot.docs.map((doc) => doc.id).toList();
    
    final playlists = [
      {
        'title': 'Chill Vibes',
        'description': 'Relaxing music for your day',
        'ownerId': 'system',
        'isPublic': true,
        'artworkUrl': 'https://i.scdn.co/image/ab67616d0000b273bb54dde68cd23e2a268ae0f5',
        'songIds': songIds.sublist(0, 10),
        'followerCount': 50000,
        'genre': 'Chill',
        'tags': ['chill', 'relax', 'ambient'],
      },
      {
        'title': 'Workout Mix',
        'description': 'High energy songs for your workout',
        'ownerId': 'system',
        'isPublic': true,
        'artworkUrl': 'https://i.scdn.co/image/ab67616d0000b273bb54dde68cd23e2a268ae0f5',
        'songIds': songIds.sublist(5, 15),
        'followerCount': 75000,
        'genre': 'Workout',
        'tags': ['workout', 'energy', 'fitness'],
      },
      {
        'title': 'Study Focus',
        'description': 'Music to help you concentrate',
        'ownerId': 'system',
        'isPublic': true,
        'artworkUrl': 'https://i.scdn.co/image/ab67616d0000b273bb54dde68cd23e2a268ae0f5',
        'songIds': songIds.sublist(0, 8),
        'followerCount': 30000,
        'genre': 'Study',
        'tags': ['study', 'focus', 'concentration'],
      },
    ];
    
    for (var playlistData in playlists) {
      final docRef = await _firestore
          .collection(FirestoreCollections.playlists)
          .add({
        ...playlistData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('  ✅ Đã tạo playlist: ${playlistData['title']} (${docRef.id})');
    }
    
    print('✅ Đã seed ${playlists.length} playlists');
  }

  /// Seed Genres
  Future<void> seedGenres() async {
    print('📝 Đang seed genres...');
    
    final genres = [
      {
        'name': 'pop',
        'displayName': 'Pop',
        'imageUrl': 'https://i.scdn.co/image/ab67616d0000b273bb54dde68cd23e2a268ae0f5',
        'color': '#1DB954',
        'songIds': [],
        'albumIds': [],
        'artistIds': [],
        'playlistIds': [],
      },
      {
        'name': 'rock',
        'displayName': 'Rock',
        'imageUrl': 'https://i.scdn.co/image/ab67616d0000b273bb54dde68cd23e2a268ae0f5',
        'color': '#FF6B6B',
        'songIds': [],
        'albumIds': [],
        'artistIds': [],
        'playlistIds': [],
      },
      {
        'name': 'hip-hop',
        'displayName': 'Hip-Hop',
        'imageUrl': 'https://i.scdn.co/image/ab67616d0000b273bb54dde68cd23e2a268ae0f5',
        'color': '#4ECDC4',
        'songIds': [],
        'albumIds': [],
        'artistIds': [],
        'playlistIds': [],
      },
      {
        'name': 'r&b',
        'displayName': 'R&B',
        'imageUrl': 'https://i.scdn.co/image/ab67616d0000b273bb54dde68cd23e2a268ae0f5',
        'color': '#95E1D3',
        'songIds': [],
        'albumIds': [],
        'artistIds': [],
        'playlistIds': [],
      },
      {
        'name': 'electronic',
        'displayName': 'Electronic',
        'imageUrl': 'https://i.scdn.co/image/ab67616d0000b273bb54dde68cd23e2a268ae0f5',
        'color': '#F38181',
        'songIds': [],
        'albumIds': [],
        'artistIds': [],
        'playlistIds': [],
      },
    ];
    
    for (var genreData in genres) {
      final docRef = await _firestore
          .collection(FirestoreCollections.genres)
          .add({
        ...genreData,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('  ✅ Đã tạo genre: ${genreData['displayName']} (${docRef.id})');
    }
    
    print('✅ Đã seed ${genres.length} genres');
  }

  /// Seed Concerts
  Future<void> seedConcerts() async {
    print('📝 Đang seed concerts...');
    
    // Lấy artists
    final artistsSnapshot = await _firestore
        .collection(FirestoreCollections.artists)
        .limit(3)
        .get();
    
    if (artistsSnapshot.docs.isEmpty) {
      print('⚠️ Chưa có artists, bỏ qua concerts');
      return;
    }
    
    final artists = artistsSnapshot.docs;
    
    final concerts = [
      {
        'title': 'Taylor Swift: The Eras Tour',
        'artistId': artists[0].id,
        'artistName': artists[0].data()['name'],
        'venue': {
          'name': 'Madison Square Garden',
          'address': '4 Pennsylvania Plaza',
          'city': 'New York',
          'country': 'USA',
        },
        'dateTime': Timestamp.fromDate(DateTime(2024, 7, 15, 20, 0)),
        'imageUrl': 'https://i.scdn.co/image/ab67616d0000b273bb54dde68cd23e2a268ae0f5',
        'ticketUrl': 'https://example.com/tickets',
        'price': {
          'min': 100.0,
          'max': 500.0,
          'currency': 'USD',
        },
        'status': 'upcoming',
        'capacity': 20000,
        'attendees': [],
      },
      {
        'title': 'Ed Sheeran: Mathematics Tour',
        'artistId': artists[1].id,
        'artistName': artists[1].data()['name'],
        'venue': {
          'name': 'Wembley Stadium',
          'address': 'Wembley',
          'city': 'London',
          'country': 'UK',
        },
        'dateTime': Timestamp.fromDate(DateTime(2024, 8, 20, 19, 30)),
        'imageUrl': 'https://i.scdn.co/image/ab67616d0000b273bb54dde68cd23e2a268ae0f5',
        'ticketUrl': 'https://example.com/tickets',
        'price': {
          'min': 80.0,
          'max': 300.0,
          'currency': 'GBP',
        },
        'status': 'upcoming',
        'capacity': 90000,
        'attendees': [],
      },
      {
        'title': 'The Weeknd: After Hours Til Dawn',
        'artistId': artists[2].id,
        'artistName': artists[2].data()['name'],
        'venue': {
          'name': 'SoFi Stadium',
          'address': '1001 S Stadium Dr',
          'city': 'Los Angeles',
          'country': 'USA',
        },
        'dateTime': Timestamp.fromDate(DateTime(2024, 9, 10, 21, 0)),
        'imageUrl': 'https://i.scdn.co/image/ab67616d0000b273bb54dde68cd23e2a268ae0f5',
        'ticketUrl': 'https://example.com/tickets',
        'price': {
          'min': 120.0,
          'max': 600.0,
          'currency': 'USD',
        },
        'status': 'upcoming',
        'capacity': 70000,
        'attendees': [],
      },
    ];
    
    for (var concertData in concerts) {
      final docRef = await _firestore
          .collection(FirestoreCollections.concerts)
          .add({
        ...concertData,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('  ✅ Đã tạo concert: ${concertData['title']} (${docRef.id})');
    }
    
    print('✅ Đã seed ${concerts.length} concerts');
  }

  /// Seed Podcasts
  Future<void> seedPodcasts() async {
    print('📝 Đang seed podcasts...');
    
    // Lấy artists để làm hosts
    final artistsSnapshot = await _firestore
        .collection(FirestoreCollections.artists)
        .limit(2)
        .get();
    
    if (artistsSnapshot.docs.isEmpty) {
      print('⚠️ Chưa có artists, bỏ qua podcasts');
      return;
    }
    
    final artists = artistsSnapshot.docs;
    
    final podcasts = [
      {
        'title': 'The Music Podcast',
        'description': 'Weekly discussions about music industry',
        'hostId': artists[0].id,
        'hostName': artists[0].data()['name'],
        'imageUrl': 'https://i.scdn.co/image/ab67616d0000b273bb54dde68cd23e2a268ae0f5',
        'category': 'Music',
        'categories': ['Music', 'Entertainment'],
        'episodeIds': [],
        'followerCount': 50000,
        'totalEpisodes': 0,
        'tags': ['music', 'industry', 'entertainment'],
      },
      {
        'title': 'Artist Stories',
        'description': 'Behind the scenes with your favorite artists',
        'hostId': artists[1].id,
        'hostName': artists[1].data()['name'],
        'imageUrl': 'https://i.scdn.co/image/ab67616d0000b273bb54dde68cd23e2a268ae0f5',
        'category': 'Entertainment',
        'categories': ['Entertainment', 'Music'],
        'episodeIds': [],
        'followerCount': 30000,
        'totalEpisodes': 0,
        'tags': ['artists', 'stories', 'behind-scenes'],
      },
    ];
    
    final List<String> podcastIds = [];
    
    for (var podcastData in podcasts) {
      final docRef = await _firestore
          .collection(FirestoreCollections.podcasts)
          .add({
        ...podcastData,
        'createdAt': FieldValue.serverTimestamp(),
      });
      podcastIds.add(docRef.id);
      print('  ✅ Đã tạo podcast: ${podcastData['title']} (${docRef.id})');
      
      // Tạo episodes cho podcast
      final episodes = [
        {
          'podcastId': docRef.id,
          'title': 'Episode 1: Introduction',
          'description': 'Welcome to the podcast',
          'episodeNumber': 1,
          'duration': 3600, // 1 hour
          'audioUrl': 'https://example.com/podcast/ep1.mp3',
          'artworkUrl': podcastData['imageUrl'],
          'releaseDate': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 7))),
          'playCount': 10000,
          'likeCount': 500,
          'isExplicit': false,
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'podcastId': docRef.id,
          'title': 'Episode 2: First Guest',
          'description': 'Interview with special guest',
          'episodeNumber': 2,
          'duration': 4200, // 70 minutes
          'audioUrl': 'https://example.com/podcast/ep2.mp3',
          'artworkUrl': podcastData['imageUrl'],
          'releaseDate': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 3))),
          'playCount': 8000,
          'likeCount': 400,
          'isExplicit': false,
          'createdAt': FieldValue.serverTimestamp(),
        },
      ];
      
      final List<String> episodeIds = [];
      
      for (var episodeData in episodes) {
        final episodeRef = await _firestore
            .collection(FirestoreCollections.podcastEpisodes)
            .add(episodeData);
        episodeIds.add(episodeRef.id);
      }
      
      // Update podcast với episodeIds
      await docRef.update({
        'episodeIds': episodeIds,
        'totalEpisodes': episodeIds.length,
      });
      
      print('    ✅ Đã tạo ${episodeIds.length} episodes cho podcast');
    }
    
    print('✅ Đã seed ${podcasts.length} podcasts');
  }

  /// Xóa tất cả songs cũ trong Firestore
  Future<void> deleteAllSongs() async {
    print('🗑️ Đang xóa tất cả songs cũ...');
    
    try {
      // Lấy tất cả songs
      final songsSnapshot = await _firestore
          .collection(FirestoreCollections.songs)
          .get();
      
      if (songsSnapshot.docs.isEmpty) {
        print('ℹ️ Không có songs nào để xóa.');
        return;
      }
      
      int deletedCount = 0;
      
      // Xóa songs
      for (var doc in songsSnapshot.docs) {
        await doc.reference.delete();
        deletedCount++;
      }
      
      // Xóa songIds từ albums
      final albumsSnapshot = await _firestore
          .collection(FirestoreCollections.albums)
          .get();
      
      for (var albumDoc in albumsSnapshot.docs) {
        await albumDoc.reference.update({
          'songIds': [],
          'totalTracks': 0,
        });
      }
      
      // Xóa songIds từ artists
      final artistsSnapshot = await _firestore
          .collection(FirestoreCollections.artists)
          .get();
      
      for (var artistDoc in artistsSnapshot.docs) {
        await artistDoc.reference.update({
          'songIds': [],
        });
      }
      
      print('✅ Đã xóa $deletedCount songs cũ');
    } catch (e) {
      print('❌ Lỗi khi xóa songs: $e');
      rethrow;
    }
  }

  /// Seed songs mới với URLs tùy chỉnh
  Future<void> seedSongsWithCustomUrls(Map<String, Map<String, dynamic>> songUrls) async {
    print('📝 Đang seed songs mới với URLs tùy chỉnh...');
    
    try {
      // Lấy hoặc tạo album mặc định
      final albumsSnapshot = await _firestore
          .collection(FirestoreCollections.albums)
          .limit(1)
          .get();
      
      String? defaultAlbumId;
      String? defaultArtistId;
      String? defaultArtistName = 'Various Artists';
      
      if (albumsSnapshot.docs.isNotEmpty) {
        final albumData = albumsSnapshot.docs.first.data();
        defaultAlbumId = albumsSnapshot.docs.first.id;
        defaultArtistId = albumData['artistId'] as String?;
        defaultArtistName = albumData['artistName'] as String?;
      } else {
        // Tạo artist và album mặc định nếu chưa có
        final artistRef = await _firestore
            .collection(FirestoreCollections.artists)
            .add({
          'name': defaultArtistName,
          'imageUrl': null,
          'bio': 'Various Artists',
          'genres': ['Pop', 'Hip-Hop', 'R&B'],
          'monthlyListeners': 0,
          'followerCount': 0,
          'verified': false,
          'albumIds': [],
          'songIds': [],
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        defaultArtistId = artistRef.id;
        
        final albumRef = await _firestore
            .collection(FirestoreCollections.albums)
            .add({
          'title': 'My Playlist',
          'artistId': defaultArtistId,
          'artistName': defaultArtistName,
          'artworkUrl': null,
          'releaseDate': FieldValue.serverTimestamp(),
          'genre': 'Pop',
          'genres': ['Pop'],
          'totalTracks': 0,
          'duration': 0,
          'songIds': [],
          'playCount': 0,
          'likeCount': 0,
          'description': 'Custom playlist',
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        defaultAlbumId = albumRef.id;
      }
      
      final List<String> allSongIds = [];
      int index = 0;
      
      for (var entry in songUrls.entries) {
        final songData = entry.value;
        
        final title = songData['title'] as String? ?? 'Unknown Song';
        final audioUrl = songData['audioUrl'] as String? ?? '';
        final artistName = songData['artistName'] as String? ?? defaultArtistName!;
        final albumName = songData['albumName'] as String? ?? 'My Playlist';
        final duration = songData['duration'] as int? ?? 180;
        final genre = songData['genre'] as String? ?? 'Pop';
        final genres = (songData['genres'] as List?)?.cast<String>() ?? [genre];
        
        if (audioUrl.isEmpty) {
          print('⚠️ Bỏ qua song "$title": không có audioUrl');
          continue;
        }
        
        final songDocData = {
          'title': title,
          'artistId': defaultArtistId!,
          'artistName': artistName,
          'albumId': defaultAlbumId!,
          'albumName': albumName,
          'duration': duration,
          'genre': genre,
          'genres': genres,
          'audioUrl': audioUrl,
          'artworkUrl': songData['artworkUrl'] as String?,
          'releaseDate': FieldValue.serverTimestamp(),
          'playCount': 0,
          'likeCount': 0,
          'isExplicit': songData['isExplicit'] as bool? ?? false,
          'trackNumber': index + 1,
          'popularity': 50,
          'tags': [
            title.toLowerCase(),
            albumName.toLowerCase(),
            artistName.toLowerCase(),
            ...genres.map((g) => g.toLowerCase()),
          ],
          'createdAt': FieldValue.serverTimestamp(),
        };
        
        final songRef = await _firestore
            .collection(FirestoreCollections.songs)
            .add(songDocData);
        
        allSongIds.add(songRef.id);
        
        // Update album với songId
        await _firestore
            .collection(FirestoreCollections.albums)
            .doc(defaultAlbumId)
            .update({
          'songIds': FieldValue.arrayUnion([songRef.id]),
          'totalTracks': allSongIds.length,
        });
        
        // Update artist với songId
        await _firestore
            .collection(FirestoreCollections.artists)
            .doc(defaultArtistId)
            .update({
          'songIds': FieldValue.arrayUnion([songRef.id]),
        });
        
        print('  ✅ Đã tạo song: $title - $artistName');
        index++;
      }
      
      print('✅ Đã seed ${allSongIds.length} songs mới');
    } catch (e) {
      print('❌ Lỗi khi seed songs: $e');
      rethrow;
    }
  }

  /// Reset và seed lại toàn bộ songs với URLs mới
  Future<void> resetAndSeedSongs(Map<String, Map<String, dynamic>> songUrls) async {
    print('🔄 Reset và seed lại songs...');
    
    try {
      await deleteAllSongs();
      await seedSongsWithCustomUrls(songUrls);
      print('✅ Hoàn tất reset và seed songs!');
    } catch (e) {
      print('❌ Lỗi khi reset songs: $e');
      rethrow;
    }
  }
}

