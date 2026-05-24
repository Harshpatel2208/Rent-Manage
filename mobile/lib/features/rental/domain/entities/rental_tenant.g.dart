// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rental_tenant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RentalTenantImpl _$$RentalTenantImplFromJson(Map<String, dynamic> json) =>
    _$RentalTenantImpl(
      id: json['id'] as String,
      unitId: json['unit_id'] as String?,
      unitName: json['unit_name'] as String?,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String?,
      rentAmount:
          const DecimalConverter().fromJson(json['rent_amount'] as String),
      leaseStart: DateTime.parse(json['lease_start'] as String),
      leaseEnd: json['lease_end'] == null
          ? null
          : DateTime.parse(json['lease_end'] as String),
      isActive: json['is_active'] as bool? ?? true,
      notes: json['notes'] as String?,
      currentMonthStatus: json['current_month_status'] as String?,
      currentMonthPaid: _$JsonConverterFromJson<String, Decimal>(
          json['current_month_paid'], const DecimalConverter().fromJson),
      currentMonthDue: _$JsonConverterFromJson<String, Decimal>(
          json['current_month_due'], const DecimalConverter().fromJson),
      currentMonthBalance: _$JsonConverterFromJson<String, Decimal>(
          json['current_month_balance'], const DecimalConverter().fromJson),
      totalOutstanding: _$JsonConverterFromJson<String, Decimal>(
          json['total_outstanding'], const DecimalConverter().fromJson),
    );

Map<String, dynamic> _$$RentalTenantImplToJson(_$RentalTenantImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'unit_id': instance.unitId,
      'unit_name': instance.unitName,
      'full_name': instance.fullName,
      'phone': instance.phone,
      'rent_amount': const DecimalConverter().toJson(instance.rentAmount),
      'lease_start': instance.leaseStart.toIso8601String(),
      'lease_end': instance.leaseEnd?.toIso8601String(),
      'is_active': instance.isActive,
      'notes': instance.notes,
      'current_month_status': instance.currentMonthStatus,
      'current_month_paid': _$JsonConverterToJson<String, Decimal>(
          instance.currentMonthPaid, const DecimalConverter().toJson),
      'current_month_due': _$JsonConverterToJson<String, Decimal>(
          instance.currentMonthDue, const DecimalConverter().toJson),
      'current_month_balance': _$JsonConverterToJson<String, Decimal>(
          instance.currentMonthBalance, const DecimalConverter().toJson),
      'total_outstanding': _$JsonConverterToJson<String, Decimal>(
          instance.totalOutstanding, const DecimalConverter().toJson),
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);
