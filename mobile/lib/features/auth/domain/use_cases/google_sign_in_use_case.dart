import '../entities/auth_tokens.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Authenticates the user via Google Sign-In.
class GoogleSignInUseCase {
  const GoogleSignInUseCase(this._repository);

  final AuthRepository _repository;

  Future<({AuthTokens tokens, UserEntity user})> call() =>
      _repository.googleSignIn();
}
