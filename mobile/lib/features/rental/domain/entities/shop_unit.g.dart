// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_unit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ShopUnitImpl _$$ShopUnitImplFromJson(Map<String, dynamic> json) =>
    _$ShopUnitImpl(
      id: json['id'] as String,
      unitName: json['unit_name'] as String,
      address: json['address'] as String?,
      description: json['description'] as String?,
      activeTenantCount: json['active_tenant_count'] == null
          ? 0
          : _parseTenantCount(json['active_tenant_count']),
    );

Map<String, dynamic> _$$ShopUnitImplToJson(_$ShopUnitImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'unit_name': instance.unitName,
      'address': instance.address,
      'description': instance.description,
      'active_tenant_count': instance.activeTenantCount,
    };
