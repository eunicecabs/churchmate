// Mirrors the `scanRecords/{qrId_sessionKey}` Firestore document.
// scannedPerson* = who the physical QR belongs to.
// scannedBy*     = the signed-in Youth Member / Youth Leader who scanned.
import 'package:cloud_firestore/cloud_firestore.dart';

class ScanRecordModel {
  final String id;
  final String qrId;
  final String scannedPersonName;
  final String scannedPersonRole;
  final String scannedByUid;
  final String scannedByName;
  final String scannedByRole;
  final DateTime date;
  final String time; // display string, e.g. "9:05 AM"
  final String? eventId;
  final String? eventName;

  const ScanRecordModel({
    required this.id,
    required this.qrId,
    required this.scannedPersonName,
    required this.scannedPersonRole,
    required this.scannedByUid,
    required this.scannedByName,
    required this.scannedByRole,
    required this.date,
    required this.time,
    this.eventId,
    this.eventName,
  });

  factory ScanRecordModel.fromMap(String id, Map<String, dynamic> data) {
    return ScanRecordModel(
      id: id,
      qrId: data['qrId'] as String? ?? '',
      scannedPersonName: data['scannedPersonName'] as String? ?? '',
      scannedPersonRole: data['scannedPersonRole'] as String? ?? '',
      scannedByUid: data['scannedByUid'] as String? ?? '',
      scannedByName: data['scannedByName'] as String? ?? '',
      scannedByRole: data['scannedByRole'] as String? ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      time: data['time'] as String? ?? '',
      eventId: data['eventId'] as String?,
      eventName: data['eventName'] as String?,
    );
  }
}
