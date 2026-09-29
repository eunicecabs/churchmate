import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../app/theme.dart';
import '../../../app/routes.dart';
import '../../../core/constants/roles.dart';
import '../../../core/services/auth_service.dart';
import '../models/transaction_model.dart';

final _currency = NumberFormat.currency(locale: 'en_PH', symbol: '₱');

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  Future<void> _confirmDelete(BuildContext context, String transactionId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.container)),
        title: const Text('Delete this transaction?'),
        content: const Text('This cannot be undone and will affect the fund totals.'),
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
    await FirebaseFirestore.instance.collection('transactions').doc(transactionId).delete();
  }

  @override
  Widget build(BuildContext context) {
    final isLeader = context.watch<AuthService>().currentUser?.role == UserRole.leader;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('transactions').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Could not load giving records.', style: AppTextStyles.bodySm));
            }

            final transactions = (snapshot.data?.docs ?? [])
                .map((d) => TransactionModel.fromMap(d.id, d.data()))
                .toList()
              ..sort((a, b) => b.date.compareTo(a.date));

            final income = transactions.where((t) => t.isIncome).fold<double>(0, (s, t) => s + t.amount);
            final expenses = transactions.where((t) => !t.isIncome).fold<double>(0, (s, t) => s + t.amount);
            final balance = income - expenses;

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.margin, AppSpacing.md, AppSpacing.margin, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Container(width: 28, height: 28, decoration: const BoxDecoration(color: AppColors.primary900, shape: BoxShape.circle), child: const Icon(Icons.church, color: Colors.white, size: 14)),
                          const SizedBox(width: 8),
                          Text('ChurchMate', style: AppTextStyles.headlineMd),
                        ]),
                        const SizedBox(height: AppSpacing.md),
                        Text('Youth Ministry Giving', style: AppTextStyles.headlineXlMobile),
                        Text('Transparent stewardship of ministry funds', style: AppTextStyles.bodySm),
                        const SizedBox(height: AppSpacing.md),

                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.primary900,
                            borderRadius: BorderRadius.circular(AppRadius.container),
                            boxShadow: cardShadow,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('CURRENT BALANCE', style: AppTextStyles.labelSm.copyWith(color: Colors.white70)),
                              Text(_currency.format(balance),
                                  style: AppTextStyles.headlineXlMobile.copyWith(color: Colors.white, fontSize: 32)),
                              const SizedBox(height: AppSpacing.sm),
                              Row(children: [
                                Expanded(child: _statChip('Total Income', income, Icons.arrow_downward, AppColors.statusSuccess)),
                                const SizedBox(width: 8),
                                Expanded(child: _statChip('Total Expenses', expenses, Icons.arrow_upward, AppColors.statusAlert)),
                              ]),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('Transaction History', style: AppTextStyles.headlineMd),
                          Text('${transactions.length} record${transactions.length == 1 ? '' : 's'}', style: AppTextStyles.bodySm),
                        ]),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                    ),
                  ),
                ),
                if (transactions.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.receipt_long_outlined, size: 48, color: AppColors.neutralMuted),
                        const SizedBox(height: AppSpacing.sm),
                        Text('No transactions yet.', style: AppTextStyles.bodyMd),
                        const SizedBox(height: 4),
                        Text('Tap Add Transaction to record the first one.', style: AppTextStyles.bodySm),
                        const SizedBox(height: AppSpacing.lg),
                      ]),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.margin, 0, AppSpacing.margin, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index.isOdd) return const SizedBox(height: 8);
                          final t = transactions[index ~/ 2];
                          final canManage = isLeader;
                          return _transactionTile(context, t, canManage);
                        },
                        childCount: transactions.length * 2 - 1,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.transactionForm),
        backgroundColor: AppColors.accent500,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Transaction', style: TextStyle(color: Colors.white)),
      ),
      bottomNavigationBar: _bottomNav(context),
    );
  }

  Widget _statChip(String label, double value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(AppRadius.base)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
          ]),
          const SizedBox(height: 2),
          Text(_currency.format(value), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _transactionTile(BuildContext context, TransactionModel t, bool canManage) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.container), boxShadow: cardShadow),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: (t.isIncome ? AppColors.statusSuccess : AppColors.statusAlert).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(t.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                color: t.isIncome ? AppColors.statusSuccess : AppColors.statusAlert, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.category, style: AppTextStyles.labelLg),
                Text(DateFormat('MMM d, yyyy').format(t.date), style: AppTextStyles.bodySm),
                if (t.description.isNotEmpty) Text(t.description, style: AppTextStyles.bodySm, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${t.isIncome ? '+' : '-'}${_currency.format(t.amount)}',
                  style: AppTextStyles.labelLg.copyWith(color: t.isIncome ? AppColors.statusSuccess : AppColors.statusAlert)),
              if (canManage)
                Row(mainAxisSize: MainAxisSize.min, children: [
                  InkWell(
                    onTap: () => Navigator.pushNamed(context, AppRoutes.transactionForm, arguments: t.id),
                    child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.edit_outlined, size: 16, color: AppColors.neutralMuted)),
                  ),
                  InkWell(
                    onTap: () => _confirmDelete(context, t.id),
                    child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.delete_outline, size: 16, color: AppColors.statusAlert)),
                  ),
                ]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bottomNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(color: AppColors.surface, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, -1))]),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _navItem(context, Icons.home_outlined, 'Home', false, AppRoutes.dashboard),
        _navItem(context, Icons.event_outlined, 'Events', false, AppRoutes.events),
        _navItem(context, Icons.menu_book_outlined, 'Library', false, AppRoutes.library),
        _navItem(context, Icons.volunteer_activism, 'Giving', true, AppRoutes.finance),
      ]),
    );
  }

  Widget _navItem(BuildContext context, IconData icon, String label, bool active, String route) {
    return InkWell(
      onTap: () { if (!active) Navigator.pushReplacementNamed(context, route); },
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: active ? AppColors.primary900 : AppColors.neutralMuted, size: 22),
        Text(label, style: TextStyle(fontSize: 10, color: active ? AppColors.primary900 : AppColors.neutralMuted)),
      ]),
    );
  }
}
