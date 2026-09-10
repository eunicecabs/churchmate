// Wraps FirebaseAuth + the user's Firestore profile (which holds `role`).
//
// Responsibilities:
// - sign up (create FirebaseAuth user + create matching `users/{uid}` doc with role)
// - log in / log out
// - expose the current user's role so screens can branch Leader vs Member
//
// Example shape (fill in once firebase_auth is wired up):
//
// class AuthService extends ChangeNotifier {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _db = FirebaseFirestore.instance;
//
//   Future<void> register({required String email, required String password, required String fullName, required String role}) async { ... }
//   Future<void> login({required String email, required String password}) async { ... }
//   Future<void> logout() async { ... }
//   Future<String?> getCurrentUserRole() async { ... }
// }
