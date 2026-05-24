// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interest_schedule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InterestScheduleImpl _$$InterestScheduleImplFromJson(
        Map<String, dynamic> json) =>
    _$InterestScheduleImpl(
      id: json['id'] as String,
      loanId: json['loanId'] as String,
      cycleMonth: DateTime.parse(json['cycleMonth'] as String),
      expectedAmount:
          const DecimalConverter().fromJson(json['expectedAmount'] as String),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$InterestScheduleImplToJson(
        _$InterestScheduleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'loanId': instance.loanId,
      'cycleMonth': instance.cycleMonth.toIso8601String(),
      'expectedAmount':
          const DecimalConverter().toJson(instance.expectedAmount),
      'status': instance.status,
      'createdAt': instance.createdAt.toIso8601String(),
    };
