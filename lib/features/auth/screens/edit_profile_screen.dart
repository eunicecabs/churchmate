import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../app/theme.dart';
import '../../../core/services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  File? _pickedPhoto;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthService>().currentUser;
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: source, maxWidth: 1024, imageQuality: 85);
      if (file == null) return;
      setState(() => _pickedPhoto = File(file.path));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not access camera/gallery. Check app permissions.')),
      );
    }
  }

  void _showPhotoSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.prominent))),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Full name cannot be empty.')));
      return;
    }
    setState(() => _isSaving = true);
    try {
      await context.read<AuthService>().updateProfile(
            fullName: _nameController.text,
            phone: _phoneController.text,
            photoFile: _pickedPhoto,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated.')));
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Could not save changes. Please try again.')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Edit Profile', style: AppTextStyles.headlineMd),
        iconTheme: const IconThemeData(color: AppColors.neutralDark),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSpacing.margin, vertical: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _showPhotoSourceSheet,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: AppColors.primary300,
                        backgroundImage: _pickedPhoto != null
                            ? FileImage(_pickedPhoto!)
                            : (user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null)
                                as ImageProvider?,
                        child: (_pickedPhoto == null && user?.photoUrl == null)
                            ? const Icon(Icons.person, color: Colors.white, size: 40)
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                              color: AppColors.primary900, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Center(
                child: Text('Tap to change photo',
                    style: AppTextStyles.bodySm.copyWith(color: AppColors.primary700)),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Full Name', style: AppTextStyles.labelMd),
              const SizedBox(height: 6),
              TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: appInputDecoration(label: 'Full name', icon: Icons.person_outline)),
              const SizedBox(height: AppSpacing.sm),
              Text('Email', style: AppTextStyles.labelMd),
              const SizedBox(height: 6),
              TextField(
                enabled: false,
                controller: TextEditingController(text: user?.email ?? ''),
                decoration: appInputDecoration(label: 'Email', icon: Icons.email_outlined),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text('Phone Number', style: AppTextStyles.labelMd),
              const SizedBox(height: 6),
              TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: appInputDecoration(label: 'e.g. 09171234567', icon: Icons.phone_outlined)),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.check),
                label: const Text('Save Changes'),
                style: AppButtonStyles.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
