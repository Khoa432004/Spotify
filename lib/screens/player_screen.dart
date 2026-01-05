import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_player_provider.dart';
import '../services/music_player_service.dart';
import '../database/models/song_model.dart';
import '../services/favorite_service.dart';

/// Màn hình Player - Phát nhạc với controls (theo Figma design)
class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  bool _isLiked = false;
  String? _lastSongId;

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicPlayerProvider>(
      builder: (context, player, child) {
        final song = player.currentSong;

        // Nếu không có bài hát nào đang phát, hiển thị empty state
        if (song == null) {
          return Scaffold(
            backgroundColor: const Color(0xFF121212),
            body: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.music_off,
                      color: Colors.grey,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Chưa có bài hát nào đang phát',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Quay lại'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final duration = player.duration ?? Duration.zero;
        final position = player.position;
        final progress = duration.inMilliseconds > 0
            ? position.inMilliseconds / duration.inMilliseconds
            : 0.0;

        return Scaffold(
          backgroundColor: const Color(0xFF121212),
          body: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(40),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Header
                    _buildHeader(song.albumName ?? 'Now Playing'),
                    const SizedBox(height: 50),
                    // Album artwork
                    _buildArtwork(song.artworkUrl),
                    const SizedBox(height: 32),
                                _buildSongInfo(song.title, song.artistName, song),
                    const SizedBox(height: 24),
                    // Timeline
                    _buildTimeline(position, duration, progress, player),
                    const SizedBox(height: 24),
                    // Controls
                    _buildControls(player),
                    const Spacer(),
                    // Bottom controls
                    _buildBottomControls(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(String albumName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back button (down arrow)
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.white,
            size: 28,
          ),
        ),
        // Album/Playlist name
        Text(
          albumName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        // More icon
        const Icon(
          Icons.more_horiz,
          color: Colors.white,
          size: 24,
        ),
      ],
    );
  }

  Widget _buildArtwork(String? artworkUrl) {
    return Container(
      width: 320,
      height: 320,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: artworkUrl != null
            ? Image.network(
                artworkUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[800],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        color: const Color(0xFF1DB954),
                        strokeWidth: 2,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[800],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.music_note,
                          size: 80,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No Image',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )
            : Container(
                color: Colors.grey[800],
                child: const Icon(
                  Icons.music_note,
                  size: 80,
                  color: Colors.grey,
                ),
              ),
      ),
    );
  }

  Widget _buildSongInfo(String title, String artistName, SongModel song) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.99,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                artistName,
                style: const TextStyle(
                  color: Color(0xFFBBBBBA),
                  fontSize: 15,
                  letterSpacing: -0.675,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // Like button
        GestureDetector(
          onTap: () async {
            final songId = song.id;
            setState(() {
              _isLiked = !_isLiked;
            });
            try {
              if (_isLiked) {
                await FavoriteService.addFavorite(song);
              } else {
                await FavoriteService.removeFavorite(songId);
              }
            } catch (e) {
              // Revert on error
              setState(() {
                _isLiked = !_isLiked;
              });
            }
          },
          child: Icon(
            _isLiked ? Icons.favorite : Icons.favorite_border,
            color: _isLiked ? const Color(0xFF57B560) : const Color(0xFFBFBFBF),
            size: 24,
          ),
        ),
      ],
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ensure like state follows currentSong
    final player = Provider.of<MusicPlayerProvider>(context, listen: false);
    final song = player.currentSong;
    if (song != null && song.id != _lastSongId) {
      _lastSongId = song.id;
      _loadIsLiked(song.id);
    }
  }

  Future<void> _loadIsLiked(String songId) async {
    try {
      final fav = await FavoriteService.isFavorite(songId);
      if (mounted) setState(() => _isLiked = fav);
    } catch (e) {
      // ignore
    }
  }

  Widget _buildTimeline(
    Duration position,
    Duration duration,
    double progress,
    MusicPlayerProvider player,
  ) {
    return Column(
      children: [
        // Progress bar with slider
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.white,
            inactiveTrackColor: Colors.grey[700],
            thumbColor: Colors.white,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            trackHeight: 4,
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
          ),
          child: Slider(
            value: progress.clamp(0.0, 1.0),
            onChanged: (value) {
              final newPosition = Duration(
                milliseconds: (duration.inMilliseconds * value).round(),
              );
              player.seek(newPosition);
            },
          ),
        ),
        // Time labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(position),
                style: const TextStyle(
                  color: Color(0xFFBABABA),
                  fontSize: 11,
                ),
              ),
              Text(
                '-${_formatDuration(duration - position)}',
                style: const TextStyle(
                  color: Color(0xFFBABABA),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControls(MusicPlayerProvider player) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Shuffle button
        _buildShuffleButton(player),
        // Previous button
        GestureDetector(
          onTap: () => player.previousSong(),
          child: const Icon(
            Icons.skip_previous,
            color: Colors.white,
            size: 35,
          ),
        ),
        // Play/Pause button
        GestureDetector(
          onTap: () => player.togglePlayPause(),
          child: Container(
            width: 63,
            height: 63,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              player.isPlaying ? Icons.pause : Icons.play_arrow,
              color: const Color(0xFF181718),
              size: 32,
            ),
          ),
        ),
        // Next button
        GestureDetector(
          onTap: () => player.nextSong(),
          child: const Icon(
            Icons.skip_next,
            color: Colors.white,
            size: 35,
          ),
        ),
        // Repeat button
        _buildRepeatButton(player),
      ],
    );
  }

  Widget _buildShuffleButton(MusicPlayerProvider player) {
    final isActive = player.shuffleMode;
    return GestureDetector(
      onTap: () => player.toggleShuffle(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shuffle,
            color: isActive ? const Color(0xFF57B560) : const Color(0xFFBABABA),
            size: 20,
          ),
          const SizedBox(height: 4),
          if (isActive)
            Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: Color(0xFF57B560),
                shape: BoxShape.circle,
              ),
            )
          else
            const SizedBox(height: 5),
        ],
      ),
    );
  }

  Widget _buildRepeatButton(MusicPlayerProvider player) {
    final isActive = player.repeatMode != RepeatMode.none;
    return GestureDetector(
      onTap: () => player.toggleRepeat(),
      child: Icon(
        player.repeatMode == RepeatMode.one ? Icons.repeat_one : Icons.repeat,
        color: isActive ? const Color(0xFF57B560) : const Color(0xFFBABABA),
        size: 22,
      ),
    );
  }

  Widget _buildBottomControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Devices icon
        GestureDetector(
          onTap: () {},
          child: const Icon(
            Icons.devices,
            color: Colors.white,
            size: 20,
          ),
        ),
        // Queue icon
        GestureDetector(
          onTap: () {},
          child: const Icon(
            Icons.queue_music,
            color: Colors.white,
            size: 20,
          ),
        ),
      ],
    );
  }
}
