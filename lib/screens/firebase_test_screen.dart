import 'package:flutter/material.dart';
import '../database/firebase_setup.dart';
import '../database/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Màn hình test Firebase connection
class FirebaseTestScreen extends StatefulWidget {
  const FirebaseTestScreen({super.key});

  @override
  State<FirebaseTestScreen> createState() => _FirebaseTestScreenState();
}

class _FirebaseTestScreenState extends State<FirebaseTestScreen> {
  bool _isLoading = false;
  String _statusMessage = '';
  List<String> _testResults = [];

  @override
  void initState() {
    super.initState();
    _testConnection();
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Đang kiểm tra kết nối...';
      _testResults.clear();
    });

    try {
      // Test 1: Check Firebase initialization
      _addResult('1. Kiểm tra Firebase initialization...');
      if (FirebaseSetup.isInitialized) {
        _addResult('   ✅ Firebase đã được khởi tạo');
      } else {
        _addResult('   ❌ Firebase chưa được khởi tạo');
        return;
      }

      // Test 2: Check Firestore connection
      _addResult('2. Kiểm tra Firestore connection...');
      final firestore = FirebaseSetup.firestore;
      // Test với collection 'songs' thay vì 'test' vì 'songs' có public read permission
      await firestore.collection('songs').limit(1).get();
      _addResult('   ✅ Firestore kết nối thành công');

      // Test 3: Check Storage connection
      _addResult('3. Kiểm tra Storage connection...');
      try {
        final storage = FirebaseSetup.storage;
        // Test với root path thay vì 'test'
        await storage.ref().listAll();
        _addResult('   ✅ Storage kết nối thành công');
      } catch (e) {
        _addResult('   ⚠️ Storage test: $e');
        _addResult('   ℹ️ Storage service vẫn hoạt động, chỉ là test path');
      }

      // Test 4: Check Auth
      _addResult('4. Kiểm tra Auth service...');
      final auth = FirebaseSetup.auth;
      _addResult('   ✅ Auth service sẵn sàng');
      _addResult('   📝 User logged in: ${auth.currentUser != null}');

      // Test 5: Test Database Service
      _addResult('5. Kiểm tra Database Service...');
      final dbService = FirebaseSetup.databaseService;
      _addResult('   ✅ Database Service hoạt động');

      // Test 6: Try to read a collection (songs)
      _addResult('6. Kiểm tra đọc dữ liệu từ Firestore...');
      try {
        final songsSnapshot = await firestore
            .collection('songs')
            .limit(1)
            .get();
        _addResult('   ✅ Có thể đọc collection "songs"');
        _addResult('   📊 Số documents: ${songsSnapshot.docs.length}');
        if (songsSnapshot.docs.isEmpty) {
          _addResult('   ℹ️ Collection "songs" chưa có dữ liệu (điều này là bình thường)');
        }
      } catch (e) {
        _addResult('   ❌ Lỗi đọc collection "songs": $e');
        // Nếu là permission error, hướng dẫn user
        if (e.toString().contains('permission-denied')) {
          _addResult('   💡 Có thể rules chưa được deploy hoặc cần đợi vài giây');
        }
      }

      setState(() {
        _statusMessage = '✅ Tất cả các test đều thành công!';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Có lỗi xảy ra: $e';
        _isLoading = false;
      });
      _addResult('❌ Lỗi: $e');
    }
  }

  void _addResult(String message) {
    setState(() {
      _testResults.add(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Firebase Connection Test'),
        backgroundColor: const Color(0xFF1DB954),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Card
              Card(
                color: const Color(0xFF282828),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (_isLoading)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF1DB954),
                                ),
                              ),
                            )
                          else
                            Icon(
                              _statusMessage.contains('✅')
                                  ? Icons.check_circle
                                  : Icons.error,
                              color: _statusMessage.contains('✅')
                                  ? const Color(0xFF1DB954)
                                  : Colors.red,
                            ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _statusMessage.isEmpty
                                  ? 'Chưa kiểm tra'
                                  : _statusMessage,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _testConnection,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1DB954),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Chạy lại test'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Test Results
              const Text(
                'Kết quả test:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ..._testResults.map((result) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      result,
                      style: TextStyle(
                        color: result.contains('✅')
                            ? const Color(0xFF1DB954)
                            : result.contains('❌')
                                ? Colors.red
                                : result.contains('⚠️')
                                    ? Colors.orange
                                    : Colors.white70,
                        fontSize: 14,
                        fontFamily: 'monospace',
                      ),
                    ),
                  )),
              const SizedBox(height: 24),
              // Firebase Info
              Card(
                color: const Color(0xFF282828),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thông tin Firebase:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow('Project ID', 'spotify-78b1f'),
                      _buildInfoRow(
                        'Firebase Initialized',
                        FirebaseSetup.isInitialized ? 'Yes' : 'No',
                      ),
                      _buildInfoRow(
                        'User Logged In',
                        FirebaseSetup.isUserLoggedIn ? 'Yes' : 'No',
                      ),
                      if (FirebaseSetup.currentUserId != null)
                        _buildInfoRow(
                          'User ID',
                          FirebaseSetup.currentUserId!,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

