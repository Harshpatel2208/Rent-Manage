import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/utils/decimal_converter.dart';

part 'expense.freezed.dart';
part 'expense.g.dart';

@freezed
class Expense with _$Expense {
  const factory Expense({
    required String id,
    @DecimalConverter() required Decimal amount,
    required String category, // 'food' | 'maintenance' | 'travel' | 'business' | 'other'
    @JsonKey(name: 'expense_date') required DateTime expenseDate,
    String? description,
    @JsonKey(name: 'idempotency_key') required String idempotencyKey,
    @JsonKey(name: 'synced_at') DateTime? syncedAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Expense;

  factory Expense.fromJson(Map<String, dynamic> json) =>
      _$ExpenseFromJson(json);
}
