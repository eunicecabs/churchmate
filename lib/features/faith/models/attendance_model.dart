// Mirrors the `attendance/{attendanceId}` Firestore document.
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceModel {
  final String id;
  final String eventId;
  final String userId;
  final String userName;
  final String eventName;
  final DateTime date;
  final String time; // display string, e.g. "7:05 PM"
  final String status; // 'Present'
  final DateTime? createdAt;

  const AttendanceModel({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.userName,
    required this.eventName,
    required this.date,
    required this.time,
    this.status = 'Present',
    this.createdAt,
  });

  factory AttendanceModel.fromMap(String id, Map<String, dynamic> data) {
    return AttendanceModel(
      id: id,
      eventId: data['eventId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? '',
      eventName: data['eventName'] as String? ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      time: data['time'] as String? ?? '',
      status: data['status'] as String? ?? 'Present',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'userId': userId,
      'userName': userName,
      'eventName': eventName,
      'date': Timestamp.fromDate(date),
      'time': time,
      'status': status,
    };
  }

  /// Deterministic doc id so `eventId + userId` can never create two
  /// attendance records for the same person at the same event.
  static String docId(String eventId, String userId) => '${eventId}_$userId';
}
