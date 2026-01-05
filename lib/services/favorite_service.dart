import 'package:cloud_firestore/cloud_firestore.dart';
import '../database/firebase_setup.dart';
import '../database/models/song_model.dart';

/// Service quản lý danh sách yêu thích cho mỗi user
class FavoriteService {
  static FirebaseFirestore get _db => FirebaseSetup.firestore;

  static String _userPath() {
    final uid = FirebaseSetup.currentUserId;
    if (uid == null) throw Exception('User chưa đăng nhập');
    return 'users/$uid/favorites';
  }

  static Future<void> addFavorite(SongModel song) async {
    final path = _userPath();
    final ref = _db.collection(path).doc(song.id);
    final data = song.toFirestore();
    data['addedAt'] = FieldValue.serverTimestamp();
    await ref.set(data, SetOptions(merge: true));
  }

  static Future<void> removeFavorite(String songId) async {
    final path = _userPath();
    final ref = _db.collection(path).doc(songId);
    await ref.delete();
  }

  static Future<bool> isFavorite(String songId) async {
    try {
      final path = _userPath();
      final ref = _db.collection(path).doc(songId);
      final snap = await ref.get();
      return snap.exists;
    } catch (e) {
      return false;
    }
  }

  static Stream<List<SongModel>> favoritesStream() {
    final uid = FirebaseSetup.currentUserId;
    if (uid == null) return const Stream.empty();
    final coll = _db.collection('users').doc(uid).collection('favorites');
    return coll.snapshots().map((snap) => snap.docs.map((d) => SongModel.fromFirestore(d)).toList());
  }
}
