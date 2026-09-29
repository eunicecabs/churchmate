// All Firestore logic for borrowing books, kept in one place so the
// dashboard, catalog and detail screens behave identically.

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/models/app_user.dart';
import '../models/borrow_model.dart';

class BorrowService {
  BorrowService._();
  static final _db = FirebaseFirestore.instance;
  static final _requests = _db.collection('borrowRequests');

  /// Requests of ONE member (single-field query, no composite index needed).
  static Stream<List<BorrowRequestModel>> streamForUser(String userId) {
    return _requests.where('userId', isEqualTo: userId).snapshots().map(
          (s) => s.docs.map((d) => BorrowRequestModel.fromMap(d.id, d.data())).toList(),
        );
  }

  /// Requests waiting for the leader's decision (newest first).
  static Stream<List<BorrowRequestModel>> streamPending() {
    return _requests.where('status', isEqualTo: BorrowStatus.pending).snapshots().map((s) {
      final list = s.docs.map((d) => BorrowRequestModel.fromMap(d.id, d.data())).toList();
      list.sort((a, b) => (b.requestedAt ?? DateTime.now()).compareTo(a.requestedAt ?? DateTime.now()));
      return list;
    });
  }

  /// Books currently lent out (approved, not yet returned).
  static Stream<List<BorrowRequestModel>> streamApproved() {
    return _requests.where('status', isEqualTo: BorrowStatus.approved).snapshots().map(
          (s) => s.docs.map((d) => BorrowRequestModel.fromMap(d.id, d.data())).toList(),
        );
  }

  /// Member taps "Borrow". Does nothing if they already have an open
  /// (pending/approved) request for the same book.
  static Future<void> requestBorrow({required String bookId, required String bookTitle, required AppUser user}) async {
    final existing = await _requests.where('userId', isEqualTo: user.id).get();
    final alreadyOpen = existing.docs.any((d) {
      final data = d.data();
      return data['bookId'] == bookId &&
          (data['status'] == BorrowStatus.pending || data['status'] == BorrowStatus.approved);
    });
    if (alreadyOpen) return;

    await _requests.add({
      'bookId': bookId,
      'bookTitle': bookTitle,
      'userId': user.id,
      'userName': user.fullName,
      'status': BorrowStatus.pending,
      'requestedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Leader taps Accept: marks the request approved and takes one copy out
  /// of the book's available quantity, atomically. Throws a [StateError]
  /// with a readable message if no copy is left.
  static Future<void> accept(BorrowRequestModel request) {
    return _db.runTransaction((tx) async {
      final reqRef = _requests.doc(request.id);
      final bookRef = _db.collection('books').doc(request.bookId);
      final reqSnap = await tx.get(reqRef);
      final bookSnap = await tx.get(bookRef);

      if (!reqSnap.exists || reqSnap.data()!['status'] != BorrowStatus.pending) {
        throw StateError('This request was already handled.');
      }
      if (!bookSnap.exists) throw StateError('This book no longer exists.');
      final qty = (bookSnap.data()!['availableQuantity'] as num?)?.toInt() ?? 0;
      if (qty <= 0) throw StateError('No copies left of "${request.bookTitle}".');

      tx.update(bookRef, {'availableQuantity': qty - 1, 'updatedAt': FieldValue.serverTimestamp()});
      tx.update(reqRef, {'status': BorrowStatus.approved, 'decidedAt': FieldValue.serverTimestamp()});
    });
  }

  static Future<void> decline(BorrowRequestModel request) {
    return _requests.doc(request.id).update({
      'status': BorrowStatus.declined,
      'decidedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Leader taps Returned: puts the copy back.
  static Future<void> markReturned(BorrowRequestModel request) {
    return _db.runTransaction((tx) async {
      final reqRef = _requests.doc(request.id);
      final bookRef = _db.collection('books').doc(request.bookId);
      final reqSnap = await tx.get(reqRef);
      final bookSnap = await tx.get(bookRef);
      if (!reqSnap.exists || reqSnap.data()!['status'] != BorrowStatus.approved) return;

      if (bookSnap.exists) {
        final qty = (bookSnap.data()!['availableQuantity'] as num?)?.toInt() ?? 0;
        tx.update(bookRef, {'availableQuantity': qty + 1, 'updatedAt': FieldValue.serverTimestamp()});
      }
      tx.update(reqRef, {'status': BorrowStatus.returned, 'decidedAt': FieldValue.serverTimestamp()});
    });
  }
}
