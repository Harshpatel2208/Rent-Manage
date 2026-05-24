import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/utils/decimal_converter.dart';

part 'loan.freezed.dart';
part 'loan.g.dart';

@freezed
class Loan with _$Loan {
  const factory Loan({
    required String id,
    required String borrowerId,
    required String borrowerName,
    @DecimalConverter() required Decimal principal,
    @DecimalConverter() required Decimal interestRate,
    required String status,
    required DateTime registeredAt,
    required DateTime firstCycleDate,
    DateTime? closedAt,
    required DateTime createdAt,
  }) = _Loan;

  factory Loan.fromJson(Map<String, dynamic> json) => _$LoanFromJson(json);
}
