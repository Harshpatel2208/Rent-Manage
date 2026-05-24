import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_tokens.freezed.dart';

/// JWT token pair returned on successful authentication.
@freezed
class AuthTokens with _$AuthTokens {
  const factory AuthTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
  }) = _AuthTokens;

  const AuthTokens._();

  /// Returns `true` if the access token has expired.
  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
