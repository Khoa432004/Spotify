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
import 'upload_podcast_audio.dart';

/// Script để seed dummy data vào Firestore
class SeedData {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final List<String> _sampleAudioUrls = [
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
    'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-11.mp3',
    'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-12.mp3',
    'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-13.mp3',
    'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-14.mp3',
    'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-15.mp3',
    'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-16.mp3',
    'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-17.mp3',
  ];

  /// Lấy sample audio URL theo index (circular)
  /// Có thể override để lấy từ Firebase Storage
  static String _getSampleAudioUrl(int index) {
    return _sampleAudioUrls[index % _sampleAudioUrls.length];
  }

  /// Lấy episode titles cho từng podcast
  static List<String> _getEpisodeTitlesForPodcast(String podcastTitle) {
    if (podcastTitle == 'Artist Stories') {
      return [
        'Introduction',
        'Taylor Swift Interview',
        'Behind the Scenes',
        'Fan Stories',
      ];
    } else if (podcastTitle == 'Tech Talk') {
      return [
        'Welcome to Tech Talk',
        'AI Revolution',
        'Future of Tech',
        'Startup Stories',
      ];
    } else {
      return ['Introduction', 'First Guest', 'Deep Dive', 'Special Episode'];
    }
  }

  /// Lấy episode descriptions cho từng podcast
  static List<String> _getEpisodeDescriptionsForPodcast(String podcastTitle) {
    if (podcastTitle == 'Artist Stories') {
      return [
        'Welcome to Artist Stories - where we explore the lives of your favorite musicians',
        'An exclusive interview with Taylor Swift about her creative process',
        'Go behind the scenes of a major concert tour',
        'Listen to amazing stories from fans around the world',
      ];
    } else if (podcastTitle == 'Tech Talk') {
      return [
        'Welcome to Tech Talk - your weekly dose of technology insights',
        'Exploring the AI revolution and its impact on society',
        'What does the future hold for technology?',
        'Inspiring stories from successful tech startups',
      ];
    } else {
      return [
        'Welcome to the podcast',
        'Interview with special guest',
        'Deep dive into the topic',
        'Special episode with exclusive content',
      ];
    }
  }

  /// Set custom audio URLs (từ Firebase Storage sau khi upload)
  static void setCustomAudioUrls(List<String> urls) {
    _sampleAudioUrls.clear();
    _sampleAudioUrls.addAll(urls);
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
        'imageUrl':
            'https://i.scdn.co/image/ab6761610000e5eb9e3a5c0e5e8e8e8e8e8e8e8e8',
        'bio': 'American singer-songwriter',
        'genres': ['Pop', 'Country', 'Rock'],
        'monthlyListeners': 85000000,
        'followerCount': 50000000,
        'verified': true,
      },
      {
        'name': 'Ed Sheeran',
        'imageUrl':
            'https://i.scdn.co/image/ab6761610000e5eb9e3a5c0e5e8e8e8e8e8e8e8e8',
        'bio': 'English singer-songwriter',
        'genres': ['Pop', 'Folk', 'Acoustic'],
        'monthlyListeners': 95000000,
        'followerCount': 60000000,
        'verified': true,
      },
      {
        'name': 'The Weeknd',
        'imageUrl':
            'https://i.scdn.co/image/ab6761610000e5eb9e3a5c0e5e8e8e8e8e8e8e8e8',
        'bio': 'Canadian singer-songwriter',
        'genres': ['R&B', 'Pop', 'Hip-Hop'],
        'monthlyListeners': 100000000,
        'followerCount': 70000000,
        'verified': true,
      },
      {
        'name': 'Billie Eilish',
        'imageUrl':
            'https://i.scdn.co/image/ab6761610000e5eb9e3a5c0e5e8e8e8e8e8e8e8e8',
        'bio': 'American singer-songwriter',
        'genres': ['Pop', 'Alternative', 'Indie'],
        'monthlyListeners': 80000000,
        'followerCount': 45000000,
        'verified': true,
      },
      {
        'name': 'Post Malone',
        'imageUrl':
            'https://i.scdn.co/image/ab6761610000e5eb9e3a5c0e5e8e8e8e8e8e8e8e8',
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
        'artworkUrl':
            'https://i.scdn.co/image/ab67616d0000b273bb54dde68cd23e2a268ae0f5',
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
        'artworkUrl':
            'https://i.scdn.co/image/ab67616d0000b273bb54dde68cd23e2a268ae0f5',
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
        'artworkUrl':
            'https://i.scdn.co/image/ab67616d0000b273bb54dde68cd23e2a268ae0f5',
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
        'artworkUrl':
            'https://i.scdn.co/image/ab67616d0000b273bb54dde68cd23e2a268ae0f5',
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
        'artworkUrl':
            'https://i.scdn.co/image/ab67616d0000b273bb54dde68cd23e2a268ae0f5',
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
          .add({...albumData, 'createdAt': FieldValue.serverTimestamp()});
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
        'artworkUrl':
            'https://i.scdn.co/image/ab67616d0000b273bb54dde68cd23e2a268ae0f5',
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
        'artworkUrl':
            'https://i.scdn.co/image/ab67616d0000b273bb54dde68cd23e2a268ae0f5',
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
        'artworkUrl':
            'https://i.scdn.co/image/ab67616d0000b273bb54dde68cd23e2a268ae0f5',
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
        'imageUrl':
            'https://i.scdn.co/image/ab67616d0000b273bb54dde68cd23e2a268ae0f5',
        'color': '#1DB954',
        'songIds': [],
        'albumIds': [],
        'artistIds': [],
        'playlistIds': [],
      },
      {
        'name': 'rock',
        'displayName': 'Rock',
        'imageUrl':
            'https://i.scdn.co/image/ab67616d0000b273bb54dde68cd23e2a268ae0f5',
        'color': '#FF6B6B',
        'songIds': [],
        'albumIds': [],
        'artistIds': [],
        'playlistIds': [],
      },
      {
        'name': 'hip-hop',
        'displayName': 'Hip-Hop',
        'imageUrl':
            'https://i.scdn.co/image/ab67616d0000b273bb54dde68cd23e2a268ae0f5',
        'color': '#4ECDC4',
        'songIds': [],
        'albumIds': [],
        'artistIds': [],
        'playlistIds': [],
      },
      {
        'name': 'r&b',
        'displayName': 'R&B',
        'imageUrl':
            'https://i.scdn.co/image/ab67616d0000b273bb54dde68cd23e2a268ae0f5',
        'color': '#95E1D3',
        'songIds': [],
        'albumIds': [],
        'artistIds': [],
        'playlistIds': [],
      },
      {
        'name': 'electronic',
        'displayName': 'Electronic',
        'imageUrl':
            'https://i.scdn.co/image/ab67616d0000b273bb54dde68cd23e2a268ae0f5',
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
          .add({...genreData, 'createdAt': FieldValue.serverTimestamp()});
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
        .limit(10)
        .get();

    if (artistsSnapshot.docs.isEmpty) {
      print('⚠️ Chưa có artists, bỏ qua concerts');
      return;
    }

    final artists = artistsSnapshot.docs;
    final now = DateTime.now();

    // Tạo concerts với nhiều locations khác nhau, bao gồm Los Angeles và các thành phố khác
    final concerts = [
      // Concerts ở Los Angeles
      {
        'title': 'STS9 with Tycho and Chrome Sparks at Red Rocks',
        'artistId': artists.length > 0 ? artists[0].id : '',
        'artistName': artists.length > 0 ? artists[0].data()['name'] : 'Tycho',
        'venue': {
          'name': 'Red Rocks Amphitheatre',
          'address': '18300 W Alameda Pkwy',
          'city': 'Morrison',
          'country': 'USA',
        },
        'dateTime': Timestamp.fromDate(now.add(const Duration(days: 30))),
        'imageUrl':
            'https://www.figma.com/api/mcp/asset/62f56cdb-e4b9-4089-964d-9722575a049a',
        'ticketUrl': 'https://example.com/tickets',
        'price': {'min': 50.0, 'max': 150.0, 'currency': 'USD'},
        'status': 'upcoming',
        'capacity': 9525,
        'attendees': [],
      },
      {
        'title': 'blink-182, Simple Plan and grandson',
        'artistId': artists.length > 1 ? artists[1].id : '',
        'artistName': artists.length > 1
            ? artists[1].data()['name']
            : 'blink-182',
        'venue': {
          'name': 'Harris Park',
          'address': '123 Main St',
          'city': 'Los Angeles',
          'country': 'USA',
        },
        'dateTime': Timestamp.fromDate(now.add(const Duration(days: 45))),
        'imageUrl':
            'https://www.figma.com/api/mcp/asset/62f56cdb-e4b9-4089-964d-9722575a049a',
        'ticketUrl': 'https://example.com/tickets',
        'price': {'min': 75.0, 'max': 200.0, 'currency': 'USD'},
        'status': 'upcoming',
        'capacity': 15000,
        'attendees': [],
      },
      {
        'title': 'Louis The Child, Jai Wolf and MEMBA',
        'artistId': artists.length > 2 ? artists[2].id : '',
        'artistName': artists.length > 2
            ? artists[2].data()['name']
            : 'Louis The Child',
        'venue': {
          'name': 'Masonic Temple',
          'address': '500 Temple St',
          'city': 'Los Angeles',
          'country': 'USA',
        },
        'dateTime': Timestamp.fromDate(now.add(const Duration(days: 60))),
        'imageUrl':
            'https://www.figma.com/api/mcp/asset/b4f2745e-5d71-43eb-9c37-25cd46fca191',
        'ticketUrl': 'https://example.com/tickets',
        'price': {'min': 40.0, 'max': 120.0, 'currency': 'USD'},
        'status': 'upcoming',
        'capacity': 5000,
        'attendees': [],
      },
      // Concerts ở các thành phố khác
      {
        'title': 'Rescheduled - III Points',
        'artistId': artists.length > 0 ? artists[0].id : '',
        'artistName': artists.length > 0 ? artists[0].data()['name'] : 'Tycho',
        'venue': {
          'name': 'Mana Wynwood',
          'address': '318 NW 23rd St',
          'city': 'Miami',
          'country': 'USA',
        },
        'dateTime': Timestamp.fromDate(now.add(const Duration(days: 90))),
        'imageUrl':
            'https://www.figma.com/api/mcp/asset/62f56cdb-e4b9-4089-964d-9722575a049a',
        'ticketUrl': 'https://example.com/tickets',
        'price': {'min': 60.0, 'max': 180.0, 'currency': 'USD'},
        'status': 'upcoming',
        'capacity': 8000,
        'attendees': [],
      },
      {
        'title': 'Tycho with Com Truise at The Caverns',
        'artistId': artists.length > 0 ? artists[0].id : '',
        'artistName': artists.length > 0 ? artists[0].data()['name'] : 'Tycho',
        'venue': {
          'name': 'The Caverns',
          'address': '555 Caverns Rd',
          'city': 'Pelham',
          'country': 'USA',
        },
        'dateTime': Timestamp.fromDate(now.add(const Duration(days: 120))),
        'imageUrl':
            'https://www.figma.com/api/mcp/asset/62f56cdb-e4b9-4089-964d-9722575a049a',
        'ticketUrl': 'https://example.com/tickets',
        'price': {'min': 45.0, 'max': 140.0, 'currency': 'USD'},
        'status': 'upcoming',
        'capacity': 1200,
        'attendees': [],
      },
      {
        'title': 'Jimmy Eat World, The Front Bottoms and Tur...',
        'artistId': artists.length > 3 ? artists[3].id : '',
        'artistName': artists.length > 3
            ? artists[3].data()['name']
            : 'Jimmy Eat World',
        'venue': {
          'name': 'The Fillmore',
          'address': '1805 Geary Blvd',
          'city': 'San Francisco',
          'country': 'USA',
        },
        'dateTime': Timestamp.fromDate(now.add(const Duration(days: 75))),
        'imageUrl':
            'https://www.figma.com/api/mcp/asset/fb659422-87f8-4108-8abe-2a2569f5af93',
        'ticketUrl': 'https://example.com/tickets',
        'price': {'min': 55.0, 'max': 160.0, 'currency': 'USD'},
        'status': 'upcoming',
        'capacity': 1200,
        'attendees': [],
      },
      {
        'title': 'Lane 8 and Sultan + Shepard',
        'artistId': artists.length > 4 ? artists[4].id : '',
        'artistName': artists.length > 4 ? artists[4].data()['name'] : 'Lane 8',
        'venue': {
          'name': 'Majestic Theatre',
          'address': '115 King St',
          'city': 'Madison',
          'country': 'USA',
        },
        'dateTime': Timestamp.fromDate(now.add(const Duration(days: 85))),
        'imageUrl':
            'https://www.figma.com/api/mcp/asset/b6c6f85e-919a-434a-98e6-6cd52a7b8718',
        'ticketUrl': 'https://example.com/tickets',
        'price': {'min': 50.0, 'max': 130.0, 'currency': 'USD'},
        'status': 'upcoming',
        'capacity': 1000,
        'attendees': [],
      },
      {
        'title': 'Marshmello',
        'artistId': artists.length > 5 ? artists[5].id : '',
        'artistName': artists.length > 5
            ? artists[5].data()['name']
            : 'Marshmello',
        'venue': {
          'name': 'Masonic Temple Theatre',
          'address': '500 Temple St',
          'city': 'Detroit',
          'country': 'USA',
        },
        'dateTime': Timestamp.fromDate(now.add(const Duration(days: 100))),
        'imageUrl':
            'https://www.figma.com/api/mcp/asset/871b2985-22e8-4b21-a514-29b6e966566b',
        'ticketUrl': 'https://example.com/tickets',
        'price': {'min': 80.0, 'max': 250.0, 'currency': 'USD'},
        'status': 'upcoming',
        'capacity': 4500,
        'attendees': [],
      },
    ];

    for (var concertData in concerts) {
      if (concertData['artistId'] == '') continue; // Skip nếu không có artist
      final docRef = await _firestore
          .collection(FirestoreCollections.concerts)
          .add({...concertData, 'createdAt': FieldValue.serverTimestamp()});
      print('  ✅ Đã tạo concert: ${concertData['title']} (${docRef.id})');
    }

    print('✅ Đã seed ${concerts.length} concerts');
  }

  /// Seed Podcasts
  ///
  /// Có thể truyền custom audio URLs từ Firebase Storage
  /// Nếu không truyền, sẽ dùng sample URLs
  Future<void> seedPodcasts({List<String>? customAudioUrls}) async {
    print('📝 Đang seed podcasts...');

    // Nếu có custom URLs, dùng chúng
    if (customAudioUrls != null && customAudioUrls.isNotEmpty) {
      print('📦 Sử dụng custom audio URLs từ Firebase Storage');
      setCustomAudioUrls(customAudioUrls);
    } else {
      // Thử lấy URLs từ Firebase Storage
      try {
        final storageUrls = await getPodcastAudioUrls(count: 10);
        if (storageUrls.isNotEmpty) {
          print('📦 Sử dụng audio URLs từ Firebase Storage');
          setCustomAudioUrls(storageUrls);
        }
      } catch (e) {
        print('⚠️ Không thể lấy URLs từ Storage, dùng sample URLs: $e');
      }
    }

    // Lấy artists để làm hosts hoặc tạo hosts riêng
    final artistsSnapshot = await _firestore
        .collection(FirestoreCollections.artists)
        .limit(3)
        .get();

    final now = DateTime.now();

    final podcasts = [
      {
        'title': 'The Basement Yard',
        'description':
            'Weekly discussions about music industry and entertainment',
        'hostId': artistsSnapshot.docs.isNotEmpty
            ? artistsSnapshot.docs[0].id
            : 'host1',
        'hostName': artistsSnapshot.docs.isNotEmpty
            ? artistsSnapshot.docs[0].data()['name']
            : 'Joe Santagato',
        'imageUrl':
            'https://www.figma.com/api/mcp/asset/90f55eb4-d1e2-4d43-93e6-d422dd17e6a2',
        'category': 'Entertainment',
        'categories': ['Entertainment', 'Comedy', 'Music'],
        'episodeIds': [],
        'followerCount': 50000,
        'totalEpisodes': 0,
        'tags': ['comedy', 'entertainment', 'music'],
      },
      {
        'title': 'Artist Stories',
        'description': 'Behind the scenes with your favorite artists',
        'hostId': artistsSnapshot.docs.length > 1
            ? artistsSnapshot.docs[1].id
            : 'host2',
        'hostName': artistsSnapshot.docs.length > 1
            ? artistsSnapshot.docs[1].data()['name']
            : 'Music Insider',
        'imageUrl':
            'https://i.scdn.co/image/ab67616d0000b273bb54dde68cd23e2a268ae0f5',
        'category': 'Music',
        'categories': ['Music', 'Entertainment'],
        'episodeIds': [],
        'followerCount': 30000,
        'totalEpisodes': 0,
        'tags': ['artists', 'stories', 'behind-scenes'],
      },
      {
        'title': 'Tech Talk',
        'description': 'Technology and innovation discussions',
        'hostId': artistsSnapshot.docs.length > 2
            ? artistsSnapshot.docs[2].id
            : 'host3',
        'hostName': artistsSnapshot.docs.length > 2
            ? artistsSnapshot.docs[2].data()['name']
            : 'Tech Expert',
        'imageUrl':
            'https://i.scdn.co/image/ab67616d0000b273bb54dde68cd23e2a268ae0f5',
        'category': 'Technology',
        'categories': ['Technology', 'Science'],
        'episodeIds': [],
        'followerCount': 25000,
        'totalEpisodes': 0,
        'tags': ['technology', 'innovation', 'science'],
      },
    ];

    final List<String> podcastIds = [];

    for (var podcastData in podcasts) {
      final docRef = await _firestore
          .collection(FirestoreCollections.podcasts)
          .add({...podcastData, 'createdAt': FieldValue.serverTimestamp()});
      podcastIds.add(docRef.id);
      print('  ✅ Đã tạo podcast: ${podcastData['title']} (${docRef.id})');

      // Tạo nhiều episodes cho podcast (đặc biệt là The Basement Yard)
      final List<Map<String, dynamic>> episodes = [];

      if (podcastData['title'] == 'The Basement Yard') {
        // Tạo 3 episodes cho The Basement Yard (phù hợp với UI)
        episodes.addAll([
          {
            'podcastId': docRef.id,
            'title': '#250 - Joe Kisses Danny',
            'description':
                'On this episode, we dive into Danny\'s dream where Joe kissed him at a party...we also dive into the dark underworld of the Karens.',
            'episodeNumber': 250,
            'duration': 4200, // 70 minutes = 1HR 10MIN
            'audioUrl': _getSampleAudioUrl(0),
            'artworkUrl': podcastData['imageUrl'],
            'releaseDate': Timestamp.fromDate(
              now.subtract(const Duration(days: 1)),
            ),
            'playCount': 10000,
            'likeCount': 500,
            'isExplicit': false,
            'createdAt': FieldValue.serverTimestamp(),
          },
          {
            'podcastId': docRef.id,
            'title': '#249 - Danny Kisses Joe',
            'description':
                'On this episode, we dive into Danny\'s dream where Joe kissed him at a party...we also dive into the dark underworld of the Karens.',
            'episodeNumber': 249,
            'duration': 4200, // 70 minutes
            'audioUrl': _getSampleAudioUrl(1),
            'artworkUrl': podcastData['imageUrl'],
            'releaseDate': Timestamp.fromDate(
              now.subtract(const Duration(days: 1)),
            ),
            'playCount': 8000,
            'likeCount': 400,
            'isExplicit': false,
            'createdAt': FieldValue.serverTimestamp(),
          },
          {
            'podcastId': docRef.id,
            'title': '#248 - Kanye 2020',
            'description':
                'On this episode, we dive into Danny\'s dream where Joe kissed him at a party...we also dive into the dark underworld of the Karens.',
            'episodeNumber': 248,
            'duration': 4200, // 70 minutes
            'audioUrl': _getSampleAudioUrl(2),
            'artworkUrl': podcastData['imageUrl'],
            'releaseDate': Timestamp.fromDate(
              now.subtract(const Duration(days: 1)),
            ),
            'playCount': 7500,
            'likeCount': 350,
            'isExplicit': false,
            'createdAt': FieldValue.serverTimestamp(),
          },
        ]);
      } else {
        final podcastTitle = podcastData['title'] as String;
        final episodeTitles = _getEpisodeTitlesForPodcast(podcastTitle);
        final episodeDescriptions = _getEpisodeDescriptionsForPodcast(
          podcastTitle,
        );

        for (int i = 0; i < 4; i++) {
          episodes.add({
            'podcastId': docRef.id,
            'title': '${podcastTitle} - Episode ${i + 1}: ${episodeTitles[i]}',
            'description': episodeDescriptions[i],
            'episodeNumber': i + 1,
            'duration': 3600 + (i * 300), // 1 hour to 1.5 hours
            'audioUrl': _getSampleAudioUrl(i),
            'artworkUrl': podcastData['imageUrl'],
            'releaseDate': Timestamp.fromDate(
              now.subtract(Duration(days: 7 - (i * 2))),
            ),
            'playCount': 10000 - (i * 500),
            'likeCount': 500 - (i * 50),
            'isExplicit': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

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
        await albumDoc.reference.update({'songIds': [], 'totalTracks': 0});
      }

      // Xóa songIds từ artists
      final artistsSnapshot = await _firestore
          .collection(FirestoreCollections.artists)
          .get();

      for (var artistDoc in artistsSnapshot.docs) {
        await artistDoc.reference.update({'songIds': []});
      }

      print('✅ Đã xóa $deletedCount songs cũ');
    } catch (e) {
      print('❌ Lỗi khi xóa songs: $e');
      rethrow;
    }
  }

  /// Seed songs mới với URLs tùy chỉnh
  Future<void> seedSongsWithCustomUrls(
    Map<String, Map<String, dynamic>> songUrls,
  ) async {
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
        final artistName =
            songData['artistName'] as String? ?? defaultArtistName!;
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
  Future<void> resetAndSeedSongs(
    Map<String, Map<String, dynamic>> songUrls,
  ) async {
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

  /// Xóa tất cả albums và clean up related data (giữ lại songs)
  Future<void> deleteAllAlbums() async {
    print('🗑️ Đang xóa tất cả albums (giữ lại songs)...');
    
    try {
      // Lấy tất cả albums
      final albumsSnapshot = await _firestore
          .collection(FirestoreCollections.albums)
          .get();
      
      if (albumsSnapshot.docs.isEmpty) {
        print('ℹ️ Không có albums nào để xóa.');
        return;
      }
      
      // Lấy artistIds cần update (chỉ xóa albumIds, giữ lại songIds)
      final artistIdsToUpdate = <String>{};
      
      for (var albumDoc in albumsSnapshot.docs) {
        final albumData = albumDoc.data();
        final artistId = albumData['artistId'] as String?;
        
        if (artistId != null) {
          artistIdsToUpdate.add(artistId);
        }
      }
      
      // Xóa albums (không xóa songs)
      int deletedAlbums = 0;
      for (var doc in albumsSnapshot.docs) {
        await doc.reference.delete();
        deletedAlbums++;
      }
      
      // Clean up artists (chỉ xóa albumIds, giữ lại songIds)
      print('  📝 Đang clean up artists (chỉ xóa albumIds)...');
      for (var artistId in artistIdsToUpdate) {
        try {
          // Lấy songIds hiện tại của artist
          final artistDoc = await _firestore
              .collection(FirestoreCollections.artists)
              .doc(artistId)
              .get();
          
          if (artistDoc.exists) {
            final currentSongIds = List<String>.from(artistDoc.data()?['songIds'] ?? []);
            // Chỉ xóa albumIds, giữ lại songIds
            await _firestore.collection(FirestoreCollections.artists).doc(artistId).update({
              'albumIds': [],
              // Giữ lại songIds hiện tại
              'songIds': currentSongIds,
            });
          }
        } catch (e) {
          print('  ⚠️ Lỗi khi clean up artist $artistId: $e');
        }
      }
      
      print('✅ Đã xóa $deletedAlbums albums (songs được giữ lại)');
    } catch (e) {
      print('❌ Lỗi khi xóa albums: $e');
      rethrow;
    }
  }

  /// Seed data mới từ file new_songs format
  Future<void> seedNewAlbumsAndSongs() async {
    print('🌱 Bắt đầu seed data mới từ new_songs...');
    
    try {
      // Xóa data cũ
      await deleteAllAlbums();
      
      // Data structure từ file new_songs
      final albumsData = [
        {
          'title': 'L2K - The Album',
          'artistName': 'Low G',
          'artworkUrl': 'https://firebasestorage.googleapis.com/v0/b/spotify-78b1f.firebasestorage.app/o/img_url%2FL2K.png?alt=media&token=eda996e1-7a6d-402d-be1c-baffa35d8598',
          'genre': 'Hip-Hop',
          'genres': ['Hip-Hop', 'Rap', 'Vietnamese'],
          'songs': [
            {
              'title': 'Đừng để tiền rơi',
              'songUrl': 'https://firebasestorage.googleapis.com/v0/b/spotify-78b1f.firebasestorage.app/o/song_urls%2FLow%20G%20_%20%C4%90%E1%BB%ABng%20%C4%90%E1%BB%83%20Ti%E1%BB%81n%20R%C6%A1i%20_%20%E2%80%98L2K%E2%80%99%20The%20Album%20%5Bu4Pk8-1Hxiw%5D.mp3?alt=media&token=e12d0ea6-c156-447b-a62b-cda85cbf66ef',
              'imgUrl': 'https://firebasestorage.googleapis.com/v0/b/spotify-78b1f.firebasestorage.app/o/img_url%2FL2K.png?alt=media&token=eda996e1-7a6d-402d-be1c-baffa35d8598',
            },
            {
              'title': 'Tràng Thi',
              'songUrl': 'https://firebasestorage.googleapis.com/v0/b/spotify-78b1f.firebasestorage.app/o/song_urls%2FLow%20G%20_%20Tr%C3%A0ng%20Thi%20_%20%E2%80%98L2K%E2%80%99%20The%20Album%20%5By8tLAOwFUZ4%5D.mp3?alt=media&token=8d596712-4152-49d5-b737-c2b71cbcec1f',
              'imgUrl': 'https://firebasestorage.googleapis.com/v0/b/spotify-78b1f.firebasestorage.app/o/img_url%2FL2K.png?alt=media&token=eda996e1-7a6d-402d-be1c-baffa35d8598',
            },
            {
              'title': 'Siêu sao',
              'songUrl': 'https://firebasestorage.googleapis.com/v0/b/spotify-78b1f.firebasestorage.app/o/song_urls%2FLow%20G%20_%20Si%C3%AAu%20Sao%20_%20%E2%80%98L2K%E2%80%99%20The%20Album%20%5BgHSMZzc-iEE%5D.mp3?alt=media&token=a605ffa0-8203-43b6-aaae-c0b882985e58',
              'imgUrl': 'https://firebasestorage.googleapis.com/v0/b/spotify-78b1f.firebasestorage.app/o/img_url%2FL2K.png?alt=media&token=eda996e1-7a6d-402d-be1c-baffa35d8598',
            },
            {
              'title': 'Peace N\' Love',
              'songUrl': 'https://firebasestorage.googleapis.com/v0/b/spotify-78b1f.firebasestorage.app/o/song_urls%2FLow%20G%20_%20Peace%20N%E2%80%99%20Love%20(ft.%20M%E1%BB%B9%20Anh)%20_%20%E2%80%98L2K%E2%80%99%20The%20Album%20%5Bn_KakQwWUoc%5D.mp3?alt=media&token=e7c84610-5db3-4dca-b386-b8e96926c5bc',
              'imgUrl': 'https://firebasestorage.googleapis.com/v0/b/spotify-78b1f.firebasestorage.app/o/img_url%2FL2K.png?alt=media&token=eda996e1-7a6d-402d-be1c-baffa35d8598',
            },
            {
              'title': 'Nét',
              'songUrl': 'https://firebasestorage.googleapis.com/v0/b/spotify-78b1f.firebasestorage.app/o/song_urls%2FLow%20G%20_%20Peace%20N%E2%80%99%20Love%20(ft.%20M%E1%BB%B9%20Anh)%20_%20%E2%80%98L2K%E2%80%99%20The%20Album%20%5Bn_KakQwWUoc%5D.mp3?alt=media&token=e7c84610-5db3-4dca-b386-b8e96926c5bc',
              'imgUrl': 'https://firebasestorage.googleapis.com/v0/b/spotify-78b1f.firebasestorage.app/o/img_url%2FL2K.png?alt=media&token=eda996e1-7a6d-402d-be1c-baffa35d8598',
            },
            {
              'title': 'Nhiều hơn',
              'songUrl': 'https://firebasestorage.googleapis.com/v0/b/spotify-78b1f.firebasestorage.app/o/song_urls%2FLow%20G%20_%20Nhi%E1%BB%81u%20H%C6%A1n%20_%20%E2%80%98L2K%E2%80%99%20The%20Album%20%5BzylC5TE9jrk%5D.mp3?alt=media&token=8c3ddc1d-14ed-44d6-bae2-155eda8c0c3b',
              'imgUrl': 'https://firebasestorage.googleapis.com/v0/b/spotify-78b1f.firebasestorage.app/o/img_url%2FL2K.png?alt=media&token=eda996e1-7a6d-402d-be1c-baffa35d8598',
            },
            {
              'title': 'Love Game',
              'songUrl': 'https://firebasestorage.googleapis.com/v0/b/spotify-78b1f.firebasestorage.app/o/song_urls%2FLow%20G%20_%20Love%20Game%20(ft.%20tlinh)%20_%20%E2%80%98L2K%E2%80%99%20The%20Album%20%5BbMmIAaMcWsU%5D.mp3?alt=media&token=771e912c-afff-40cc-9aeb-d694310c79d6',
              'imgUrl': 'https://firebasestorage.googleapis.com/v0/b/spotify-78b1f.firebasestorage.app/o/img_url%2FL2K.png?alt=media&token=eda996e1-7a6d-402d-be1c-baffa35d8598',
            },
            {
              'title': 'Long',
              'songUrl': 'https://firebasestorage.googleapis.com/v0/b/spotify-78b1f.firebasestorage.app/o/song_urls%2FLow%20G%20_%20Long%20_%20%E2%80%98L2K%E2%80%99%20The%20Album%20%5B78HyHkjbkb4%5D.mp3?alt=media&token=371d659e-1d5b-49e4-a36e-c33adc45cfe9',
              'imgUrl': 'https://firebasestorage.googleapis.com/v0/b/spotify-78b1f.firebasestorage.app/o/img_url%2FL2K.png?alt=media&token=eda996e1-7a6d-402d-be1c-baffa35d8598',
            },
            {
              'title': 'Giải Cứu Mỹ Nhân',
              'songUrl': 'https://firebasestorage.googleapis.com/v0/b/spotify-78b1f.firebasestorage.app/o/song_urls%2FLow%20G%20_%20Gi%E1%BA%A3i%20C%E1%BB%A9u%20M%E1%BB%B9%20Nh%C3%A2n%20(ft.%20Ho%C3%A0ng%20T%C3%B4n)%20_%20%E2%80%98L2K%E2%80%99%20The%20Album%20%5BAWLp157GHZA%5D.mp3?alt=media&token=17cd6705-01ae-4fb3-955d-fae947716bd8',
              'imgUrl': 'https://firebasestorage.googleapis.com/v0/b/spotify-78b1f.firebasestorage.app/o/img_url%2FL2K.png?alt=media&token=eda996e1-7a6d-402d-be1c-baffa35d8598',
            },
            {
              'title': 'Celeb Date',
              'songUrl': 'https://firebasestorage.googleapis.com/v0/b/spotify-78b1f.firebasestorage.app/o/song_urls%2FLow%20G%20_%20Celeb%20Date%20_%20%E2%80%98L2K%E2%80%99%20The%20Album%20%5BFu7Kr7hNh1s%5D.mp3?alt=media&token=66b786c8-18af-4517-9c5f-56f7ff397711',
              'imgUrl': 'https://firebasestorage.googleapis.com/v0/b/spotify-78b1f.firebasestorage.app/o/img_url%2FL2K.png?alt=media&token=eda996e1-7a6d-402d-be1c-baffa35d8598',
            },
            {
              'title': 'In Love',
              'songUrl': 'https://firebasestorage.googleapis.com/v0/b/spotify-78b1f.firebasestorage.app/o/song_urls%2FLow%20G%20_%20In%20Love%20(ft.%20JustaTee)%20_%20%E2%80%98L2K%E2%80%99%20The%20Album%20%5BT7ksmtaVeOk%5D.mp3?alt=media&token=be58b4b1-3248-4530-b43b-091926d966d7',
              'imgUrl': 'https://firebasestorage.googleapis.com/v0/b/spotify-78b1f.firebasestorage.app/o/img_url%2FL2K.png?alt=media&token=eda996e1-7a6d-402d-be1c-baffa35d8598',
            },
          ],
        },
        {
          'title': 'Từng Ngày Như Mãi Mãi',
          'artistName': 'buitruonglinh',
          'artworkUrl': 'https://firebasestorage.googleapis.com/v0/b/spotify-78b1f.firebasestorage.app/o/img_url%2FT%E1%BB%ABng%20Ng%C3%A0y%20Nh%C6%B0%20M%C3%A3i%20M%C3%A3i.png?alt=media&token=ec524b7a-fa3a-4e0a-aef9-3486dc29906a',
          'genre': 'Pop',
          'genres': ['Pop', 'Ballad', 'Vietnamese'],
          'songs': [
            {
              'title': 'Đi Cùng Anh',
              'songUrl': 'https://firebasestorage.googleapis.com/v0/b/spotify-78b1f.firebasestorage.app/o/song_urls%2F%C4%90i%20C%C3%B9ng%20Anh%20_%20buitruonglinh%20(ft.%2052Hz)%20%5BVO3uefb_rBc%5D.mp3?alt=media&token=70524f23-c8c0-4117-830a-6682c7e84a69',
              'imgUrl': 'https://firebasestorage.googleapis.com/v0/b/spotify-78b1f.firebasestorage.app/o/img_url%2FT%E1%BB%ABng%20Ng%C3%A0y%20Nh%C6%B0%20M%C3%A3i%20M%C3%A3i.png?alt=media&token=ec524b7a-fa3a-4e0a-aef9-3486dc29906a',
            },
            {
              'title': 'Vì Điều Gì',
              'songUrl': 'https://firebasestorage.googleapis.com/v0/b/spotify-78b1f.firebasestorage.app/o/song_urls%2FV%C3%AC%20%C4%90i%E1%BB%81u%20G%C3%AC%20_%20buitruonglinh%20(ft.%20Dangrangto)%20%5B_rEtH_Ir0nE%5D.mp3?alt=media&token=c8dcf9a4-19be-4734-8f53-59048a8a2d60',
              'imgUrl': 'https://firebasestorage.googleapis.com/v0/b/spotify-78b1f.firebasestorage.app/o/img_url%2FT%E1%BB%ABng%20Ng%C3%A0y%20Nh%C6%B0%20M%C3%A3i%20M%C3%A3i.png?alt=media&token=ec524b7a-fa3a-4e0a-aef9-3486dc29906a',
            },
            {
              'title': 'Từng Ngày Như Mãi Mãi',
              'songUrl': 'https://firebasestorage.googleapis.com/v0/b/spotify-78b1f.firebasestorage.app/o/song_urls%2FT%E1%BB%ABng%20Ng%C3%A0y%20Nh%C6%B0%20M%C3%A3i%20M%C3%A3i%20_%20buitruonglinh%20%5Bp3FnuJnm8iQ%5D.mp3?alt=media&token=876a252d-a7a4-4752-b29f-6d8700152d89',
              'imgUrl': 'https://firebasestorage.googleapis.com/v0/b/spotify-78b1f.firebasestorage.app/o/img_url%2FT%E1%BB%ABng%20Ng%C3%A0y%20Nh%C6%B0%20M%C3%A3i%20M%C3%A3i.png?alt=media&token=ec524b7a-fa3a-4e0a-aef9-3486dc29906a',
            },
            {
              'title': 'Nàng Công Chúa Nhỏ (interlude)',
              'songUrl': 'https://firebasestorage.googleapis.com/v0/b/spotify-78b1f.firebasestorage.app/o/song_urls%2FN%C3%A0ng%20C%C3%B4ng%20Ch%C3%BAa%20Nh%E1%BB%8F%20_%20buitruonglinh%20(interlude)%20%5B3CSNJ5_TCbY%5D.mp3?alt=media&token=924cd261-b0e9-4f73-851e-3c70d87d26f5',
              'imgUrl': 'https://firebasestorage.googleapis.com/v0/b/spotify-78b1f.firebasestorage.app/o/img_url%2FT%E1%BB%ABng%20Ng%C3%A0y%20Nh%C6%B0%20M%C3%A3i%20M%C3%A3i.png?alt=media&token=ec524b7a-fa3a-4e0a-aef9-3486dc29906a',
            },
            {
              'title': 'Giờ Thì',
              'songUrl': 'https://firebasestorage.googleapis.com/v0/b/spotify-78b1f.firebasestorage.app/o/song_urls%2FGi%E1%BB%9D%20Th%C3%AC%20_%20buitruonglinh%20%5BItRExComFJ4%5D.mp3?alt=media&token=b06d35d7-503d-4cc5-a34c-825943c518b5',
              'imgUrl': 'https://firebasestorage.googleapis.com/v0/b/spotify-78b1f.firebasestorage.app/o/img_url%2FT%E1%BB%ABng%20Ng%C3%A0y%20Nh%C6%B0%20M%C3%A3i%20M%C3%A3i.png?alt=media&token=ec524b7a-fa3a-4e0a-aef9-3486dc29906a',
            },
            {
              'title': 'Em Ơi Là Em',
              'songUrl': 'https://firebasestorage.googleapis.com/v0/b/spotify-78b1f.firebasestorage.app/o/song_urls%2FEm%20%C6%A0i%20L%C3%A0%20Em%20_%20buitruonglinh%20(ft.%20Ki%E1%BB%81u%20Chi%2C%20BMZ)%20%5BKOlX-v0q-8A%5D.mp3?alt=media&token=c9536cef-163f-40c5-9b5f-21900f361d58',
              'imgUrl': 'https://firebasestorage.googleapis.com/v0/b/spotify-78b1f.firebasestorage.app/o/img_url%2FT%E1%BB%ABng%20Ng%C3%A0y%20Nh%C6%B0%20M%C3%A3i%20M%C3%A3i.png?alt=media&token=ec524b7a-fa3a-4e0a-aef9-3486dc29906a',
            },
            {
              'title': 'Dù Em Từng Yêu',
              'songUrl': 'https://firebasestorage.googleapis.com/v0/b/spotify-78b1f.firebasestorage.app/o/song_urls%2FD%C3%B9%20Em%20T%E1%BB%ABng%20Y%C3%AAu%20_%20buitruonglinh%20%5BKIIgt2VY-u0%5D.mp3?alt=media&token=e1e1f008-3378-4c5f-9f47-52534ec3a23c',
              'imgUrl': 'https://firebasestorage.googleapis.com/v0/b/spotify-78b1f.firebasestorage.app/o/img_url%2FT%E1%BB%ABng%20Ng%C3%A0y%20Nh%C6%B0%20M%C3%A3i%20M%C3%A3i.png?alt=media&token=ec524b7a-fa3a-4e0a-aef9-3486dc29906a',
            },
            {
              'title': 'Chỉ Là Không Có Nhau',
              'songUrl': 'https://firebasestorage.googleapis.com/v0/b/spotify-78b1f.firebasestorage.app/o/song_urls%2FCh%E1%BB%89%20L%C3%A0%20Kh%C3%B4ng%20C%C3%B3%20Nhau%20_%20buitruonglinh%20%5BFvWPSA2mt2s%5D.mp3?alt=media&token=df897624-1931-4f3b-818a-668a8bfa03de',
              'imgUrl': 'https://firebasestorage.googleapis.com/v0/b/spotify-78b1f.firebasestorage.app/o/img_url%2FT%E1%BB%ABng%20Ng%C3%A0y%20Nh%C6%B0%20M%C3%A3i%20M%C3%A3i.png?alt=media&token=ec524b7a-fa3a-4e0a-aef9-3486dc29906a',
            },
          ],
        },
      ];
      
      // Standalone songs
      final standaloneSongs = [
        {
          'title': '2GOILAYS',
          'artistName': 'DMT, Dangrangto, TeuYungBoy',
          'songUrl': 'https://firebasestorage.googleapis.com/v0/b/spotify-78b1f.firebasestorage.app/o/song_urls%2F2GOILAYS%20-%20DMT%2C%20Dangrangto%2C%20TeuYungBoy%20(Prod.%20DONAL)%20_%20Official%20MV%20%5BILsA2VFJ150%5D.mp3?alt=media&token=296a5e3d-f328-4ae7-83dd-1da46d8d0853',
          'imgUrl': 'https://firebasestorage.googleapis.com/v0/b/spotify-78b1f.firebasestorage.app/o/img_url%2F2GOILAYS.png?alt=media&token=6496aa99-e952-42e9-9b20-77c0c93a27bf',
          'genre': 'Hip-Hop',
          'genres': ['Hip-Hop', 'Rap', 'Vietnamese'],
        },
        {
          'title': 'Buồn Hay Vui',
          'artistName': 'VSOUL x MCK x Obito x Ronboogz x Boyzed',
          'songUrl': 'https://firebasestorage.googleapis.com/v0/b/spotify-78b1f.firebasestorage.app/o/song_urls%2FBU%E1%BB%92N%20HAY%20VUI%20-%20VSOUL%20x%20MCK%20x%20Obito%20x%20Ronboogz%20x%20Boyzed%20(Official%20Audio)%20%5BJV0dEgbX5yk%5D.mp3?alt=media&token=4b386eb7-21ad-4fa8-bf0c-99bd82588af3',
          'imgUrl': 'https://firebasestorage.googleapis.com/v0/b/spotify-78b1f.firebasestorage.app/o/img_url%2FBU%E1%BB%92N%20HAY%20VUI.png?alt=media&token=fd881953-c3e3-4595-a729-0d06b8b4faaf',
          'genre': 'Hip-Hop',
          'genres': ['Hip-Hop', 'Rap', 'Vietnamese'],
        },
      ];
      
      // Tạo hoặc lấy artists
      final Map<String, String> artistNameToId = {};
      
      // Collect unique artist names
      final Set<String> uniqueArtistNames = {};
      for (var albumData in albumsData) {
        uniqueArtistNames.add(albumData['artistName'] as String);
      }
      for (var songData in standaloneSongs) {
        uniqueArtistNames.add(songData['artistName'] as String);
      }
      
      // Tạo artists
      print('📝 Đang tạo ${uniqueArtistNames.length} artists...');
      for (var artistName in uniqueArtistNames) {
        // Kiểm tra xem artist đã tồn tại chưa
        final existingArtists = await _firestore
            .collection(FirestoreCollections.artists)
            .where('name', isEqualTo: artistName)
            .limit(1)
            .get();
        
        String artistId;
        if (existingArtists.docs.isNotEmpty) {
          artistId = existingArtists.docs.first.id;
          // Giữ lại songIds hiện tại, chỉ clear albumIds
          final currentSongIds = List<String>.from(existingArtists.docs.first.data()['songIds'] ?? []);
          await existingArtists.docs.first.reference.update({
            'albumIds': [],
            // Giữ lại songIds hiện tại
            'songIds': currentSongIds,
          });
        } else {
          // Tạo artist mới
          final artistRef = await _firestore
              .collection(FirestoreCollections.artists)
              .add({
            'name': artistName,
            'imageUrl': null,
            'bio': null,
            'genres': artistName == 'Low G' 
                ? ['Hip-Hop', 'Rap', 'Vietnamese']
                : artistName == 'buitruonglinh'
                    ? ['Pop', 'Ballad', 'Vietnamese']
                    : ['Hip-Hop', 'Rap', 'Vietnamese'],
            'monthlyListeners': 0,
            'followerCount': 0,
            'albumIds': [],
            'songIds': [],
            'verified': true,
            'createdAt': FieldValue.serverTimestamp(),
          });
          artistId = artistRef.id;
        }
        
        artistNameToId[artistName] = artistId;
        print('  ✅ Artist: $artistName ($artistId)');
      }
      
      // Tạo albums và songs
      final Map<String, List<String>> artistAlbumIds = {};
      final Map<String, List<String>> artistSongIds = {};
      
      for (var artistName in uniqueArtistNames) {
        artistAlbumIds[artistName] = [];
        artistSongIds[artistName] = [];
      }
      
      print('📝 Đang tạo albums và songs...');
      for (var albumData in albumsData) {
        final albumTitle = albumData['title'] as String;
        final artistName = albumData['artistName'] as String;
        final artistId = artistNameToId[artistName]!;
        final artworkUrl = albumData['artworkUrl'] as String;
        final genre = albumData['genre'] as String;
        final genres = List<String>.from(albumData['genres'] as List);
        final songsData = List<Map<String, dynamic>>.from(albumData['songs'] as List);
        
        // Tạo album
        final albumRef = await _firestore
            .collection(FirestoreCollections.albums)
            .add({
          'title': albumTitle,
          'artistId': artistId,
          'artistName': artistName,
          'artworkUrl': artworkUrl,
          'releaseDate': FieldValue.serverTimestamp(),
          'genre': genre,
          'genres': genres,
          'totalTracks': songsData.length,
          'duration': 0, // Sẽ tính sau nếu cần
          'songIds': [],
          'playCount': 0,
          'likeCount': 0,
          'description': null,
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        final albumId = albumRef.id;
        artistAlbumIds[artistName]!.add(albumId);
        print('  ✅ Album: $albumTitle ($albumId)');
        
        // Tạo songs cho album
        final List<String> albumSongIds = [];
        int trackNumber = 1;
        
        for (var songData in songsData) {
          final songTitle = songData['title'] as String;
          final songUrl = songData['songUrl'] as String;
          final imgUrl = songData['imgUrl'] as String;
          
          // Skip nếu không có songUrl
          if (songUrl.isEmpty) {
            print('  ⚠️ Bỏ qua song "$songTitle": không có songUrl');
            continue;
          }
          
          final songRef = await _firestore
              .collection(FirestoreCollections.songs)
              .add({
            'title': songTitle,
            'artistId': artistId,
            'artistName': artistName,
            'albumId': albumId,
            'albumName': albumTitle,
            'duration': 180, // Default 3 minutes, có thể update sau
            'genre': genre,
            'genres': genres,
            'audioUrl': songUrl,
            'artworkUrl': imgUrl.trim(),
            'releaseDate': FieldValue.serverTimestamp(),
            'playCount': 0,
            'likeCount': 0,
            'isExplicit': false,
            'trackNumber': trackNumber,
            'popularity': 50,
            'tags': [
              songTitle.toLowerCase(),
              albumTitle.toLowerCase(),
              artistName.toLowerCase(),
              ...genres.map((g) => g.toLowerCase()),
            ],
            'createdAt': FieldValue.serverTimestamp(),
          });
          
          albumSongIds.add(songRef.id);
          artistSongIds[artistName]!.add(songRef.id);
          trackNumber++;
        }
        
        // Update album với songIds
        await albumRef.update({
          'songIds': albumSongIds,
          'totalTracks': albumSongIds.length,
        });
        
        print('    ✅ Đã tạo ${albumSongIds.length} songs cho album: $albumTitle');
      }
      
      // Tạo standalone songs (songs không thuộc album)
      print('📝 Đang tạo standalone songs...');
      for (var songData in standaloneSongs) {
        final songTitle = songData['title'] as String;
        final artistName = songData['artistName'] as String;
        final artistId = artistNameToId[artistName]!;
        final songUrl = songData['songUrl'] as String;
        final imgUrl = songData['imgUrl'] as String;
        final genre = songData['genre'] as String;
        final genres = List<String>.from(songData['genres'] as List);
        
        final songRef = await _firestore
            .collection(FirestoreCollections.songs)
            .add({
          'title': songTitle,
          'artistId': artistId,
          'artistName': artistName,
          'albumId': null,
          'albumName': null,
          'duration': 180, // Default 3 minutes
          'genre': genre,
          'genres': genres,
          'audioUrl': songUrl,
          'artworkUrl': imgUrl,
          'releaseDate': FieldValue.serverTimestamp(),
          'playCount': 0,
          'likeCount': 0,
          'isExplicit': false,
          'trackNumber': null,
          'popularity': 50,
          'tags': [
            songTitle.toLowerCase(),
            artistName.toLowerCase(),
            ...genres.map((g) => g.toLowerCase()),
          ],
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        artistSongIds[artistName]!.add(songRef.id);
        print('  ✅ Song: $songTitle - $artistName');
      }
      
      // Update artists với albumIds và songIds (merge với data hiện có)
      print('📝 Đang update artists...');
      for (var entry in artistNameToId.entries) {
        final artistName = entry.key;
        final artistId = entry.value;
        final newAlbumIds = artistAlbumIds[artistName] ?? [];
        final newSongIds = artistSongIds[artistName] ?? [];
        
        // Lấy songIds hiện tại của artist
        final artistDoc = await _firestore
            .collection(FirestoreCollections.artists)
            .doc(artistId)
            .get();
        
        final currentSongIds = artistDoc.exists 
            ? List<String>.from(artistDoc.data()?['songIds'] ?? [])
            : <String>[];
        
        // Merge songIds: combine current + new (remove duplicates)
        final allSongIds = <String>{...currentSongIds, ...newSongIds}.toList();
        
        await _firestore
            .collection(FirestoreCollections.artists)
            .doc(artistId)
            .update({
          'albumIds': newAlbumIds,
          'songIds': allSongIds,
        });
        
        print('  ✅ Updated artist: $artistName (${newAlbumIds.length} albums mới, ${newSongIds.length} songs mới, tổng ${allSongIds.length} songs)');
      }
      
      print('✅ Hoàn tất seed data mới!');
    } catch (e, stackTrace) {
      print('❌ Lỗi khi seed data mới: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
