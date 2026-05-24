// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'borrower.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BorrowerImpl _$$BorrowerImplFromJson(Map<String, dynamic> json) =>
    _$BorrowerImpl(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$BorrowerImplToJson(_$BorrowerImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      'phone': instance.phone,
      'address': instance.address,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
    };
