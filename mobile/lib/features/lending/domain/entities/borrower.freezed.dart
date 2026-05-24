// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'borrower.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Borrower _$BorrowerFromJson(Map<String, dynamic> json) {
  return _Borrower.fromJson(json);
}

/// @nodoc
mixin _$Borrower {
  String get id => throw _privateConstructorUsedError;
  String get fullName => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Borrower to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Borrower
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BorrowerCopyWith<Borrower> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BorrowerCopyWith<$Res> {
  factory $BorrowerCopyWith(Borrower value, $Res Function(Borrower) then) =
      _$BorrowerCopyWithImpl<$Res, Borrower>;
  @useResult
  $Res call(
      {String id,
      String fullName,
      String phone,
      String address,
      String? notes,
      DateTime createdAt});
}

/// @nodoc
class _$BorrowerCopyWithImpl<$Res, $Val extends Borrower>
    implements $BorrowerCopyWith<$Res> {
  _$BorrowerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Borrower
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fullName = null,
    Object? phone = null,
    Object? address = null,
    Object? notes = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
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
abstract class _$$BorrowerImplCopyWith<$Res>
    implements $BorrowerCopyWith<$Res> {
  factory _$$BorrowerImplCopyWith(
          _$BorrowerImpl value, $Res Function(_$BorrowerImpl) then) =
      __$$BorrowerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String fullName,
      String phone,
      String address,
      String? notes,
      DateTime createdAt});
}

/// @nodoc
class __$$BorrowerImplCopyWithImpl<$Res>
    extends _$BorrowerCopyWithImpl<$Res, _$BorrowerImpl>
    implements _$$BorrowerImplCopyWith<$Res> {
  __$$BorrowerImplCopyWithImpl(
      _$BorrowerImpl _value, $Res Function(_$BorrowerImpl) _then)
      : super(_value, _then);

  /// Create a copy of Borrower
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fullName = null,
    Object? phone = null,
    Object? address = null,
    Object? notes = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$BorrowerImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
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
class _$BorrowerImpl implements _Borrower {
  const _$BorrowerImpl(
      {required this.id,
      required this.fullName,
      required this.phone,
      required this.address,
      this.notes,
      required this.createdAt});

  factory _$BorrowerImpl.fromJson(Map<String, dynamic> json) =>
      _$$BorrowerImplFromJson(json);

  @override
  final String id;
  @override
  final String fullName;
  @override
  final String phone;
  @override
  final String address;
  @override
  final String? notes;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'Borrower(id: $id, fullName: $fullName, phone: $phone, address: $address, notes: $notes, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BorrowerImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, fullName, phone, address, notes, createdAt);

  /// Create a copy of Borrower
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BorrowerImplCopyWith<_$BorrowerImpl> get copyWith =>
      __$$BorrowerImplCopyWithImpl<_$BorrowerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BorrowerImplToJson(
      this,
    );
  }
}

abstract class _Borrower implements Borrower {
  const factory _Borrower(
      {required final String id,
      required final String fullName,
      required final String phone,
      required final String address,
      final String? notes,
      required final DateTime createdAt}) = _$BorrowerImpl;

  factory _Borrower.fromJson(Map<String, dynamic> json) =
      _$BorrowerImpl.fromJson;

  @override
  String get id;
  @override
  String get fullName;
  @override
  String get phone;
  @override
  String get address;
  @override
  String? get notes;
  @override
  DateTime get createdAt;

  /// Create a copy of Borrower
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BorrowerImplCopyWith<_$BorrowerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
