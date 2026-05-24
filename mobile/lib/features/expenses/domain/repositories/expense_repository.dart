import '../entities/expense.dart';

abstract class ExpenseRepository {
  Future<List<Expense>> getExpenses({
    String? category,
    DateTime? dateFrom,
    DateTime? dateTo,
    int? limit,
    int? offset,
  });

  Future<Expense> createExpense({
    required double amount,
    required String category,
    required DateTime expenseDate,
    String? description,
  });
}
