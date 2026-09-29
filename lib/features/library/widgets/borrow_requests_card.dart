import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../models/borrow_model.dart';
import '../services/borrow_service.dart';

/// Leader-only panel: pending borrow requests with Accept / Decline, and
/// (when [showLent] is true) books currently lent out with a Returned button.
class BorrowRequestsCard extends StatelessWidget {
  final bool showLent;
  const BorrowRequestsCard({super.key, this.showLent = false});

  Future<void> _run(BuildContext context, Future<void> Function() action, String okMessage) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action();
      messenger.showSnackBar(SnackBar(content: Text(okMessage)));
    } on StateError catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('Something went wrong. Please try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.container), boxShadow: cardShadow),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.bookmark_added_outlined, size: 18, color: AppColors.accent500),
            const SizedBox(width: 6),
            Text('Borrow Requests', style: AppTextStyles.headlineMd),
          ]),
          const SizedBox(height: AppSpacing.sm),
          StreamBuilder<List<BorrowRequestModel>>(
            stream: BorrowService.streamPending(),
            builder: (context, snapshot) {
              final pending = snapshot.data ?? [];
              if (pending.isEmpty) {
                return Text('No pending borrow requests.', style: AppTextStyles.bodySm);
              }
              return Column(
                children: [for (final r in pending) _pendingRow(context, r)],
              );
            },
          ),
          if (showLent) ...[
            const SizedBox(height: AppSpacing.md),
            Text('CURRENTLY BORROWED', style: AppTextStyles.labelSm),
            const SizedBox(height: 6),
            StreamBuilder<List<BorrowRequestModel>>(
              stream: BorrowService.streamApproved(),
              builder: (context, snapshot) {
                final lent = snapshot.data ?? [];
                if (lent.isEmpty) return Text('No books are currently borrowed.', style: AppTextStyles.bodySm);
                return Column(children: [for (final r in lent) _lentRow(context, r)]);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _pendingRow(BuildContext context, BorrowRequestModel r) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(r.bookTitle, style: AppTextStyles.labelLg),
            Text('${r.userName} wants to borrow this', style: AppTextStyles.bodySm),
          ]),
        ),
        IconButton(
          tooltip: 'Decline',
          onPressed: () => _run(context, () => BorrowService.decline(r), 'Request declined.'),
          icon: const Icon(Icons.close, color: AppColors.statusAlert),
        ),
        ElevatedButton(
          onPressed: () => _run(context, () => BorrowService.accept(r), 'Accepted. ${r.userName} can borrow "${r.bookTitle}".'),
          style: AppButtonStyles.primary.copyWith(
            minimumSize: const WidgetStatePropertyAll(Size(0, 36)),
            padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 14)),
          ),
          child: const Text('Accept'),
        ),
      ]),
    );
  }

  Widget _lentRow(BuildContext context, BorrowRequestModel r) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(r.bookTitle, style: AppTextStyles.labelLg),
            Text('Borrowed by ${r.userName}', style: AppTextStyles.bodySm),
          ]),
        ),
        OutlinedButton(
          onPressed: () => _run(context, () => BorrowService.markReturned(r), 'Marked as returned.'),
          style: AppButtonStyles.secondary.copyWith(
            minimumSize: const WidgetStatePropertyAll(Size(0, 36)),
            padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 14)),
          ),
          child: const Text('Returned'),
        ),
      ]),
    );
  }
}
