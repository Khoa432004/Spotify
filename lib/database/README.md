# Firebase Database Setup

Thư mục này chứa tất cả các file liên quan đến Firebase Database setup cho Spotify Clone app.

## Cấu trúc thư mục

```
lib/database/
├── constants.dart              # Constants cho collections và fields
├── firebase_setup.dart         # Firebase initialization
├── database_service.dart       # Service class cho database operations
├── models/                     # Data models
│   ├── user_model.dart
│   ├── song_model.dart
│   ├── album_model.dart
│   ├── artist_model.dart
│   ├── playlist_model.dart
│   ├── concert_model.dart
│   ├── podcast_model.dart
│   ├── user_likes_model.dart
│   ├── user_playback_model.dart
│   └── user_downloads_model.dart
└── README.md                   # File này
```

## Cài đặt

### 1. Thêm Firebase dependencies

Đã được thêm vào `pubspec.yaml`:
- `firebase_core: ^3.6.0`
- `firebase_auth: ^5.3.1`
- `cloud_firestore: ^5.4.4`
- `firebase_storage: ^12.3.4`

### 2. Setup Firebase project

1. Tạo Firebase project tại [Firebase Console](https://console.firebase.google.com/)
2. Thêm Android/iOS app vào project
3. Download `google-services.json` (Android) và `GoogleService-Info.plist` (iOS)
4. Đặt các file này vào đúng thư mục:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`

### 3. Initialize Firebase trong app

Trong `main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'database/firebase_setup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseSetup.initialize();
  runApp(MyApp());
}
```

## Sử dụng

### Database Service

```dart
import 'database/firebase_setup.dart';
import 'database/database_service.dart';

// Lấy instance
final dbService = FirebaseSetup.databaseService;

// Lấy songs
final songs = await dbService.getSongs(genre: 'Pop', limit: 20);

// Lấy album
final album = await dbService.getAlbum('albumId');

// Lấy songs trong album
final albumSongs = await dbService.getAlbumSongs('albumId');

// Tìm kiếm
final searchResults = await dbService.searchSongs('query');

// User likes
await dbService.toggleLikeSong(userId, songId, true);
final likedSongs = await dbService.getLikedSongs(userId);
```

### Models

Tất cả models đều có:
- `fromFirestore()`: Convert từ Firestore document
- `toFirestore()`: Convert sang Firestore format
- `copyWith()`: Tạo bản copy với các field được update

Ví dụ:

```dart
// Từ Firestore
final doc = await FirebaseFirestore.instance
    .collection('songs')
    .doc('songId')
    .get();
final song = SongModel.fromFirestore(doc);

// To Firestore
await FirebaseFirestore.instance
    .collection('songs')
    .doc('songId')
    .set(song.toFirestore());
```

### Constants

Sử dụng constants để tránh hardcode strings:

```dart
import 'database/constants.dart';

FirestoreCollections.songs
FirestoreCollections.albums
StoragePaths.audioSongs
SongFields.title
```

## Firestore Security Rules

Đã được cung cấp trong file `firestore.rules` (cần tạo trong Firebase Console).

## Storage Security Rules

Đã được cung cấp trong file `storage.rules` (cần tạo trong Firebase Console).

## Indexes cần tạo

Trong Firestore Console, tạo các composite indexes sau:

1. `songs`: `genre` (ascending), `popularity` (descending)
2. `songs`: `artistId` (ascending), `releaseDate` (descending)
3. `albums`: `artistId` (ascending), `releaseDate` (descending)
4. `concerts`: `dateTime` (ascending), `status` (ascending)
5. `notifications`: `userId` (ascending), `createdAt` (descending)
6. `podcastEpisodes`: `podcastId` (ascending), `releaseDate` (descending)

## Lưu ý

- Tất cả các operations đều có error handling
- Sử dụng Streams cho real-time updates
- Models sử dụng denormalization để tối ưu performance
- Timestamps được convert tự động giữa Firestore và Dart DateTime

