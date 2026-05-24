// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rent_payment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RentPayment _$RentPaymentFromJson(Map<String, dynamic> json) {
  return _RentPayment.fromJson(json);
}

/// @nodoc
mixin _$RentPayment {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'rental_tenant_id')
  String get rentalTenantId => throw _privateConstructorUsedError;
  @JsonKey(name: 'cycle_month')
  DateTime get cycleMonth => throw _privateConstructorUsedError;
  @JsonKey(name: 'amount_due')
  @DecimalConverter()
  Decimal get amountDue => throw _privateConstructorUsedError;
  @JsonKey(name: 'amount_paid')
  @DecimalConverter()
  Decimal get amountPaid => throw _privateConstructorUsedError;
  @JsonKey(name: 'remaining_balance')
  @DecimalConverter()
  Decimal get remainingBalance => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'idempotency_key')
  String get idempotencyKey => throw _privateConstructorUsedError;
  @JsonKey(name: 'synced_at')
  DateTime? get syncedAt => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this RentPayment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RentPayment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RentPaymentCopyWith<RentPayment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RentPaymentCopyWith<$Res> {
  factory $RentPaymentCopyWith(
          RentPayment value, $Res Function(RentPayment) then) =
      _$RentPaymentCopyWithImpl<$Res, RentPayment>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'rental_tenant_id') String rentalTenantId,
      @JsonKey(name: 'cycle_month') DateTime cycleMonth,
      @JsonKey(name: 'amount_due') @DecimalConverter() Decimal amountDue,
      @JsonKey(name: 'amount_paid') @DecimalConverter() Decimal amountPaid,
      @JsonKey(name: 'remaining_balance')
      @DecimalConverter()
      Decimal remainingBalance,
      String status,
      @JsonKey(name: 'idempotency_key') String idempotencyKey,
      @JsonKey(name: 'synced_at') DateTime? syncedAt,
      String? notes,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class _$RentPaymentCopyWithImpl<$Res, $Val extends RentPayment>
    implements $RentPaymentCopyWith<$Res> {
  _$RentPaymentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RentPayment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? rentalTenantId = null,
    Object? cycleMonth = null,
    Object? amountDue = null,
    Object? amountPaid = null,
    Object? remainingBalance = null,
    Object? status = null,
    Object? idempotencyKey = null,
    Object? syncedAt = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      rentalTenantId: null == rentalTenantId
          ? _value.rentalTenantId
          : rentalTenantId // ignore: cast_nullable_to_non_nullable
              as String,
      cycleMonth: null == cycleMonth
          ? _value.cycleMonth
          : cycleMonth // ignore: cast_nullable_to_non_nullable
              as DateTime,
      amountDue: null == amountDue
          ? _value.amountDue
          : amountDue // ignore: cast_nullable_to_non_nullable
              as Decimal,
      amountPaid: null == amountPaid
          ? _value.amountPaid
          : amountPaid // ignore: cast_nullable_to_non_nullable
              as Decimal,
      remainingBalance: null == remainingBalance
          ? _value.remainingBalance
          : remainingBalance // ignore: cast_nullable_to_non_nullable
              as Decimal,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      idempotencyKey: null == idempotencyKey
          ? _value.idempotencyKey
          : idempotencyKey // ignore: cast_nullable_to_non_nullable
              as String,
      syncedAt: freezed == syncedAt
          ? _value.syncedAt
          : syncedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RentPaymentImplCopyWith<$Res>
    implements $RentPaymentCopyWith<$Res> {
  factory _$$RentPaymentImplCopyWith(
          _$RentPaymentImpl value, $Res Function(_$RentPaymentImpl) then) =
      __$$RentPaymentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'rental_tenant_id') String rentalTenantId,
      @JsonKey(name: 'cycle_month') DateTime cycleMonth,
      @JsonKey(name: 'amount_due') @DecimalConverter() Decimal amountDue,
      @JsonKey(name: 'amount_paid') @DecimalConverter() Decimal amountPaid,
      @JsonKey(name: 'remaining_balance')
      @DecimalConverter()
      Decimal remainingBalance,
      String status,
      @JsonKey(name: 'idempotency_key') String idempotencyKey,
      @JsonKey(name: 'synced_at') DateTime? syncedAt,
      String? notes,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class __$$RentPaymentImplCopyWithImpl<$Res>
    extends _$RentPaymentCopyWithImpl<$Res, _$RentPaymentImpl>
    implements _$$RentPaymentImplCopyWith<$Res> {
  __$$RentPaymentImplCopyWithImpl(
      _$RentPaymentImpl _value, $Res Function(_$RentPaymentImpl) _then)
      : super(_value, _then);

  /// Create a copy of RentPayment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? rentalTenantId = null,
    Object? cycleMonth = null,
    Object? amountDue = null,
    Object? amountPaid = null,
    Object? remainingBalance = null,
    Object? status = null,
    Object? idempotencyKey = null,
    Object? syncedAt = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$RentPaymentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      rentalTenantId: null == rentalTenantId
          ? _value.rentalTenantId
          : rentalTenantId // ignore: cast_nullable_to_non_nullable
              as String,
      cycleMonth: null == cycleMonth
          ? _value.cycleMonth
          : cycleMonth // ignore: cast_nullable_to_non_nullable
              as DateTime,
      amountDue: null == amountDue
          ? _value.amountDue
          : amountDue // ignore: cast_nullable_to_non_nullable
              as Decimal,
      amountPaid: null == amountPaid
          ? _value.amountPaid
          : amountPaid // ignore: cast_nullable_to_non_nullable
              as Decimal,
      remainingBalance: null == remainingBalance
          ? _value.remainingBalance
          : remainingBalance // ignore: cast_nullable_to_non_nullable
              as Decimal,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      idempotencyKey: null == idempotencyKey
          ? _value.idempotencyKey
          : idempotencyKey // ignore: cast_nullable_to_non_nullable
              as String,
      syncedAt: freezed == syncedAt
          ? _value.syncedAt
          : syncedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RentPaymentImpl implements _RentPayment {
  const _$RentPaymentImpl(
      {required this.id,
      @JsonKey(name: 'rental_tenant_id') required this.rentalTenantId,
      @JsonKey(name: 'cycle_month') required this.cycleMonth,
      @JsonKey(name: 'amount_due') @DecimalConverter() required this.amountDue,
      @JsonKey(name: 'amount_paid')
      @DecimalConverter()
      required this.amountPaid,
      @JsonKey(name: 'remaining_balance')
      @DecimalConverter()
      required this.remainingBalance,
      required this.status,
      @JsonKey(name: 'idempotency_key') required this.idempotencyKey,
      @JsonKey(name: 'synced_at') this.syncedAt,
      this.notes,
      @JsonKey(name: 'created_at') required this.createdAt});

  factory _$RentPaymentImpl.fromJson(Map<String, dynamic> json) =>
      _$$RentPaymentImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'rental_tenant_id')
  final String rentalTenantId;
  @override
  @JsonKey(name: 'cycle_month')
  final DateTime cycleMonth;
  @override
  @JsonKey(name: 'amount_due')
  @DecimalConverter()
  final Decimal amountDue;
  @override
  @JsonKey(name: 'amount_paid')
  @DecimalConverter()
  final Decimal amountPaid;
  @override
  @JsonKey(name: 'remaining_balance')
  @DecimalConverter()
  final Decimal remainingBalance;
  @override
  final String status;
  @override
  @JsonKey(name: 'idempotency_key')
  final String idempotencyKey;
  @override
  @JsonKey(name: 'synced_at')
  final DateTime? syncedAt;
  @override
  final String? notes;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'RentPayment(id: $id, rentalTenantId: $rentalTenantId, cycleMonth: $cycleMonth, amountDue: $amountDue, amountPaid: $amountPaid, remainingBalance: $remainingBalance, status: $status, idempotencyKey: $idempotencyKey, syncedAt: $syncedAt, notes: $notes, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RentPaymentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.rentalTenantId, rentalTenantId) ||
                other.rentalTenantId == rentalTenantId) &&
            (identical(other.cycleMonth, cycleMonth) ||
                other.cycleMonth == cycleMonth) &&
            (identical(other.amountDue, amountDue) ||
                other.amountDue == amountDue) &&
            (identical(other.amountPaid, amountPaid) ||
                other.amountPaid == amountPaid) &&
            (identical(other.remainingBalance, remainingBalance) ||
                other.remainingBalance == remainingBalance) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.idempotencyKey, idempotencyKey) ||
                other.idempotencyKey == idempotencyKey) &&
            (identical(other.syncedAt, syncedAt) ||
                other.syncedAt == syncedAt) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      rentalTenantId,
      cycleMonth,
      amountDue,
      amountPaid,
      remainingBalance,
      status,
      idempotencyKey,
      syncedAt,
      notes,
      createdAt);

  /// Create a copy of RentPayment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RentPaymentImplCopyWith<_$RentPaymentImpl> get copyWith =>
      __$$RentPaymentImplCopyWithImpl<_$RentPaymentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RentPaymentImplToJson(
      this,
    );
  }
}

abstract class _RentPayment implements RentPayment {
  const factory _RentPayment(
      {required final String id,
      @JsonKey(name: 'rental_tenant_id') required final String rentalTenantId,
      @JsonKey(name: 'cycle_month') required final DateTime cycleMonth,
      @JsonKey(name: 'amount_due')
      @DecimalConverter()
      required final Decimal amountDue,
      @JsonKey(name: 'amount_paid')
      @DecimalConverter()
      required final Decimal amountPaid,
      @JsonKey(name: 'remaining_balance')
      @DecimalConverter()
      required final Decimal remainingBalance,
      required final String status,
      @JsonKey(name: 'idempotency_key') required final String idempotencyKey,
      @JsonKey(name: 'synced_at') final DateTime? syncedAt,
      final String? notes,
      @JsonKey(name: 'created_at')
      required final DateTime createdAt}) = _$RentPaymentImpl;

  factory _RentPayment.fromJson(Map<String, dynamic> json) =
      _$RentPaymentImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'rental_tenant_id')
  String get rentalTenantId;
  @override
  @JsonKey(name: 'cycle_month')
  DateTime get cycleMonth;
  @override
  @JsonKey(name: 'amount_due')
  @DecimalConverter()
  Decimal get amountDue;
  @override
  @JsonKey(name: 'amount_paid')
  @DecimalConverter()
  Decimal get amountPaid;
  @override
  @JsonKey(name: 'remaining_balance')
  @DecimalConverter()
  Decimal get remainingBalance;
  @override
  String get status;
  @override
  @JsonKey(name: 'idempotency_key')
  String get idempotencyKey;
  @override
  @JsonKey(name: 'synced_at')
  DateTime? get syncedAt;
  @override
  String? get notes;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of RentPayment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RentPaymentImplCopyWith<_$RentPaymentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
