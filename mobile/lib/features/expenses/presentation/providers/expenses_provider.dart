import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/expense.dart';
import '../../data/repositories/expense_repository_impl.dart';

part 'expenses_provider.g.dart';

@riverpod
class ExpensesList extends _$ExpensesList {
  String? _category;
  DateTime? _dateFrom;
  DateTime? _dateTo;

  @override
  FutureOr<List<Expense>> build() async {
    final repository = ref.watch(expenseRepositoryProvider);
    return repository.getExpenses(
      category: _category,
      dateFrom: _dateFrom,
      dateTo: _dateTo,
    );
  }

  Future<void> updateFilters({
    String? category,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    _category = category;
    _dateFrom = dateFrom;
    _dateTo = dateTo;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(expenseRepositoryProvider);
      return repository.getExpenses(
        category: _category,
        dateFrom: _dateFrom,
        dateTo: _dateTo,
      );
    });
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(expenseRepositoryProvider);
      return repository.getExpenses(
        category: _category,
        dateFrom: _dateFrom,
        dateTo: _dateTo,
      );
    });
  }

  Future<Expense> addExpense({
    required double amount,
    required String category,
    required DateTime expenseDate,
    String? description,
  }) async {
    final repository = ref.read(expenseRepositoryProvider);
    final result = await repository.createExpense(
      amount: amount,
      category: category,
      expenseDate: expenseDate,
      description: description,
    );
    ref.invalidateSelf();
    return result;
  }
}
