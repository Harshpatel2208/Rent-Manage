// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_metrics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DashboardMetrics {
  /// Total principal currently out on active loans.
  Decimal get totalActiveCapital => throw _privateConstructorUsedError;

  /// Sum of expected monthly interest across all active loans.
  Decimal get expectedMonthlyInterest => throw _privateConstructorUsedError;

  /// Sum of expected monthly rent from active tenants.
  Decimal get expectedMonthlyRent => throw _privateConstructorUsedError;

  /// Combined expected monthly income (interest + rent).
  Decimal get expectedMonthlyIncome => throw _privateConstructorUsedError;

  /// Total expenses recorded this calendar month.
  Decimal get totalExpensesThisMonth => throw _privateConstructorUsedError;

  /// Number of currently active loans.
  int get activeLoansCount => throw _privateConstructorUsedError;

  /// Number of currently active rental tenants.
  int get activeTenantsCount => throw _privateConstructorUsedError;

  /// Number of pending sync conflicts awaiting resolution.
  int get pendingConflictsCount => throw _privateConstructorUsedError;

  /// Create a copy of DashboardMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DashboardMetricsCopyWith<DashboardMetrics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DashboardMetricsCopyWith<$Res> {
  factory $DashboardMetricsCopyWith(
          DashboardMetrics value, $Res Function(DashboardMetrics) then) =
      _$DashboardMetricsCopyWithImpl<$Res, DashboardMetrics>;
  @useResult
  $Res call(
      {Decimal totalActiveCapital,
      Decimal expectedMonthlyInterest,
      Decimal expectedMonthlyRent,
      Decimal expectedMonthlyIncome,
      Decimal totalExpensesThisMonth,
      int activeLoansCount,
      int activeTenantsCount,
      int pendingConflictsCount});
}

/// @nodoc
class _$DashboardMetricsCopyWithImpl<$Res, $Val extends DashboardMetrics>
    implements $DashboardMetricsCopyWith<$Res> {
  _$DashboardMetricsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DashboardMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalActiveCapital = null,
    Object? expectedMonthlyInterest = null,
    Object? expectedMonthlyRent = null,
    Object? expectedMonthlyIncome = null,
    Object? totalExpensesThisMonth = null,
    Object? activeLoansCount = null,
    Object? activeTenantsCount = null,
    Object? pendingConflictsCount = null,
  }) {
    return _then(_value.copyWith(
      totalActiveCapital: null == totalActiveCapital
          ? _value.totalActiveCapital
          : totalActiveCapital // ignore: cast_nullable_to_non_nullable
              as Decimal,
      expectedMonthlyInterest: null == expectedMonthlyInterest
          ? _value.expectedMonthlyInterest
          : expectedMonthlyInterest // ignore: cast_nullable_to_non_nullable
              as Decimal,
      expectedMonthlyRent: null == expectedMonthlyRent
          ? _value.expectedMonthlyRent
          : expectedMonthlyRent // ignore: cast_nullable_to_non_nullable
              as Decimal,
      expectedMonthlyIncome: null == expectedMonthlyIncome
          ? _value.expectedMonthlyIncome
          : expectedMonthlyIncome // ignore: cast_nullable_to_non_nullable
              as Decimal,
      totalExpensesThisMonth: null == totalExpensesThisMonth
          ? _value.totalExpensesThisMonth
          : totalExpensesThisMonth // ignore: cast_nullable_to_non_nullable
              as Decimal,
      activeLoansCount: null == activeLoansCount
          ? _value.activeLoansCount
          : activeLoansCount // ignore: cast_nullable_to_non_nullable
              as int,
      activeTenantsCount: null == activeTenantsCount
          ? _value.activeTenantsCount
          : activeTenantsCount // ignore: cast_nullable_to_non_nullable
              as int,
      pendingConflictsCount: null == pendingConflictsCount
          ? _value.pendingConflictsCount
          : pendingConflictsCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DashboardMetricsImplCopyWith<$Res>
    implements $DashboardMetricsCopyWith<$Res> {
  factory _$$DashboardMetricsImplCopyWith(_$DashboardMetricsImpl value,
          $Res Function(_$DashboardMetricsImpl) then) =
      __$$DashboardMetricsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Decimal totalActiveCapital,
      Decimal expectedMonthlyInterest,
      Decimal expectedMonthlyRent,
      Decimal expectedMonthlyIncome,
      Decimal totalExpensesThisMonth,
      int activeLoansCount,
      int activeTenantsCount,
      int pendingConflictsCount});
}

/// @nodoc
class __$$DashboardMetricsImplCopyWithImpl<$Res>
    extends _$DashboardMetricsCopyWithImpl<$Res, _$DashboardMetricsImpl>
    implements _$$DashboardMetricsImplCopyWith<$Res> {
  __$$DashboardMetricsImplCopyWithImpl(_$DashboardMetricsImpl _value,
      $Res Function(_$DashboardMetricsImpl) _then)
      : super(_value, _then);

  /// Create a copy of DashboardMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalActiveCapital = null,
    Object? expectedMonthlyInterest = null,
    Object? expectedMonthlyRent = null,
    Object? expectedMonthlyIncome = null,
    Object? totalExpensesThisMonth = null,
    Object? activeLoansCount = null,
    Object? activeTenantsCount = null,
    Object? pendingConflictsCount = null,
  }) {
    return _then(_$DashboardMetricsImpl(
      totalActiveCapital: null == totalActiveCapital
          ? _value.totalActiveCapital
          : totalActiveCapital // ignore: cast_nullable_to_non_nullable
              as Decimal,
      expectedMonthlyInterest: null == expectedMonthlyInterest
          ? _value.expectedMonthlyInterest
          : expectedMonthlyInterest // ignore: cast_nullable_to_non_nullable
              as Decimal,
      expectedMonthlyRent: null == expectedMonthlyRent
          ? _value.expectedMonthlyRent
          : expectedMonthlyRent // ignore: cast_nullable_to_non_nullable
              as Decimal,
      expectedMonthlyIncome: null == expectedMonthlyIncome
          ? _value.expectedMonthlyIncome
          : expectedMonthlyIncome // ignore: cast_nullable_to_non_nullable
              as Decimal,
      totalExpensesThisMonth: null == totalExpensesThisMonth
          ? _value.totalExpensesThisMonth
          : totalExpensesThisMonth // ignore: cast_nullable_to_non_nullable
              as Decimal,
      activeLoansCount: null == activeLoansCount
          ? _value.activeLoansCount
          : activeLoansCount // ignore: cast_nullable_to_non_nullable
              as int,
      activeTenantsCount: null == activeTenantsCount
          ? _value.activeTenantsCount
          : activeTenantsCount // ignore: cast_nullable_to_non_nullable
              as int,
      pendingConflictsCount: null == pendingConflictsCount
          ? _value.pendingConflictsCount
          : pendingConflictsCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$DashboardMetricsImpl implements _DashboardMetrics {
  const _$DashboardMetricsImpl(
      {required this.totalActiveCapital,
      required this.expectedMonthlyInterest,
      required this.expectedMonthlyRent,
      required this.expectedMonthlyIncome,
      required this.totalExpensesThisMonth,
      required this.activeLoansCount,
      required this.activeTenantsCount,
      required this.pendingConflictsCount});

  /// Total principal currently out on active loans.
  @override
  final Decimal totalActiveCapital;

  /// Sum of expected monthly interest across all active loans.
  @override
  final Decimal expectedMonthlyInterest;

  /// Sum of expected monthly rent from active tenants.
  @override
  final Decimal expectedMonthlyRent;

  /// Combined expected monthly income (interest + rent).
  @override
  final Decimal expectedMonthlyIncome;

  /// Total expenses recorded this calendar month.
  @override
  final Decimal totalExpensesThisMonth;

  /// Number of currently active loans.
  @override
  final int activeLoansCount;

  /// Number of currently active rental tenants.
  @override
  final int activeTenantsCount;

  /// Number of pending sync conflicts awaiting resolution.
  @override
  final int pendingConflictsCount;

  @override
  String toString() {
    return 'DashboardMetrics(totalActiveCapital: $totalActiveCapital, expectedMonthlyInterest: $expectedMonthlyInterest, expectedMonthlyRent: $expectedMonthlyRent, expectedMonthlyIncome: $expectedMonthlyIncome, totalExpensesThisMonth: $totalExpensesThisMonth, activeLoansCount: $activeLoansCount, activeTenantsCount: $activeTenantsCount, pendingConflictsCount: $pendingConflictsCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DashboardMetricsImpl &&
            (identical(other.totalActiveCapital, totalActiveCapital) ||
                other.totalActiveCapital == totalActiveCapital) &&
            (identical(
                    other.expectedMonthlyInterest, expectedMonthlyInterest) ||
                other.expectedMonthlyInterest == expectedMonthlyInterest) &&
            (identical(other.expectedMonthlyRent, expectedMonthlyRent) ||
                other.expectedMonthlyRent == expectedMonthlyRent) &&
            (identical(other.expectedMonthlyIncome, expectedMonthlyIncome) ||
                other.expectedMonthlyIncome == expectedMonthlyIncome) &&
            (identical(other.totalExpensesThisMonth, totalExpensesThisMonth) ||
                other.totalExpensesThisMonth == totalExpensesThisMonth) &&
            (identical(other.activeLoansCount, activeLoansCount) ||
                other.activeLoansCount == activeLoansCount) &&
            (identical(other.activeTenantsCount, activeTenantsCount) ||
                other.activeTenantsCount == activeTenantsCount) &&
            (identical(other.pendingConflictsCount, pendingConflictsCount) ||
                other.pendingConflictsCount == pendingConflictsCount));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      totalActiveCapital,
      expectedMonthlyInterest,
      expectedMonthlyRent,
      expectedMonthlyIncome,
      totalExpensesThisMonth,
      activeLoansCount,
      activeTenantsCount,
      pendingConflictsCount);

  /// Create a copy of DashboardMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DashboardMetricsImplCopyWith<_$DashboardMetricsImpl> get copyWith =>
      __$$DashboardMetricsImplCopyWithImpl<_$DashboardMetricsImpl>(
          this, _$identity);
}

abstract class _DashboardMetrics implements DashboardMetrics {
  const factory _DashboardMetrics(
      {required final Decimal totalActiveCapital,
      required final Decimal expectedMonthlyInterest,
      required final Decimal expectedMonthlyRent,
      required final Decimal expectedMonthlyIncome,
      required final Decimal totalExpensesThisMonth,
      required final int activeLoansCount,
      required final int activeTenantsCount,
      required final int pendingConflictsCount}) = _$DashboardMetricsImpl;

  /// Total principal currently out on active loans.
  @override
  Decimal get totalActiveCapital;

  /// Sum of expected monthly interest across all active loans.
  @override
  Decimal get expectedMonthlyInterest;

  /// Sum of expected monthly rent from active tenants.
  @override
  Decimal get expectedMonthlyRent;

  /// Combined expected monthly income (interest + rent).
  @override
  Decimal get expectedMonthlyIncome;

  /// Total expenses recorded this calendar month.
  @override
  Decimal get totalExpensesThisMonth;

  /// Number of currently active loans.
  @override
  int get activeLoansCount;

  /// Number of currently active rental tenants.
  @override
  int get activeTenantsCount;

  /// Number of pending sync conflicts awaiting resolution.
  @override
  int get pendingConflictsCount;

  /// Create a copy of DashboardMetrics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DashboardMetricsImplCopyWith<_$DashboardMetricsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
