import '../entities/auth_tokens.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Registers a new user account.
class RegisterUseCase {
  const RegisterUseCase(this._repository);

  final AuthRepository _repository;

  /// Calls the auth repository register and returns tokens + user.
  Future<({AuthTokens tokens, UserEntity user})> call({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) =>
      _repository.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
}
