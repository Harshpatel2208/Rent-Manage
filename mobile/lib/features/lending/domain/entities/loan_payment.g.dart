// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loan_payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LoanPaymentImpl _$$LoanPaymentImplFromJson(Map<String, dynamic> json) =>
    _$LoanPaymentImpl(
      id: json['id'] as String,
      loanId: json['loanId'] as String,
      amount: const DecimalConverter().fromJson(json['amount'] as String),
      paymentDate: DateTime.parse(json['paymentDate'] as String),
      type: json['type'] as String,
      idempotencyKey: json['idempotencyKey'] as String,
      syncedAt: json['syncedAt'] == null
          ? null
          : DateTime.parse(json['syncedAt'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$LoanPaymentImplToJson(_$LoanPaymentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'loanId': instance.loanId,
      'amount': const DecimalConverter().toJson(instance.amount),
      'paymentDate': instance.paymentDate.toIso8601String(),
      'type': instance.type,
      'idempotencyKey': instance.idempotencyKey,
      'syncedAt': instance.syncedAt?.toIso8601String(),
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
    };
