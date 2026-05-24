import '../entities/auth_tokens.dart';
import '../entities/user_entity.dart';

/// Abstract authentication repository.
///
/// Implementations live in the data layer. The domain layer depends only on
/// this interface — never on concrete classes.
abstract class AuthRepository {
  /// Authenticates with email and password.
  Future<({AuthTokens tokens, UserEntity user})> login({
    required String email,
    required String password,
  });

  /// Registers a new user account.
  Future<({AuthTokens tokens, UserEntity user})> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  });

  /// Sends an OTP to [phone].
  Future<void> sendOtp({required String phone});

  /// Verifies [otp] for [phone] and returns tokens on success.
  Future<({AuthTokens tokens, UserEntity user})> verifyOtp({
    required String phone,
    required String otp,
  });

  /// Authenticates via Google Sign-In.
  Future<({AuthTokens tokens, UserEntity user})> googleSignIn();

  /// Exchanges a refresh token for a new access token.
  Future<AuthTokens> refreshToken({required String refreshToken});

  /// Logs out the current user (invalidates server-side session).
  Future<void> logout();

  /// Returns the currently cached [UserEntity], or null if unauthenticated.
  Future<UserEntity?> getCurrentUser();
}
