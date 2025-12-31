/// Main export file cho database package
/// 
/// Import tất cả các components cần thiết từ một nơi duy nhất
/// 
/// Usage:
/// ```dart
/// import 'package:spotify_app/database/database.dart';
/// ```
library database;

// Constants
export 'constants.dart';

// Setup
export 'firebase_setup.dart';

// Service
export 'database_service.dart';

// Models
export 'models/user_model.dart';
export 'models/song_model.dart';
export 'models/album_model.dart';
export 'models/artist_model.dart';
export 'models/playlist_model.dart';
export 'models/concert_model.dart';
export 'models/podcast_model.dart';
export 'models/user_likes_model.dart';
export 'models/user_playback_model.dart';
export 'models/user_downloads_model.dart';

