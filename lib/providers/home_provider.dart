import 'package:flutter/material.dart';
import '../database/database_service.dart';
import '../database/models/album_model.dart';
import '../database/models/playlist_model.dart';
import '../database/models/song_model.dart';
import '../database/models/user_model.dart';

class HomeProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<PlaylistModel> _quickAccessPlaylists = [];
  List<AlbumModel> _recentlyPlayedAlbums = [];
  List<AlbumModel> _madeForYouAlbums = [];
  bool _isLoading = true;

  List<PlaylistModel> get quickAccessPlaylists => _quickAccessPlaylists;
  List<AlbumModel> get recentlyPlayedAlbums => _recentlyPlayedAlbums;
  List<AlbumModel> get madeForYouAlbums => _madeForYouAlbums;
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
