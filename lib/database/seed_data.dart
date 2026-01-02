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
}
