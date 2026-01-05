import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import '../database/models/podcast_model.dart';

// Conditional imports for file system (mobile/desktop only)
import 'dart:io' if (dart.library.html) 'podcast_download_stub.dart' show File, Directory;
import 'package:path_provider/path_provider.dart' if (dart.library.html) 'podcast_download_stub.dart';

// Conditional import for html (web only)
import 'podcast_download_stub.dart' if (dart.library.html) 'dart:html' as html;

/// Service để download và quản lý podcast episodes offline
class PodcastDownloadService {
  static const String _downloadsFolder = 'podcast_downloads';

  /// Lấy thư mục lưu trữ downloads (chỉ cho mobile/desktop)
  dynamic _getDownloadsDirectory() async {
    if (kIsWeb) {
      throw UnsupportedError('File system không được hỗ trợ trên web platform');
    }
    
    final appDir = await getApplicationDocumentsDirectory();
    final downloadsDir = Directory(path.join(appDir.path, _downloadsFolder));
    
    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }
    
    return downloadsDir;
  }

  /// Lấy đường dẫn local file cho episode
  Future<String> getLocalFilePath(String episodeId) async {
    if (kIsWeb) {
      // Trên web, trả về URL thay vì file path
      return 'web_cache://$episodeId.mp3';
    }
    
    final downloadsDir = await _getDownloadsDirectory();
    return path.join(downloadsDir.path, '$episodeId.mp3');
  }

  /// Kiểm tra xem episode đã được download chưa
  Future<bool> isEpisodeDownloaded(String episodeId) async {
    if (kIsWeb) {
      // Trên web, check localStorage thay vì file system
      try {
        final storage = html.window.localStorage;
        return storage.containsKey('podcast_download_$episodeId');
      } catch (e) {
        print('❌ Lỗi khi kiểm tra downloaded trên web: $e');
        return false;
      }
    }
    
    // Mobile/Desktop: check file system
    try {
      final filePath = await getLocalFilePath(episodeId);
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      print('❌ Lỗi khi kiểm tra file downloaded: $e');
      return false;
    }
  }

  /// Download episode
  Future<String> downloadEpisode(
    PodcastEpisodeModel episode, {
    Function(double)? onProgress,
  }) async {
    try {
      if (episode.audioUrl.isEmpty) {
        throw Exception('Episode không có audio URL');
      }

      // Kiểm tra xem đã download chưa
      final isDownloaded = await isEpisodeDownloaded(episode.id);
      if (isDownloaded) {
        print('📦 Episode ${episode.id} đã được download');
        if (kIsWeb) {
          final storage = html.window.localStorage;
          return storage['podcast_download_${episode.id}'] ?? episode.audioUrl;
        }
        return await getLocalFilePath(episode.id);
      }

      // Trên web, trigger browser download thay vì lưu local
      if (kIsWeb) {
        print('🌐 Trên web: Sử dụng browser download');
        try {
          // Lưu metadata vào localStorage
          final storage = html.window.localStorage;
          storage['podcast_download_${episode.id}'] = episode.audioUrl;
          storage['podcast_download_time_${episode.id}'] = DateTime.now().toIso8601String();
          
          // Trigger browser download
          final anchor = html.AnchorElement(href: episode.audioUrl)
            ..download = '${episode.title.replaceAll(RegExp(r'[^\w\s-]'), '_')}.mp3'
            ..target = '_blank';
          
          html.document.body?.append(anchor);
          anchor.click();
          anchor.remove();
          
          print('✅ Đã trigger browser download cho: ${episode.title}');
          return episode.audioUrl;
        } catch (e) {
          print('❌ Lỗi khi trigger browser download: $e');
          // Fallback: chỉ lưu URL để phát sau
          final storage = html.window.localStorage;
          storage['podcast_download_${episode.id}'] = episode.audioUrl;
          return episode.audioUrl;
        }
      }

      // Mobile/Desktop: Download thực sự
      print('⬇️ Bắt đầu download episode: ${episode.title}');
      print('🔗 URL: ${episode.audioUrl}');

      // Validate URL
      final uri = Uri.tryParse(episode.audioUrl);
      if (uri == null || (!uri.hasScheme || !uri.scheme.startsWith('http'))) {
        throw Exception('URL không hợp lệ: ${episode.audioUrl}');
      }

      // Tạo request với timeout và headers
      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'Flutter-Podcast-App',
          'Accept': '*/*',
        },
      ).timeout(
        const Duration(seconds: 60), // Timeout 60 giây cho download
        onTimeout: () {
          throw Exception('Timeout khi download. Vui lòng kiểm tra kết nối mạng và thử lại.');
        },
      );

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }

      // Kiểm tra content type
      final contentType = response.headers['content-type'] ?? '';
      if (!contentType.toLowerCase().contains('audio') && 
          !contentType.toLowerCase().contains('mp3') &&
          !contentType.toLowerCase().contains('mpeg') &&
          !contentType.toLowerCase().contains('octet-stream')) {
        print('⚠️ Warning: Content-Type không phải audio: $contentType');
        // Continue anyway, có thể vẫn là audio file
      }

      // Lưu file (chỉ cho non-web) - code này chỉ chạy khi !kIsWeb
      if (!kIsWeb) {
        final filePath = await getLocalFilePath(episode.id);
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        final fileSize = await file.length();
        print('✅ Download thành công: $filePath');
        print('📊 File size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');

        return filePath;
      }
      
      // Fallback (không bao giờ đến đây trên web vì đã return ở trên)
      return episode.audioUrl;
    } on http.ClientException catch (e) {
      // Xử lý lỗi network/connection
      print('❌ Lỗi kết nối khi download: $e');
      throw Exception('Lỗi kết nối mạng. Vui lòng kiểm tra internet và thử lại.');
    } on TimeoutException catch (e) {
      print('❌ Timeout khi download: $e');
      throw Exception('Download quá lâu. Vui lòng kiểm tra kết nối mạng và thử lại.');
    } on FormatException catch (e) {
      print('❌ Lỗi format URL: $e');
      throw Exception('URL không hợp lệ. Vui lòng kiểm tra lại URL.');
    } catch (e, stackTrace) {
      print('❌ Lỗi khi download episode: $e');
      print('📋 Stack trace: $stackTrace');
      
      // Xử lý các lỗi cụ thể
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('failed to fetch') || errorStr.contains('network')) {
        throw Exception('Lỗi kết nối mạng. Vui lòng kiểm tra internet và thử lại.');
      } else if (errorStr.contains('404') || errorStr.contains('not found')) {
        throw Exception('File không tìm thấy. URL có thể không còn hợp lệ.');
      } else if (errorStr.contains('403') || errorStr.contains('forbidden')) {
        throw Exception('Không có quyền truy cập file này.');
      } else if (errorStr.contains('timeout')) {
        throw Exception('Download quá lâu. Vui lòng thử lại.');
      }
      
      rethrow;
    }
  }

  /// Xóa episode đã download
  Future<bool> deleteEpisode(String episodeId) async {
    if (kIsWeb) {
      try {
        final storage = html.window.localStorage;
        storage.remove('podcast_download_$episodeId');
        storage.remove('podcast_download_time_$episodeId');
        print('🗑️ Đã xóa episode khỏi cache: $episodeId');
        return true;
      } catch (e) {
        print('❌ Lỗi khi xóa episode trên web: $e');
        return false;
      }
    }
    
    // Mobile/Desktop: Xóa file
    try {
      final filePath = await getLocalFilePath(episodeId);
      final file = File(filePath);
      
      if (await file.exists()) {
        await file.delete();
        print('🗑️ Đã xóa episode: $episodeId');
        return true;
      }
      
      return false;
    } catch (e) {
      print('❌ Lỗi khi xóa episode: $e');
      return false;
    }
  }

  /// Lấy kích thước file đã download
  Future<int> getFileSize(String episodeId) async {
    if (kIsWeb) {
      // Trên web không có cách lấy file size từ localStorage
      // Có thể lưu trong metadata nếu cần
      return 0;
    }
    
    // Mobile/Desktop: Lấy từ file system
    try {
      final filePath = await getLocalFilePath(episodeId);
      final file = File(filePath);
      
      if (await file.exists()) {
        return await file.length();
      }
      
      return 0;
    } catch (e) {
      print('❌ Lỗi khi lấy file size: $e');
      return 0;
    }
  }

  /// Lấy tất cả episodes đã download
  Future<List<String>> getDownloadedEpisodeIds() async {
    if (kIsWeb) {
      try {
        final storage = html.window.localStorage;
        final episodeIds = <String>[];
        
        // Lặp qua tất cả keys trong localStorage
        storage.forEach((key, value) {
          if (key.startsWith('podcast_download_') && !key.endsWith('_time')) {
            final episodeId = key.replaceFirst('podcast_download_', '');
            episodeIds.add(episodeId);
          }
        });
        
        return episodeIds;
      } catch (e) {
        print('❌ Lỗi khi lấy danh sách downloaded episodes trên web: $e');
        return [];
      }
    }
    
    // Mobile/Desktop: Lấy từ file system
    try {
      final downloadsDir = await _getDownloadsDirectory();
      final files = downloadsDir.listSync();
      
      final episodeIds = <String>[];
      for (var file in files) {
        // Kiểm tra file type - chỉ check path, không dùng is operator
        final filePath = file.path;
        if (filePath.endsWith('.mp3')) {
          final fileName = path.basenameWithoutExtension(filePath);
          episodeIds.add(fileName);
        }
      }
      
      return episodeIds;
    } catch (e) {
      print('❌ Lỗi khi lấy danh sách downloaded episodes: $e');
      return [];
    }
  }

  /// Xóa tất cả downloads
  Future<void> clearAllDownloads() async {
    if (kIsWeb) {
      try {
        final storage = html.window.localStorage;
        final keysToRemove = <String>[];
        
        // Lặp qua tất cả keys để tìm các keys cần xóa
        storage.forEach((key, value) {
          if (key.startsWith('podcast_download_')) {
            keysToRemove.add(key);
          }
        });
        
        for (var key in keysToRemove) {
          storage.remove(key);
        }
        
        print('🗑️ Đã xóa tất cả downloads khỏi cache');
      } catch (e) {
        print('❌ Lỗi khi xóa tất cả downloads trên web: $e');
      }
      return;
    }
    
    // Mobile/Desktop: Xóa từ file system
    try {
      final downloadsDir = await _getDownloadsDirectory();
      if (await downloadsDir.exists()) {
        await downloadsDir.delete(recursive: true);
        print('🗑️ Đã xóa tất cả downloads');
      }
    } catch (e) {
      print('❌ Lỗi khi xóa tất cả downloads: $e');
    }
  }
}
