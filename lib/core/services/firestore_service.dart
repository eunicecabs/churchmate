// Generic Firestore read/write helpers shared across Faith, Library, and
// Finance modules, so each feature doesn't repeat boilerplate.

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> collection(String path) => _db.collection(path);

  /// One-time fetch of every document in [path], as `{id, ...data}` maps.
  Future<List<Map<String, dynamic>>> getCollection(String path) async {
    final snapshot = await _db.collection(path).get();
    return snapshot.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }

  /// Live stream of every document in [path] — use for lists that should
  /// update in real time (e.g. events list, live check-in counts).
  Stream<List<Map<String, dynamic>>> streamCollection(String path) {
    return _db.collection(path).snapshots().map(
          (snapshot) => snapshot.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
        );
  }

  Future<Map<String, dynamic>?> getDocument(String path, String id) async {
    final doc = await _db.collection(path).doc(id).get();
    return doc.exists ? {'id': doc.id, ...doc.data()!} : null;
  }

  Stream<Map<String, dynamic>?> streamDocument(String path, String id) {
    return _db.collection(path).doc(id).snapshots().map(
          (doc) => doc.exists ? {'id': doc.id, ...doc.data()!} : null,
        );
  }

  /// Adds a new document with an auto-generated id. Returns that id.
  Future<String> addDocument(String path, Map<String, dynamic> data) async {
    final ref = await _db.collection(path).add(data);
    return ref.id;
  }

  Future<void> setDocument(String path, String id, Map<String, dynamic> data, {bool merge = true}) {
    return _db.collection(path).doc(id).set(data, SetOptions(merge: merge));
  }

  Future<void> updateDocument(String path, String id, Map<String, dynamic> data) {
    return _db.collection(path).doc(id).update(data);
  }

  Future<void> deleteDocument(String path, String id) {
    return _db.collection(path).doc(id).delete();
  }
}
