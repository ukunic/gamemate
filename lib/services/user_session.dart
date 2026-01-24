import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';

class UserSession {
  static AppUser? currentUser;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static bool get isLoggedIn => _auth.currentUser != null;

  /// Anonymous Firebase login + username binding
  static Future<void> login(String username) async {
    // If not logged in, sign in anonymously
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }

    final user = _auth.currentUser!;

    // Create our app-level user
    currentUser = AppUser(
      uid: user.uid,
      username: username,
    );
  }

  static Future<void> logout() async {
    await _auth.signOut();
    currentUser = null;
  }
}
