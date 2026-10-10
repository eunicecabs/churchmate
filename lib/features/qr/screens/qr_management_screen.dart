import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../models/qr_person_model.dart';
import '../services/qr_registry_service.dart';
import '../widgets/qr_id_card.dart';

/// Youth Leader only: view, rename, deactivate/reactivate and delete Elder/Member QR records.
class QrManagementScreen extends StatefulWidget {
  const QrManagementScreen({super.key});

  @override
  State<QrManagementScreen> createState() => _QrManagementScreenState();
}

class _QrManagementScreenState extends State<QrManagementScreen> {
  final _service = QrRegistryService();

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _run(Future<void> Function() action, String failMsg) async {
    try {
      await action();
    } catch (_) {
      if (mounted) _toast(failMsg);
    }
  }

  void _openDetail(QrPerson p) {
    final cardKey = GlobalKey();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            QrIdCard(person: p, repaintKey: cardKey),
            const SizedBox(height: AppSpacing.sm),
            ElevatedButton.icon(
              style: AppButtonStyles.primary,
              icon: const Icon(Icons.ios_share),
              label: const Text('Save / Print QR'),
              onPressed: () => _run(() => shareQrCard(cardKey, p.qrId), 'Could not export the QR image.'),
            ),
            const SizedBox(height: 4),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              TextButton.icon(
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Rename'),
                onPressed: () {
                  Navigator.pop(ctx);
                  _rename(p);
                },
              ),
              TextButton.icon(
                icon: Icon(p.active ? Icons.block : Icons.check_circle_outline),
                label: Text(p.active ? 'Deactivate' : 'Activate'),
                onPressed: () {
                  Navigator.pop(ctx);
                  _run(() => _service.setActive(p.qrId, !p.active), 'Could not update the record.');
                },
              ),
              TextButton.icon(
                icon: const Icon(Icons.delete_outline, color: AppColors.statusAlert),
                label: const Text('Delete', style: TextStyle(color: AppColors.statusAlert)),
                onPressed: () {
                  Navigator.pop(ctx);
                  _confirmDelete(p);
                },
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  Future<void> _rename(QrPerson p) async {
    final controller = TextEditingController(text: p.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename'),
        content: TextField(controller: controller, textCapitalization: TextCapitalization.words),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('Save')),
        ],
      ),
    );
    controller.dispose();
    if (newName == null || newName.isEmpty || newName == p.name) return;
    await _run(() => _service.rename(p.qrId, newName), 'Could not rename.');
  }

  Future<void> _confirmDelete(QrPerson p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete QR record?'),
        content: Text('${p.name} (${p.qrId}) will no longer be scannable. Existing scan records are kept.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) await _run(() => _service.delete(p.qrId), 'Could not delete the record.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('QR Management', style: AppTextStyles.headlineMd),
        iconTheme: const IconThemeData(color: AppColors.neutralDark),
      ),
      body: SafeArea(
        child: StreamBuilder<List<QrPerson>>(
          stream: _service.streamAll(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Could not load QR records.', style: AppTextStyles.bodyMd));
            }
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final people = snapshot.data!;
            if (people.isEmpty) {
              return Center(child: Text('No Elder/Member QR records yet.', style: AppTextStyles.bodyMd));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.margin),
              itemCount: people.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final p = people[i];
                return GestureDetector(
                  onTap: () => _openDetail(p),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.container), boxShadow: cardShadow),
                    child: Row(children: [
                      const Icon(Icons.qr_code_2, color: AppColors.primary900),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(p.name, style: AppTextStyles.labelLg),
                          Text('${p.role} - ${p.qrId}', style: AppTextStyles.bodySm),
                        ]),
                      ),
                      Text(p.active ? 'Active' : 'Inactive',
                          style: AppTextStyles.bodySm.copyWith(color: p.active ? AppColors.statusSuccess : AppColors.statusAlert)),
                    ]),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
