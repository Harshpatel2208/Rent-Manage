// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shop_unit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ShopUnit _$ShopUnitFromJson(Map<String, dynamic> json) {
  return _ShopUnit.fromJson(json);
}

/// @nodoc
mixin _$ShopUnit {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'unit_name')
  String get unitName => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'active_tenant_count', fromJson: _parseTenantCount)
  int get activeTenantCount => throw _privateConstructorUsedError;

  /// Serializes this ShopUnit to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ShopUnit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShopUnitCopyWith<ShopUnit> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShopUnitCopyWith<$Res> {
  factory $ShopUnitCopyWith(ShopUnit value, $Res Function(ShopUnit) then) =
      _$ShopUnitCopyWithImpl<$Res, ShopUnit>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'unit_name') String unitName,
      String? address,
      String? description,
      @JsonKey(name: 'active_tenant_count', fromJson: _parseTenantCount)
      int activeTenantCount});
}

/// @nodoc
class _$ShopUnitCopyWithImpl<$Res, $Val extends ShopUnit>
    implements $ShopUnitCopyWith<$Res> {
  _$ShopUnitCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ShopUnit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? unitName = null,
    Object? address = freezed,
    Object? description = freezed,
    Object? activeTenantCount = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      unitName: null == unitName
          ? _value.unitName
          : unitName // ignore: cast_nullable_to_non_nullable
              as String,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      activeTenantCount: null == activeTenantCount
          ? _value.activeTenantCount
          : activeTenantCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ShopUnitImplCopyWith<$Res>
    implements $ShopUnitCopyWith<$Res> {
  factory _$$ShopUnitImplCopyWith(
          _$ShopUnitImpl value, $Res Function(_$ShopUnitImpl) then) =
      __$$ShopUnitImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'unit_name') String unitName,
      String? address,
      String? description,
      @JsonKey(name: 'active_tenant_count', fromJson: _parseTenantCount)
      int activeTenantCount});
}

/// @nodoc
class __$$ShopUnitImplCopyWithImpl<$Res>
    extends _$ShopUnitCopyWithImpl<$Res, _$ShopUnitImpl>
    implements _$$ShopUnitImplCopyWith<$Res> {
  __$$ShopUnitImplCopyWithImpl(
      _$ShopUnitImpl _value, $Res Function(_$ShopUnitImpl) _then)
      : super(_value, _then);

  /// Create a copy of ShopUnit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? unitName = null,
    Object? address = freezed,
    Object? description = freezed,
    Object? activeTenantCount = null,
  }) {
    return _then(_$ShopUnitImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      unitName: null == unitName
          ? _value.unitName
          : unitName // ignore: cast_nullable_to_non_nullable
              as String,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      activeTenantCount: null == activeTenantCount
          ? _value.activeTenantCount
          : activeTenantCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ShopUnitImpl implements _ShopUnit {
  const _$ShopUnitImpl(
      {required this.id,
      @JsonKey(name: 'unit_name') required this.unitName,
      this.address,
      this.description,
      @JsonKey(name: 'active_tenant_count', fromJson: _parseTenantCount)
      this.activeTenantCount = 0});

  factory _$ShopUnitImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShopUnitImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'unit_name')
  final String unitName;
  @override
  final String? address;
  @override
  final String? description;
  @override
  @JsonKey(name: 'active_tenant_count', fromJson: _parseTenantCount)
  final int activeTenantCount;

  @override
  String toString() {
    return 'ShopUnit(id: $id, unitName: $unitName, address: $address, description: $description, activeTenantCount: $activeTenantCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShopUnitImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.unitName, unitName) ||
                other.unitName == unitName) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.activeTenantCount, activeTenantCount) ||
                other.activeTenantCount == activeTenantCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, unitName, address, description, activeTenantCount);

  /// Create a copy of ShopUnit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShopUnitImplCopyWith<_$ShopUnitImpl> get copyWith =>
      __$$ShopUnitImplCopyWithImpl<_$ShopUnitImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ShopUnitImplToJson(
      this,
    );
  }
}

abstract class _ShopUnit implements ShopUnit {
  const factory _ShopUnit(
      {required final String id,
      @JsonKey(name: 'unit_name') required final String unitName,
      final String? address,
      final String? description,
      @JsonKey(name: 'active_tenant_count', fromJson: _parseTenantCount)
      final int activeTenantCount}) = _$ShopUnitImpl;

  factory _ShopUnit.fromJson(Map<String, dynamic> json) =
      _$ShopUnitImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'unit_name')
  String get unitName;
  @override
  String? get address;
  @override
  String? get description;
  @override
  @JsonKey(name: 'active_tenant_count', fromJson: _parseTenantCount)
  int get activeTenantCount;

  /// Create a copy of ShopUnit
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShopUnitImplCopyWith<_$ShopUnitImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
