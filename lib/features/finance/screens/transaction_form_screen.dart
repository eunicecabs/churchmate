import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../app/theme.dart';
import '../../../core/services/auth_service.dart';
import '../models/transaction_model.dart';

const List<String> kIncomeCategories = ['Tithes', 'Offerings', 'Donations', 'Other Income'];
const List<String> kExpenseCategories = [
  'Church Activity',
  'Youth Fellowship',
  'Outreach',
  'Food',
  'Transportation',
  'Supplies',
  'Events',
  'Equipment',
  'Other Expense',
];

/// Create or edit a transaction. Pass a transaction id as the route
/// argument to edit an existing one; pass nothing to add a new one.
class TransactionFormScreen extends StatefulWidget {
  const TransactionFormScreen({super.key});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _db = FirebaseFirestore.instance;

  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _type = TransactionType.income;
  String _category = kIncomeCategories.first;
  DateTime _date = DateTime.now();

  String? _transactionId;
  bool _loaded = false;
  bool _isSaving = false;

  List<String> get _categories => _type == TransactionType.income ? kIncomeCategories : kExpenseCategories;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final id = ModalRoute.of(context)?.settings.arguments as String?;
    if (id != null) {
      _transactionId = id;
      _loadTransaction(id);
    }
  }

  Future<void> _loadTransaction(String id) async {
    final doc = await _db.collection('transactions').doc(id).get();
    if (!doc.exists || !mounted) return;
    final t = TransactionModel.fromMap(doc.id, doc.data()!);
    setState(() {
      _type = t.type;
      _category = _categories.contains(t.category) ? t.category : _categories.first;
      _amountController.text = t.amount.toStringAsFixed(2);
      _descriptionController.text = t.description;
      _date = t.date;
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _setType(String type) {
    setState(() {
      _type = type;
      _category = _categories.first;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 3)),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please enter a valid amount.')));
      return;
    }

    final uid = context.read<AuthService>().currentUser?.id ?? '';
    setState(() => _isSaving = true);
    try {
      final data = TransactionModel(
        id: '',
        type: _type,
        category: _category,
        amount: amount,
        date: _date,
        description: _descriptionController.text.trim(),
        createdBy: uid,
      ).toMap();

      if (_transactionId != null) {
        await _db.collection('transactions').doc(_transactionId).update({
          ...data,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await _db.collection('transactions').add({
          ...data,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(_transactionId != null ? 'Transaction updated.' : 'Transaction recorded.')));
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Could not save transaction. Please try again.')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _transactionId != null;
    final isIncome = _type == TransactionType.income;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(isEditing ? 'Edit Transaction' : 'Add Transaction', style: AppTextStyles.headlineMd),
        iconTheme: const IconThemeData(color: AppColors.neutralDark),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.margin, vertical: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _setType(TransactionType.income),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isIncome ? AppColors.statusSuccess : AppColors.surface,
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(AppRadius.container)),
                        border: Border.all(color: AppColors.statusSuccess),
                      ),
                      child: Center(
                        child: Text('Income', style: AppTextStyles.labelLg.copyWith(color: isIncome ? Colors.white : AppColors.statusSuccess)),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _setType(TransactionType.expense),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: !isIncome ? AppColors.statusAlert : AppColors.surface,
                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(AppRadius.container)),
                        border: Border.all(color: AppColors.statusAlert),
                      ),
                      child: Center(
                        child: Text('Expense', style: AppTextStyles.labelLg.copyWith(color: !isIncome ? Colors.white : AppColors.statusAlert)),
                      ),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: AppSpacing.md),

              Text('Category *', style: AppTextStyles.labelMd),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _categories.contains(_category) ? _category : _categories.first,
                decoration: appInputDecoration(label: 'Category', icon: Icons.category_outlined),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _category = v ?? _category),
              ),
              const SizedBox(height: AppSpacing.sm),

              Text('Amount (₱) *', style: AppTextStyles.labelMd),
              const SizedBox(height: 6),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: appInputDecoration(label: 'e.g. 500.00', icon: Icons.payments_outlined),
              ),
              const SizedBox(height: AppSpacing.sm),

              Text('Date *', style: AppTextStyles.labelMd),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: appInputDecoration(label: 'Date', icon: Icons.calendar_today_outlined),
                  child: Text(DateFormat('MMM d, yyyy').format(_date)),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              Text('Description / Notes', style: AppTextStyles.labelMd),
              const SizedBox(height: 6),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: appInputDecoration(label: 'e.g. Sunday tithe'),
              ),
              const SizedBox(height: AppSpacing.lg),

              ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.check),
                label: Text(isEditing ? 'Save Changes' : 'Save Transaction'),
                style: AppButtonStyles.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
