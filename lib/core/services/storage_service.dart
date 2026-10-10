// Wraps Firebase Storage uploads used across the app: profile pictures and
// book cover images. Every upload returns a public download URL that gets
// saved on the matching Firestore document.

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Storage rules only accept `image/*`. Set the content type explicitly so
  /// the upload is never rejected just because the picked file has an odd or
  /// missing extension.
  String _contentTypeFor(String ext) {
    switch (ext.toLowerCase()) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'heic':
        return 'image/heic';
      default:
        return 'image/jpeg';
    }
  }

  String _extOf(File file) {
    final name = file.path.split('/').last;
    return name.contains('.') ? name.split('.').last : 'jpg';
  }

  Future<String> _upload(String path, File file, String ext) async {
    final ref = _storage.ref().child(path);
    final task = await ref.putFile(file, SettableMetadata(contentType: _contentTypeFor(ext)));
    return task.ref.getDownloadURL();
  }

  Future<String> uploadProfilePhoto(String uid, File file) {
    final ext = _extOf(file);
    return _upload('profile_photos/$uid.$ext', file, ext);
  }

  /// Unique file name per upload so replacing a cover never serves the old,
  /// cached image.
  Future<String> uploadBookCover(String bookId, File file) {
    final ext = _extOf(file);
    final stamp = DateTime.now().millisecondsSinceEpoch;
    return _upload('book_covers/${bookId}_$stamp.$ext', file, ext);
  }
}
