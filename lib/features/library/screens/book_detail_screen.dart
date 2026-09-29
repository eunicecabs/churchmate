import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme.dart';
import '../../../app/routes.dart';
import '../../../core/constants/roles.dart';
import '../../../core/services/auth_service.dart';
import '../../../shared/widgets/book_cover.dart';
import '../models/book_model.dart';
import '../widgets/borrow_button.dart';

class BookDetailScreen extends StatelessWidget {
  const BookDetailScreen({super.key});

  Future<void> _confirmDelete(BuildContext context, String bookId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.container)),
        title: const Text('Delete this book?'),
        content: const Text('This will remove it from the catalog. This cannot be undone.'),
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
    await FirebaseFirestore.instance.collection('books').doc(bookId).delete();
    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Book deleted.')));
    }
  }

  Future<void> _adjustQuantity(BuildContext context, BookModel book, int delta) async {
    final newQuantity = (book.availableQuantity + delta).clamp(0, 1 << 30);
    await FirebaseFirestore.instance.collection('books').doc(book.id).update({
      'availableQuantity': newQuantity,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookId = ModalRoute.of(context)!.settings.arguments as String;
    final isLeader = context.watch<AuthService>().currentUser?.role == UserRole.leader;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('books').doc(bookId).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(child: Text('This book no longer exists.', style: AppTextStyles.bodyMd));
            }

            final book = BookModel.fromMap(snapshot.data!.id, snapshot.data!.data()!);
            final canManage = isLeader; // only the Youth Leader manages the catalog
            final available = book.availableQuantity > 0;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(AppSpacing.margin, AppSpacing.md, AppSpacing.margin, AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)),
                    Expanded(child: Text('Book Details', style: AppTextStyles.headlineMd)),
                    if (canManage) ...[
                      IconButton(
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.bookForm, arguments: book.id),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        onPressed: () => _confirmDelete(context, book.id),
                        icon: const Icon(Icons.delete_outline, color: AppColors.statusAlert),
                      ),
                    ],
                  ]),
                  const SizedBox(height: AppSpacing.sm),
                  _pill(book.category, AppColors.primary700),
                  const SizedBox(height: AppSpacing.md),

                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.base),
                      child: BookCover(
                        url: book.imageUrl,
                        base64Data: book.coverBase64,
                        width: 140,
                        height: 190,
                        fallback: Container(
                          width: 140, height: 190,
                          decoration: BoxDecoration(color: AppColors.primary900, borderRadius: BorderRadius.circular(AppRadius.base)),
                          child: const Icon(Icons.menu_book, color: Colors.white, size: 48),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Center(child: _pill(available ? 'Available to Borrow' : 'Not Available', available ? AppColors.statusSuccess : AppColors.statusAlert)),
                  const SizedBox(height: 6),
                  Center(child: Text(book.title, style: AppTextStyles.headlineXlMobile, textAlign: TextAlign.center)),
                  Center(child: Text(book.author, style: AppTextStyles.bodyMd.copyWith(color: AppColors.primary700))),
                  if (book.isbn != null || book.publicationYear != null)
                    Center(
                      child: Text(
                        [if (book.isbn != null) 'ISBN ${book.isbn}', if (book.publicationYear != null) '${book.publicationYear}'].join(' • '),
                        style: AppTextStyles.bodySm,
                      ),
                    ),
                  const SizedBox(height: AppSpacing.md),

                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.container), boxShadow: cardShadow),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('AVAILABLE COPIES', style: AppTextStyles.labelSm),
                          Text('${book.availableQuantity}', style: AppTextStyles.headlineXlMobile),
                        ]),
                        if (canManage)
                          Row(children: [
                            IconButton.outlined(
                              onPressed: book.availableQuantity > 0 ? () => _adjustQuantity(context, book, -1) : null,
                              icon: const Icon(Icons.remove),
                            ),
                            const SizedBox(width: 8),
                            IconButton.filled(
                              style: IconButton.styleFrom(backgroundColor: AppColors.primary900),
                              onPressed: () => _adjustQuantity(context, book, 1),
                              icon: const Icon(Icons.add),
                            ),
                          ]),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  if (!isLeader) ...[
                    BorrowButton(book: book),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  if (book.description != null && book.description!.isNotEmpty) ...[
                    Text('Overview', style: AppTextStyles.headlineMd),
                    const SizedBox(height: 6),
                    Text(book.description!, style: AppTextStyles.bodyMd),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _pill(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(AppRadius.full)),
    child: Text(text, style: AppTextStyles.labelSm.copyWith(color: color)),
  );
}
