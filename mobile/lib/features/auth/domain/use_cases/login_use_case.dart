import '../entities/auth_tokens.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Logs in a user with email and password.
class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  /// Calls the auth repository login and returns tokens + user.
  Future<({AuthTokens tokens, UserEntity user})> call({
    required String email,
    required String password,
  }) =>
      _repository.login(email: email, password: password);
}
