import 'package:flutter/material.dart';
import '../../../app/theme.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.margin, AppSpacing.md, AppSpacing.margin, AppSpacing.lg),
          children: [
            Row(children: [
              Container(width: 28, height: 28, decoration: const BoxDecoration(color: AppColors.primary900, shape: BoxShape.circle), child: const Icon(Icons.church, color: Colors.white, size: 14)),
              const SizedBox(width: 8),
              Text('ChurchMate', style: AppTextStyles.headlineMd),
              const Spacer(),
              const Icon(Icons.notifications_outlined),
              const SizedBox(width: 8),
              const CircleAvatar(radius: 16, backgroundColor: AppColors.primary300, child: Icon(Icons.person, color: Colors.white, size: 16)),
            ]),
            const SizedBox(height: AppSpacing.md),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Ministry Treasury', style: AppTextStyles.headlineLgMobile),
              _pill('Fiscal Year 2024', AppColors.primary300),
            ]),
            const SizedBox(height: AppSpacing.sm),

            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(color: AppColors.primary900, borderRadius: BorderRadius.circular(AppRadius.prominent)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.shield_outlined, color: Colors.white70, size: 14),
                  const SizedBox(width: 4),
                  Text('ODB PRESBYTERIAN YOUTH FUND', style: AppTextStyles.labelSm.copyWith(color: Colors.white70)),
                  const Spacer(),
                  const Icon(Icons.visibility_outlined, color: Colors.white70, size: 16),
                ]),
                const SizedBox(height: 8),
                Text('Total Available Balance', style: AppTextStyles.bodySm.copyWith(color: Colors.white70)),
                Text('₱18,450.00', style: AppTextStyles.headlineXlMobile.copyWith(color: Colors.white)),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: _fundBox('↓ Month Inflow', '+₱8,200.00', 'Tithes & Offerings')),
                  const SizedBox(width: 8),
                  Expanded(child: _fundBox('↑ Month Outflow', '-₱3,450.00', 'Fellowship & Mission')),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.add, size: 16, color: Colors.white), label: const Text('Record Tithe', style: TextStyle(color: Colors.white)), style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white54), minimumSize: const Size.fromHeight(42)))),
                  const SizedBox(width: 8),
                  Expanded(child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.receipt_long_outlined, size: 16), label: const Text('Claim Expense'), style: AppButtonStyles.accent.copyWith(minimumSize: const WidgetStatePropertyAll(Size.fromHeight(42))))),
                ]),
              ]),
            ),
            const SizedBox(height: AppSpacing.md),

            SizedBox(
              height: 32,
              child: ListView(scrollDirection: Axis.horizontal, children: [
                _filterPill('All (24)', _filter == 'All', () => setState(() => _filter = 'All')),
                const SizedBox(width: 8),
                _filterPill('Pending Approvals (2)', _filter == 'Pending', () => setState(() => _filter = 'Pending')),
                const SizedBox(width: 8),
                _filterPill('Tithes & Giving', _filter == 'Tithes', () => setState(() => _filter = 'Tithes')),
              ]),
            ),
            const SizedBox(height: AppSpacing.md),

            Row(children: [
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.statusPending, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text('NEEDS LEADER VERIFICATION', style: AppTextStyles.labelSm),
              const Spacer(),
              Text('2 requests', style: AppTextStyles.bodySm),
            ]),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.container), boxShadow: cardShadow),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Youth Fellowship Supplies', style: AppTextStyles.labelLg),
                    Text('Requested by Deaconess Ruth • Oct 19', style: AppTextStyles.bodySm),
                  ])),
                  Text('-₱1,250.00', style: AppTextStyles.labelLg.copyWith(color: AppColors.statusAlert)),
                ]),
                const SizedBox(height: 4),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Receipt #OR-8921 • 3 items', style: AppTextStyles.bodySm),
                  _pill('Pending Approval', AppColors.statusPending),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: OutlinedButton(onPressed: () {}, style: AppButtonStyles.secondary.copyWith(minimumSize: const WidgetStatePropertyAll(Size.fromHeight(38))), child: const Text('Review Notes'))),
                  const SizedBox(width: 8),
                  Expanded(child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.check_circle_outline, size: 16), label: const Text('Approve'), style: AppButtonStyles.primary.copyWith(minimumSize: const WidgetStatePropertyAll(Size.fromHeight(38))))),
                ]),
              ]),
            ),
            const SizedBox(height: AppSpacing.md),

            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Ledger Entries', style: AppTextStyles.headlineMd), Text('October 2024', style: AppTextStyles.bodySm)]),
            const SizedBox(height: 6),
            _ledgerRow(Icons.volunteer_activism, AppColors.statusSuccess, 'Sunday Youth Tithe', 'Congregation • Oct 20', '+₱3,500.00', true),
            _ledgerRow(Icons.groups, AppColors.statusAlert, 'Outreach Feeding', 'Bro. Caleb • Oct 15', '-₱2,200.00', false),
            _ledgerRow(Icons.music_note, AppColors.statusAlert, 'Guitar Strings & Picks', 'Sis. Hannah • Oct 12', '-₱650.00', false),
            const SizedBox(height: AppSpacing.md),

            ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.add), label: const Text('Add Transaction'), style: AppButtonStyles.primary),
          ],
        ),
      ),
      bottomNavigationBar: _bottomNav(context),
    );
  }

  Widget _fundBox(String label, String value, String sub) => Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(AppRadius.base)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppTextStyles.bodySm.copyWith(color: Colors.white70, fontSize: 10)),
      Text(value, style: AppTextStyles.labelLg.copyWith(color: Colors.white)),
      Text(sub, style: AppTextStyles.bodySm.copyWith(color: Colors.white54, fontSize: 9)),
    ]),
  );

  Widget _filterPill(String text, bool selected, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(color: selected ? AppColors.primary900 : AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.full), border: Border.all(color: selected ? AppColors.primary900 : AppColors.primary300.withOpacity(0.4))),
      child: Center(child: Text(text, style: AppTextStyles.labelMd.copyWith(color: selected ? Colors.white : AppColors.neutralDark))),
    ),
  );

  Widget _ledgerRow(IconData icon, Color color, String title, String sub, String amount, bool positive) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.base), boxShadow: cardShadow),
      child: Row(children: [
        CircleAvatar(radius: 16, backgroundColor: color.withOpacity(0.15), child: Icon(icon, size: 16, color: color)),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: AppTextStyles.labelMd), Text(sub, style: AppTextStyles.bodySm)])),
        Text(amount, style: AppTextStyles.labelLg.copyWith(color: positive ? AppColors.statusSuccess : AppColors.statusAlert)),
      ]),
    ),
  );

  Widget _pill(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(AppRadius.full)),
    child: Text(text, style: AppTextStyles.labelSm.copyWith(color: color)),
  );

  Widget _bottomNav(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: const BoxDecoration(color: AppColors.surface, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, -1))]),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      _navItem(context, Icons.home_outlined, 'Home', false, '/dashboard'),
      _navItem(context, Icons.event_outlined, 'Events', false, '/events'),
      GestureDetector(onTap: () => Navigator.pushNamed(context, '/qr-display'), child: Container(width: 44, height: 44, decoration: const BoxDecoration(color: AppColors.primary900, shape: BoxShape.circle), child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 20))),
      _navItem(context, Icons.menu_book_outlined, 'Library', false, '/library'),
      _navItem(context, Icons.volunteer_activism, 'Giving', true, '/finance'),
    ]),
  );

  Widget _navItem(BuildContext context, IconData icon, String label, bool active, String route) => InkWell(
    onTap: () { if (!active) Navigator.pushReplacementNamed(context, route); },
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: active ? AppColors.primary900 : AppColors.neutralMuted, size: 22),
      Text(label, style: TextStyle(fontSize: 10, color: active ? AppColors.primary900 : AppColors.neutralMuted)),
    ]),
  );
}