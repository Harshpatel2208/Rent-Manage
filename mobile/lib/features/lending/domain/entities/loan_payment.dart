import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/utils/decimal_converter.dart';

part 'loan_payment.freezed.dart';
part 'loan_payment.g.dart';

@freezed
class LoanPayment with _$LoanPayment {
  const factory LoanPayment({
    required String id,
    required String loanId,
    @DecimalConverter() required Decimal amount,
    required DateTime paymentDate,
    required String type, // 'interest' | 'principal'
    required String idempotencyKey,
    DateTime? syncedAt,
    String? notes,
    required DateTime createdAt,
  }) = _LoanPayment;

  factory LoanPayment.fromJson(Map<String, dynamic> json) => _$LoanPaymentFromJson(json);
}
