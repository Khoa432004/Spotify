import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/firebase_setup.dart';
import '../database/models/artist_model.dart';
import '../database/models/song_model.dart';
import '../providers/music_player_provider.dart';

class ArtistSongsScreen extends StatefulWidget {
  final ArtistModel artist;

  const ArtistSongsScreen({required this.artist, super.key});

  @override
  State<ArtistSongsScreen> createState() => _ArtistSongsScreenState();
}

class _ArtistSongsScreenState extends State<ArtistSongsScreen> {
  late Future<List<SongModel>> _songsFuture;

  @override
  void initState() {
    super.initState();
    _songsFuture = _loadSongsForArtist();
  }

  Future<List<SongModel>> _loadSongsForArtist() async {
    // First try to get by artistId (works when artist doc exists or songs have artistId)
    try {
      final byId = await FirebaseSetup.databaseService.getArtistSongs(widget.artist.id, limit: 500);
      if (byId.isNotEmpty) return byId;
    } catch (_) {}

    // Fallback: fetch a larger sample and filter by artistName
    try {
      final all = await FirebaseSetup.databaseService.getSongs(limit: 500);
      final filtered = all.where((s) => (s.artistName ?? '').trim() == widget.artist.name.trim()).toList();
      return filtered;
    } catch (e) {
      print('Error loading songs for artist fallback: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        title: Text(widget.artist.name),
      ),
      backgroundColor: const Color(0xFF121212),
      body: FutureBuilder<List<SongModel>>(
        future: _songsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }
          final songs = snapshot.data ?? [];
          if (songs.isEmpty) {
            return const Center(child: Text('Không có bài hát nào', style: TextStyle(color: Colors.white)));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: songs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final song = songs[index];
              return _buildSongTile(context, song, index, songs);
            },
          );
        },
      ),
    );
  }

  Widget _buildSongTile(BuildContext context, SongModel song, int index, List<SongModel> queue) {
    return Consumer<MusicPlayerProvider>(builder: (context, player, _) {
      final isCurrent = player.currentSong?.id == song.id;
      final isPlaying = isCurrent && player.isPlaying;

      return Container(
        decoration: BoxDecoration(
          color: isCurrent ? const Color(0xFF1DB954).withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          onTap: () async {
            await player.playSong(song, queue: queue, initialIndex: index);
          },
          leading: song.artworkUrl != null
              ? ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.network(song.artworkUrl!, width: 48, height: 48, fit: BoxFit.cover))
              : Container(width: 48, height: 48, color: Colors.grey[800], child: const Icon(Icons.music_note, color: Colors.white38)),
          title: Text(song.title, style: const TextStyle(color: Colors.white)),
          subtitle: Text(song.albumName ?? '', style: const TextStyle(color: Colors.grey)),
          trailing: IconButton(
            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white70),
            onPressed: () async {
              if (isCurrent) {
                await player.togglePlayPause();
              } else {
                await player.playSong(song, queue: queue, initialIndex: index);
              }
            },
          ),
        ),
      );
    });
  }
}
