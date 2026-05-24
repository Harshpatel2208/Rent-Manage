import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/auth_tokens.dart';
import 'user_model.dart';

part 'auth_response_model.freezed.dart';
part 'auth_response_model.g.dart';

/// Data model for the authentication response from the API.
/// Backend returns: { access_token, refresh_token, user }
@freezed
class AuthResponseModel with _$AuthResponseModel {
  const factory AuthResponseModel({
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'refresh_token') required String refreshToken,
    @JsonKey(name: 'expires_at') String? expiresAt,
    required UserModel user,
  }) = _AuthResponseModel;

  const AuthResponseModel._();

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);

  /// Converts to domain [AuthTokens].
  AuthTokens toTokens() => AuthTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
        // Default to 24h from now if backend doesn't return expires_at
        expiresAt: expiresAt != null
            ? DateTime.parse(expiresAt!)
            : DateTime.now().add(const Duration(hours: 24)),
      );
}
