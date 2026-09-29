import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../app/theme.dart';
import '../models/scan_record_model.dart';

/// Youth Leader only: full scan history (who was scanned, who scanned, when).
class ScanRecordsScreen extends StatelessWidget {
  const ScanRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stream = FirebaseFirestore.instance
        .collection('scanRecords')
        .orderBy('createdAt', descending: true)
        .limit(300)
        .snapshots();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Scan Records', style: AppTextStyles.headlineMd),
        iconTheme: const IconThemeData(color: AppColors.neutralDark),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: stream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Could not load scan records.', style: AppTextStyles.bodyMd));
            }
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final records = snapshot.data!.docs.map((d) => ScanRecordModel.fromMap(d.id, d.data())).toList();
            if (records.isEmpty) {
              return Center(child: Text('No scans recorded yet.', style: AppTextStyles.bodyMd));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.margin),
              itemCount: records.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final r = records[i];
                return Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.container), boxShadow: cardShadow),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(r.scannedPersonName, style: AppTextStyles.labelLg),
                    Text('${r.scannedPersonRole} - ${r.qrId}', style: AppTextStyles.bodySm),
                    const SizedBox(height: 6),
                    Text('Scanned by: ${r.scannedByName} (${r.scannedByRole})', style: AppTextStyles.bodySm),
                    Text('${DateFormat('MMMM d, yyyy').format(r.date)} at ${r.time}', style: AppTextStyles.bodySm),
                    if (r.eventName != null && r.eventName!.isNotEmpty)
                      Text('Event: ${r.eventName}', style: AppTextStyles.bodySm),
                  ]),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
