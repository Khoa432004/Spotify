import 'package:firebase_storage/firebase_storage.dart';
import 'firebase_setup.dart';
import 'dart:io';

/// Script để upload MP3 files lên Firebase Storage cho podcast episodes
/// 
/// Cách sử dụng:
/// 1. Đặt MP3 files trong thư mục `assets/podcasts/` hoặc chỉ định đường dẫn
/// 2. Gọi hàm uploadPodcastAudio() với đường dẫn file
/// 
/// Example:
/// ```dart
/// import 'database/upload_podcast_audio.dart';
/// await uploadPodcastAudio('assets/podcasts/episode1.mp3', 'episode1.mp3');
/// ```
Future<String> uploadPodcastAudio(String filePath, String fileName) async {
  try {
    print('📤 Đang upload podcast audio: $fileName');
    
    final storage = FirebaseSetup.storage;
    
    // Upload lên Firebase Storage
    // Note: putFile() chỉ hoạt động trên mobile/desktop, không phải web
    final ref = storage.ref().child('podcasts/$fileName');
    
    // Kiểm tra file có tồn tại không (chỉ trên mobile/desktop)
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File không tồn tại: $filePath');
      }
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      print('✅ Upload thành công: $fileName');
      print('🔗 Download URL: $downloadUrl');
      
      return downloadUrl;
    } catch (e) {
      // Nếu không phải File (có thể đang chạy trên web), hướng dẫn upload qua Console
      print('⚠️ Không thể upload file trực tiếp: $e');
      print('💡 Vui lòng upload file qua Firebase Console:');
      print('   1. Mở Firebase Console → Storage');
      print('   2. Tạo folder "podcasts"');
      print('   3. Upload file: $fileName');
      print('   4. Copy Download URL và cập nhật vào seed_data.dart');
      rethrow;
    }
    
  } catch (e) {
    print('❌ Lỗi upload podcast audio: $e');
    rethrow;
  }
}

/// Upload nhiều podcast audio files
Future<Map<String, String>> uploadMultiplePodcastAudios(
  Map<String, String> files, // {fileName: filePath}
) async {
  final urls = <String, String>{};
  
  for (var entry in files.entries) {
    try {
      final url = await uploadPodcastAudio(entry.value, entry.key);
      urls[entry.key] = url;
    } catch (e) {
      print('⚠️ Không thể upload ${entry.key}: $e');
    }
  }
  
  return urls;
}

/// Tạo sample podcast audio URLs từ Firebase Storage
/// Nếu chưa có files, sẽ trả về URLs mẫu từ internet
Future<List<String>> getPodcastAudioUrls({int count = 10}) async {
  final storage = FirebaseSetup.storage;
  final urls = <String>[];
  
  try {
    // Thử lấy files từ Firebase Storage
    final listResult = await storage.ref().child('podcasts').listAll();
    
    for (var item in listResult.items) {
      if (item.name.endsWith('.mp3')) {
        final url = await item.getDownloadURL();
        urls.add(url);
        if (urls.length >= count) break;
      }
    }
    
    print('📊 Found ${urls.length} podcast audio files in Firebase Storage');
  } catch (e) {
    print('⚠️ Không thể lấy files từ Storage: $e');
  }
  
  // Nếu không có files trong Storage, dùng sample URLs
  if (urls.isEmpty) {
    print('💡 Sử dụng sample URLs từ internet');
    urls.addAll([
      // Có thể thêm sample URLs ở đây nếu cần
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
    ]);
  }
  
  return urls;
}

