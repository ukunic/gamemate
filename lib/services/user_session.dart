import '../models/user.dart';

class UserSession {
  static AppUser? currentUser;

  static bool get isLoggedIn => currentUser != null;

  static void login(String username) {
    currentUser = AppUser(username: username);
  }

  static void logout() {
    currentUser = null;
  }
}
