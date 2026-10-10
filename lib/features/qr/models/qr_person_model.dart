// Mirrors the `qrRegistry/{qrId}` Firestore document: an Elder or Member who
// has NO app account and is identified only by the printed QR (e.g. ELD-0001).
import 'package:cloud_firestore/cloud_firestore.dart';

class QrPerson {
  static const roleElder = 'Elder';
  static const roleMember = 'Member';

  final String id; // == qrId, also the Firestore doc id
  final String name;
  final String role; // roleElder or roleMember
  final String qrId;
  final String createdBy; // Youth Leader UID
  final bool active;
  final DateTime? createdAt;

  const QrPerson({
    required this.id,
    required this.name,
    required this.role,
    required this.qrId,
    required this.createdBy,
    this.active = true,
    this.createdAt,
  });

  factory QrPerson.fromMap(String id, Map<String, dynamic> data) {
    return QrPerson(
      id: id,
      name: data['name'] as String? ?? '',
      role: data['role'] as String? ?? roleMember,
      qrId: data['qrId'] as String? ?? id,
      createdBy: data['createdBy'] as String? ?? '',
      active: data['active'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
