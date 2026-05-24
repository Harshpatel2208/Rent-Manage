import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/utils/decimal_converter.dart';

part 'rent_payment.freezed.dart';
part 'rent_payment.g.dart';

@freezed
class RentPayment with _$RentPayment {
  const factory RentPayment({
    required String id,
    @JsonKey(name: 'rental_tenant_id') required String rentalTenantId,
    @JsonKey(name: 'cycle_month') required DateTime cycleMonth,
    @JsonKey(name: 'amount_due') @DecimalConverter() required Decimal amountDue,
    @JsonKey(name: 'amount_paid') @DecimalConverter() required Decimal amountPaid,
    @JsonKey(name: 'remaining_balance') @DecimalConverter() required Decimal remainingBalance,
    required String status,
    @JsonKey(name: 'idempotency_key') required String idempotencyKey,
    @JsonKey(name: 'synced_at') DateTime? syncedAt,
    String? notes,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _RentPayment;

  factory RentPayment.fromJson(Map<String, dynamic> json) =>
      _$RentPaymentFromJson(json);
}
