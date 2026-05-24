import 'package:decimal/decimal.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_metrics.freezed.dart';

/// Aggregated dashboard metrics returned from the backend.
@freezed
class DashboardMetrics with _$DashboardMetrics {
  const factory DashboardMetrics({
    /// Total principal currently out on active loans.
    required Decimal totalActiveCapital,

    /// Sum of expected monthly interest across all active loans.
    required Decimal expectedMonthlyInterest,

    /// Sum of expected monthly rent from active tenants.
    required Decimal expectedMonthlyRent,

    /// Combined expected monthly income (interest + rent).
    required Decimal expectedMonthlyIncome,

    /// Total expenses recorded this calendar month.
    required Decimal totalExpensesThisMonth,

    /// Number of currently active loans.
    required int activeLoansCount,

    /// Number of currently active rental tenants.
    required int activeTenantsCount,

    /// Number of pending sync conflicts awaiting resolution.
    required int pendingConflictsCount,
  }) = _DashboardMetrics;
}
