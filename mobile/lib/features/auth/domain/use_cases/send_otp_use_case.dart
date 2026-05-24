import '../repositories/auth_repository.dart';

/// Sends an OTP SMS to the given phone number.
class SendOtpUseCase {
  const SendOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({required String phone}) =>
      _repository.sendOtp(phone: phone);
}
