import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/utils/decimal_converter.dart';

part 'interest_schedule.freezed.dart';
part 'interest_schedule.g.dart';

@freezed
class InterestSchedule with _$InterestSchedule {
  const factory InterestSchedule({
    required String id,
    required String loanId,
    required DateTime cycleMonth,
    @DecimalConverter() required Decimal expectedAmount,
    required String status, // 'pending' | 'collected' | 'waived'
    required DateTime createdAt,
  }) = _InterestSchedule;

  factory InterestSchedule.fromJson(Map<String, dynamic> json) =>
      _$InterestScheduleFromJson(json);
}
