import 'package:flutter/material.dart';
import '../database/database_service.dart';
import '../database/firebase_setup.dart';
import '../database/models/album_model.dart';
import '../database/models/artist_model.dart';
import '../database/models/playlist_model.dart';
import '../database/models/song_model.dart';
import '../database/models/user_model.dart';

class HomeProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<PlaylistModel> _quickAccessPlaylists = [];
  List<AlbumModel> _recentlyPlayedAlbums = [];
  List<AlbumModel> _madeForYouAlbums = [];
  List<SongModel> _songsByArtist = [];
  bool _isLoading = true;
  List<ArtistModel> _madeForYouArtists = [];

  List<PlaylistModel> get quickAccessPlaylists => _quickAccessPlaylists;
  List<AlbumModel> get recentlyPlayedAlbums => _recentlyPlayedAlbums;
  List<AlbumModel> get madeForYouAlbums => _madeForYouAlbums;
  List<SongModel> get songsByArtist => _songsByArtist;
  List<ArtistModel> get madeForYouArtists => _madeForYouArtists;
  bool get isLoading => _isLoading;

  HomeProvider() {
    _initData();
  }

  Future<void> _initData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Fetch Quick Access (Playlists for now, could be mix)
      // Assuming 'system' as owner or just fetching public playlists
      final playlists = await _databaseService.getUserPlaylists('system');
      if (playlists.isEmpty) {
        // Fallback if no system playlists, try fetching some recent created ones
        // This part might need adjustment based on how 'getUserPlaylists' is implemented or we need a new method
        // to fetch public playlists generally.
        // Let's use Seed Data logic logic resemblance: fetch standard playlists
        // Doing a direct query might be needed if getUserPlaylists is strict on ownerId
      }
      // For now, let's assume we want to show some specific playlists or just generic ones.
      // Since DatabaseService doesn't have 'getPublicPlaylists', let's use a workaround or update DatabaseService.
      // But looking at seed data, playlists have ownerId='system'.
      _quickAccessPlaylists = await _databaseService.getUserPlaylists('system');

      // If still empty, maybe fetch any playlists (mocking "Good Afternoon" logic)
      if (_quickAccessPlaylists.isEmpty) {
        // This relies on having a method to get all playlists or specific ones.
        // Let's assume for this task we might need to add `getPublicPlaylists` to DatabaseService
        // OR just trust there are system playlists from seed.
      }

      // Fetch Recently Played
      // Logic: Get albums that were accessed recently. Since we don't have a full robust
      // history in DatabaseService public API yet (model exists but service methods might be limited),
      // we will simulate this by fetching some albums.
      _recentlyPlayedAlbums = await _databaseService.getAlbums(limit: 5);
      print('🏠 Recently played albums: ${_recentlyPlayedAlbums.length}');
      for (var album in _recentlyPlayedAlbums) {
        print('  📀 ${album.title} - artworkUrl: ${album.artworkUrl}');
      }

      // Fetch Made for You
      // Logic: Recommendation engine. For now, fetch random or popular albums
      // We can offset the previous fetch or fetch by different genre
      _madeForYouAlbums = await _databaseService.getAlbums(limit: 5);
      print('🎵 Made for you albums: ${_madeForYouAlbums.length}');
      // In a real app we would filter defaults.

      // Fetch songs for a recommended artist (take artist from first made-for-you album)
      if (_madeForYouAlbums.isNotEmpty) {
        final artistId = _madeForYouAlbums.first.artistId;
        if (artistId != null && artistId.isNotEmpty) {
          _songsByArtist = await _databaseService.getArtistSongs(artistId, limit: 10);
          print('🎤 Songs by artist (${artistId}): ${_songsByArtist.length}');
        }
      }
      // Build a list of recommended artists based on songs collection
      _madeForYouArtists = [];

      // Fetch artist images mapping from `artistsImage` collection (idArtist -> urlImage)
      final Map<String, String> artistImageMap = {};
      try {
        final snap = await FirebaseSetup.firestore.collection('artistsImage').get();
        for (var doc in snap.docs) {
          final data = doc.data();
          final idArtist = (data['idArtist'] as String?)?.trim();
          final url = (data['urlImage'] as String?);
          if (idArtist != null && idArtist.isNotEmpty && url != null && url.isNotEmpty) {
            artistImageMap[idArtist] = url;
          }
        }
        print('📸 Loaded artistsImage entries (by id): ${artistImageMap.length}');
        if (artistImageMap.isNotEmpty) {
          final sample = artistImageMap.entries.take(8).map((e) => '${e.key}=>${e.value}').join(', ');
          print('📸 artistsImage sample (id=>url): $sample');
        }
      } catch (e) {
        // ignore if collection missing
      }

      // Fetch a larger sample of songs and group them by artistName/artistId
      final songsSample = await _databaseService.getSongs(limit: 200);
      final Map<String, List<SongModel>> groups = {};

      for (var song in songsSample) {
        final key = (song.artistId != null && song.artistId!.isNotEmpty)
            ? song.artistId!
            : (song.artistName?.trim().isNotEmpty == true ? song.artistName!.trim() : null);

        if (key == null) continue;

        groups.putIfAbsent(key, () => []).add(song);
      }

      for (var entry in groups.entries) {
        final key = entry.key;
        final songs = entry.value;

        if (songs.length > 1) {
          print('🎶 Group: $key -> ${songs.length} songs (example: ${songs.first.title})');
        }

        // Try to fetch an artist document when key looks like an ID (we can't reliably know,
        // but attempting will succeed when artist doc exists).
        ArtistModel? artistDoc;
        try {
          artistDoc = await _databaseService.getArtist(key);
        } catch (_) {
          artistDoc = null;
        }

        if (artistDoc != null) {
          // If artist doc missing image, try to fill from artistsImage map by name
          if ((artistDoc.imageUrl == null || artistDoc.imageUrl!.isEmpty) &&
              artistImageMap.containsKey(artistDoc.id)) {
            final usedUrl = artistImageMap[artistDoc.id];
            artistDoc = artistDoc.copyWith(imageUrl: usedUrl);
            print('🖼️ Using artistsImage (by id) for artist "${artistDoc.name}" (id=${artistDoc.id}): $usedUrl');
          }
          _madeForYouArtists.add(artistDoc);
        } else {
          // Create fallback using song metadata (artistName from first song)
          final first = songs.first;
          final artistName = first.artistName ?? 'Unknown Artist';
          // Prefer artworkUrl from song, else try artistsImage map by name
          String? imageUrl = first.artworkUrl;
          // If song carries artistId and artistsImage has mapping by id, prefer that
          if ((imageUrl == null || imageUrl.isEmpty) && first.artistId != null && first.artistId!.isNotEmpty && artistImageMap.containsKey(first.artistId)) {
            imageUrl = artistImageMap[first.artistId!];
            print('🖼️ Using artistsImage (by id) for fallback artist "$artistName" (id=${first.artistId}): $imageUrl');
          }

          final fallback = ArtistModel(
            id: key,
            name: artistName,
            imageUrl: imageUrl,
            bio: null,
            genres: [],
            monthlyListeners: 0,
            followerCount: 0,
            albumIds: [],
            songIds: songs.map((s) => s.id).toList(),
            verified: false,
            createdAt: DateTime.now(),
          );
          _madeForYouArtists.add(fallback);
        }
      }

      print('👩‍🎤 Made for you artists (from songs): ${_madeForYouArtists.length}');
      // Detailed debug: list artists with image urls
      for (var a in _madeForYouArtists) {
        print('👩‍🎤 Artist entry -> id: ${a.id}, name: ${a.name}, imageUrl: ${a.imageUrl}');
      }
    } catch (e) {
      print("Error loading home data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await _initData();
  }
}
