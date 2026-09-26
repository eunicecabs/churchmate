import 'package:flutter/material.dart';
import '../../../app/theme.dart';

class LibraryCatalogScreen extends StatefulWidget {
  const LibraryCatalogScreen({super.key});

  @override
  State<LibraryCatalogScreen> createState() => _LibraryCatalogScreenState();
}

class _LibraryCatalogScreenState extends State<LibraryCatalogScreen> {
  String _filter = 'All Books (142)';
  final _filters = ['All Books (142)', 'Discipleship', 'Theology', 'Youth'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.margin, AppSpacing.md, AppSpacing.margin, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Youth Sanctuary Library', style: AppTextStyles.headlineLgMobile),
                    Text('Faith, wisdom, and fellowship through reading', style: AppTextStyles.bodySm),
                  ])),
                  Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.primary300.withOpacity(0.3), borderRadius: BorderRadius.circular(AppRadius.base)), child: const Icon(Icons.bookmark_outline, color: AppColors.primary900, size: 18)),
                ]),
                const SizedBox(height: AppSpacing.sm),
                TextField(decoration: appInputDecoration(label: 'Search books by title, author...', icon: Icons.search)),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal, itemCount: _filters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final selected = _filters[i] == _filter;
                      return GestureDetector(
                        onTap: () => setState(() => _filter = _filters[i]),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(color: selected ? AppColors.primary900 : AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.full), border: Border.all(color: selected ? AppColors.primary900 : AppColors.primary300.withOpacity(0.4))),
                          child: Center(child: Text(_filters[i], style: AppTextStyles.labelMd.copyWith(color: selected ? Colors.white : AppColors.neutralDark))),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
              ]),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.margin, 0, AppSpacing.margin, AppSpacing.lg),
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(color: AppColors.primary300.withOpacity(0.2), borderRadius: BorderRadius.circular(AppRadius.container)),
                    child: Row(children: [
                      const Icon(Icons.menu_book, color: AppColors.primary900),
                      const SizedBox(width: 10),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('YOUR ACTIVE READING', style: AppTextStyles.labelSm),
                        Text('Knowing God • J.I. Packer', style: AppTextStyles.labelLg),
                        const SizedBox(height: 4),
                        ClipRRect(borderRadius: BorderRadius.circular(AppRadius.full), child: LinearProgressIndicator(value: 0.6, minHeight: 6, backgroundColor: Colors.white, valueColor: const AlwaysStoppedAnimation(AppColors.primary700))),
                        const SizedBox(height: 4),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('Shelf A2 • Borrowed 10 days ago', style: AppTextStyles.bodySm),
                          Text('Renew', style: AppTextStyles.labelMd.copyWith(color: AppColors.primary700)),
                        ]),
                      ])),
                      _pill('Due Oct 24', AppColors.statusPending),
                    ]),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Available Titles', style: AppTextStyles.headlineMd),
                    Text('Sort: Popularity', style: AppTextStyles.bodySm),
                  ]),
                  const SizedBox(height: AppSpacing.sm),
                  _bookCard('Mere Christianity', 'C.S. Lewis', 'Apologetics', 'Shelf B2', '4.9', 'Available (2 copies)', AppColors.statusSuccess),
                  const SizedBox(height: 8),
                  _bookCard("Don't Waste Your Life", 'John Piper', 'Youth Discipleship', 'Shelf A1', '4.8', 'Available', AppColors.statusSuccess),
                  const SizedBox(height: 8),
                  _bookCard('The Purpose Driven Life', 'Rick Warren', 'Devotional', 'Reserved', '4.7', 'Reserved by Mark D.', AppColors.statusPending),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(color: AppColors.accent500.withOpacity(0.15), borderRadius: BorderRadius.circular(AppRadius.base)),
                    child: Row(children: [
                      const Icon(Icons.emoji_events_outlined, color: AppColors.accent500),
                      const SizedBox(width: 8),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('October Reading Quest', style: AppTextStyles.labelLg),
                        Text('Youth goal: 40 books completed together', style: AppTextStyles.bodySm),
                      ])),
                      Text('26/40', style: AppTextStyles.labelLg),
                    ]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: () {}, backgroundColor: AppColors.primary900, icon: const Icon(Icons.add, color: Colors.white), label: const Text('Add Book', style: TextStyle(color: Colors.white))),
      bottomNavigationBar: _bottomNav(context),
    );
  }

  Widget _bookCard(String title, String author, String tag, String shelfOrNote, String rating, String status, Color statusColor) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/book-detail'),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.container), boxShadow: cardShadow),
        child: Row(children: [
          Container(width: 48, height: 64, decoration: BoxDecoration(color: AppColors.primary300.withOpacity(0.3), borderRadius: BorderRadius.circular(6)), child: const Icon(Icons.menu_book, color: AppColors.primary900)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [_pill(tag, AppColors.primary700), const Spacer(), _pill(shelfOrNote, AppColors.neutralMuted)]),
            Text(title, style: AppTextStyles.labelLg),
            Text(author, style: AppTextStyles.bodySm),
            Row(children: [
              const Icon(Icons.star, size: 12, color: AppColors.accent500),
              Text(' $rating  ', style: AppTextStyles.bodySm),
              Expanded(child: Text(status, style: AppTextStyles.bodySm.copyWith(color: statusColor), overflow: TextOverflow.ellipsis)),
            ]),
          ])),
        ]),
      ),
    );
  }

  Widget _pill(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(AppRadius.full)),
    child: Text(text, style: AppTextStyles.labelSm.copyWith(color: color, fontSize: 9)),
  );

  Widget _bottomNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(color: AppColors.surface, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, -1))]),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _navItem(context, Icons.home_outlined, 'Home', false, '/dashboard'),
        _navItem(context, Icons.event_outlined, 'Events', false, '/events'),
        GestureDetector(onTap: () => Navigator.pushNamed(context, '/qr-display'), child: Container(width: 44, height: 44, decoration: const BoxDecoration(color: AppColors.primary900, shape: BoxShape.circle), child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 20))),
        _navItem(context, Icons.menu_book, 'Library', true, '/library'),
        _navItem(context, Icons.volunteer_activism_outlined, 'Giving', false, '/finance'),
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