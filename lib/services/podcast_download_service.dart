import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../database/models/podcast_model.dart';

/// Service để download và quản lý podcast episodes offline
class PodcastDownloadService {
  static const String _downloadsFolder = 'podcast_downloads';

  /// Lấy thư mục lưu trữ downloads
  Future<Directory> _getDownloadsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final downloadsDir = Directory(path.join(appDir.path, _downloadsFolder));
    
    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }
    
    return downloadsDir;
  }

  /// Lấy đường dẫn local file cho episode
  Future<String> getLocalFilePath(String episodeId) async {
    final downloadsDir = await _getDownloadsDirectory();
    return path.join(downloadsDir.path, '$episodeId.mp3');
  }

  /// Kiểm tra xem episode đã được download chưa
  Future<bool> isEpisodeDownloaded(String episodeId) async {
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
        return await getLocalFilePath(episode.id);
      }

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

      // Lưu file
      final filePath = await getLocalFilePath(episode.id);
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      final fileSize = await file.length();
      print('✅ Download thành công: $filePath');
      print('📊 File size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');

      return filePath;
    } on http.ClientException catch (e) {
      // Xử lý lỗi network/connection
      print('❌ Lỗi kết nối khi download: $e');
      throw Exception('Lỗi kết nối mạng. Vui lòng kiểm tra internet và thử lại.');
    } on SocketException catch (e) {
      print('❌ Lỗi socket khi download: $e');
      throw Exception('Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.');
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
    try {
      final downloadsDir = await _getDownloadsDirectory();
      final files = downloadsDir.listSync();
      
      final episodeIds = <String>[];
      for (var file in files) {
        if (file is File && file.path.endsWith('.mp3')) {
          final fileName = path.basenameWithoutExtension(file.path);
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

