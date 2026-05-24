import '../entities/auth_tokens.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Verifies a one-time password for phone-based authentication.
class VerifyOtpUseCase {
  const VerifyOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<({AuthTokens tokens, UserEntity user})> call({
    required String phone,
    required String otp,
  }) =>
      _repository.verifyOtp(phone: phone, otp: otp);
}
