// Single place where the Giving totals are computed, so every screen
// (Giving page, Home fund card, expense warning) agrees and the available
// balance can NEVER be negative.
//
// The raw income/expense records are never altered. When expenses are bigger
// than income, available funds are shown as 0 and the difference is reported
// as a shortage instead of a negative balance.
import 'transaction_model.dart';

class FundSummary {
  final double income;
  final double expenses;

  const FundSummary({required this.income, required this.expenses});

  factory FundSummary.from(Iterable<TransactionModel> transactions) {
    double income = 0;
    double expenses = 0;
    for (final t in transactions) {
      if (t.isIncome) {
        income += t.amount;
      } else {
        expenses += t.amount;
      }
    }
    return FundSummary(income: income, expenses: expenses);
  }

  /// Available money, never below zero.
  double get available => income > expenses ? income - expenses : 0;

  /// How much the expenses exceed the income (0 when funds are enough).
  double get shortage => expenses > income ? expenses - income : 0;

  bool get isInsufficient => shortage > 0;

  String get statusLabel => isInsufficient ? 'Insufficient Funds / Kapos sa Pera' : 'Funds OK';
}
