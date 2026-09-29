import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../app/theme.dart';
import '../../../app/routes.dart';
import '../../../core/constants/roles.dart';
import '../../../core/services/auth_service.dart';
import '../../../shared/widgets/book_cover.dart';
import '../../faith/models/event_model.dart';
import '../../finance/models/transaction_model.dart';
import '../../library/models/book_model.dart';
import '../../library/widgets/borrow_button.dart';
import '../../library/widgets/borrow_requests_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;
    final isLeader = user?.role == UserRole.leader;

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
                    width: 40,
                    height: 40,
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
                            decoration: BoxDecoration(
                                color: AppColors.primary300.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(AppRadius.full)),
                            child: Text(isLeader ? 'Youth Leader' : 'Youth Member',
                                style: AppTextStyles.labelSm.copyWith(color: AppColors.primary900)),
                          ),
                        ]),
                        Text('ODB Presbyterian Church – Dayap', style: AppTextStyles.bodySm),
                      ],
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primary300,
                      backgroundImage:
                          user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
                      child: user?.photoUrl == null
                          ? const Icon(Icons.person, color: Colors.white, size: 18)
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Dynamic greeting — never hardcoded, always the signed-in user's name.
              Text('Hello, ${user?.displayName ?? '...'}!', style: AppTextStyles.headlineXlMobile),
              const SizedBox(height: 2),
              Text(DateFormat('EEEE, MMM d, yyyy').format(DateTime.now()), style: AppTextStyles.bodySm),
              const SizedBox(height: AppSpacing.md),

              // Scripture card (ministry theme, not user data)
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.container),
                  border: const Border(left: BorderSide(color: AppColors.accent500, width: 4)),
                  boxShadow: cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.menu_book_outlined, size: 16, color: AppColors.accent500),
                      const SizedBox(width: 6),
                      Text('DAILY SCRIPTURE VERSE', style: AppTextStyles.labelSm),
                    ]),
                    const SizedBox(height: 8),
                    Text(
                      '"Don\'t let anyone look down on you because you are young, but set an example for the believers in speech, in conduct, in love, in faith and in purity."',
                      style: AppTextStyles.bodyMd.copyWith(fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 8),
                    Text('1 Timothy 4:12', style: AppTextStyles.labelMd.copyWith(color: AppColors.primary700)),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Quick actions
              Text('QUICK MINISTRY ACTIONS', style: AppTextStyles.labelSm),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: isLeader ? MainAxisAlignment.spaceBetween : MainAxisAlignment.spaceEvenly,
                children: [
                  _quickAction(context, Icons.menu_book, 'Library', AppColors.primary300.withValues(alpha: 0.4),
                      AppColors.primary900, AppRoutes.library),
                  // Giving is for Youth Leaders only.
                  if (isLeader)
                    _quickAction(context, Icons.volunteer_activism, 'Giving', AppColors.accent500.withValues(alpha: 0.3),
                        AppColors.accent500, AppRoutes.finance),
                  _quickAction(context, Icons.event, 'Events', AppColors.neutralMuted.withValues(alpha: 0.15),
                      AppColors.neutralDark, AppRoutes.events),
                ],
              ),
              // QR tools for Youth Leaders only (Elder/Member QR registry + scan history).
              if (isLeader) ...[
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _quickAction(context, Icons.qr_code_2, 'Create Elder/\nMember QR', AppColors.primary300.withValues(alpha: 0.4),
                        AppColors.primary900, AppRoutes.qrCreate),
                    _quickAction(context, Icons.badge_outlined, 'QR\nManagement', AppColors.primary300.withValues(alpha: 0.4),
                        AppColors.primary900, AppRoutes.qrManagement),
                    _quickAction(context, Icons.fact_check_outlined, 'Scan\nRecords', AppColors.primary300.withValues(alpha: 0.4),
                        AppColors.primary900, AppRoutes.scanRecords),
                  ],
                ),
              ],
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

              if (isLeader) ...[
                // ---- Youth Leader dashboard ----
                _NextEventCard(isLeader: true),
                const SizedBox(height: AppSpacing.md),
                const BorrowRequestsCard(),
                const SizedBox(height: AppSpacing.md),
                _LibrarySummaryCard(),
                const SizedBox(height: AppSpacing.md),
                _FundSummaryCard(),
              ] else ...[
                // ---- Youth Member dashboard ----
                _MemberEventsList(),
                const SizedBox(height: AppSpacing.md),
                _MemberBooksList(),
              ],
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _BottomNav(isLeader: isLeader),
    );
  }

  Widget _quickAction(BuildContext context, IconData icon, String label, Color bg, Color fg, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadius.container)),
            child: Icon(icon, color: fg),
          ),
          const SizedBox(height: 6),
          Text(label, textAlign: TextAlign.center, style: AppTextStyles.bodySm),
        ],
      ),
    );
  }
}

class _NextEventCard extends StatelessWidget {
  final bool isLeader;
  const _NextEventCard({this.isLeader = false});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('events').snapshots(),
      builder: (context, snapshot) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
              color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.container), boxShadow: cardShadow),
          child: _buildBody(context, snapshot),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
          child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()));
    }
    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Upcoming Events', style: AppTextStyles.headlineMd),
          const SizedBox(height: 8),
          Text('No events available yet.', style: AppTextStyles.bodySm),
          if (isLeader) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.eventForm),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Create Event'),
              style: AppButtonStyles.secondary,
            ),
          ],
        ],
      );
    }

    final events = snapshot.data!.docs
        .map((d) => EventModel.fromMap(d.id, d.data()))
        .where((e) => !e.isPast)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (events.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Upcoming Events', style: AppTextStyles.headlineMd),
          const SizedBox(height: 8),
          Text('No upcoming events. Check past events in the Events tab.', style: AppTextStyles.bodySm),
        ],
      );
    }

    final next = events.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: AppColors.primary300.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(AppRadius.base)),
            child: Column(children: [
              Text(DateFormat('MMM').format(next.date).toUpperCase(), style: AppTextStyles.labelSm),
              Text(DateFormat('d').format(next.date), style: AppTextStyles.headlineLgMobile),
            ]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (next.isToday) _pill('Today • ${next.time}', AppColors.statusSuccess),
                Text(next.eventName, style: AppTextStyles.headlineMd),
                Text('${next.place}${next.time.isNotEmpty ? ' • ${next.time}' : ''}', style: AppTextStyles.bodySm),
              ],
            ),
          ),
        ]),
        const SizedBox(height: AppSpacing.sm),
        Row(children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.eventDetail, arguments: next.id),
              icon: const Icon(Icons.info_outline, size: 18),
              label: const Text('View Details'),
              style: AppButtonStyles.primary,
            ),
          ),
          if (isLeader) ...[
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.eventForm),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Create Event'),
                style: AppButtonStyles.secondary,
              ),
            ),
          ],
        ]),
      ],
    );
  }

  Widget _pill(String text, Color color) => Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(AppRadius.full)),
        child: Text(text, style: AppTextStyles.labelSm.copyWith(color: color)),
      );
}

class _LibrarySummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('books').snapshots(),
      builder: (context, snapshot) {
        final books = snapshot.data?.docs.map((d) => BookModel.fromMap(d.id, d.data())).toList() ?? [];
        final totalCopies = books.fold<int>(0, (sum, b) => sum + b.availableQuantity);

        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.container), boxShadow: cardShadow),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Library', style: AppTextStyles.headlineMd),
                Text('Browse →', style: AppTextStyles.bodySm.copyWith(color: AppColors.primary700)),
              ]),
              const SizedBox(height: AppSpacing.sm),
              if (books.isEmpty)
                Text('No books available yet.', style: AppTextStyles.bodySm)
              else
                Row(children: [
                  const Icon(Icons.menu_book, color: AppColors.primary900),
                  const SizedBox(width: 8),
                  Text('${books.length} titles • $totalCopies copies available', style: AppTextStyles.bodyMd),
                ]),
            ],
          ),
        );
      },
    );
  }
}

class _FundSummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('transactions').snapshots(),
      builder: (context, snapshot) {
        final transactions =
            snapshot.data?.docs.map((d) => TransactionModel.fromMap(d.id, d.data())).toList() ?? [];
        final income = transactions.where((t) => t.isIncome).fold<double>(0, (s, t) => s + t.amount);
        final expenses = transactions.where((t) => !t.isIncome).fold<double>(0, (s, t) => s + t.amount);
        final balance = income - expenses;
        final currency = NumberFormat.currency(locale: 'en_PH', symbol: '₱');

        return Container(
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
              Text('CURRENT BALANCE', style: AppTextStyles.labelSm),
              Text(currency.format(balance), style: AppTextStyles.headlineXlMobile),
              if (transactions.isEmpty) ...[
                const SizedBox(height: 4),
                Text('No transactions yet.', style: AppTextStyles.bodySm),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Youth Member: upcoming events created by the Youth Leader (read-only).
class _MemberEventsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('events').snapshots(),
      builder: (context, snapshot) {
        final events = (snapshot.data?.docs ?? [])
            .map((d) => EventModel.fromMap(d.id, d.data()))
            .where((e) => !e.isPast)
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));

        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.container), boxShadow: cardShadow),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Upcoming Events', style: AppTextStyles.headlineMd),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.events),
                  child: Text('See all →', style: AppTextStyles.bodySm.copyWith(color: AppColors.primary700)),
                ),
              ]),
              const SizedBox(height: AppSpacing.sm),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()))
              else if (events.isEmpty)
                Text('No upcoming events from your Youth Leader yet.', style: AppTextStyles.bodySm)
              else
                for (final e in events.take(5))
                  InkWell(
                    onTap: () => Navigator.pushNamed(context, AppRoutes.eventDetail, arguments: e.id),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(children: [
                        Container(
                          width: 48,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                              color: AppColors.primary300.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(AppRadius.base)),
                          child: Column(children: [
                            Text(e.isToday ? 'TODAY' : DateFormat('MMM').format(e.date).toUpperCase(), style: AppTextStyles.labelSm),
                            Text(DateFormat('d').format(e.date), style: AppTextStyles.headlineLgMobile),
                          ]),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(e.eventName, style: AppTextStyles.labelLg),
                            Text('${e.place}${e.time.isNotEmpty ? ' • ${e.time}' : ''}',
                                style: AppTextStyles.bodySm, overflow: TextOverflow.ellipsis),
                          ]),
                        ),
                        const Icon(Icons.chevron_right, color: AppColors.neutralMuted),
                      ]),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}

/// Youth Member: books that can be borrowed, each with a Borrow button.
class _MemberBooksList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('books').snapshots(),
      builder: (context, snapshot) {
        final books = (snapshot.data?.docs ?? [])
            .map((d) => BookModel.fromMap(d.id, d.data()))
            .where((b) => b.availableQuantity > 0)
            .toList()
          ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.container), boxShadow: cardShadow),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Available Books', style: AppTextStyles.headlineMd),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.library),
                  child: Text('Browse all →', style: AppTextStyles.bodySm.copyWith(color: AppColors.primary700)),
                ),
              ]),
              const SizedBox(height: AppSpacing.sm),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()))
              else if (books.isEmpty)
                Text('No books available to borrow right now.', style: AppTextStyles.bodySm)
              else
                for (final b in books.take(6))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: BookCover(
                          url: b.imageUrl,
                          base64Data: b.coverBase64,
                          width: 40,
                          height: 54,
                          fallback: Container(
                            width: 40,
                            height: 54,
                            color: AppColors.primary300.withValues(alpha: 0.3),
                            child: const Icon(Icons.menu_book, color: AppColors.primary900, size: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          onTap: () => Navigator.pushNamed(context, AppRoutes.bookDetail, arguments: b.id),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(b.title, style: AppTextStyles.labelLg, maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text(b.author, style: AppTextStyles.bodySm, maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text('${b.availableQuantity} available',
                                style: AppTextStyles.bodySm.copyWith(color: AppColors.statusSuccess)),
                          ]),
                        ),
                      ),
                      const SizedBox(width: 8),
                      BorrowButton(book: b, compact: true),
                    ]),
                  ),
            ],
          ),
        );
      },
    );
  }
}

class _BottomNav extends StatelessWidget {
  final bool isLeader;
  const _BottomNav({required this.isLeader});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(color: AppColors.surface, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, -1))]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(context, Icons.home, 'Home', true, AppRoutes.dashboard),
          _navItem(context, Icons.event_outlined, 'Events', false, AppRoutes.events),
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
