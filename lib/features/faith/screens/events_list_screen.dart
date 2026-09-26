import 'package:flutter/material.dart';
import '../../../app/theme.dart';

class EventsListScreen extends StatefulWidget {
  const EventsListScreen({super.key});

  @override
  State<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> {
  String _filter = 'All';
  final _filters = ['All', 'Worship Service', 'Bible Study', 'Youth Fellowship'];

  @override
  Widget build(BuildContext context) {
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
                        onPressed: () => Navigator.pop(context), 
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
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), 
                        decoration: BoxDecoration(
                          color: AppColors.primary300.withOpacity(0.3), 
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ), 
                        child: Text('Youth Leader', style: AppTextStyles.labelSm.copyWith(color: AppColors.primary900)),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Upcoming Events', style: AppTextStyles.headlineXlMobile),
                      ElevatedButton.icon(
                        onPressed: () {},
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
                  TextField(decoration: appInputDecoration(label: 'Search events, themes...', icon: Icons.search)),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _filters.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final selected = _filters[i] == _filter;
                        return GestureDetector(
                          onTap: () => setState(() => _filter = _filters[i]),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected ? AppColors.primary900 : AppColors.surface,
                              borderRadius: BorderRadius.circular(AppRadius.full),
                              border: Border.all(color: selected ? AppColors.primary900 : AppColors.primary300.withOpacity(0.4)),
                            ),
                            child: Center(
                              child: Text(
                                _filters[i], 
                                style: AppTextStyles.labelMd.copyWith(color: selected ? Colors.white : AppColors.neutralDark),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.margin, 0, AppSpacing.margin, AppSpacing.lg),
                children: [
                  _eventCard(
                    context, tagLabel: 'Youth Fellowship', tagColor: AppColors.primary700,
                    statusLabel: 'ONGOING • LIVE CHECK-IN ACTIVE', statusColor: AppColors.statusPending,
                    day: 'TODAY', date: '20', dateSub: 'Sun',
                    title: "Youth Fellowship: Rooted & Grounded",
                    subtitle: '4:00 PM • Main Sanctuary', leader: 'Leader: Ptr. Caleb Cruz',
                    footer: '48 checked in', footerIcon: Icons.groups, footerExtra: '🔴 Room filling',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _eventCard(
                    context, tagLabel: 'Worship Service', tagColor: AppColors.primary700,
                    statusLabel: null, statusColor: null,
                    day: 'OCT', date: '27', dateSub: 'Sun',
                    title: 'Sunday Worship Service',
                    subtitle: '9:00 AM • Sanctuary', leader: 'Worship Leader: Sis. Hannah & Band',
                    footer: '82 Expected Attendees', footerIcon: Icons.person_outline, footerExtra: 'Liturgical • Communion',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _eventCard(
                    context, tagLabel: 'Bible Study', tagColor: AppColors.accent500,
                    statusLabel: null, statusColor: null,
                    day: 'OCT', date: '23', dateSub: 'Wed',
                    title: 'Midweek Youth Bible Study: James',
                    subtitle: '7:00 PM • Fellowship Hall', leader: 'Speaker: Bro. Joshua Ramos',
                    footer: '28 Registered', footerIcon: Icons.groups, footerExtra: 'Bring study notebooks',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _eventCard(
                    context, tagLabel: 'Outreach • Mission', tagColor: AppColors.statusPending,
                    statusLabel: null, statusColor: null,
                    day: 'NOV', date: '02', dateSub: 'Sat',
                    title: 'Barangay Dayap Community Outreach',
                    subtitle: '8:00 AM • Dayap Covered Court', leader: 'Mission Lead: Deaconess Ruth',
                    footer: 'Volunteers Mobilized', footerIcon: Icons.volunteer_activism, footerExtra: '24 / 35 joined',
                    showProgress: true, progressValue: 24 / 35,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _bottomNav(context),
    );
  }

  Widget _eventCard(BuildContext context, {
    required String tagLabel, required Color tagColor,
    String? statusLabel, Color? statusColor,
    required String day, required String date, required String dateSub,
    required String title, required String subtitle, required String leader,
    required String footer, required IconData footerIcon, required String footerExtra,
    bool showProgress = false, double progressValue = 0,
  }) {
    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween, 
            children: [
              _pill(tagLabel, tagColor),
              if (statusLabel != null) _pill(statusLabel, statusColor!),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary300.withOpacity(0.2), 
                  borderRadius: BorderRadius.circular(AppRadius.base),
                ),
                child: Column(children: [
                  Text(day, style: AppTextStyles.labelSm),
                  Text(date, style: AppTextStyles.headlineLgMobile),
                ]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.headlineMd),
                    Row(children: [
                      const Icon(Icons.access_time, size: 12, color: AppColors.neutralMuted), 
                      const SizedBox(width: 4), 
                      Text(subtitle, style: AppTextStyles.bodySm),
                    ]),
                    Text(leader, style: AppTextStyles.bodySm),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.background, 
              borderRadius: BorderRadius.circular(AppRadius.base),
            ),
            child: showProgress
                ? Column(children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                      children: [
                        Text(footer, style: AppTextStyles.bodySm),
                        Text(footerExtra, style: AppTextStyles.labelMd),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.full), 
                      child: LinearProgressIndicator(
                        value: progressValue, 
                        minHeight: 6, 
                        backgroundColor: AppColors.primary300.withOpacity(0.2), 
                        valueColor: const AlwaysStoppedAnimation(AppColors.primary700),
                      ),
                    ),
                  ])
                : Row(children: [
                    Icon(footerIcon, size: 14, color: AppColors.neutralMuted),
                    const SizedBox(width: 4),
                    Text(footer, style: AppTextStyles.bodySm),
                    const Spacer(),
                    Flexible(child: Text(footerExtra, style: AppTextStyles.bodySm, overflow: TextOverflow.ellipsis)),
                  ]),
          ),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                // Safely show details modal or navigate to distinct screen
                onPressed: () {
                  showModalBottomSheet(
                    context: context, 
                    builder: (_) => Container(
                      padding: const EdgeInsets.all(16), 
                      child: Text(title, style: AppTextStyles.headlineMd),
                    ),
                  );
                }, 
                icon: const Icon(Icons.info_outline, size: 16), 
                label: const Text('View Details'), 
                style: AppButtonStyles.secondary.copyWith(minimumSize: const WidgetStatePropertyAll(Size(0, 40))),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/qr-display'), 
                icon: const Icon(Icons.qr_code, size: 16), 
                label: const Text('Check-In QR'), 
                style: AppButtonStyles.primary.copyWith(minimumSize: const WidgetStatePropertyAll(Size(0, 40))),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _pill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(AppRadius.full)),
      child: Text(text, style: AppTextStyles.labelSm.copyWith(color: color)),
    );
  }

  Widget _bottomNav(BuildContext context) {
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
          _navItem(context, Icons.home_outlined, 'Home', false, '/dashboard'),
          _navItem(context, Icons.event, 'Events', true, '/events'),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/qr-display'),
            child: Container(
              width: 44, 
              height: 44, 
              decoration: const BoxDecoration(color: AppColors.primary900, shape: BoxShape.circle), 
              child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 20),
            ),
          ),
          _navItem(context, Icons.menu_book_outlined, 'Library', false, null),
          _navItem(context, Icons.volunteer_activism_outlined, 'Giving', false, null),
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