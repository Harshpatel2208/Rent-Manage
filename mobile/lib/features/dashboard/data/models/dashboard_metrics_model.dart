import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';


import '../../domain/entities/dashboard_metrics.dart';

part 'dashboard_metrics_model.freezed.dart';
part 'dashboard_metrics_model.g.dart';

/// Data model for [DashboardMetrics] — all monetary values come as strings
/// from the API and are parsed into [Decimal] here.
@freezed
class DashboardMetricsModel with _$DashboardMetricsModel {
  const factory DashboardMetricsModel({
    @JsonKey(name: 'total_active_capital')
    required String totalActiveCapital,
    @JsonKey(name: 'expected_monthly_interest')
    required String expectedMonthlyInterest,
    @JsonKey(name: 'expected_monthly_rent')
    required String expectedMonthlyRent,
    @JsonKey(name: 'expected_monthly_income')
    required String expectedMonthlyIncome,
    @JsonKey(name: 'total_expenses_this_month')
    required String totalExpensesThisMonth,
    @JsonKey(name: 'active_loans_count') required int activeLoansCount,
    @JsonKey(name: 'active_tenants_count') required int activeTenantsCount,
    @JsonKey(name: 'pending_conflicts_count')
    required int pendingConflictsCount,
  }) = _DashboardMetricsModel;

  const DashboardMetricsModel._();

  factory DashboardMetricsModel.fromJson(Map<String, dynamic> json) =>
      _$DashboardMetricsModelFromJson(json);

  /// Converts to the domain [DashboardMetrics] entity.
  DashboardMetrics toEntity() => DashboardMetrics(
        totalActiveCapital: Decimal.parse(totalActiveCapital),
        expectedMonthlyInterest: Decimal.parse(expectedMonthlyInterest),
        expectedMonthlyRent: Decimal.parse(expectedMonthlyRent),
        expectedMonthlyIncome: Decimal.parse(expectedMonthlyIncome),
        totalExpensesThisMonth: Decimal.parse(totalExpensesThisMonth),
        activeLoansCount: activeLoansCount,
        activeTenantsCount: activeTenantsCount,
        pendingConflictsCount: pendingConflictsCount,
      );
}
