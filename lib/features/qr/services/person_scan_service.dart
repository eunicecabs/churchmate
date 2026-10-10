// Scanning a physical Elder/Member QR (payload is just the ID, e.g. "ELD-0001").
//
// WHO WAS SCANNED  -> the QR ID, looked up in `qrRegistry`.
// WHO SCANNED      -> the signed-in Firebase user (Youth Member / Youth Leader).
//
// Duplicate protection: the record id is deterministic
//   "<qrId>_<eventId>"  when scanning from an event page (or exactly one
//                       event is scheduled today), else "<qrId>_<yyyyMMdd>"
// and a tiny `scanMarkers` doc with the same id is written in the same batch.
// Youth Members cannot read `scanRecords`, but they CAN read one marker by id,
// which is how "Already recorded at 9:05 AM" works without exposing history.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/roles.dart';
import '../../../shared/models/app_user.dart';
import '../models/qr_person_model.dart';

enum PersonScanStatus { success, alreadyScanned, notFound, inactive, error }

class PersonScanResult {
  final PersonScanStatus status;
  final String message;
  final String? personName;
  final String? personRole;
  final String? time;
  const PersonScanResult(this.status, this.message, {this.personName, this.personRole, this.time});
}

class PersonScanService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static final RegExp _qrIdPattern = RegExp(r'^(ELD|MEM)-\d{4,}$');

  /// True when [raw] is an Elder/Member QR ID (as opposed to an event QR).
  static bool isPersonQr(String raw) => _qrIdPattern.hasMatch(raw.trim().toUpperCase());

  static String scannerRoleLabel(AppUser user) =>
      user.role == UserRole.leader ? 'Youth Leader' : 'Youth Member';

  Future<PersonScanResult> scan({required String rawCode, required AppUser scanner, String? eventId}) async {
    final qrId = rawCode.trim().toUpperCase();
    try {
      final personDoc = await _db.collection('qrRegistry').doc(qrId).get();
      if (!personDoc.exists) {
        return const PersonScanResult(PersonScanStatus.notFound, 'This QR ID is not registered.');
      }
      final person = QrPerson.fromMap(personDoc.id, personDoc.data()!);
      if (!person.active) {
        return PersonScanResult(PersonScanStatus.inactive, 'This QR ID has been deactivated.',
            personName: person.name, personRole: person.role);
      }

      final now = DateTime.now();
      final session = eventId != null ? await _eventSession(eventId) : await _todaySession(now);
      final sessionKey = session?.id ?? DateFormat('yyyyMMdd').format(now);
      final key = '${qrId}_$sessionKey';

      final markerRef = _db.collection('scanMarkers').doc(key);
      final marker = await markerRef.get();
      if (marker.exists) {
        return _already(person, marker.data()?['time'] as String?);
      }

      final time = DateFormat('h:mm a').format(now);
      final batch = _db.batch();
      batch.set(_db.collection('scanRecords').doc(key), {
        'qrId': qrId,
        'scannedPersonName': person.name,
        'scannedPersonRole': person.role,
        'scannedByUid': scanner.id,
        'scannedByName': scanner.fullName,
        'scannedByRole': scannerRoleLabel(scanner),
        'date': Timestamp.fromDate(now),
        'time': time,
        'sessionKey': sessionKey,
        if (session != null) 'eventId': session.id,
        if (session != null) 'eventName': session.name,
        'createdAt': FieldValue.serverTimestamp(),
      });
      batch.set(markerRef, {
        'qrId': qrId,
        'time': time,
        if (session != null) 'eventId': session.id,
        'createdAt': FieldValue.serverTimestamp(),
      });

      try {
        await batch.commit();
      } on FirebaseException {
        // Two devices scanning at the same moment: the second create is
        // rejected by the rules. Treat it as a duplicate if the marker exists.
        final again = await markerRef.get();
        if (again.exists) return _already(person, again.data()?['time'] as String?);
        rethrow;
      }

      return PersonScanResult(PersonScanStatus.success, 'Scan recorded.',
          personName: person.name, personRole: person.role, time: time);
    } catch (_) {
      return const PersonScanResult(PersonScanStatus.error, 'Could not record the scan. Check your connection and try again.');
    }
  }

  PersonScanResult _already(QrPerson person, String? time) {
    return PersonScanResult(
      PersonScanStatus.alreadyScanned,
      time == null || time.isEmpty ? 'Already recorded.' : 'Already recorded at $time.',
      personName: person.name,
      personRole: person.role,
      time: time,
    );
  }

  Future<({String id, String name})?> _eventSession(String eventId) async {
    try {
      final d = await _db.collection('events').doc(eventId).get();
      if (!d.exists) return null;
      return (id: d.id, name: d.data()?['eventName'] as String? ?? '');
    } catch (_) {
      return null;
    }
  }

  /// If exactly one event is scheduled today, scans belong to that event.
  /// Otherwise the session is simply "today".
  Future<({String id, String name})?> _todaySession(DateTime now) async {
    try {
      final start = DateTime(now.year, now.month, now.day);
      final end = start.add(const Duration(days: 1));
      final snap = await _db
          .collection('events')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('date', isLessThan: Timestamp.fromDate(end))
          .get();
      if (snap.docs.length != 1) return null;
      final d = snap.docs.first;
      return (id: d.id, name: d.data()['eventName'] as String? ?? '');
    } catch (_) {
      return null;
    }
  }
}
