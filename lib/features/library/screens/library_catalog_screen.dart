import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/roles.dart';
import '../../../core/services/auth_service.dart';
import '../widgets/borrow_button.dart';
import '../widgets/borrow_requests_card.dart';
import '../../../app/theme.dart';
import '../../../app/routes.dart';
import '../../../shared/widgets/book_cover.dart';
import '../models/book_model.dart';

class LibraryCatalogScreen extends StatefulWidget {
  const LibraryCatalogScreen({super.key});

  @override
  State<LibraryCatalogScreen> createState() => _LibraryCatalogScreenState();
}

class _LibraryCatalogScreenState extends State<LibraryCatalogScreen> {
  String _search = '';
  String _categoryFilter = 'All';

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
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(width: 28, height: 28, decoration: const BoxDecoration(color: AppColors.primary900, shape: BoxShape.circle), child: const Icon(Icons.church, color: Colors.white, size: 14)),
                  const SizedBox(width: 8),
                  Text('ChurchMate', style: AppTextStyles.headlineMd),
                ]),
                const SizedBox(height: AppSpacing.md),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Youth Sanctuary Library', style: AppTextStyles.headlineLgMobile),
                    Text('Faith, wisdom, and fellowship through reading', style: AppTextStyles.bodySm),
                  ])),
                ]),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  decoration: appInputDecoration(label: 'Search books by title, author...', icon: Icons.search),
                  onChanged: (v) => setState(() => _search = v.trim().toLowerCase()),
                ),
                const SizedBox(height: AppSpacing.sm),
                // Youth Leader: accept / decline borrow requests right here.
                if (isLeader) ...[
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 260),
                    child: const SingleChildScrollView(child: BorrowRequestsCard(showLent: true)),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ]),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance.collection('books').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Could not load books.', style: AppTextStyles.bodySm));
                  }

                  var books = (snapshot.data?.docs ?? [])
                      .map((d) => BookModel.fromMap(d.id, d.data()))
                      .toList()
                    ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

                  final categories = ['All', ...{for (final b in books) b.category}];

                  if (_categoryFilter != 'All') {
                    books = books.where((b) => b.category == _categoryFilter).toList();
                  }
                  if (_search.isNotEmpty) {
                    books = books
                        .where((b) => b.title.toLowerCase().contains(_search) || b.author.toLowerCase().contains(_search))
                        .toList();
                  }

                  return Column(
                    children: [
                      if (categories.length > 1)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
                          child: SizedBox(
                            height: 36,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: categories.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 8),
                              itemBuilder: (context, i) {
                                final selected = categories[i] == _categoryFilter;
                                return GestureDetector(
                                  onTap: () => setState(() => _categoryFilter = categories[i]),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: selected ? AppColors.primary900 : AppColors.surface,
                                      borderRadius: BorderRadius.circular(AppRadius.full),
                                      border: Border.all(color: selected ? AppColors.primary900 : AppColors.primary300.withValues(alpha: 0.4)),
                                    ),
                                    child: Center(
                                      child: Text(categories[i],
                                          style: AppTextStyles.labelMd.copyWith(color: selected ? Colors.white : AppColors.neutralDark)),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      const SizedBox(height: AppSpacing.sm),
                      Expanded(
                        child: books.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(AppSpacing.lg),
                                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                                    const Icon(Icons.menu_book_outlined, size: 48, color: AppColors.neutralMuted),
                                    const SizedBox(height: AppSpacing.sm),
                                    Text('No books available yet.', style: AppTextStyles.bodyMd),
                                    const SizedBox(height: 4),
                                    Text(isLeader ? 'Tap Add Book to start the catalog.' : 'Your Youth Leader has not added books yet.', style: AppTextStyles.bodySm),
                                  ]),
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(AppSpacing.margin, 0, AppSpacing.margin, AppSpacing.lg),
                                itemCount: books.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 8),
                                itemBuilder: (context, i) => _bookCard(context, books[i], isLeader),
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: isLeader
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.bookForm),
              backgroundColor: AppColors.primary900,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Add Book', style: TextStyle(color: Colors.white)),
            )
          : null,
      bottomNavigationBar: _bottomNav(context, isLeader),
    );
  }

  Widget _bookCard(BuildContext context, BookModel book, bool isLeader) {
    final available = book.availableQuantity > 0;
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.bookDetail, arguments: book.id),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.container), boxShadow: cardShadow),
        child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: BookCover(
              url: book.imageUrl,
              base64Data: book.coverBase64,
              width: 48,
              height: 64,
              fallback: Container(
                width: 48, height: 64,
                decoration: BoxDecoration(color: AppColors.primary300.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(6)),
                child: const Icon(Icons.menu_book, color: AppColors.primary900),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _pill(book.category, AppColors.primary700),
            Text(book.title, style: AppTextStyles.labelLg),
            Text(book.author, style: AppTextStyles.bodySm),
            Text(
              available ? '${book.availableQuantity} available' : 'Not available',
              style: AppTextStyles.bodySm.copyWith(color: available ? AppColors.statusSuccess : AppColors.statusAlert),
            ),
          ])),
          if (!isLeader) ...[
            const SizedBox(width: 8),
            BorrowButton(book: book, compact: true),
          ],
        ]),
      ),
    );
  }

  Widget _pill(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(AppRadius.full)),
    child: Text(text, style: AppTextStyles.labelSm.copyWith(color: color, fontSize: 9)),
  );

  Widget _bottomNav(BuildContext context, bool isLeader) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(color: AppColors.surface, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, -1))]),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _navItem(context, Icons.home_outlined, 'Home', false, AppRoutes.dashboard),
        _navItem(context, Icons.event_outlined, 'Events', false, AppRoutes.events),
        _navItem(context, Icons.menu_book, 'Library', true, AppRoutes.library),
        if (isLeader) _navItem(context, Icons.volunteer_activism_outlined, 'Giving', false, AppRoutes.finance),
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
