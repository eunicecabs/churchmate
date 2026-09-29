import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../app/theme.dart';
import '../../../app/routes.dart';
import '../../../core/constants/roles.dart';
import '../../../core/services/auth_service.dart';
import '../models/event_model.dart';

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key});

  Future<void> _confirmDelete(BuildContext context, String eventId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.container)),
        title: const Text('Delete this event?'),
        content: const Text('This cannot be undone. Attendance history for this event will remain, but the event itself will be removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.statusAlert),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await FirebaseFirestore.instance.collection('events').doc(eventId).delete();
    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event deleted.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventId = ModalRoute.of(context)!.settings.arguments as String;
    final isLeader = context.watch<AuthService>().currentUser?.role == UserRole.leader;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('events').doc(eventId).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(child: Text('This event no longer exists.', style: AppTextStyles.bodyMd));
            }

            final event = EventModel.fromMap(snapshot.data!.id, snapshot.data!.data()!);
            final canManage = isLeader; // only the Youth Leader edits/deletes events

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(AppSpacing.margin, AppSpacing.md, AppSpacing.margin, AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)),
                    Expanded(child: Text('Event Details', style: AppTextStyles.headlineMd)),
                    if (canManage) ...[
                      IconButton(
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.eventForm, arguments: event.id),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        onPressed: () => _confirmDelete(context, event.id),
                        icon: const Icon(Icons.delete_outline, color: AppColors.statusAlert),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 6),
                  Text(event.eventName, style: AppTextStyles.headlineXlMobile),
                  Row(children: [
                    const Icon(Icons.place_outlined, size: 14, color: AppColors.neutralMuted),
                    const SizedBox(width: 4),
                    Expanded(child: Text(event.place, style: AppTextStyles.bodySm)),
                  ]),
                  const SizedBox(height: AppSpacing.md),

                  Row(children: [
                    Expanded(
                        child: _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.primary700),
                        const SizedBox(width: 4),
                        Text('Date & Time', style: AppTextStyles.bodySm),
                      ]),
                      const SizedBox(height: 4),
                      Text(DateFormat('EEE, MMM d, yyyy').format(event.date), style: AppTextStyles.labelLg),
                      Text(event.time, style: AppTextStyles.bodySm),
                    ]))),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        const Icon(Icons.groups_outlined, size: 14, color: AppColors.primary700),
                        const SizedBox(width: 4),
                        Text('Capacity', style: AppTextStyles.bodySm),
                      ]),
                      const SizedBox(height: 4),
                      Text(event.maxParticipants?.toString() ?? 'No limit', style: AppTextStyles.labelLg),
                      if (event.organizer != null) Text('By ${event.organizer}', style: AppTextStyles.bodySm),
                    ]))),
                  ]),
                  const SizedBox(height: AppSpacing.sm),

                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Details', style: AppTextStyles.headlineMd),
                        const SizedBox(height: 6),
                        Text(event.details, style: AppTextStyles.bodyMd),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Live Attendance = Elders/Members scanned for THIS event.
                  // Everyone can see the count (scanMarkers hold no names or
                  // scanner info); only Youth Leaders see the names list.
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('scanMarkers')
                        .where('eventId', isEqualTo: event.id)
                        .snapshots(),
                    builder: (context, attSnapshot) {
                      final count = attSnapshot.data?.docs.length ?? 0;
                      return _card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Expanded(
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text('Live Attendance', style: AppTextStyles.headlineMd),
                              ])),
                              Text('$count', style: AppTextStyles.headlineXlMobile),
                              const SizedBox(width: 4),
                              Text(event.maxParticipants != null ? '/ ${event.maxParticipants}' : 'checked in',
                                  style: AppTextStyles.bodySm),
                            ]),
                            const SizedBox(height: AppSpacing.sm),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    Navigator.pushNamed(context, AppRoutes.attendanceScanner, arguments: event.id),
                                icon: const Icon(Icons.qr_code_scanner, size: 16),
                                label: const Text('Scan QR'),
                                style: AppButtonStyles.primary,
                              ),
                            ),
                            if (isLeader) _attendeeList(event.id),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _attendeeList(String eventId) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('scanRecords').where('eventId', isEqualTo: eventId).snapshots(),
      builder: (context, snap) {
        final docs = [...(snap.data?.docs ?? [])]
          ..sort((a, b) => ((a.data()['date'] as Timestamp?)?.millisecondsSinceEpoch ?? 0)
              .compareTo((b.data()['date'] as Timestamp?)?.millisecondsSinceEpoch ?? 0));
        if (docs.isEmpty) return const SizedBox.shrink();
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: AppSpacing.sm),
          const Divider(height: 1),
          const SizedBox(height: 6),
          for (final d in docs)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(children: [
                Expanded(
                  child: Text('${d.data()['scannedPersonName'] ?? ''} (${d.data()['scannedPersonRole'] ?? ''})',
                      style: AppTextStyles.bodyMd),
                ),
                Text(d.data()['time'] as String? ?? '', style: AppTextStyles.bodySm),
              ]),
            ),
        ]);
      },
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.container), boxShadow: cardShadow),
      child: child,
    );
  }
}
