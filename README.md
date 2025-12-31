# Spotify Clone App

Flutter application - Spotify music streaming clone với Firebase backend.

## Tính năng

- ✅ Login/Logout
- ✅ Load nhạc lên trang chủ
- ✅ Tìm kiếm, phân loại theo thể loại
- ✅ List các album → các bài nhạc trong album
- ✅ Nhạc yêu thích
- ✅ List các nghệ sĩ → các bài nhạc theo nghệ sĩ
- ✅ Nghe nhạc, nghe theo thứ tự random
- ✅ Tải nhạc về
- ✅ Hiển thị các concert, thông báo các buổi diễn sắp tới
- ✅ Podcast, chia nhiều tập và phát
- ✅ Popup để nghe nhạc dưới thao tác các chức năng khác

## Tech Stack

- **Framework**: Flutter 3.9.2+
- **Backend**: Firebase
  - Firestore Database
  - Firebase Storage
  - Firebase Authentication
- **State Management**: (TBD)

## Cấu trúc Project

```
lib/
├── main.dart                    # Entry point, Firebase initialization
├── firebase_options.dart        # Firebase config (auto-generated)
├── database/                    # Firebase database layer
│   ├── firebase_setup.dart     # Firebase initialization
│   ├── database_service.dart    # Database operations
│   ├── constants.dart           # Firestore collections & fields
│   ├── seed_data.dart           # Dummy data seeder
│   ├── models/                  # Data models
│   └── README.md                # Database documentation
├── screens/                     # App screens
│   ├── home_screen.dart
│   ├── search_screen.dart
│   ├── library_screen.dart
│   ├── player_screen.dart
│   └── firebase_test_screen.dart
└── widgets/                     # Reusable widgets
```

## Setup

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Firebase Setup

Firebase đã được cấu hình:
- Project ID: `spotify-78b1f`
- Firestore Database: `asia-southeast1`
- Storage: `asia-southeast1`
- Security Rules: Đã deploy
- Indexes: Đã deploy

### 3. Run App

```bash
flutter run
```

## Firebase Configuration

### Security Rules

- **Firestore**: Public read cho songs, albums, artists, concerts, podcasts
- **Storage**: Public read cho images (artwork)
- **Write permissions**: Tạm thời mở cho development (cần update cho production)

### Seed Data

Để thêm dummy data vào Firestore, sử dụng script `lib/database/seed_data.dart`:

```dart
import 'package:spotify_app/database/seed_data.dart';
import 'package:spotify_app/database/firebase_setup.dart';

// Sau khi Firebase đã initialize
final seedData = SeedData();
await seedData.seedAll();
```

## Database Structure

Xem chi tiết trong `lib/database/README.md`

## Development Notes

- Firebase rules hiện cho phép write không cần auth (development mode)
- Cần update rules trước khi deploy production
- Test screens có sẵn để kiểm tra Firebase connection

## License

Private project
