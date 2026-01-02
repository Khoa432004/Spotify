# Hướng dẫn Upload MP3 Files cho Podcast Episodes

## Tổng quan

Podcast episodes cần audio URLs để phát. Có 2 cách:
1. **Upload MP3 files lên Firebase Storage** (Khuyến nghị)
2. Dùng sample URLs từ internet (có thể bị 404)

## Cách 1: Upload MP3 lên Firebase Storage

### Bước 1: Chuẩn bị MP3 files

1. Tạo thư mục `assets/podcasts/` trong project (hoặc bất kỳ đâu)
2. Đặt các file MP3 vào thư mục đó:
   ```
   assets/podcasts/
   ├── episode1.mp3
   ├── episode2.mp3
   └── episode3.mp3
   ```

### Bước 2: Upload qua Firebase Console (Dễ nhất)

1. Mở Firebase Console: https://console.firebase.google.com/
2. Chọn project: `spotify-78b1f`
3. Vào **Storage**
4. Tạo folder `podcasts` (nếu chưa có)
5. Upload các file MP3 vào folder `podcasts`
6. Sau khi upload, click vào từng file → Copy **Download URL**

### Bước 3: Cập nhật URLs trong code

Mở `lib/database/seed_data.dart` và cập nhật `_sampleAudioUrls`:

```dart
static final List<String> _sampleAudioUrls = [
  'https://firebasestorage.googleapis.com/v0/b/spotify-78b1f.firebasestorage.app/o/podcasts%2Fepisode1.mp3?alt=media&token=...',
  'https://firebasestorage.googleapis.com/v0/b/spotify-78b1f.firebasestorage.app/o/podcasts%2Fepisode2.mp3?alt=media&token=...',
  'https://firebasestorage.googleapis.com/v0/b/spotify-78b1f.firebasestorage.app/o/podcasts%2Fepisode3.mp3?alt=media&token=...',
];
```

### Bước 4: Seed lại podcasts

1. Chạy app
2. Vào FirebaseTestScreen
3. Click "Seed Concerts & Podcasts Only"
4. Podcast episodes sẽ có audio URLs từ Firebase Storage

## Cách 2: Upload qua Code (Nâng cao)

### Sử dụng script upload

```dart
import 'database/upload_podcast_audio.dart';

// Upload một file
final url = await uploadPodcastAudio(
  'assets/podcasts/episode1.mp3',
  'episode1.mp3'
);

// Upload nhiều files
final urls = await uploadMultiplePodcastAudios({
  'episode1.mp3': 'assets/podcasts/episode1.mp3',
  'episode2.mp3': 'assets/podcasts/episode2.mp3',
  'episode3.mp3': 'assets/podcasts/episode3.mp3',
});
```

### Thêm button upload trong FirebaseTestScreen

Có thể thêm button trong `firebase_test_screen.dart`:

```dart
ElevatedButton(
  onPressed: () async {
    final urls = await uploadMultiplePodcastAudios({
      'episode1.mp3': 'assets/podcasts/episode1.mp3',
      'episode2.mp3': 'assets/podcasts/episode2.mp3',
    });
    print('Uploaded URLs: $urls');
  },
  child: Text('Upload Podcast MP3s'),
)
```

## Cách 3: Dùng Local MP3 Files (Test trên Device)

Nếu test trên device và có MP3 files local:

1. Đặt files trong `assets/` folder
2. Thêm vào `pubspec.yaml`:
   ```yaml
   flutter:
     assets:
       - assets/podcasts/
   ```
3. Load file và convert sang URL:
   ```dart
   import 'package:flutter/services.dart';
   
   Future<String> getLocalAudioUrl(String assetPath) async {
     final byteData = await rootBundle.load(assetPath);
     // Convert to file và upload, hoặc dùng asset URL
     return 'asset:///$assetPath';
   }
   ```

**Lưu ý:** `just_audio` package có thể không hỗ trợ `asset://` URLs trực tiếp. Nên upload lên Firebase Storage hoặc dùng HTTP URLs.

## Kiểm tra Audio URLs

Sau khi có URLs, test trong browser:
1. Copy URL
2. Paste vào browser
3. Nếu file download được → URL hợp lệ
4. Nếu 404 → URL không hợp lệ

## Troubleshooting

### Lỗi: "Audio file not found (404)"
- Kiểm tra URL có đúng không
- Kiểm tra file có tồn tại trong Firebase Storage không
- Kiểm tra Storage Rules có cho phép read không

### Lỗi: "Permission denied"
- Kiểm tra Firebase Storage Rules
- Đảm bảo rules cho phép read:
  ```javascript
  match /podcasts/{allPaths=**} {
    allow read: if true; // Public read
  }
  ```

### File quá lớn
- Firebase Storage free tier: 5GB
- Nếu file > 100MB, có thể cần compress hoặc dùng CDN khác

## Recommended File Sizes

- **Podcast Episode (30-60 min)**: 20-50 MB
- **Podcast Episode (1-2 hours)**: 50-100 MB
- Format: MP3, bitrate 128kbps hoặc 192kbps

## Quick Start

1. **Upload 3 MP3 files** lên Firebase Storage → folder `podcasts`
2. **Copy Download URLs** từ Firebase Console
3. **Cập nhật** `_sampleAudioUrls` trong `seed_data.dart`
4. **Seed lại** podcasts từ FirebaseTestScreen
5. **Test** phát podcast trong app

## Example URLs Format

```
https://firebasestorage.googleapis.com/v0/b/spotify-78b1f.firebasestorage.app/o/podcasts%2Fepisode1.mp3?alt=media&token=abc123...
```

Sau khi upload, URLs sẽ có format tương tự.

