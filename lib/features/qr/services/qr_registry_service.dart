// Youth Leader-only management of the Elder/Member QR registry.
// IDs are generated with a Firestore transaction on a counter document so two
// leaders can never receive the same ELD-/MEM- number.
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/qr_person_model.dart';

class QrRegistryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _registry => _db.collection('qrRegistry');

  Stream<List<QrPerson>> streamAll() {
    return _registry.orderBy('qrId').snapshots().map(
          (s) => s.docs.map((d) => QrPerson.fromMap(d.id, d.data())).toList(),
        );
  }

  /// Registers a new Elder/Member and returns it (with its generated QR ID).
  Future<QrPerson> create({required String name, required String role, required String createdBy}) {
    final isElder = role == QrPerson.roleElder;
    final prefix = isElder ? 'ELD' : 'MEM';
    final field = isElder ? 'eld' : 'mem';
    final counterRef = _db.collection('counters').doc('qrRegistry');

    return _db.runTransaction<QrPerson>((tx) async {
      final snap = await tx.get(counterRef);
      final next = ((snap.data()?[field] as num?)?.toInt() ?? 0) + 1;
      final qrId = '$prefix-${next.toString().padLeft(4, '0')}';

      tx.set(counterRef, {field: next}, SetOptions(merge: true));
      tx.set(_registry.doc(qrId), {
        'name': name,
        'role': role,
        'qrId': qrId,
        'createdBy': createdBy,
        'active': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return QrPerson(id: qrId, name: name, role: role, qrId: qrId, createdBy: createdBy);
    });
  }

  Future<void> rename(String qrId, String name) => _registry.doc(qrId).update({'name': name});

  Future<void> setActive(String qrId, bool active) => _registry.doc(qrId).update({'active': active});

  Future<void> delete(String qrId) => _registry.doc(qrId).delete();
}
