import 'package:flutter/material.dart';
import '../../../app/theme.dart';

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.margin, AppSpacing.md, AppSpacing.margin, AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)),
                Container(width: 28, height: 28, decoration: const BoxDecoration(color: AppColors.primary900, shape: BoxShape.circle), child: const Icon(Icons.church, color: Colors.white, size: 14)),
                const SizedBox(width: 8),
                Text('Event Details', style: AppTextStyles.headlineMd),
                const Spacer(),
                const CircleAvatar(radius: 16, backgroundColor: AppColors.primary300, child: Icon(Icons.person, color: Colors.white, size: 16)),
              ]),
              const SizedBox(height: AppSpacing.sm),
              Row(children: [_pill('Youth Fellowship', AppColors.primary700), const Spacer(), _pill('Live Now', AppColors.statusPending)]),
              const SizedBox(height: 6),
              Text('Youth Fellowship: Rooted & Grounded', style: AppTextStyles.headlineXlMobile),
              Row(children: [const Icon(Icons.groups_outlined, size: 14, color: AppColors.neutralMuted), const SizedBox(width: 4), Expanded(child: Text('Our Daily Bread Presbyterian Church - Dayap', style: AppTextStyles.bodySm))]),
              const SizedBox(height: AppSpacing.md),

              _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [Text('MEMORY & CORE PASSAGE', style: AppTextStyles.labelSm.copyWith(color: AppColors.accent500)), const Spacer(), const Icon(Icons.volume_up_outlined, size: 18, color: AppColors.neutralMuted)]),
                const SizedBox(height: 6),
                Text('"Rooted and built up in Him and established in the faith..."', style: AppTextStyles.bodyMd.copyWith(fontStyle: FontStyle.italic)),
                Text('Colossians 2:6-7', style: AppTextStyles.labelMd.copyWith(color: AppColors.primary700)),
              ]), goldBorder: true),
              const SizedBox(height: AppSpacing.sm),

              _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Live Attendance Tracker', style: AppTextStyles.headlineMd),
                    Text('ODB Sanctuary Youth Hall', style: AppTextStyles.bodySm),
                  ])),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text('48', style: AppTextStyles.headlineXlMobile),
                    Text('/ 65 expected', style: AppTextStyles.bodySm),
                  ]),
                ]),
                const SizedBox(height: 8),
                ClipRRect(borderRadius: BorderRadius.circular(AppRadius.full), child: LinearProgressIndicator(value: 48 / 65, minHeight: 8, backgroundColor: AppColors.primary300.withOpacity(0.2), valueColor: const AlwaysStoppedAnimation(AppColors.primary700))),
                const SizedBox(height: 4),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('74% Present', style: AppTextStyles.bodySm.copyWith(color: AppColors.statusSuccess)),
                  Text('17 Yet to Arrive', style: AppTextStyles.bodySm),
                ]),
                const SizedBox(height: AppSpacing.sm),
                Row(children: [
                  Expanded(child: ElevatedButton.icon(onPressed: () => Navigator.pushNamed(context, '/qr-display'), icon: const Icon(Icons.qr_code, size: 16), label: const Text('Display Event QR'), style: AppButtonStyles.primary)),
                  const SizedBox(width: 8),
                  Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.person_add_alt, size: 16), label: const Text('Manual Roll Call'), style: AppButtonStyles.secondary)),
                ]),
              ])),
              const SizedBox(height: AppSpacing.sm),

              Row(children: [
                Expanded(child: _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.primary700), const SizedBox(width: 4), Text('Date & Time', style: AppTextStyles.bodySm)]),
                  const SizedBox(height: 4),
                  Text('Sun, Oct 20, 2024', style: AppTextStyles.labelLg),
                  Text('4:00 PM - 6:30 PM', style: AppTextStyles.bodySm),
                ]))),
                const SizedBox(width: 8),
                Expanded(child: _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [const Icon(Icons.place_outlined, size: 14, color: AppColors.primary700), const SizedBox(width: 4), Text('Location', style: AppTextStyles.bodySm)]),
                  const SizedBox(height: 4),
                  Text('Main Sanctuary', style: AppTextStyles.labelLg),
                  Text('ODB Dayap, Calauan', style: AppTextStyles.bodySm),
                ]))),
              ]),
              const SizedBox(height: AppSpacing.sm),

              _card(child: Row(children: [
                const CircleAvatar(radius: 20, backgroundColor: AppColors.primary300, child: Icon(Icons.person, color: Colors.white)),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Preacher & Youth Lead', style: AppTextStyles.bodySm),
                  Text('Ptr. Samuel David & Sis. Hannah', style: AppTextStyles.labelLg),
                  Text('Youth Council • Series: Deeply Rooted', style: AppTextStyles.bodySm.copyWith(color: AppColors.primary700)),
                ])),
              ])),
              const SizedBox(height: AppSpacing.md),

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Program & Agenda', style: AppTextStyles.headlineMd),
                Text('4 Sessions', style: AppTextStyles.bodySm),
              ]),
              const SizedBox(height: AppSpacing.sm),
              _agendaItem('4:00 PM', '30m', 'Praise & Worship', 'Led by the ODB Youth Music Team', false),
              _agendaItem('4:30 PM', '30m', 'Icebreaker & Welcoming', "Get to know new attendees", false),
              _agendaItem('5:00 PM', '60m', 'Message & Small Groups', 'Colossians 2:6-7 with Pastor Samuel', true),
              _agendaItem('6:00 PM', '30m', 'Fellowship Snacks & Wrap Up', 'Warm bread, tea, open prayer circles', false),
              const SizedBox(height: AppSpacing.md),

              Text('Assigned Volunteers', style: AppTextStyles.headlineMd),
              const SizedBox(height: AppSpacing.sm),
              GridView.count(
                crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 2.6,
                children: [
                  _volunteerCard(Icons.music_note, 'Music Team', 'Caleb & Sarah', 'Ready'),
                  _volunteerCard(Icons.pan_tool_outlined, 'Ushering & Door', 'Mark & Joshua', 'Stationed'),
                  _volunteerCard(Icons.restaurant_outlined, 'Food & Snacks', 'Sis. Ruth', 'Preparing'),
                  _volunteerCard(Icons.videocam_outlined, 'Tech & Media', 'Dave & Leo', 'Live Stream'),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              Row(children: [
                Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.qr_code_scanner, size: 18), label: const Text('Check In with QR'), style: AppButtonStyles.secondary)),
                const SizedBox(width: 8),
                Expanded(child: ElevatedButton.icon(onPressed: () => Navigator.pushNamed(context, '/qr-display'), icon: const Icon(Icons.manage_accounts_outlined, size: 18), label: const Text('Manage QR'), style: AppButtonStyles.primary)),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card({required Widget child, bool goldBorder = false}) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.container), boxShadow: cardShadow,
        border: goldBorder ? const Border(left: BorderSide(color: AppColors.accent500, width: 4)) : null,
      ),
      child: child,
    );
  }

  Widget _pill(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(AppRadius.full)),
    child: Text(text, style: AppTextStyles.labelSm.copyWith(color: color)),
  );

  Widget _agendaItem(String time, String duration, String title, String desc, bool active) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: active ? AppColors.primary300.withOpacity(0.15) : Colors.transparent, borderRadius: BorderRadius.circular(AppRadius.base)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 60, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(time, style: AppTextStyles.labelMd), Text(duration, style: AppTextStyles.bodySm)])),
          Container(width: 8, height: 8, margin: const EdgeInsets.only(top: 4, right: 8), decoration: BoxDecoration(color: active ? AppColors.statusSuccess : AppColors.primary300, shape: BoxShape.circle)),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Text(title, style: AppTextStyles.labelLg), if (active) ...[const SizedBox(width: 6), _pill('Active', AppColors.statusSuccess)]]),
            Text(desc, style: AppTextStyles.bodySm),
          ])),
        ]),
      ),
    );
  }

  Widget _volunteerCard(IconData icon, String team, String names, String status) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.base), boxShadow: cardShadow),
      child: Row(children: [
        CircleAvatar(radius: 16, backgroundColor: AppColors.primary300.withOpacity(0.3), child: Icon(icon, size: 16, color: AppColors.primary900)),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(team, style: AppTextStyles.bodySm),
          Text(names, style: AppTextStyles.labelMd, overflow: TextOverflow.ellipsis),
          Text(status, style: AppTextStyles.bodySm.copyWith(color: AppColors.statusSuccess, fontSize: 10)),
        ])),
      ]),
    );
  }
}