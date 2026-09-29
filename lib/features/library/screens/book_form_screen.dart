import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../app/theme.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../shared/widgets/book_cover.dart';
import '../models/book_model.dart';

const List<String> kBookCategories = [
  'Bible Study',
  'Christian Living',
  'Devotional',
  'Theology',
  'Youth',
  'Other',
];

/// Create or edit a book. Pass a book id as the route argument to edit an
/// existing book; pass nothing to add a new one.
class BookFormScreen extends StatefulWidget {
  const BookFormScreen({super.key});

  @override
  State<BookFormScreen> createState() => _BookFormScreenState();
}

class _BookFormScreenState extends State<BookFormScreen> {
  final _db = FirebaseFirestore.instance;
  final _storage = StorageService();

  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _descriptionController = TextEditingController();
  final _isbnController = TextEditingController();
  final _yearController = TextEditingController();

  String _category = kBookCategories.first;
  File? _pickedImage;
  String? _existingImageUrl;
  String? _existingBase64;

  String? _bookId;
  bool _loaded = false;
  bool _isSaving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final id = ModalRoute.of(context)?.settings.arguments as String?;
    if (id != null) {
      _bookId = id;
      _loadBook(id);
    }
  }

  Future<void> _loadBook(String id) async {
    final doc = await _db.collection('books').doc(id).get();
    if (!doc.exists || !mounted) return;
    final book = BookModel.fromMap(doc.id, doc.data()!);
    setState(() {
      _titleController.text = book.title;
      _authorController.text = book.author;
      _quantityController.text = book.availableQuantity.toString();
      _descriptionController.text = book.description ?? '';
      _isbnController.text = book.isbn ?? '';
      _yearController.text = book.publicationYear?.toString() ?? '';
      _category = kBookCategories.contains(book.category) ? book.category : kBookCategories.last;
      _existingImageUrl = book.imageUrl;
      _existingBase64 = book.coverBase64;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    _isbnController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800, imageQuality: 75);
      if (file != null) setState(() => _pickedImage = File(file.path));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open gallery.')));
    }
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty || _authorController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please fill in the book title and author.')));
      return;
    }
    final quantity = int.tryParse(_quantityController.text.trim());
    if (quantity == null || quantity < 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please enter a valid available quantity.')));
      return;
    }

    final uid = context.read<AuthService>().currentUser?.id ?? '';
    setState(() => _isSaving = true);
    try {
      // Reserve the document id first so the cover can be uploaded under it
      // and the book is written ONCE with its final coverUrl.
      final ref = _bookId != null ? _db.collection('books').doc(_bookId) : _db.collection('books').doc();

      String? coverUrl = _existingImageUrl;
      String? coverBase64 = _existingBase64;
      String? coverProblem;
      if (_pickedImage != null) {
        try {
          // Preferred: Firebase Storage. Timeout so a misconfigured bucket
          // can't leave the screen spinning forever.
          coverUrl = await _storage
              .uploadBookCover(ref.id, _pickedImage!)
              .timeout(const Duration(seconds: 25));
          coverBase64 = null; // Storage copy wins
        } catch (e) {
          coverProblem = e.toString();
          // Fallback: keep the (already resized) image on the book document so
          // the cover still persists and displays.
          try {
            final bytes = await _pickedImage!.readAsBytes();
            if (bytes.length <= 700 * 1024) {
              coverBase64 = base64Encode(bytes);
              coverUrl = null;
              coverProblem = null;
            }
          } catch (_) {}
        }
      }

      final data = BookModel(
        id: '',
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        category: _category,
        availableQuantity: quantity,
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        isbn: _isbnController.text.trim().isEmpty ? null : _isbnController.text.trim(),
        publicationYear: int.tryParse(_yearController.text.trim()),
        imageUrl: coverUrl,
        coverBase64: coverBase64,
        createdBy: uid,
      ).toMap();

      if (_bookId != null) {
        await ref.update({
          ...data,
          if (coverUrl == null) 'imageUrl': FieldValue.delete(),
          if (coverBase64 == null) 'coverBase64': FieldValue.delete(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await ref.set({
          ...data,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(coverProblem != null
            ? 'Book saved, but the cover could not be saved ($coverProblem).'
            : (_bookId != null ? 'Book updated.' : 'Book added.')),
      ));
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Could not save book. Please try again.')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _bookId != null;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(isEditing ? 'Edit Book' : 'Add Book', style: AppTextStyles.headlineMd),
        iconTheme: const IconThemeData(color: AppColors.neutralDark),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin, vertical: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Center(
                  child: Container(
                    width: 110,
                    height: 150,
                    decoration: BoxDecoration(
                      color: AppColors.primary300.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppRadius.base),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _pickedImage != null
                        ? Image.file(_pickedImage!, width: 110, height: 150, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_outlined, color: AppColors.primary900))
                        : BookCover(
                            url: _existingImageUrl,
                            base64Data: _existingBase64,
                            width: 110,
                            height: 150,
                            fallback: const Center(
                                child: Icon(Icons.add_photo_alternate_outlined, color: AppColors.primary900, size: 28)),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(child: Text('Cover image (optional)', style: AppTextStyles.bodySm)),
              const SizedBox(height: AppSpacing.md),

              Text('Book Title *', style: AppTextStyles.labelMd),
              const SizedBox(height: 6),
              TextField(
                  controller: _titleController,
                  decoration: appInputDecoration(label: 'e.g. Understanding the Bible', icon: Icons.menu_book_outlined)),
              const SizedBox(height: AppSpacing.sm),

              Text('Author *', style: AppTextStyles.labelMd),
              const SizedBox(height: 6),
              TextField(
                  controller: _authorController,
                  decoration: appInputDecoration(label: 'e.g. John Smith', icon: Icons.person_outline)),
              const SizedBox(height: AppSpacing.sm),

              Text('Category *', style: AppTextStyles.labelMd),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: appInputDecoration(label: 'Category', icon: Icons.category_outlined),
                items: kBookCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _category = v ?? _category),
              ),
              const SizedBox(height: AppSpacing.sm),

              Text('Available Quantity *', style: AppTextStyles.labelMd),
              const SizedBox(height: 6),
              TextField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: appInputDecoration(label: 'e.g. 5', icon: Icons.inventory_2_outlined)),
              const SizedBox(height: AppSpacing.sm),

              Text('Description (optional)', style: AppTextStyles.labelMd),
              const SizedBox(height: 6),
              TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: appInputDecoration(label: 'Short synopsis...')),
              const SizedBox(height: AppSpacing.sm),

              Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('ISBN (optional)', style: AppTextStyles.labelMd),
                    const SizedBox(height: 6),
                    TextField(controller: _isbnController, decoration: appInputDecoration(label: 'ISBN')),
                  ]),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Year (optional)', style: AppTextStyles.labelMd),
                    const SizedBox(height: 6),
                    TextField(
                        controller: _yearController,
                        keyboardType: TextInputType.number,
                        decoration: appInputDecoration(label: 'e.g. 2020')),
                  ]),
                ),
              ]),
              const SizedBox(height: AppSpacing.lg),

              ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.check),
                label: Text(isEditing ? 'Save Changes' : 'Add Book'),
                style: AppButtonStyles.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
