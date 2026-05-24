// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'interest_schedule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

InterestSchedule _$InterestScheduleFromJson(Map<String, dynamic> json) {
  return _InterestSchedule.fromJson(json);
}

/// @nodoc
mixin _$InterestSchedule {
  String get id => throw _privateConstructorUsedError;
  String get loanId => throw _privateConstructorUsedError;
  DateTime get cycleMonth => throw _privateConstructorUsedError;
  @DecimalConverter()
  Decimal get expectedAmount => throw _privateConstructorUsedError;
  String get status =>
      throw _privateConstructorUsedError; // 'pending' | 'collected' | 'waived'
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this InterestSchedule to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InterestSchedule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InterestScheduleCopyWith<InterestSchedule> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InterestScheduleCopyWith<$Res> {
  factory $InterestScheduleCopyWith(
          InterestSchedule value, $Res Function(InterestSchedule) then) =
      _$InterestScheduleCopyWithImpl<$Res, InterestSchedule>;
  @useResult
  $Res call(
      {String id,
      String loanId,
      DateTime cycleMonth,
      @DecimalConverter() Decimal expectedAmount,
      String status,
      DateTime createdAt});
}

/// @nodoc
class _$InterestScheduleCopyWithImpl<$Res, $Val extends InterestSchedule>
    implements $InterestScheduleCopyWith<$Res> {
  _$InterestScheduleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InterestSchedule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? loanId = null,
    Object? cycleMonth = null,
    Object? expectedAmount = null,
    Object? status = null,
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
      cycleMonth: null == cycleMonth
          ? _value.cycleMonth
          : cycleMonth // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expectedAmount: null == expectedAmount
          ? _value.expectedAmount
          : expectedAmount // ignore: cast_nullable_to_non_nullable
              as Decimal,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InterestScheduleImplCopyWith<$Res>
    implements $InterestScheduleCopyWith<$Res> {
  factory _$$InterestScheduleImplCopyWith(_$InterestScheduleImpl value,
          $Res Function(_$InterestScheduleImpl) then) =
      __$$InterestScheduleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String loanId,
      DateTime cycleMonth,
      @DecimalConverter() Decimal expectedAmount,
      String status,
      DateTime createdAt});
}

/// @nodoc
class __$$InterestScheduleImplCopyWithImpl<$Res>
    extends _$InterestScheduleCopyWithImpl<$Res, _$InterestScheduleImpl>
    implements _$$InterestScheduleImplCopyWith<$Res> {
  __$$InterestScheduleImplCopyWithImpl(_$InterestScheduleImpl _value,
      $Res Function(_$InterestScheduleImpl) _then)
      : super(_value, _then);

  /// Create a copy of InterestSchedule
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? loanId = null,
    Object? cycleMonth = null,
    Object? expectedAmount = null,
    Object? status = null,
    Object? createdAt = null,
  }) {
    return _then(_$InterestScheduleImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      loanId: null == loanId
          ? _value.loanId
          : loanId // ignore: cast_nullable_to_non_nullable
              as String,
      cycleMonth: null == cycleMonth
          ? _value.cycleMonth
          : cycleMonth // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expectedAmount: null == expectedAmount
          ? _value.expectedAmount
          : expectedAmount // ignore: cast_nullable_to_non_nullable
              as Decimal,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$InterestScheduleImpl implements _InterestSchedule {
  const _$InterestScheduleImpl(
      {required this.id,
      required this.loanId,
      required this.cycleMonth,
      @DecimalConverter() required this.expectedAmount,
      required this.status,
      required this.createdAt});

  factory _$InterestScheduleImpl.fromJson(Map<String, dynamic> json) =>
      _$$InterestScheduleImplFromJson(json);

  @override
  final String id;
  @override
  final String loanId;
  @override
  final DateTime cycleMonth;
  @override
  @DecimalConverter()
  final Decimal expectedAmount;
  @override
  final String status;
// 'pending' | 'collected' | 'waived'
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'InterestSchedule(id: $id, loanId: $loanId, cycleMonth: $cycleMonth, expectedAmount: $expectedAmount, status: $status, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InterestScheduleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.loanId, loanId) || other.loanId == loanId) &&
            (identical(other.cycleMonth, cycleMonth) ||
                other.cycleMonth == cycleMonth) &&
            (identical(other.expectedAmount, expectedAmount) ||
                other.expectedAmount == expectedAmount) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, loanId, cycleMonth, expectedAmount, status, createdAt);

  /// Create a copy of InterestSchedule
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InterestScheduleImplCopyWith<_$InterestScheduleImpl> get copyWith =>
      __$$InterestScheduleImplCopyWithImpl<_$InterestScheduleImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InterestScheduleImplToJson(
      this,
    );
  }
}

abstract class _InterestSchedule implements InterestSchedule {
  const factory _InterestSchedule(
      {required final String id,
      required final String loanId,
      required final DateTime cycleMonth,
      @DecimalConverter() required final Decimal expectedAmount,
      required final String status,
      required final DateTime createdAt}) = _$InterestScheduleImpl;

  factory _InterestSchedule.fromJson(Map<String, dynamic> json) =
      _$InterestScheduleImpl.fromJson;

  @override
  String get id;
  @override
  String get loanId;
  @override
  DateTime get cycleMonth;
  @override
  @DecimalConverter()
  Decimal get expectedAmount;
  @override
  String get status; // 'pending' | 'collected' | 'waived'
  @override
  DateTime get createdAt;

  /// Create a copy of InterestSchedule
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InterestScheduleImplCopyWith<_$InterestScheduleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
