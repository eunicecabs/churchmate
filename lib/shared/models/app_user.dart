// The shared user model used across all three modules — mirrors the
// `users/{uid}` Firestore document. Almost every other model points here
// via a userId/createdBy field.

import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id; // Firebase Auth UID, also the Firestore doc id
  final String fullName;
  final String email;
  final String role; // UserRole.leader or UserRole.member
  final String? photoUrl;
  final String? phone;
  final String authProvider; // 'password' or 'google.com'
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.photoUrl,
    this.phone,
    this.authProvider = 'password',
    this.createdAt,
    this.updatedAt,
  });

  factory AppUser.fromMap(String id, Map<String, dynamic> data) {
    return AppUser(
      id: id,
      fullName: data['fullName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      role: data['role'] as String? ?? 'member',
      photoUrl: data['photoUrl'] as String?,
      phone: data['phone'] as String?,
      authProvider: data['authProvider'] as String? ?? 'password',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'role': role,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (phone != null) 'phone': phone,
      'authProvider': authProvider,
    };
  }

  AppUser copyWith({
    String? fullName,
    String? photoUrl,
    String? phone,
  }) {
    return AppUser(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email,
      role: role,
      photoUrl: photoUrl ?? this.photoUrl,
      phone: phone ?? this.phone,
      authProvider: authProvider,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Display name used in greetings, e.g. "Hello, Hannah" or "Hello, Karl Dave".
  /// Uses the full name exactly as stored — no "Sister"/"Brother" prefixes,
  /// no truncation.
  String get displayName => fullName.trim().isEmpty ? 'there' : fullName.trim();
}
