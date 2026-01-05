import 'package:flutter/material.dart';

/// Dialog hiển thị tiến trình download
class DownloadProgressDialog extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Future<void> Function(Function(double) onProgress) downloadTask;
  final VoidCallback? onSuccess;
  final Function(String)? onError;

  const DownloadProgressDialog({
    super.key,
    required this.title,
    this.subtitle,
    required this.downloadTask,
    this.onSuccess,
    this.onError,
  });

  @override
  State<DownloadProgressDialog> createState() => _DownloadProgressDialogState();
}

class _DownloadProgressDialogState extends State<DownloadProgressDialog> {
  double _progress = 0.0;
  bool _isDownloading = true;
  bool _isSuccess = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  Future<void> _startDownload() async {
    try {
      await widget.downloadTask((progress) {
        if (mounted) {
          setState(() {
            _progress = progress;
          });
        }
      });

      if (mounted) {
        setState(() {
          _isDownloading = false;
          _isSuccess = true;
        });

        // Đóng dialog sau 1.5 giây khi thành công
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          Navigator.of(context).pop(true);
          widget.onSuccess?.call();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _isSuccess = false;
          _errorMessage = e.toString();
        });
        widget.onError?.call(_errorMessage!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Không cho phép đóng khi đang download
        return !_isDownloading;
      },
      child: AlertDialog(
        backgroundColor: const Color(0xFF282828),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.subtitle != null) ...[
              Text(
                widget.subtitle!,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (_isDownloading) ...[
              // Progress indicator
              CircularProgressIndicator(
                value: _progress > 0 ? _progress : null,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF1DB954),
                ),
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              // Progress text
              Text(
                '${(_progress * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Đang tải xuống...',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
            ] else if (_isSuccess) ...[
              const Icon(
                Icons.check_circle,
                color: Color(0xFF1DB954),
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'Tải xuống thành công!',
                style: TextStyle(
                  color: Color(0xFF1DB954),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ] else if (_errorMessage != null) ...[
              const Icon(
                Icons.error,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Lỗi khi tải xuống',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        actions: [
          if (!_isDownloading)
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Đóng',
                style: TextStyle(color: Color(0xFF1DB954)),
              ),
            ),
        ],
      ),
    );
  }
}

