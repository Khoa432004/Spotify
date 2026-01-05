import 'package:firebase_auth/firebase_auth.dart';
import '../database/firebase_setup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static FirebaseAuth get _auth => FirebaseSetup.auth;

  static User? get currentUser => _auth.currentUser;

  static Stream<User?> authStateChanges() => FirebaseSetup.authStateChanges;

  static Future<User?> signInWithEmail(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return cred.user;
  }

  static Future<User?> signUpWithEmail(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = cred.user;
    // Create basic user document in Firestore
    if (user != null) {
      final users = FirebaseSetup.firestore.collection('users');
      await users.doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    return user;
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }
}
