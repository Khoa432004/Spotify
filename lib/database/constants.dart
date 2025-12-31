/// Constants cho Firestore Collections và Fields
class FirestoreCollections {
  static const String users = 'users';
  static const String songs = 'songs';
  static const String albums = 'albums';
  static const String artists = 'artists';
  static const String playlists = 'playlists';
  static const String userLikes = 'userLikes';
  static const String userPlayback = 'userPlayback';
  static const String userDownloads = 'userDownloads';
  static const String concerts = 'concerts';
  static const String notifications = 'notifications';
  static const String podcasts = 'podcasts';
  static const String podcastEpisodes = 'podcastEpisodes';
  static const String genres = 'genres';
  static const String homeContent = 'homeContent';
  static const String searchHistory = 'searchHistory';
}

/// Constants cho Storage paths
class StoragePaths {
  static const String audioSongs = 'audio/songs';
  static const String audioPodcasts = 'audio/podcasts';
  static const String imagesArtworks = 'images/artworks';
  static const String imagesAlbums = 'images/artworks/albums';
  static const String imagesSongs = 'images/artworks/songs';
  static const String imagesArtists = 'images/artists';
  static const String imagesPlaylists = 'images/playlists';
  static const String imagesPodcasts = 'images/podcasts';
  static const String imagesConcerts = 'images/concerts';
  static const String downloads = 'downloads';
}

/// Constants cho User fields
class UserFields {
  static const String email = 'email';
  static const String displayName = 'displayName';
  static const String photoURL = 'photoURL';
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';
  static const String preferences = 'preferences';
  static const String subscription = 'subscription';
  static const String stats = 'stats';
}

/// Constants cho Song fields
class SongFields {
  static const String title = 'title';
  static const String artistId = 'artistId';
  static const String artistName = 'artistName';
  static const String albumId = 'albumId';
  static const String albumName = 'albumName';
  static const String duration = 'duration';
  static const String genre = 'genre';
  static const String genres = 'genres';
  static const String audioUrl = 'audioUrl';
  static const String artworkUrl = 'artworkUrl';
  static const String releaseDate = 'releaseDate';
  static const String playCount = 'playCount';
  static const String likeCount = 'likeCount';
  static const String createdAt = 'createdAt';
  static const String isExplicit = 'isExplicit';
  static const String trackNumber = 'trackNumber';
  static const String popularity = 'popularity';
  static const String tags = 'tags';
}

/// Constants cho Album fields
class AlbumFields {
  static const String title = 'title';
  static const String artistId = 'artistId';
  static const String artistName = 'artistName';
  static const String artworkUrl = 'artworkUrl';
  static const String releaseDate = 'releaseDate';
  static const String genre = 'genre';
  static const String genres = 'genres';
  static const String totalTracks = 'totalTracks';
  static const String duration = 'duration';
  static const String songIds = 'songIds';
  static const String playCount = 'playCount';
  static const String likeCount = 'likeCount';
  static const String createdAt = 'createdAt';
  static const String description = 'description';
}

/// Constants cho Artist fields
class ArtistFields {
  static const String name = 'name';
  static const String imageUrl = 'imageUrl';
  static const String bio = 'bio';
  static const String genres = 'genres';
  static const String monthlyListeners = 'monthlyListeners';
  static const String followerCount = 'followerCount';
  static const String albumIds = 'albumIds';
  static const String songIds = 'songIds';
  static const String verified = 'verified';
  static const String createdAt = 'createdAt';
  static const String socialLinks = 'socialLinks';
}

/// Constants cho Playlist fields
class PlaylistFields {
  static const String title = 'title';
  static const String description = 'description';
  static const String ownerId = 'ownerId';
  static const String isPublic = 'isPublic';
  static const String artworkUrl = 'artworkUrl';
  static const String songIds = 'songIds';
  static const String followerCount = 'followerCount';
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';
  static const String genre = 'genre';
  static const String tags = 'tags';
}

/// Constants cho Concert fields
class ConcertFields {
  static const String title = 'title';
  static const String artistId = 'artistId';
  static const String artistName = 'artistName';
  static const String venue = 'venue';
  static const String dateTime = 'dateTime';
  static const String imageUrl = 'imageUrl';
  static const String ticketUrl = 'ticketUrl';
  static const String price = 'price';
  static const String status = 'status';
  static const String capacity = 'capacity';
  static const String attendees = 'attendees';
  static const String createdAt = 'createdAt';
}

/// Constants cho Notification fields
class NotificationFields {
  static const String userId = 'userId';
  static const String type = 'type';
  static const String title = 'title';
  static const String message = 'message';
  static const String imageUrl = 'imageUrl';
  static const String actionUrl = 'actionUrl';
  static const String read = 'read';
  static const String createdAt = 'createdAt';
  static const String scheduledFor = 'scheduledFor';
  static const String data = 'data';
}

/// Constants cho Podcast fields
class PodcastFields {
  static const String title = 'title';
  static const String description = 'description';
  static const String hostId = 'hostId';
  static const String hostName = 'hostName';
  static const String imageUrl = 'imageUrl';
  static const String category = 'category';
  static const String categories = 'categories';
  static const String episodeIds = 'episodeIds';
  static const String followerCount = 'followerCount';
  static const String totalEpisodes = 'totalEpisodes';
  static const String createdAt = 'createdAt';
  static const String tags = 'tags';
}

/// Constants cho Podcast Episode fields
class PodcastEpisodeFields {
  static const String podcastId = 'podcastId';
  static const String title = 'title';
  static const String description = 'description';
  static const String episodeNumber = 'episodeNumber';
  static const String duration = 'duration';
  static const String audioUrl = 'audioUrl';
  static const String artworkUrl = 'artworkUrl';
  static const String releaseDate = 'releaseDate';
  static const String playCount = 'playCount';
  static const String likeCount = 'likeCount';
  static const String isExplicit = 'isExplicit';
  static const String createdAt = 'createdAt';
}

/// Constants cho Genre fields
class GenreFields {
  static const String name = 'name';
  static const String displayName = 'displayName';
  static const String imageUrl = 'imageUrl';
  static const String color = 'color';
  static const String songIds = 'songIds';
  static const String albumIds = 'albumIds';
  static const String artistIds = 'artistIds';
  static const String playlistIds = 'playlistIds';
  static const String createdAt = 'createdAt';
}

/// Notification types
enum NotificationType {
  concertReminder,
  newRelease,
  artistUpdate,
  playlistUpdate,
}

extension NotificationTypeExtension on NotificationType {
  String get value {
    switch (this) {
      case NotificationType.concertReminder:
        return 'concert_reminder';
      case NotificationType.newRelease:
        return 'new_release';
      case NotificationType.artistUpdate:
        return 'artist_update';
      case NotificationType.playlistUpdate:
        return 'playlist_update';
    }
  }

  static NotificationType fromString(String value) {
    switch (value) {
      case 'concert_reminder':
        return NotificationType.concertReminder;
      case 'new_release':
        return NotificationType.newRelease;
      case 'artist_update':
        return NotificationType.artistUpdate;
      case 'playlist_update':
        return NotificationType.playlistUpdate;
      default:
        return NotificationType.newRelease;
    }
  }
}

/// Concert status
enum ConcertStatus {
  upcoming,
  ongoing,
  completed,
  cancelled,
}

extension ConcertStatusExtension on ConcertStatus {
  String get value {
    switch (this) {
      case ConcertStatus.upcoming:
        return 'upcoming';
      case ConcertStatus.ongoing:
        return 'ongoing';
      case ConcertStatus.completed:
        return 'completed';
      case ConcertStatus.cancelled:
        return 'cancelled';
    }
  }

  static ConcertStatus fromString(String value) {
    switch (value) {
      case 'upcoming':
        return ConcertStatus.upcoming;
      case 'ongoing':
        return ConcertStatus.ongoing;
      case 'completed':
        return ConcertStatus.completed;
      case 'cancelled':
        return ConcertStatus.cancelled;
      default:
        return ConcertStatus.upcoming;
    }
  }
}

/// Repeat mode for playback
enum RepeatMode {
  none,
  one,
  all,
}

extension RepeatModeExtension on RepeatMode {
  String get value {
    switch (this) {
      case RepeatMode.none:
        return 'none';
      case RepeatMode.one:
        return 'one';
      case RepeatMode.all:
        return 'all';
    }
  }

  static RepeatMode fromString(String value) {
    switch (value) {
      case 'none':
        return RepeatMode.none;
      case 'one':
        return RepeatMode.one;
      case 'all':
        return RepeatMode.all;
      default:
        return RepeatMode.none;
    }
  }
}

/// Subscription types
enum SubscriptionType {
  free,
  premium,
}

extension SubscriptionTypeExtension on SubscriptionType {
  String get value {
    switch (this) {
      case SubscriptionType.free:
        return 'free';
      case SubscriptionType.premium:
        return 'premium';
    }
  }

  static SubscriptionType fromString(String value) {
    switch (value) {
      case 'free':
        return SubscriptionType.free;
      case 'premium':
        return SubscriptionType.premium;
      default:
        return SubscriptionType.free;
    }
  }
}

