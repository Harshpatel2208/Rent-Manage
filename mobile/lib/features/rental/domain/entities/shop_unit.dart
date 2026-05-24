import 'package:freezed_annotation/freezed_annotation.dart';

part 'shop_unit.freezed.dart';
part 'shop_unit.g.dart';

int _parseTenantCount(dynamic value) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

@freezed
class ShopUnit with _$ShopUnit {
  const factory ShopUnit({
    required String id,
    @JsonKey(name: 'unit_name') required String unitName,
    String? address,
    String? description,
    @JsonKey(name: 'active_tenant_count', fromJson: _parseTenantCount) @Default(0) int activeTenantCount,
  }) = _ShopUnit;

  factory ShopUnit.fromJson(Map<String, dynamic> json) => _$ShopUnitFromJson(json);
}
