// Builds the attendance report (PDF / CSV) for ONE event from the existing
// `scanRecords` documents (the QR check-ins). Nothing is created or deleted
// in Firebase - this only reads.
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../models/event_model.dart';

class AttendanceRow {
  final String name;
  final String email; // scanned Elders/Members have no account; blank when unavailable
  final String role;
  final DateTime checkInAt;
  final String checkInTime;
  final String status;
  final String scannedBy;

  const AttendanceRow({
    required this.name,
    required this.email,
    required this.role,
    required this.checkInAt,
    required this.checkInTime,
    required this.status,
    required this.scannedBy,
  });
}

class AttendanceExportService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static final DateFormat _dateFmt = DateFormat('MMMM d, yyyy');

  /// Only people who actually scanned in for this event.
  Future<List<AttendanceRow>> loadAttendance(String eventId) async {
    final snap = await _db.collection('scanRecords').where('eventId', isEqualTo: eventId).get();
    final rows = snap.docs.map((d) {
      final m = d.data();
      final date = (m['date'] as Timestamp?)?.toDate() ?? (m['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
      final email = (m['scannedPersonEmail'] as String?) ?? '';
      return AttendanceRow(
        name: m['scannedPersonName'] as String? ?? '',
        email: email,
        role: m['scannedPersonRole'] as String? ?? '',
        checkInAt: date,
        checkInTime: m['time'] as String? ?? DateFormat('h:mm a').format(date),
        status: 'Present',
        scannedBy: m['scannedByName'] as String? ?? '',
      );
    }).toList()
      ..sort((a, b) => a.checkInAt.compareTo(b.checkInAt));
    return rows;
  }

  String _safeName(EventModel e) {
    final base = e.eventName.trim().isEmpty ? 'event' : e.eventName.trim();
    final cleaned = base.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_').replaceAll(RegExp(r'^_+|_+$'), '');
    return 'attendance_${cleaned.isEmpty ? 'event' : cleaned}_${DateFormat('yyyyMMdd').format(e.date)}';
  }

  Future<File> _writeTemp(String fileName, List<int> bytes) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  // ------------------------------------------------------------------ CSV
  Future<void> exportCsv(EventModel event) async {
    final rows = await loadAttendance(event.id);
    final data = <List<dynamic>>[
      ['Event Name', event.eventName],
      ['Event Date', _dateFmt.format(event.date)],
      ['Event Time', event.time],
      ['Event Location', event.place],
      ['Event Details', event.details],
      ['Total Attendees', rows.length],
      [],
      [
        'Attendee Name',
        'Attendee Email',
        'Role',
        'Check-in Date',
        'Check-in Time',
        'Attendance Status',
        'Scanned By',
      ],
      if (rows.isEmpty)
        ['No attendance records yet', '', '', '', '', '', '']
      else
        for (final r in rows)
          [
            r.name,
            r.email.isEmpty ? 'N/A' : r.email,
            r.role,
            _dateFmt.format(r.checkInAt),
            r.checkInTime,
            r.status,
            r.scannedBy,
          ],
    ];
    final csvText = const ListToCsvConverter().convert(data);
    // UTF-8 BOM so Excel opens accents / special characters correctly.
    final bytes = <int>[0xEF, 0xBB, 0xBF, ...utf8.encode(csvText)];
    final file = await _writeTemp('${_safeName(event)}.csv', bytes);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'text/csv')],
      subject: 'Attendance - ${event.eventName}',
    );
  }

  // ------------------------------------------------------------------ PDF
  Future<void> exportPdf(EventModel event) async {
    final rows = await loadAttendance(event.id);
    final doc = pw.Document();
    final generated = DateFormat('MMMM d, yyyy h:mm a').format(DateTime.now());

    pw.Widget infoLine(String label, String value) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 3),
          child: pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.SizedBox(width: 90, child: pw.Text('$label:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
            pw.Expanded(child: pw.Text(value.isEmpty ? '-' : value, style: const pw.TextStyle(fontSize: 10))),
          ]),
        );

    pw.Widget cell(String text, {bool header = false}) => pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: pw.Text(
            text,
            style: pw.TextStyle(fontSize: 9, fontWeight: header ? pw.FontWeight.bold : pw.FontWeight.normal),
          ),
        );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        footer: (ctx) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text('Page ${ctx.pageNumber} of ${ctx.pagesCount}', style: const pw.TextStyle(fontSize: 8)),
        ),
        build: (ctx) => [
          pw.Text('ChurchMate - Event Attendance Report',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.Text('ODB Presbyterian Church - Dayap Youth Ministry', style: const pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: 4),
          pw.Divider(),
          pw.SizedBox(height: 6),
          infoLine('Event Name', event.eventName),
          infoLine('Event Date', _dateFmt.format(event.date)),
          infoLine('Event Time', event.time),
          infoLine('Location', event.place),
          infoLine('Details', event.details),
          infoLine('Total Attendees', '${rows.length}'),
          infoLine('Generated', generated),
          pw.SizedBox(height: 12),
          pw.Text('Attendance Records', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          if (rows.isEmpty)
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey600)),
              child: pw.Text('No attendance records for this event yet.', style: const pw.TextStyle(fontSize: 11)),
            )
          else
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.5),
              columnWidths: {
                0: const pw.FixedColumnWidth(24),
                1: const pw.FlexColumnWidth(3),
                2: const pw.FlexColumnWidth(3),
                3: const pw.FlexColumnWidth(1.6),
                4: const pw.FlexColumnWidth(2.2),
                5: const pw.FlexColumnWidth(1.6),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    cell('#', header: true),
                    cell('Attendee Name', header: true),
                    cell('Attendee Email', header: true),
                    cell('Role', header: true),
                    cell('Check-in', header: true),
                    cell('Status', header: true),
                  ],
                ),
                for (var i = 0; i < rows.length; i++)
                  pw.TableRow(children: [
                    cell('${i + 1}'),
                    cell(rows[i].name),
                    cell(rows[i].email.isEmpty ? 'N/A' : rows[i].email),
                    cell(rows[i].role),
                    cell('${DateFormat('MMM d, yyyy').format(rows[i].checkInAt)}\n${rows[i].checkInTime}'),
                    cell(rows[i].status),
                  ]),
              ],
            ),
        ],
      ),
    );

    final bytes = await doc.save();
    final file = await _writeTemp('${_safeName(event)}.pdf', bytes);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/pdf')],
      subject: 'Attendance - ${event.eventName}',
    );
  }
}
