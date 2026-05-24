// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rental_tenant.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RentalTenant _$RentalTenantFromJson(Map<String, dynamic> json) {
  return _RentalTenant.fromJson(json);
}

/// @nodoc
mixin _$RentalTenant {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'unit_id')
  String? get unitId => throw _privateConstructorUsedError;
  @JsonKey(name: 'unit_name')
  String? get unitName => throw _privateConstructorUsedError;
  @JsonKey(name: 'full_name')
  String get fullName => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  @JsonKey(name: 'rent_amount')
  @DecimalConverter()
  Decimal get rentAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'lease_start')
  DateTime get leaseStart => throw _privateConstructorUsedError;
  @JsonKey(name: 'lease_end')
  DateTime? get leaseEnd => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_month_status')
  String? get currentMonthStatus => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_month_paid')
  @DecimalConverter()
  Decimal? get currentMonthPaid => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_month_due')
  @DecimalConverter()
  Decimal? get currentMonthDue => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_month_balance')
  @DecimalConverter()
  Decimal? get currentMonthBalance => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_outstanding')
  @DecimalConverter()
  Decimal? get totalOutstanding => throw _privateConstructorUsedError;

  /// Serializes this RentalTenant to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RentalTenant
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RentalTenantCopyWith<RentalTenant> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RentalTenantCopyWith<$Res> {
  factory $RentalTenantCopyWith(
          RentalTenant value, $Res Function(RentalTenant) then) =
      _$RentalTenantCopyWithImpl<$Res, RentalTenant>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'unit_id') String? unitId,
      @JsonKey(name: 'unit_name') String? unitName,
      @JsonKey(name: 'full_name') String fullName,
      String? phone,
      @JsonKey(name: 'rent_amount') @DecimalConverter() Decimal rentAmount,
      @JsonKey(name: 'lease_start') DateTime leaseStart,
      @JsonKey(name: 'lease_end') DateTime? leaseEnd,
      @JsonKey(name: 'is_active') bool isActive,
      String? notes,
      @JsonKey(name: 'current_month_status') String? currentMonthStatus,
      @JsonKey(name: 'current_month_paid')
      @DecimalConverter()
      Decimal? currentMonthPaid,
      @JsonKey(name: 'current_month_due')
      @DecimalConverter()
      Decimal? currentMonthDue,
      @JsonKey(name: 'current_month_balance')
      @DecimalConverter()
      Decimal? currentMonthBalance,
      @JsonKey(name: 'total_outstanding')
      @DecimalConverter()
      Decimal? totalOutstanding});
}

/// @nodoc
class _$RentalTenantCopyWithImpl<$Res, $Val extends RentalTenant>
    implements $RentalTenantCopyWith<$Res> {
  _$RentalTenantCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RentalTenant
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? unitId = freezed,
    Object? unitName = freezed,
    Object? fullName = null,
    Object? phone = freezed,
    Object? rentAmount = null,
    Object? leaseStart = null,
    Object? leaseEnd = freezed,
    Object? isActive = null,
    Object? notes = freezed,
    Object? currentMonthStatus = freezed,
    Object? currentMonthPaid = freezed,
    Object? currentMonthDue = freezed,
    Object? currentMonthBalance = freezed,
    Object? totalOutstanding = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      unitId: freezed == unitId
          ? _value.unitId
          : unitId // ignore: cast_nullable_to_non_nullable
              as String?,
      unitName: freezed == unitName
          ? _value.unitName
          : unitName // ignore: cast_nullable_to_non_nullable
              as String?,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      rentAmount: null == rentAmount
          ? _value.rentAmount
          : rentAmount // ignore: cast_nullable_to_non_nullable
              as Decimal,
      leaseStart: null == leaseStart
          ? _value.leaseStart
          : leaseStart // ignore: cast_nullable_to_non_nullable
              as DateTime,
      leaseEnd: freezed == leaseEnd
          ? _value.leaseEnd
          : leaseEnd // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      currentMonthStatus: freezed == currentMonthStatus
          ? _value.currentMonthStatus
          : currentMonthStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      currentMonthPaid: freezed == currentMonthPaid
          ? _value.currentMonthPaid
          : currentMonthPaid // ignore: cast_nullable_to_non_nullable
              as Decimal?,
      currentMonthDue: freezed == currentMonthDue
          ? _value.currentMonthDue
          : currentMonthDue // ignore: cast_nullable_to_non_nullable
              as Decimal?,
      currentMonthBalance: freezed == currentMonthBalance
          ? _value.currentMonthBalance
          : currentMonthBalance // ignore: cast_nullable_to_non_nullable
              as Decimal?,
      totalOutstanding: freezed == totalOutstanding
          ? _value.totalOutstanding
          : totalOutstanding // ignore: cast_nullable_to_non_nullable
              as Decimal?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RentalTenantImplCopyWith<$Res>
    implements $RentalTenantCopyWith<$Res> {
  factory _$$RentalTenantImplCopyWith(
          _$RentalTenantImpl value, $Res Function(_$RentalTenantImpl) then) =
      __$$RentalTenantImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'unit_id') String? unitId,
      @JsonKey(name: 'unit_name') String? unitName,
      @JsonKey(name: 'full_name') String fullName,
      String? phone,
      @JsonKey(name: 'rent_amount') @DecimalConverter() Decimal rentAmount,
      @JsonKey(name: 'lease_start') DateTime leaseStart,
      @JsonKey(name: 'lease_end') DateTime? leaseEnd,
      @JsonKey(name: 'is_active') bool isActive,
      String? notes,
      @JsonKey(name: 'current_month_status') String? currentMonthStatus,
      @JsonKey(name: 'current_month_paid')
      @DecimalConverter()
      Decimal? currentMonthPaid,
      @JsonKey(name: 'current_month_due')
      @DecimalConverter()
      Decimal? currentMonthDue,
      @JsonKey(name: 'current_month_balance')
      @DecimalConverter()
      Decimal? currentMonthBalance,
      @JsonKey(name: 'total_outstanding')
      @DecimalConverter()
      Decimal? totalOutstanding});
}

/// @nodoc
class __$$RentalTenantImplCopyWithImpl<$Res>
    extends _$RentalTenantCopyWithImpl<$Res, _$RentalTenantImpl>
    implements _$$RentalTenantImplCopyWith<$Res> {
  __$$RentalTenantImplCopyWithImpl(
      _$RentalTenantImpl _value, $Res Function(_$RentalTenantImpl) _then)
      : super(_value, _then);

  /// Create a copy of RentalTenant
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? unitId = freezed,
    Object? unitName = freezed,
    Object? fullName = null,
    Object? phone = freezed,
    Object? rentAmount = null,
    Object? leaseStart = null,
    Object? leaseEnd = freezed,
    Object? isActive = null,
    Object? notes = freezed,
    Object? currentMonthStatus = freezed,
    Object? currentMonthPaid = freezed,
    Object? currentMonthDue = freezed,
    Object? currentMonthBalance = freezed,
    Object? totalOutstanding = freezed,
  }) {
    return _then(_$RentalTenantImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      unitId: freezed == unitId
          ? _value.unitId
          : unitId // ignore: cast_nullable_to_non_nullable
              as String?,
      unitName: freezed == unitName
          ? _value.unitName
          : unitName // ignore: cast_nullable_to_non_nullable
              as String?,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      rentAmount: null == rentAmount
          ? _value.rentAmount
          : rentAmount // ignore: cast_nullable_to_non_nullable
              as Decimal,
      leaseStart: null == leaseStart
          ? _value.leaseStart
          : leaseStart // ignore: cast_nullable_to_non_nullable
              as DateTime,
      leaseEnd: freezed == leaseEnd
          ? _value.leaseEnd
          : leaseEnd // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      currentMonthStatus: freezed == currentMonthStatus
          ? _value.currentMonthStatus
          : currentMonthStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      currentMonthPaid: freezed == currentMonthPaid
          ? _value.currentMonthPaid
          : currentMonthPaid // ignore: cast_nullable_to_non_nullable
              as Decimal?,
      currentMonthDue: freezed == currentMonthDue
          ? _value.currentMonthDue
          : currentMonthDue // ignore: cast_nullable_to_non_nullable
              as Decimal?,
      currentMonthBalance: freezed == currentMonthBalance
          ? _value.currentMonthBalance
          : currentMonthBalance // ignore: cast_nullable_to_non_nullable
              as Decimal?,
      totalOutstanding: freezed == totalOutstanding
          ? _value.totalOutstanding
          : totalOutstanding // ignore: cast_nullable_to_non_nullable
              as Decimal?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RentalTenantImpl implements _RentalTenant {
  const _$RentalTenantImpl(
      {required this.id,
      @JsonKey(name: 'unit_id') this.unitId,
      @JsonKey(name: 'unit_name') this.unitName,
      @JsonKey(name: 'full_name') required this.fullName,
      this.phone,
      @JsonKey(name: 'rent_amount')
      @DecimalConverter()
      required this.rentAmount,
      @JsonKey(name: 'lease_start') required this.leaseStart,
      @JsonKey(name: 'lease_end') this.leaseEnd,
      @JsonKey(name: 'is_active') this.isActive = true,
      this.notes,
      @JsonKey(name: 'current_month_status') this.currentMonthStatus,
      @JsonKey(name: 'current_month_paid')
      @DecimalConverter()
      this.currentMonthPaid,
      @JsonKey(name: 'current_month_due')
      @DecimalConverter()
      this.currentMonthDue,
      @JsonKey(name: 'current_month_balance')
      @DecimalConverter()
      this.currentMonthBalance,
      @JsonKey(name: 'total_outstanding')
      @DecimalConverter()
      this.totalOutstanding});

  factory _$RentalTenantImpl.fromJson(Map<String, dynamic> json) =>
      _$$RentalTenantImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'unit_id')
  final String? unitId;
  @override
  @JsonKey(name: 'unit_name')
  final String? unitName;
  @override
  @JsonKey(name: 'full_name')
  final String fullName;
  @override
  final String? phone;
  @override
  @JsonKey(name: 'rent_amount')
  @DecimalConverter()
  final Decimal rentAmount;
  @override
  @JsonKey(name: 'lease_start')
  final DateTime leaseStart;
  @override
  @JsonKey(name: 'lease_end')
  final DateTime? leaseEnd;
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;
  @override
  final String? notes;
  @override
  @JsonKey(name: 'current_month_status')
  final String? currentMonthStatus;
  @override
  @JsonKey(name: 'current_month_paid')
  @DecimalConverter()
  final Decimal? currentMonthPaid;
  @override
  @JsonKey(name: 'current_month_due')
  @DecimalConverter()
  final Decimal? currentMonthDue;
  @override
  @JsonKey(name: 'current_month_balance')
  @DecimalConverter()
  final Decimal? currentMonthBalance;
  @override
  @JsonKey(name: 'total_outstanding')
  @DecimalConverter()
  final Decimal? totalOutstanding;

  @override
  String toString() {
    return 'RentalTenant(id: $id, unitId: $unitId, unitName: $unitName, fullName: $fullName, phone: $phone, rentAmount: $rentAmount, leaseStart: $leaseStart, leaseEnd: $leaseEnd, isActive: $isActive, notes: $notes, currentMonthStatus: $currentMonthStatus, currentMonthPaid: $currentMonthPaid, currentMonthDue: $currentMonthDue, currentMonthBalance: $currentMonthBalance, totalOutstanding: $totalOutstanding)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RentalTenantImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.unitId, unitId) || other.unitId == unitId) &&
            (identical(other.unitName, unitName) ||
                other.unitName == unitName) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.rentAmount, rentAmount) ||
                other.rentAmount == rentAmount) &&
            (identical(other.leaseStart, leaseStart) ||
                other.leaseStart == leaseStart) &&
            (identical(other.leaseEnd, leaseEnd) ||
                other.leaseEnd == leaseEnd) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.currentMonthStatus, currentMonthStatus) ||
                other.currentMonthStatus == currentMonthStatus) &&
            (identical(other.currentMonthPaid, currentMonthPaid) ||
                other.currentMonthPaid == currentMonthPaid) &&
            (identical(other.currentMonthDue, currentMonthDue) ||
                other.currentMonthDue == currentMonthDue) &&
            (identical(other.currentMonthBalance, currentMonthBalance) ||
                other.currentMonthBalance == currentMonthBalance) &&
            (identical(other.totalOutstanding, totalOutstanding) ||
                other.totalOutstanding == totalOutstanding));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      unitId,
      unitName,
      fullName,
      phone,
      rentAmount,
      leaseStart,
      leaseEnd,
      isActive,
      notes,
      currentMonthStatus,
      currentMonthPaid,
      currentMonthDue,
      currentMonthBalance,
      totalOutstanding);

  /// Create a copy of RentalTenant
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RentalTenantImplCopyWith<_$RentalTenantImpl> get copyWith =>
      __$$RentalTenantImplCopyWithImpl<_$RentalTenantImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RentalTenantImplToJson(
      this,
    );
  }
}

abstract class _RentalTenant implements RentalTenant {
  const factory _RentalTenant(
      {required final String id,
      @JsonKey(name: 'unit_id') final String? unitId,
      @JsonKey(name: 'unit_name') final String? unitName,
      @JsonKey(name: 'full_name') required final String fullName,
      final String? phone,
      @JsonKey(name: 'rent_amount')
      @DecimalConverter()
      required final Decimal rentAmount,
      @JsonKey(name: 'lease_start') required final DateTime leaseStart,
      @JsonKey(name: 'lease_end') final DateTime? leaseEnd,
      @JsonKey(name: 'is_active') final bool isActive,
      final String? notes,
      @JsonKey(name: 'current_month_status') final String? currentMonthStatus,
      @JsonKey(name: 'current_month_paid')
      @DecimalConverter()
      final Decimal? currentMonthPaid,
      @JsonKey(name: 'current_month_due')
      @DecimalConverter()
      final Decimal? currentMonthDue,
      @JsonKey(name: 'current_month_balance')
      @DecimalConverter()
      final Decimal? currentMonthBalance,
      @JsonKey(name: 'total_outstanding')
      @DecimalConverter()
      final Decimal? totalOutstanding}) = _$RentalTenantImpl;

  factory _RentalTenant.fromJson(Map<String, dynamic> json) =
      _$RentalTenantImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'unit_id')
  String? get unitId;
  @override
  @JsonKey(name: 'unit_name')
  String? get unitName;
  @override
  @JsonKey(name: 'full_name')
  String get fullName;
  @override
  String? get phone;
  @override
  @JsonKey(name: 'rent_amount')
  @DecimalConverter()
  Decimal get rentAmount;
  @override
  @JsonKey(name: 'lease_start')
  DateTime get leaseStart;
  @override
  @JsonKey(name: 'lease_end')
  DateTime? get leaseEnd;
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;
  @override
  String? get notes;
  @override
  @JsonKey(name: 'current_month_status')
  String? get currentMonthStatus;
  @override
  @JsonKey(name: 'current_month_paid')
  @DecimalConverter()
  Decimal? get currentMonthPaid;
  @override
  @JsonKey(name: 'current_month_due')
  @DecimalConverter()
  Decimal? get currentMonthDue;
  @override
  @JsonKey(name: 'current_month_balance')
  @DecimalConverter()
  Decimal? get currentMonthBalance;
  @override
  @JsonKey(name: 'total_outstanding')
  @DecimalConverter()
  Decimal? get totalOutstanding;

  /// Create a copy of RentalTenant
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RentalTenantImplCopyWith<_$RentalTenantImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
