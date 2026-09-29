import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme.dart';
import '../../../core/services/auth_service.dart';
import '../models/qr_person_model.dart';
import '../services/qr_registry_service.dart';
import '../widgets/qr_id_card.dart';

/// Youth Leader only (guarded by LeaderOnly in routes.dart and by Firestore rules).
class QrCreateScreen extends StatefulWidget {
  const QrCreateScreen({super.key});

  @override
  State<QrCreateScreen> createState() => _QrCreateScreenState();
}

class _QrCreateScreenState extends State<QrCreateScreen> {
  final _service = QrRegistryService();
  final _nameController = TextEditingController();
  final _cardKey = GlobalKey();

  String _role = QrPerson.roleElder;
  QrPerson? _created;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a name.')));
      return;
    }
    final uid = context.read<AuthService>().currentUser?.id ?? '';
    setState(() => _isSaving = true);
    try {
      final person = await _service.create(name: name, role: _role, createdBy: uid);
      if (!mounted) return;
      setState(() => _created = person);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Could not create the QR. Please try again.')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _createAnother() {
    setState(() {
      _created = null;
      _nameController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Create Elder/Member QR', style: AppTextStyles.headlineMd),
        iconTheme: const IconThemeData(color: AppColors.neutralDark),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin, vertical: AppSpacing.md),
          child: _created == null ? _form() : _result(_created!),
        ),
      ),
    );
  }

  Widget _form() {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('Name *', style: AppTextStyles.labelMd),
      const SizedBox(height: 6),
      TextField(
        controller: _nameController,
        textCapitalization: TextCapitalization.words,
        decoration: appInputDecoration(label: 'e.g. Juan Dela Cruz', icon: Icons.person_outline),
      ),
      const SizedBox(height: AppSpacing.sm),
      Text('Role *', style: AppTextStyles.labelMd),
      const SizedBox(height: 6),
      DropdownButtonFormField<String>(
        value: _role,
        decoration: appInputDecoration(label: 'Role', icon: Icons.badge_outlined),
        items: const [QrPerson.roleElder, QrPerson.roleMember]
            .map((r) => DropdownMenuItem(value: r, child: Text(r)))
            .toList(),
        onChanged: (v) => setState(() => _role = v ?? _role),
      ),
      const SizedBox(height: AppSpacing.sm),
      Text('The QR will contain only the generated ID (ELD-#### or MEM-####). No personal information is stored in it.',
          style: AppTextStyles.bodySm),
      const SizedBox(height: AppSpacing.lg),
      ElevatedButton.icon(
        onPressed: _isSaving ? null : _generate,
        icon: _isSaving
            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.qr_code_2),
        label: const Text('Generate QR'),
        style: AppButtonStyles.primary,
      ),
    ]);
  }

  Widget _result(QrPerson person) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Center(child: QrIdCard(person: person, repaintKey: _cardKey)),
      const SizedBox(height: AppSpacing.md),
      ElevatedButton.icon(
        onPressed: () async {
          try {
            await shareQrCard(_cardKey, person.qrId);
          } catch (_) {
            if (!mounted) return;
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Could not export the QR image.')));
          }
        },
        icon: const Icon(Icons.ios_share),
        label: const Text('Save / Print QR'),
        style: AppButtonStyles.primary,
      ),
      const SizedBox(height: AppSpacing.sm),
      OutlinedButton(onPressed: _createAnother, child: const Text('Create Another')),
    ]);
  }
}
