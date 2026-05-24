// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'loan_payment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LoanPayment _$LoanPaymentFromJson(Map<String, dynamic> json) {
  return _LoanPayment.fromJson(json);
}

/// @nodoc
mixin _$LoanPayment {
  String get id => throw _privateConstructorUsedError;
  String get loanId => throw _privateConstructorUsedError;
  @DecimalConverter()
  Decimal get amount => throw _privateConstructorUsedError;
  DateTime get paymentDate => throw _privateConstructorUsedError;
  String get type =>
      throw _privateConstructorUsedError; // 'interest' | 'principal'
  String get idempotencyKey => throw _privateConstructorUsedError;
  DateTime? get syncedAt => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this LoanPayment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LoanPayment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LoanPaymentCopyWith<LoanPayment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoanPaymentCopyWith<$Res> {
  factory $LoanPaymentCopyWith(
          LoanPayment value, $Res Function(LoanPayment) then) =
      _$LoanPaymentCopyWithImpl<$Res, LoanPayment>;
  @useResult
  $Res call(
      {String id,
      String loanId,
      @DecimalConverter() Decimal amount,
      DateTime paymentDate,
      String type,
      String idempotencyKey,
      DateTime? syncedAt,
      String? notes,
      DateTime createdAt});
}

/// @nodoc
class _$LoanPaymentCopyWithImpl<$Res, $Val extends LoanPayment>
    implements $LoanPaymentCopyWith<$Res> {
  _$LoanPaymentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LoanPayment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? loanId = null,
    Object? amount = null,
    Object? paymentDate = null,
    Object? type = null,
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
      loanId: null == loanId
          ? _value.loanId
          : loanId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as Decimal,
      paymentDate: null == paymentDate
          ? _value.paymentDate
          : paymentDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
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
abstract class _$$LoanPaymentImplCopyWith<$Res>
    implements $LoanPaymentCopyWith<$Res> {
  factory _$$LoanPaymentImplCopyWith(
          _$LoanPaymentImpl value, $Res Function(_$LoanPaymentImpl) then) =
      __$$LoanPaymentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String loanId,
      @DecimalConverter() Decimal amount,
      DateTime paymentDate,
      String type,
      String idempotencyKey,
      DateTime? syncedAt,
      String? notes,
      DateTime createdAt});
}

/// @nodoc
class __$$LoanPaymentImplCopyWithImpl<$Res>
    extends _$LoanPaymentCopyWithImpl<$Res, _$LoanPaymentImpl>
    implements _$$LoanPaymentImplCopyWith<$Res> {
  __$$LoanPaymentImplCopyWithImpl(
      _$LoanPaymentImpl _value, $Res Function(_$LoanPaymentImpl) _then)
      : super(_value, _then);

  /// Create a copy of LoanPayment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? loanId = null,
    Object? amount = null,
    Object? paymentDate = null,
    Object? type = null,
    Object? idempotencyKey = null,
    Object? syncedAt = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$LoanPaymentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      loanId: null == loanId
          ? _value.loanId
          : loanId // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as Decimal,
      paymentDate: null == paymentDate
          ? _value.paymentDate
          : paymentDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
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
class _$LoanPaymentImpl implements _LoanPayment {
  const _$LoanPaymentImpl(
      {required this.id,
      required this.loanId,
      @DecimalConverter() required this.amount,
      required this.paymentDate,
      required this.type,
      required this.idempotencyKey,
      this.syncedAt,
      this.notes,
      required this.createdAt});

  factory _$LoanPaymentImpl.fromJson(Map<String, dynamic> json) =>
      _$$LoanPaymentImplFromJson(json);

  @override
  final String id;
  @override
  final String loanId;
  @override
  @DecimalConverter()
  final Decimal amount;
  @override
  final DateTime paymentDate;
  @override
  final String type;
// 'interest' | 'principal'
  @override
  final String idempotencyKey;
  @override
  final DateTime? syncedAt;
  @override
  final String? notes;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'LoanPayment(id: $id, loanId: $loanId, amount: $amount, paymentDate: $paymentDate, type: $type, idempotencyKey: $idempotencyKey, syncedAt: $syncedAt, notes: $notes, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoanPaymentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.loanId, loanId) || other.loanId == loanId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.paymentDate, paymentDate) ||
                other.paymentDate == paymentDate) &&
            (identical(other.type, type) || other.type == type) &&
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
  int get hashCode => Object.hash(runtimeType, id, loanId, amount, paymentDate,
      type, idempotencyKey, syncedAt, notes, createdAt);

  /// Create a copy of LoanPayment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoanPaymentImplCopyWith<_$LoanPaymentImpl> get copyWith =>
      __$$LoanPaymentImplCopyWithImpl<_$LoanPaymentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LoanPaymentImplToJson(
      this,
    );
  }
}

abstract class _LoanPayment implements LoanPayment {
  const factory _LoanPayment(
      {required final String id,
      required final String loanId,
      @DecimalConverter() required final Decimal amount,
      required final DateTime paymentDate,
      required final String type,
      required final String idempotencyKey,
      final DateTime? syncedAt,
      final String? notes,
      required final DateTime createdAt}) = _$LoanPaymentImpl;

  factory _LoanPayment.fromJson(Map<String, dynamic> json) =
      _$LoanPaymentImpl.fromJson;

  @override
  String get id;
  @override
  String get loanId;
  @override
  @DecimalConverter()
  Decimal get amount;
  @override
  DateTime get paymentDate;
  @override
  String get type; // 'interest' | 'principal'
  @override
  String get idempotencyKey;
  @override
  DateTime? get syncedAt;
  @override
  String? get notes;
  @override
  DateTime get createdAt;

  /// Create a copy of LoanPayment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoanPaymentImplCopyWith<_$LoanPaymentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
