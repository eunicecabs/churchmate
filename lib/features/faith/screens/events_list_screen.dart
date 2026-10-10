import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/roles.dart';
import '../../../core/services/auth_service.dart';
import 'package:intl/intl.dart';
import '../../../app/theme.dart';
import '../../../app/routes.dart';
import '../models/event_model.dart';

class EventsListScreen extends StatefulWidget {
  const EventsListScreen({super.key});

  @override
  State<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final isLeader = context.watch<AuthService>().currentUser?.role == UserRole.leader;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.margin, AppSpacing.md, AppSpacing.margin, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.maybePop(context),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(color: AppColors.primary900, shape: BoxShape.circle),
                        child: const Icon(Icons.church, color: Colors.white, size: 14),
                      ),
                      const SizedBox(width: 8),
                      Text('ChurchMate', style: AppTextStyles.headlineMd),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Upcoming Events', style: AppTextStyles.headlineXlMobile),
                      if (isLeader)
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.eventForm),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Create'),
                        style: AppButtonStyles.primary.copyWith(
                          minimumSize: const WidgetStatePropertyAll(Size(0, 40)),
                          padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 14)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    decoration: appInputDecoration(label: 'Search events, places...', icon: Icons.search),
                    onChanged: (v) => setState(() => _search = v.trim().toLowerCase()),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance.collection('events').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Could not load events.', style: AppTextStyles.bodySm));
                  }

                  var events = (snapshot.data?.docs ?? [])
                      .map((d) => EventModel.fromMap(d.id, d.data()))
                      .toList()
                    ..sort((a, b) => a.date.compareTo(b.date));

                  if (_search.isNotEmpty) {
                    events = events
                        .where((e) =>
                            e.eventName.toLowerCase().contains(_search) ||
                            e.place.toLowerCase().contains(_search))
                        .toList();
                  }

                  if (events.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.event_busy, size: 48, color: AppColors.neutralMuted),
                            const SizedBox(height: AppSpacing.sm),
                            Text('No events available yet.', style: AppTextStyles.bodyMd),
                            const SizedBox(height: 4),
                            Text('Tap Create to add the first one.', style: AppTextStyles.bodySm),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.margin, AppSpacing.sm, AppSpacing.margin, AppSpacing.lg),
                    itemCount: events.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, i) => _eventCard(context, events[i], isLeader),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _bottomNav(context, isLeader),
    );
  }

  Widget _eventCard(BuildContext context, EventModel event, bool isLeader) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.eventDetail, arguments: event.id),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.container),
          boxShadow: cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary300.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppRadius.base),
                  ),
                  child: Column(children: [
                    Text(event.isToday ? 'TODAY' : DateFormat('MMM').format(event.date).toUpperCase(),
                        style: AppTextStyles.labelSm),
                    Text(DateFormat('d').format(event.date), style: AppTextStyles.headlineLgMobile),
                  ]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event.eventName, style: AppTextStyles.headlineMd),
                      Row(children: [
                        const Icon(Icons.access_time, size: 12, color: AppColors.neutralMuted),
                        const SizedBox(width: 4),
                        Expanded(
                            child: Text('${event.place}${event.time.isNotEmpty ? ' • ${event.time}' : ''}',
                                style: AppTextStyles.bodySm, overflow: TextOverflow.ellipsis)),
                      ]),
                      if (event.organizer != null && event.organizer!.isNotEmpty)
                        Text('Organizer: ${event.organizer}', style: AppTextStyles.bodySm),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.eventDetail, arguments: event.id),
                  icon: const Icon(Icons.info_outline, size: 16),
                  label: const Text('View Details'),
                  style: AppButtonStyles.secondary.copyWith(minimumSize: const WidgetStatePropertyAll(Size(0, 40))),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.attendanceScanner, arguments: event.id),
                  icon: const Icon(Icons.qr_code_scanner, size: 16),
                  label: const Text('Scan QR'),
                  style: AppButtonStyles.primary.copyWith(minimumSize: const WidgetStatePropertyAll(Size(0, 40))),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _bottomNav(BuildContext context, bool isLeader) {
    return Container(
      height: 65,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, -1))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(context, Icons.home_outlined, 'Home', false, AppRoutes.dashboard),
          _navItem(context, Icons.event, 'Events', true, AppRoutes.events),
          _navItem(context, Icons.menu_book_outlined, 'Library', false, AppRoutes.library),
          if (isLeader) _navItem(context, Icons.volunteer_activism_outlined, 'Giving', false, AppRoutes.finance),
        ],
      ),
    );
  }

  Widget _navItem(BuildContext context, IconData icon, String label, bool active, String? route) {
    return InkWell(
      onTap: () {
        if (route != null && !active) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: active ? AppColors.primary900 : AppColors.neutralMuted, size: 22),
          Text(label, style: TextStyle(fontSize: 10, color: active ? AppColors.primary900 : AppColors.neutralMuted)),
        ],
      ),
    );
  }
}
