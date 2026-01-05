import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../database/models/song_model.dart';

/// Service để download và quản lý songs offline
class SongDownloadService {
  static const String _downloadsFolder = 'song_downloads';

  /// Lấy thư mục lưu trữ downloads
  Future<Directory> _getDownloadsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final downloadsDir = Directory(path.join(appDir.path, _downloadsFolder));

    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }

    return downloadsDir;
  }

  /// Lấy đường dẫn local file cho song
  Future<String> getLocalFilePath(String songId) async {
    final downloadsDir = await _getDownloadsDirectory();
    return path.join(downloadsDir.path, '$songId.mp3');
  }

  /// Kiểm tra xem song đã được download chưa
  Future<bool> isSongDownloaded(String songId) async {
    try {
      final filePath = await getLocalFilePath(songId);
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      print('❌ Lỗi khi kiểm tra file downloaded: $e');
      return false;
    }
  }

  /// Download song
  Future<String> downloadSong(
    SongModel song, {
    Function(double)? onProgress,
  }) async {
    try {
      if (song.audioUrl.isEmpty) {
        throw Exception('Song không có audio URL');
      }

      // Kiểm tra xem đã download chưa
      final isDownloaded = await isSongDownloaded(song.id);
      if (isDownloaded) {
        print('📦 Song ${song.id} đã được download');
        return await getLocalFilePath(song.id);
      }

      // Download thực sự
      print('⬇️ Bắt đầu download song: ${song.title}');
      print('🔗 URL: ${song.audioUrl}');

      // Validate URL
      final uri = Uri.tryParse(song.audioUrl);
      if (uri == null || (!uri.hasScheme || !uri.scheme.startsWith('http'))) {
        throw Exception('URL không hợp lệ: ${song.audioUrl}');
      }

      // Download với streaming để có progress tracking
      final filePath = await getLocalFilePath(song.id);
      final file = File(filePath);

      // Tạo request với timeout
      final client = http.Client();
      try {
        final request = http.Request('GET', uri);
        request.headers.addAll({
          'User-Agent': 'Flutter-Music-App',
          'Accept': '*/*',
        });

        final streamedResponse = await client
            .send(request)
            .timeout(
              const Duration(minutes: 3), // Timeout 3 phút cho song
              onTimeout: () {
                client.close();
                throw TimeoutException(
                  'Download quá lâu. Vui lòng kiểm tra kết nối mạng và thử lại.',
                  const Duration(minutes: 3),
                );
              },
            );

        if (streamedResponse.statusCode != 200) {
          client.close();
          throw Exception(
            'HTTP ${streamedResponse.statusCode}: ${streamedResponse.reasonPhrase}',
          );
        }

        // Kiểm tra content type
        final contentType = streamedResponse.headers['content-type'] ?? '';
        if (!contentType.toLowerCase().contains('audio') &&
            !contentType.toLowerCase().contains('mp3') &&
            !contentType.toLowerCase().contains('mpeg') &&
            !contentType.toLowerCase().contains('octet-stream')) {
          print('⚠️ Warning: Content-Type không phải audio: $contentType');
          // Continue anyway, có thể vẫn là audio file
        }

        // Stream download vào file để có progress tracking
        final sink = file.openWrite();
        int bytesDownloaded = 0;
        final totalBytes = streamedResponse.contentLength;

        try {
          await for (var chunk in streamedResponse.stream) {
            sink.add(chunk);
            bytesDownloaded += chunk.length;

            // Callback progress nếu có
            if (onProgress != null && totalBytes != null) {
              onProgress(bytesDownloaded / totalBytes);
            }
          }

          await sink.close();
        } catch (e) {
          await sink.close();
          // Xóa file nếu download không hoàn thành
          if (await file.exists()) {
            await file.delete();
          }
          rethrow;
        } finally {
          client.close();
        }

        final fileSize = await file.length();
        print('✅ Download thành công: $filePath');
        print(
          '📊 File size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB',
        );

        return filePath;
      } catch (e) {
        client.close();
        // Xóa file nếu download không hoàn thành
        if (await file.exists()) {
          await file.delete();
        }
        rethrow;
      }
    } on http.ClientException catch (e) {
      // Xử lý lỗi network/connection
      print('❌ Lỗi kết nối khi download: $e');
      throw Exception(
        'Lỗi kết nối mạng. Vui lòng kiểm tra internet và thử lại.',
      );
    } on TimeoutException catch (e) {
      print('❌ Timeout khi download: $e');
      throw Exception(
        'Download quá lâu. Vui lòng kiểm tra kết nối mạng và thử lại.',
      );
    } on FormatException catch (e) {
      print('❌ Lỗi format URL: $e');
      throw Exception('URL không hợp lệ. Vui lòng kiểm tra lại URL.');
    } catch (e, stackTrace) {
      print('❌ Lỗi khi download song: $e');
      print('📋 Stack trace: $stackTrace');

      // Xử lý các lỗi cụ thể
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('failed to fetch') ||
          errorStr.contains('network')) {
        throw Exception(
          'Lỗi kết nối mạng. Vui lòng kiểm tra internet và thử lại.',
        );
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

  /// Download nhiều songs (cho album)
  Future<List<String>> downloadSongs(
    List<SongModel> songs, {
    Function(int current, int total)? onProgress,
  }) async {
    final downloadedPaths = <String>[];

    for (int i = 0; i < songs.length; i++) {
      try {
        final path = await downloadSong(songs[i]);
        downloadedPaths.add(path);

        if (onProgress != null) {
          onProgress(i + 1, songs.length);
        }
      } catch (e) {
        print('❌ Lỗi khi download song ${songs[i].id}: $e');
        // Continue với các songs khác
      }
    }

    return downloadedPaths;
  }

  /// Xóa song đã download
  Future<bool> deleteSong(String songId) async {
    try {
      final filePath = await getLocalFilePath(songId);
      final file = File(filePath);

      if (await file.exists()) {
        await file.delete();
        print('🗑️ Đã xóa song: $songId');
        return true;
      }

      return false;
    } catch (e) {
      print('❌ Lỗi khi xóa song: $e');
      return false;
    }
  }

  /// Lấy kích thước file đã download
  Future<int> getFileSize(String songId) async {
    try {
      final filePath = await getLocalFilePath(songId);
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

  /// Lấy tất cả songs đã download
  Future<List<String>> getDownloadedSongIds() async {
    try {
      final downloadsDir = await _getDownloadsDirectory();
      final files = downloadsDir.listSync();

      final songIds = <String>[];
      for (var file in files) {
        final filePath = file.path;
        if (filePath.endsWith('.mp3')) {
          final fileName = path.basenameWithoutExtension(filePath);
          songIds.add(fileName);
        }
      }

      return songIds;
    } catch (e) {
      print('❌ Lỗi khi lấy danh sách downloaded songs: $e');
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
