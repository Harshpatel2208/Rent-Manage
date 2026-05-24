// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_metrics_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DashboardMetricsModelImpl _$$DashboardMetricsModelImplFromJson(
        Map<String, dynamic> json) =>
    _$DashboardMetricsModelImpl(
      totalActiveCapital: json['total_active_capital'] as String,
      expectedMonthlyInterest: json['expected_monthly_interest'] as String,
      expectedMonthlyRent: json['expected_monthly_rent'] as String,
      expectedMonthlyIncome: json['expected_monthly_income'] as String,
      totalExpensesThisMonth: json['total_expenses_this_month'] as String,
      activeLoansCount: (json['active_loans_count'] as num).toInt(),
      activeTenantsCount: (json['active_tenants_count'] as num).toInt(),
      pendingConflictsCount: (json['pending_conflicts_count'] as num).toInt(),
    );

Map<String, dynamic> _$$DashboardMetricsModelImplToJson(
        _$DashboardMetricsModelImpl instance) =>
    <String, dynamic>{
      'total_active_capital': instance.totalActiveCapital,
      'expected_monthly_interest': instance.expectedMonthlyInterest,
      'expected_monthly_rent': instance.expectedMonthlyRent,
      'expected_monthly_income': instance.expectedMonthlyIncome,
      'total_expenses_this_month': instance.totalExpensesThisMonth,
      'active_loans_count': instance.activeLoansCount,
      'active_tenants_count': instance.activeTenantsCount,
      'pending_conflicts_count': instance.pendingConflictsCount,
    };
