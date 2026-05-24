// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExpenseImpl _$$ExpenseImplFromJson(Map<String, dynamic> json) =>
    _$ExpenseImpl(
      id: json['id'] as String,
      amount: const DecimalConverter().fromJson(json['amount'] as String),
      category: json['category'] as String,
      expenseDate: DateTime.parse(json['expense_date'] as String),
      description: json['description'] as String?,
      idempotencyKey: json['idempotency_key'] as String,
      syncedAt: json['synced_at'] == null
          ? null
          : DateTime.parse(json['synced_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$ExpenseImplToJson(_$ExpenseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': const DecimalConverter().toJson(instance.amount),
      'category': instance.category,
      'expense_date': instance.expenseDate.toIso8601String(),
      'description': instance.description,
      'idempotency_key': instance.idempotencyKey,
      'synced_at': instance.syncedAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
    };
