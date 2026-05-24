import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/user_entity.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// Data model for [UserEntity] — serialisable from the API JSON response.
/// Backend register returns: { id, tenant_id, email, phone, role }
/// Backend login returns full user row with created_at.
@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    @JsonKey(name: 'tenant_id') required String tenantId,
    String? email,
    String? phone,
    required String role,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _UserModel;

  const UserModel._();

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Maps this model to the domain [UserEntity].
  UserEntity toEntity() => UserEntity(
        id: id,
        tenantId: tenantId,
        email: email ?? '',
        phone: phone,
        role: role == 'admin' ? UserRole.admin : UserRole.viewer,
        createdAt: createdAt != null
            ? DateTime.parse(createdAt!)
            : DateTime.now(),
      );
}
