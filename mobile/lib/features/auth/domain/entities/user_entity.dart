import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_entity.freezed.dart';

/// Role of an authenticated user within a tenant.
enum UserRole { admin, viewer }

/// Core user domain entity.
///
/// Immutable — created by the auth repository on successful login.
@freezed
class UserEntity with _$UserEntity {
  const factory UserEntity({
    required String id,
    required String tenantId,
    required String email,
    String? phone,
    required UserRole role,
    required DateTime createdAt,
  }) = _UserEntity;
}
