// Wraps FirebaseAuth + the user's Firestore profile (which holds `role`).
//
// Responsibilities:
// - sign up / log in / log out with email + password
// - sign in with Google (creates a matching users/{uid} doc on first use)
// - expose the current user's role so screens can branch Leader vs Member
// - let the user edit their profile (name, phone, photo) and reset password

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../shared/models/app_user.dart';
import '../constants/roles.dart';
import 'storage_service.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  final StorageService _storage = StorageService();

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  // True while login()/register()/signInWithGoogle() is running. During that
  // time the auth-state listener must not touch _currentUser (the profile doc
  // may not exist yet, or the role check may still reject the login), and the
  // AuthGate must not jump to the dashboard before the role check passes.
  bool _pendingAuth = false;
  bool get isPendingAuth => _pendingAuth;

  // False while the profile of an already-signed-in user (app restart) is
  // still being loaded from Firestore.
  bool _profileResolved = false;
  bool get profileResolved => _profileResolved;
  bool get isSignedIn => _auth.currentUser != null;
  bool get isGoogleUser => _currentUser?.authProvider == 'google.com';

  AuthService() {
    // Keep _currentUser in sync with FirebaseAuth's own auth-state stream,
    // so the app remembers the signed-in user across restarts and the
    // greeting/UI update automatically for whoever is currently logged in.
    _auth.authStateChanges().listen((user) async {
      if (_pendingAuth) return; // login/register handle their own state
      if (user == null) {
        _currentUser = null;
        _profileResolved = true;
      } else {
        _profileResolved = false;
        notifyListeners();
        try {
          _currentUser = await _loadProfile(user.uid);
        } catch (_) {
          _currentUser = null;
        }
        _profileResolved = true;
      }
      notifyListeners();
    });
  }

  Future<AppUser?> _loadProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(doc.id, doc.data()!);
  }

  /// Creates a Firebase Auth user + matching `users/{uid}` Firestore doc.
  /// Throws a [FirebaseAuthException] on failure (bad email, weak password,
  /// email already in use, etc.) — catch this in the UI and show `e.message`.
  Future<AppUser> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    _pendingAuth = true;
    notifyListeners();
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = credential.user!.uid;

      final user = AppUser(
        id: uid,
        fullName: fullName.trim(),
        email: email.trim(),
        role: role,
        authProvider: 'password',
      );
      await _db.collection('users').doc(uid).set({
        ...user.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await credential.user!.updateDisplayName(fullName.trim());
      _currentUser = user;
      _profileResolved = true;
      return user;
    } finally {
      _pendingAuth = false;
      notifyListeners();
    }
  }

  /// Signs in and loads the matching Firestore profile.
  ///
  /// [expectedRole] is the tab the person chose on the login screen
  /// (Youth Member or Youth Leader). If the account was registered under the
  /// OTHER role, the sign-in is rejected and the person is signed out again,
  /// so a Youth Member can only ever enter through "Youth Member" and a
  /// Youth Leader only through "Youth Leader".
  /// Throws a [FirebaseAuthException] on failure (user-not-found,
  /// wrong-password, invalid-email, wrong-role, etc.).
  Future<AppUser> login({
    required String email,
    required String password,
    required String expectedRole,
  }) async {
    _pendingAuth = true;
    notifyListeners();
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final profile = await _loadProfile(credential.user!.uid);
      if (profile == null) {
        await _auth.signOut();
        throw FirebaseAuthException(
          code: 'profile-missing',
          message: 'Signed in, but no matching users/{uid} document was found in Firestore.',
        );
      }
      if (profile.role != expectedRole) {
        await _auth.signOut();
        throw FirebaseAuthException(
          code: 'wrong-role',
          message: _wrongRoleMessage(profile.role),
        );
      }
      _currentUser = profile;
      _profileResolved = true;
      return profile;
    } finally {
      _pendingAuth = false;
      notifyListeners();
    }
  }

  String _wrongRoleMessage(String actualRole) {
    return actualRole == UserRole.leader
        ? 'This account is registered as a Youth Leader. Please sign in using the "Youth Leader" tab.'
        : 'This account is registered as a Youth Member. Please sign in using the "Youth Member" tab.';
  }

  /// Opens the native Google account picker, authenticates with Firebase,
  /// and creates a `users/{uid}` document the first time this Google
  /// account signs in (with the role of the tab that was selected).
  /// If the Google account already exists under the other role, the
  /// sign-in is rejected. Returns null if the user cancels the picker.
  Future<AppUser?> signInWithGoogle({required String role}) async {
    _pendingAuth = true;
    notifyListeners();
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // user cancelled the picker

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final fbUser = userCredential.user!;
      final uid = fbUser.uid;

      final existing = await _db.collection('users').doc(uid).get();
      AppUser user;
      if (existing.exists) {
        user = AppUser.fromMap(uid, existing.data()!);
        if (user.role != role) {
          await _auth.signOut();
          await _googleSignIn.signOut();
          throw FirebaseAuthException(
            code: 'wrong-role',
            message: _wrongRoleMessage(user.role),
          );
        }
      } else {
        user = AppUser(
          id: uid,
          fullName: fbUser.displayName ?? googleUser.displayName ?? 'Google User',
          email: fbUser.email ?? googleUser.email,
          role: role,
          photoUrl: fbUser.photoURL ?? googleUser.photoUrl,
          authProvider: 'google.com',
        );
        await _db.collection('users').doc(uid).set({
          ...user.toMap(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      _currentUser = user;
      _profileResolved = true;
      return user;
    } finally {
      _pendingAuth = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    if (await _googleSignIn.isSignedIn()) {
      await _googleSignIn.signOut();
    }
    _currentUser = null;
    _profileResolved = true;
    notifyListeners();
  }

  /// Reads the role of whoever is currently signed in ('leader' or 'member'),
  /// or null if nobody is signed in / no profile doc exists yet.
  Future<String?> getCurrentUserRole() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final profile = await _loadProfile(uid);
    return profile?.role;
  }

  /// Updates the signed-in user's name / phone / photo. Pass [photoFile] to
  /// upload a new profile picture (camera or gallery) to Firebase Storage
  /// first; the resulting download URL is saved to Firestore and mirrored
  /// onto the FirebaseAuth profile so it shows up everywhere in the app.
  Future<AppUser> updateProfile({
    String? fullName,
    String? phone,
    File? photoFile,
  }) async {
    final fbUser = _auth.currentUser;
    if (fbUser == null || _currentUser == null) {
      throw StateError('No signed-in user to update.');
    }

    String? photoUrl = _currentUser!.photoUrl;
    if (photoFile != null) {
      photoUrl = await _storage.uploadProfilePhoto(fbUser.uid, photoFile);
    }

    final updated = _currentUser!.copyWith(
      fullName: fullName,
      phone: phone,
      photoUrl: photoUrl,
    );

    await _db.collection('users').doc(fbUser.uid).set({
      ...updated.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (fullName != null && fullName.trim().isNotEmpty) {
      await fbUser.updateDisplayName(fullName.trim());
    }
    if (photoUrl != null) {
      await fbUser.updatePhotoURL(photoUrl);
    }

    _currentUser = updated;
    notifyListeners();
    return updated;
  }

  /// Sends a Firebase Auth password-reset email. Only meaningful for
  /// email/password accounts — Google accounts manage their own password.
  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }
}
