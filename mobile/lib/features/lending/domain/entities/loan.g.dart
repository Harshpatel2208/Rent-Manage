// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LoanImpl _$$LoanImplFromJson(Map<String, dynamic> json) => _$LoanImpl(
      id: json['id'] as String,
      borrowerId: json['borrowerId'] as String,
      borrowerName: json['borrowerName'] as String,
      principal: const DecimalConverter().fromJson(json['principal'] as String),
      interestRate:
          const DecimalConverter().fromJson(json['interestRate'] as String),
      status: json['status'] as String,
      registeredAt: DateTime.parse(json['registeredAt'] as String),
      firstCycleDate: DateTime.parse(json['firstCycleDate'] as String),
      closedAt: json['closedAt'] == null
          ? null
          : DateTime.parse(json['closedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$LoanImplToJson(_$LoanImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'borrowerId': instance.borrowerId,
      'borrowerName': instance.borrowerName,
      'principal': const DecimalConverter().toJson(instance.principal),
      'interestRate': const DecimalConverter().toJson(instance.interestRate),
      'status': instance.status,
      'registeredAt': instance.registeredAt.toIso8601String(),
      'firstCycleDate': instance.firstCycleDate.toIso8601String(),
      'closedAt': instance.closedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };
