// Mirrors the `transactions/{transactionId}` Firestore document.
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionType {
  static const income = 'Income';
  static const expense = 'Expense';
}

class TransactionModel {
  final String id;
  final String type; // TransactionType.income or .expense
  final String category;
  final double amount;
  final DateTime date;
  final String description;
  final String createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TransactionModel({
    required this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.date,
    required this.description,
    required this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory TransactionModel.fromMap(String id, Map<String, dynamic> data) {
    return TransactionModel(
      id: id,
      type: data['type'] as String? ?? TransactionType.income,
      category: data['category'] as String? ?? 'Other',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      description: data['description'] as String? ?? '',
      createdBy: data['createdBy'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'category': category,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'description': description,
      'createdBy': createdBy,
    };
  }

  bool get isIncome => type == TransactionType.income;
}
