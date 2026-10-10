// Mirrors the `events/{eventId}` Firestore document.
import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String eventName;
  final String place;
  final DateTime date;
  final String time; // stored as display string, e.g. "7:00 PM"
  final String details;
  final String? organizer;
  final int? maxParticipants;
  final bool attendanceRequired;
  final String createdBy; // uid of leader/admin who created it
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const EventModel({
    required this.id,
    required this.eventName,
    required this.place,
    required this.date,
    required this.time,
    required this.details,
    this.organizer,
    this.maxParticipants,
    this.attendanceRequired = false,
    required this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory EventModel.fromMap(String id, Map<String, dynamic> data) {
    return EventModel(
      id: id,
      eventName: data['eventName'] as String? ?? '',
      place: data['place'] as String? ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      time: data['time'] as String? ?? '',
      details: data['details'] as String? ?? '',
      organizer: data['organizer'] as String?,
      maxParticipants: data['maxParticipants'] as int?,
      attendanceRequired: data['attendanceRequired'] as bool? ?? false,
      createdBy: data['createdBy'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventName': eventName,
      'place': place,
      'date': Timestamp.fromDate(date),
      'time': time,
      'details': details,
      if (organizer != null) 'organizer': organizer,
      if (maxParticipants != null) 'maxParticipants': maxParticipants,
      'attendanceRequired': attendanceRequired,
      'createdBy': createdBy,
    };
  }

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool get isPast {
    final now = DateTime.now();
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    return endOfDay.isBefore(now);
  }
}
