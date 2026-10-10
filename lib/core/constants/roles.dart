/// The two roles required by the professor's spec.
/// Read this from the logged-in user's Firestore document (`users/{uid}.role`)
/// to decide what the UI shows and what Firestore security rules allow.
class UserRole {
  static const leader = 'leader';
  static const member = 'member';
}
