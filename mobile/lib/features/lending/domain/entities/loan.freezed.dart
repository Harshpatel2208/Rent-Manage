// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'loan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Loan _$LoanFromJson(Map<String, dynamic> json) {
  return _Loan.fromJson(json);
}

/// @nodoc
mixin _$Loan {
  String get id => throw _privateConstructorUsedError;
  String get borrowerId => throw _privateConstructorUsedError;
  String get borrowerName => throw _privateConstructorUsedError;
  @DecimalConverter()
  Decimal get principal => throw _privateConstructorUsedError;
  @DecimalConverter()
  Decimal get interestRate => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  DateTime get registeredAt => throw _privateConstructorUsedError;
  DateTime get firstCycleDate => throw _privateConstructorUsedError;
  DateTime? get closedAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Loan to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Loan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LoanCopyWith<Loan> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoanCopyWith<$Res> {
  factory $LoanCopyWith(Loan value, $Res Function(Loan) then) =
      _$LoanCopyWithImpl<$Res, Loan>;
  @useResult
  $Res call(
      {String id,
      String borrowerId,
      String borrowerName,
      @DecimalConverter() Decimal principal,
      @DecimalConverter() Decimal interestRate,
      String status,
      DateTime registeredAt,
      DateTime firstCycleDate,
      DateTime? closedAt,
      DateTime createdAt});
}

/// @nodoc
class _$LoanCopyWithImpl<$Res, $Val extends Loan>
    implements $LoanCopyWith<$Res> {
  _$LoanCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Loan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? borrowerId = null,
    Object? borrowerName = null,
    Object? principal = null,
    Object? interestRate = null,
    Object? status = null,
    Object? registeredAt = null,
    Object? firstCycleDate = null,
    Object? closedAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      borrowerId: null == borrowerId
          ? _value.borrowerId
          : borrowerId // ignore: cast_nullable_to_non_nullable
              as String,
      borrowerName: null == borrowerName
          ? _value.borrowerName
          : borrowerName // ignore: cast_nullable_to_non_nullable
              as String,
      principal: null == principal
          ? _value.principal
          : principal // ignore: cast_nullable_to_non_nullable
              as Decimal,
      interestRate: null == interestRate
          ? _value.interestRate
          : interestRate // ignore: cast_nullable_to_non_nullable
              as Decimal,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      registeredAt: null == registeredAt
          ? _value.registeredAt
          : registeredAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      firstCycleDate: null == firstCycleDate
          ? _value.firstCycleDate
          : firstCycleDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      closedAt: freezed == closedAt
          ? _value.closedAt
          : closedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LoanImplCopyWith<$Res> implements $LoanCopyWith<$Res> {
  factory _$$LoanImplCopyWith(
          _$LoanImpl value, $Res Function(_$LoanImpl) then) =
      __$$LoanImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String borrowerId,
      String borrowerName,
      @DecimalConverter() Decimal principal,
      @DecimalConverter() Decimal interestRate,
      String status,
      DateTime registeredAt,
      DateTime firstCycleDate,
      DateTime? closedAt,
      DateTime createdAt});
}

/// @nodoc
class __$$LoanImplCopyWithImpl<$Res>
    extends _$LoanCopyWithImpl<$Res, _$LoanImpl>
    implements _$$LoanImplCopyWith<$Res> {
  __$$LoanImplCopyWithImpl(_$LoanImpl _value, $Res Function(_$LoanImpl) _then)
      : super(_value, _then);

  /// Create a copy of Loan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? borrowerId = null,
    Object? borrowerName = null,
    Object? principal = null,
    Object? interestRate = null,
    Object? status = null,
    Object? registeredAt = null,
    Object? firstCycleDate = null,
    Object? closedAt = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$LoanImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      borrowerId: null == borrowerId
          ? _value.borrowerId
          : borrowerId // ignore: cast_nullable_to_non_nullable
              as String,
      borrowerName: null == borrowerName
          ? _value.borrowerName
          : borrowerName // ignore: cast_nullable_to_non_nullable
              as String,
      principal: null == principal
          ? _value.principal
          : principal // ignore: cast_nullable_to_non_nullable
              as Decimal,
      interestRate: null == interestRate
          ? _value.interestRate
          : interestRate // ignore: cast_nullable_to_non_nullable
              as Decimal,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      registeredAt: null == registeredAt
          ? _value.registeredAt
          : registeredAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      firstCycleDate: null == firstCycleDate
          ? _value.firstCycleDate
          : firstCycleDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      closedAt: freezed == closedAt
          ? _value.closedAt
          : closedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LoanImpl implements _Loan {
  const _$LoanImpl(
      {required this.id,
      required this.borrowerId,
      required this.borrowerName,
      @DecimalConverter() required this.principal,
      @DecimalConverter() required this.interestRate,
      required this.status,
      required this.registeredAt,
      required this.firstCycleDate,
      this.closedAt,
      required this.createdAt});

  factory _$LoanImpl.fromJson(Map<String, dynamic> json) =>
      _$$LoanImplFromJson(json);

  @override
  final String id;
  @override
  final String borrowerId;
  @override
  final String borrowerName;
  @override
  @DecimalConverter()
  final Decimal principal;
  @override
  @DecimalConverter()
  final Decimal interestRate;
  @override
  final String status;
  @override
  final DateTime registeredAt;
  @override
  final DateTime firstCycleDate;
  @override
  final DateTime? closedAt;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'Loan(id: $id, borrowerId: $borrowerId, borrowerName: $borrowerName, principal: $principal, interestRate: $interestRate, status: $status, registeredAt: $registeredAt, firstCycleDate: $firstCycleDate, closedAt: $closedAt, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoanImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.borrowerId, borrowerId) ||
                other.borrowerId == borrowerId) &&
            (identical(other.borrowerName, borrowerName) ||
                other.borrowerName == borrowerName) &&
            (identical(other.principal, principal) ||
                other.principal == principal) &&
            (identical(other.interestRate, interestRate) ||
                other.interestRate == interestRate) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.registeredAt, registeredAt) ||
                other.registeredAt == registeredAt) &&
            (identical(other.firstCycleDate, firstCycleDate) ||
                other.firstCycleDate == firstCycleDate) &&
            (identical(other.closedAt, closedAt) ||
                other.closedAt == closedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      borrowerId,
      borrowerName,
      principal,
      interestRate,
      status,
      registeredAt,
      firstCycleDate,
      closedAt,
      createdAt);

  /// Create a copy of Loan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoanImplCopyWith<_$LoanImpl> get copyWith =>
      __$$LoanImplCopyWithImpl<_$LoanImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LoanImplToJson(
      this,
    );
  }
}

abstract class _Loan implements Loan {
  const factory _Loan(
      {required final String id,
      required final String borrowerId,
      required final String borrowerName,
      @DecimalConverter() required final Decimal principal,
      @DecimalConverter() required final Decimal interestRate,
      required final String status,
      required final DateTime registeredAt,
      required final DateTime firstCycleDate,
      final DateTime? closedAt,
      required final DateTime createdAt}) = _$LoanImpl;

  factory _Loan.fromJson(Map<String, dynamic> json) = _$LoanImpl.fromJson;

  @override
  String get id;
  @override
  String get borrowerId;
  @override
  String get borrowerName;
  @override
  @DecimalConverter()
  Decimal get principal;
  @override
  @DecimalConverter()
  Decimal get interestRate;
  @override
  String get status;
  @override
  DateTime get registeredAt;
  @override
  DateTime get firstCycleDate;
  @override
  DateTime? get closedAt;
  @override
  DateTime get createdAt;

  /// Create a copy of Loan
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoanImplCopyWith<_$LoanImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
