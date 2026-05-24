// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rent_payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RentPaymentImpl _$$RentPaymentImplFromJson(Map<String, dynamic> json) =>
    _$RentPaymentImpl(
      id: json['id'] as String,
      rentalTenantId: json['rental_tenant_id'] as String,
      cycleMonth: DateTime.parse(json['cycle_month'] as String),
      amountDue:
          const DecimalConverter().fromJson(json['amount_due'] as String),
      amountPaid:
          const DecimalConverter().fromJson(json['amount_paid'] as String),
      remainingBalance: const DecimalConverter()
          .fromJson(json['remaining_balance'] as String),
      status: json['status'] as String,
      idempotencyKey: json['idempotency_key'] as String,
      syncedAt: json['synced_at'] == null
          ? null
          : DateTime.parse(json['synced_at'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$RentPaymentImplToJson(_$RentPaymentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'rental_tenant_id': instance.rentalTenantId,
      'cycle_month': instance.cycleMonth.toIso8601String(),
      'amount_due': const DecimalConverter().toJson(instance.amountDue),
      'amount_paid': const DecimalConverter().toJson(instance.amountPaid),
      'remaining_balance':
          const DecimalConverter().toJson(instance.remainingBalance),
      'status': instance.status,
      'idempotency_key': instance.idempotencyKey,
      'synced_at': instance.syncedAt?.toIso8601String(),
      'notes': instance.notes,
      'created_at': instance.createdAt.toIso8601String(),
    };
