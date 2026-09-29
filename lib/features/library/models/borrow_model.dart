// Mirrors the `borrowRequests/{requestId}` Firestore document.
//
// Flow: a Youth Member taps "Borrow" -> a `pending` request is created ->
// the Youth Leader sees it on their dashboard / library page and taps
// Accept (status `approved`, book copies -1) or Decline (`declined`).
// When the book comes back the leader taps Returned (`returned`, copies +1).
import 'package:cloud_firestore/cloud_firestore.dart';

class BorrowStatus {
  static const pending = 'pending';
  static const approved = 'approved';
  static const declined = 'declined';
  static const returned = 'returned';
}

class BorrowRequestModel {
  final String id;
  final String bookId;
  final String bookTitle;
  final String userId;
  final String userName;
  final String status;
  final DateTime? requestedAt;
  final DateTime? decidedAt;

  const BorrowRequestModel({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.userId,
    required this.userName,
    required this.status,
    this.requestedAt,
    this.decidedAt,
  });

  bool get isPending => status == BorrowStatus.pending;
  bool get isApproved => status == BorrowStatus.approved;

  factory BorrowRequestModel.fromMap(String id, Map<String, dynamic> data) {
    return BorrowRequestModel(
      id: id,
      bookId: data['bookId'] as String? ?? '',
      bookTitle: data['bookTitle'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? '',
      status: data['status'] as String? ?? BorrowStatus.pending,
      requestedAt: (data['requestedAt'] as Timestamp?)?.toDate(),
      decidedAt: (data['decidedAt'] as Timestamp?)?.toDate(),
    );
  }
}
