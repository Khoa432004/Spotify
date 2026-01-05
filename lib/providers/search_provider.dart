import 'package:flutter/material.dart';
import '../database/database_service.dart';
import '../database/models/song_model.dart';
import '../database/models/album_model.dart';
import '../database/models/artist_model.dart';
import '../database/models/playlist_model.dart';

/// Provider quản lý tìm kiếm và lọc theo thể loại
class SearchProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  // Search state
  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;

  // Search results
  List<SongModel> _songs = [];
  List<AlbumModel> _albums = [];
  List<ArtistModel> _artists = [];
  List<PlaylistModel> _playlists = [];

  // Genre state
  String? _selectedGenre;
  List<String> _availableGenres = [];

  // Recent searches
  final List<Map<String, dynamic>> _recentSearches = [];

  // Getters
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<SongModel> get songs => _songs;
  List<AlbumModel> get albums => _albums;
  List<ArtistModel> get artists => _artists;
  List<PlaylistModel> get playlists => _playlists;
  String? get selectedGenre => _selectedGenre;
  List<String> get availableGenres => _availableGenres;
  List<Map<String, dynamic>> get recentSearches => _recentSearches;

  bool get hasResults =>
      _songs.isNotEmpty ||
      _albums.isNotEmpty ||
      _artists.isNotEmpty ||
      _playlists.isNotEmpty;

  /// Tìm kiếm tất cả
  Future<void> searchAll(String query) async {
    if (query.trim().isEmpty) {
      clearResults();
      return;
    }

    _searchQuery = query;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Tìm kiếm song trước (method đã có sẵn)
      final songsResult = await _databaseService.searchSongs(query, limit: 20);

      // Tìm kiếm các loại khác (sẽ implement trong database service)
      final albumsResult = await _databaseService.searchAlbums(
        query,
        limit: 10,
      );
      final artistsResult = await _databaseService.searchArtists(
        query,
        limit: 10,
      );
      final playlistsResult = await _databaseService.searchPlaylists(
        query,
        limit: 10,
      );

      _songs = songsResult;
      _albums = albumsResult;
      _artists = artistsResult;
      _playlists = playlistsResult;
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('Error searching: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tìm kiếm theo thể loại
  Future<void> searchByGenre(String genre) async {
    _selectedGenre = genre;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔍 Searching for genre: "$genre"');

      // Lấy songs và albums theo genre
      final songsResult = await _databaseService.getSongs(
        genre: genre,
        limit: 50,
      );
      final albumsResult = await _databaseService.getAlbums(
        genre: genre,
        limit: 20,
      );

      print(
        '✅ Found ${songsResult.length} songs and ${albumsResult.length} albums for genre "$genre"',
      );

      _songs = songsResult;
      _albums = albumsResult;
      _artists = [];
      _playlists = [];
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('❌ Error searching by genre "$genre": $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Lấy danh sách thể loại có sẵn
  Future<void> loadAvailableGenres() async {
    try {
      final genres = await _databaseService.getAvailableGenres();
      _availableGenres = genres;
      notifyListeners();
    } catch (e) {
      print('Error loading genres: $e');
    }
  }

  /// Thêm vào lịch sử tìm kiếm
  void addToRecentSearches(Map<String, dynamic> item) {
    // Xóa item cũ nếu đã tồn tại (dựa vào type và id)
    _recentSearches.removeWhere(
      (search) => search['type'] == item['type'] && search['id'] == item['id'],
    );

    // Thêm item mới vào đầu danh sách
    _recentSearches.insert(0, item);

    // Giới hạn 20 items
    if (_recentSearches.length > 20) {
      _recentSearches.removeRange(20, _recentSearches.length);
    }

    notifyListeners();
  }

  /// Xóa khỏi lịch sử tìm kiếm
  void removeFromRecentSearches(int index) {
    if (index >= 0 && index < _recentSearches.length) {
      _recentSearches.removeAt(index);
      notifyListeners();
    }
  }

  /// Xóa toàn bộ lịch sử tìm kiếm
  void clearRecentSearches() {
    _recentSearches.clear();
    notifyListeners();
  }

  /// Xóa kết quả tìm kiếm
  void clearResults() {
    _searchQuery = '';
    _songs = [];
    _albums = [];
    _artists = [];
    _playlists = [];
    _selectedGenre = null;
    _error = null;
    notifyListeners();
  }

  /// Tạo recent search item từ SongModel
  Map<String, dynamic> createRecentSearchFromSong(SongModel song) {
    return {
      'type': 'song',
      'id': song.id,
      'title': song.title,
      'subtitle': 'Song • ${song.artistName}',
      'imageUrl': song.artworkUrl,
    };
  }

  /// Tạo recent search item từ AlbumModel
  Map<String, dynamic> createRecentSearchFromAlbum(AlbumModel album) {
    return {
      'type': 'album',
      'id': album.id,
      'title': album.title,
      'subtitle': 'Album • ${album.artistName}',
      'imageUrl': album.artworkUrl,
    };
  }

  /// Tạo recent search item từ ArtistModel
  Map<String, dynamic> createRecentSearchFromArtist(ArtistModel artist) {
    return {
      'type': 'artist',
      'id': artist.id,
      'title': artist.name,
      'subtitle': 'Artist',
      'imageUrl': artist.imageUrl,
    };
  }

  /// Tạo recent search item từ PlaylistModel
  Map<String, dynamic> createRecentSearchFromPlaylist(PlaylistModel playlist) {
    return {
      'type': 'playlist',
      'id': playlist.id,
      'title': playlist.title,
      'subtitle': 'Playlist',
      'imageUrl': playlist.artworkUrl,
    };
  }
}
