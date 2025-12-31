import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../firebase_options.dart';
import 'database_service.dart';

/// Class để setup và initialize Firebase
class FirebaseSetup {
  static DatabaseService? _databaseService;
  static bool _initialized = false;

  /// Initialize Firebase
  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _initialized = true;
      _databaseService = DatabaseService();
      print('✅ Firebase initialized successfully');
    } catch (e) {
      print('❌ Error initializing Firebase: $e');
      rethrow;
    }
  }

  /// Get DatabaseService instance
  static DatabaseService get databaseService {
    if (!_initialized) {
      throw Exception('Firebase chưa được khởi tạo. Gọi FirebaseSetup.initialize() trước.');
    }
    return _databaseService!;
  }

  /// Check if Firebase is initialized
  static bool get isInitialized => _initialized;

  /// Get Firebase Auth instance
  static FirebaseAuth get auth {
    if (!_initialized) {
      throw Exception('Firebase chưa được khởi tạo. Gọi FirebaseSetup.initialize() trước.');
    }
    return FirebaseAuth.instance;
  }

  /// Get Firestore instance
  static FirebaseFirestore get firestore {
    if (!_initialized) {
      throw Exception('Firebase chưa được khởi tạo. Gọi FirebaseSetup.initialize() trước.');
    }
    return FirebaseFirestore.instance;
  }

  /// Get Storage instance
  static FirebaseStorage get storage {
    if (!_initialized) {
      throw Exception('Firebase chưa được khởi tạo. Gọi FirebaseSetup.initialize() trước.');
    }
    return FirebaseStorage.instance;
  }

  /// Get current user ID
  static String? get currentUserId {
    return auth.currentUser?.uid;
  }

  /// Check if user is logged in
  static bool get isUserLoggedIn {
    return auth.currentUser != null;
  }

  /// Stream of auth state changes
  static Stream<User?> get authStateChanges {
    return auth.authStateChanges();
  }
}

