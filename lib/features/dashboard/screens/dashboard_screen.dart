import 'package:flutter/material.dart';
import '../../../app/theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin, vertical: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top bar
              Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: const BoxDecoration(color: AppColors.primary900, shape: BoxShape.circle),
                    child: const Icon(Icons.church, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text('ChurchMate', style: AppTextStyles.headlineMd),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.primary300.withOpacity(0.3), borderRadius: BorderRadius.circular(AppRadius.full)),
                            child: Text('Youth Leader', style: AppTextStyles.labelSm.copyWith(color: AppColors.primary900)),
                          ),
                        ]),
                        Text('ODB Presbyterian Church – Dayap', style: AppTextStyles.bodySm),
                      ],
                    ),
                  ),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_outlined)),
                  const CircleAvatar(radius: 18, backgroundColor: AppColors.primary300, child: Icon(Icons.person, color: Colors.white, size: 18)),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Greeting
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Shalom, Sister Hannah!', style: AppTextStyles.headlineXlMobile),
                        const SizedBox(height: 2),
                        Text('Sunday, Oct 20, 2024', style: AppTextStyles.bodySm),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.primary300.withOpacity(0.25), borderRadius: BorderRadius.circular(AppRadius.full)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text('YOUTH LEADER', style: AppTextStyles.labelSm.copyWith(color: AppColors.primary900)),
                      const Icon(Icons.unfold_more, size: 14, color: AppColors.primary900),
                    ]),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Scripture card
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.container),
                  border: Border(left: BorderSide(color: AppColors.accent500, width: 4)),
                  boxShadow: cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.menu_book_outlined, size: 16, color: AppColors.accent500),
                      const SizedBox(width: 6),
                      Text('DAILY SCRIPTURE VERSE', style: AppTextStyles.labelSm),
                      const Spacer(),
                      const Icon(Icons.volume_up_outlined, size: 18, color: AppColors.neutralMuted),
                    ]),
                    const SizedBox(height: 8),
                    Text(
                      '"Don\'t let anyone look down on you because you are young, but set an example for the believers in speech, in conduct, in love, in faith and in purity."',
                      style: AppTextStyles.bodyMd.copyWith(fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 8),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('1 Timothy 4:12', style: AppTextStyles.labelMd.copyWith(color: AppColors.primary700)),
                      Row(children: [
                        const Icon(Icons.check_circle, size: 14, color: AppColors.statusSuccess),
                        const SizedBox(width: 4),
                        Text('Memorized', style: AppTextStyles.bodySm),
                      ]),
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Quick actions
              Text('QUICK MINISTRY ACTIONS', style: AppTextStyles.labelSm),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _quickAction(Icons.qr_code_2, 'Event\nCheck-In', AppColors.primary900, Colors.white),
                  _quickAction(Icons.menu_book, 'Borrow\nBook', AppColors.primary300.withOpacity(0.4), AppColors.primary900),
                  _quickAction(Icons.volunteer_activism, 'Give /\nRecord', AppColors.accent500.withOpacity(0.3), AppColors.accent500),
                  _quickAction(Icons.badge_outlined, 'Leader\nQR', AppColors.neutralMuted.withOpacity(0.15), AppColors.neutralDark),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Ministry Overview
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Ministry Overview', style: AppTextStyles.headlineMd),
                Row(children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.statusSuccess, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text('Live Sync', style: AppTextStyles.bodySm),
                ]),
              ]),
              const SizedBox(height: AppSpacing.sm),

              // Event card
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.container), boxShadow: cardShadow),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: AppColors.primary300.withOpacity(0.2), borderRadius: BorderRadius.circular(AppRadius.base)),
                          child: Column(children: [
                            Text('OCT', style: AppTextStyles.labelSm),
                            Text('20', style: AppTextStyles.headlineLgMobile),
                          ]),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                _pill('Today • 4:00 PM', AppColors.statusSuccess),
                                const SizedBox(width: 6),
                                _pill('In 2h 45m', AppColors.statusPending),
                              ]),
                              const SizedBox(height: 4),
                              Text('Youth Sunday Fellowship', style: AppTextStyles.headlineMd),
                              Text('ODB Sanctuary Hall', style: AppTextStyles.bodySm),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Row(children: [
                        const Icon(Icons.groups, size: 16, color: AppColors.neutralMuted),
                        const SizedBox(width: 4),
                        Text('RSVP Check-in', style: AppTextStyles.bodySm),
                      ]),
                      Text('42 / 65 expected', style: AppTextStyles.labelMd),
                    ]),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      child: LinearProgressIndicator(
                        value: 42 / 65, minHeight: 8,
                        backgroundColor: AppColors.primary300.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation(AppColors.primary700),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('65% confirmed', style: AppTextStyles.bodySm.copyWith(color: AppColors.statusSuccess)),
                      Text('23 pending doors', style: AppTextStyles.bodySm),
                    ]),
                    const SizedBox(height: AppSpacing.sm),
                    Row(children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pushNamed(context, '/qr-display'),
                          icon: const Icon(Icons.groups, size: 18),
                          label: const Text('View Roster & QR'),
                          style: AppButtonStyles.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.outlined(onPressed: () {}, icon: const Icon(Icons.share_outlined)),
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Active borrows
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.container), boxShadow: cardShadow),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('Your Active Borrows', style: AppTextStyles.headlineMd),
                      Text('Explore 140+ →', style: AppTextStyles.bodySm.copyWith(color: AppColors.primary700)),
                    ]),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Container(
                          width: 48, height: 64,
                          decoration: BoxDecoration(color: AppColors.primary300.withOpacity(0.3), borderRadius: BorderRadius.circular(6)),
                          child: const Icon(Icons.menu_book, color: AppColors.primary900),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Knowing God', style: AppTextStyles.labelLg),
                              Text('J.I. Packer • Theological', style: AppTextStyles.bodySm),
                              const SizedBox(height: 4),
                              Row(children: [_pill('Due in 4 days', AppColors.statusPending), const SizedBox(width: 6), Text('Oct 24', style: AppTextStyles.bodySm)]),
                            ],
                          ),
                        ),
                        OutlinedButton(onPressed: () {}, style: AppButtonStyles.secondary.copyWith(minimumSize: const WidgetStatePropertyAll(Size(80, 36))), child: const Text('Renew')),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Ministry fund
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.container), boxShadow: cardShadow),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Row(children: [
                        const Icon(Icons.account_balance_wallet_outlined, size: 18, color: AppColors.accent500),
                        const SizedBox(width: 6),
                        Text('Youth Ministry Fund', style: AppTextStyles.headlineMd),
                      ]),
                      Text('Ledger ↗', style: AppTextStyles.bodySm.copyWith(color: AppColors.primary700)),
                    ]),
                    const SizedBox(height: AppSpacing.sm),
                    Text('CURRENT VERIFIED BALANCE', style: AppTextStyles.labelSm),
                    Row(children: [
                      Text('₱18,450.00', style: AppTextStyles.headlineXlMobile),
                      const SizedBox(width: 8),
                      _pill('+₱6,200 this mo.', AppColors.statusSuccess),
                    ]),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: AppColors.accent500.withOpacity(0.12), borderRadius: BorderRadius.circular(AppRadius.base)),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('₱1,250.00 • Fellowship', style: AppTextStyles.labelMd),
                                Text('Requested by Deacon Mark • Oct 19', style: AppTextStyles.bodySm),
                              ],
                            ),
                          ),
                          _pill('Pending Approval', AppColors.statusPending),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _BottomNav(),
    );
  }

  Widget _quickAction(IconData icon, String label, Color bg, Color fg) {
    return Column(
      children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadius.container)),
          child: Icon(icon, color: fg),
        ),
        const SizedBox(height: 6),
        Text(label, textAlign: TextAlign.center, style: AppTextStyles.bodySm),
      ],
    );
  }

  Widget _pill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(AppRadius.full)),
      child: Text(text, style: AppTextStyles.labelSm.copyWith(color: color)),
    );
  }
}

class _BottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(color: AppColors.surface, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, -1))]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home, 'Home', true),
          _navItem(Icons.event_outlined, 'Events', false),
          _scanButton(),
          _navItem(Icons.menu_book_outlined, 'Library', false),
          _navItem(Icons.volunteer_activism_outlined, 'Giving', false),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool active) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: active ? AppColors.primary900 : AppColors.neutralMuted, size: 22),
        Text(label, style: TextStyle(fontSize: 10, color: active ? AppColors.primary900 : AppColors.neutralMuted)),
      ],
    );
  }

  Widget _scanButton() {
    return Container(
      width: 44, height: 44,
      decoration: const BoxDecoration(color: AppColors.primary900, shape: BoxShape.circle),
      child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 20),
    );
  }
}