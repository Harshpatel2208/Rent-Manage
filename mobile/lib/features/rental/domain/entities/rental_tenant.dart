import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/utils/decimal_converter.dart';

part 'rental_tenant.freezed.dart';
part 'rental_tenant.g.dart';

@freezed
class RentalTenant with _$RentalTenant {
  const factory RentalTenant({
    required String id,
    @JsonKey(name: 'unit_id') String? unitId,
    @JsonKey(name: 'unit_name') String? unitName,
    @JsonKey(name: 'full_name') required String fullName,
    String? phone,
    @JsonKey(name: 'rent_amount') @DecimalConverter() required Decimal rentAmount,
    @JsonKey(name: 'lease_start') required DateTime leaseStart,
    @JsonKey(name: 'lease_end') DateTime? leaseEnd,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    String? notes,
    @JsonKey(name: 'current_month_status') String? currentMonthStatus,
    @JsonKey(name: 'current_month_paid') @DecimalConverter() Decimal? currentMonthPaid,
    @JsonKey(name: 'current_month_due') @DecimalConverter() Decimal? currentMonthDue,
    @JsonKey(name: 'current_month_balance') @DecimalConverter() Decimal? currentMonthBalance,
    @JsonKey(name: 'total_outstanding') @DecimalConverter() Decimal? totalOutstanding,
  }) = _RentalTenant;

  factory RentalTenant.fromJson(Map<String, dynamic> json) =>
      _$RentalTenantFromJson(json);
}
