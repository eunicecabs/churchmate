import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme.dart';
import '../../../core/services/auth_service.dart';
import '../models/book_model.dart';
import '../models/borrow_model.dart';
import '../services/borrow_service.dart';

/// The "Borrow" button a Youth Member sees on a book. It reflects the
/// member's own request live: Borrow -> Requested (waiting for the leader)
/// -> Borrowed (leader accepted). Not shown to leaders.
class BorrowButton extends StatelessWidget {
  final BookModel book;
  final bool compact;
  const BorrowButton({super.key, required this.book, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;
    if (user == null) return const SizedBox.shrink();

    return StreamBuilder<List<BorrowRequestModel>>(
      stream: BorrowService.streamForUser(user.id),
      builder: (context, snapshot) {
        final mine = (snapshot.data ?? []).where((r) => r.bookId == book.id);
        final pending = mine.any((r) => r.isPending);
        final approved = mine.any((r) => r.isApproved);

        String label;
        IconData icon;
        VoidCallback? onPressed;
        if (approved) {
          label = 'Borrowed';
          icon = Icons.check_circle_outline;
        } else if (pending) {
          label = 'Requested';
          icon = Icons.hourglass_top;
        } else if (book.availableQuantity <= 0) {
          label = 'Not available';
          icon = Icons.block;
        } else {
          label = 'Borrow';
          icon = Icons.bookmark_add_outlined;
          onPressed = () async {
            final messenger = ScaffoldMessenger.of(context);
            try {
              await BorrowService.requestBorrow(bookId: book.id, bookTitle: book.title, user: user);
              messenger.showSnackBar(SnackBar(content: Text('Borrow request for "${book.title}" sent to your Youth Leader.')));
            } catch (_) {
              messenger.showSnackBar(const SnackBar(content: Text('Could not send the request. Please try again.')));
            }
          };
        }

        return ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 16),
          label: Text(label),
          style: AppButtonStyles.primary.copyWith(
            minimumSize: WidgetStatePropertyAll(Size(compact ? 0 : double.infinity, compact ? 36 : 44)),
            padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: compact ? 12 : 16)),
          ),
        );
      },
    );
  }
}
