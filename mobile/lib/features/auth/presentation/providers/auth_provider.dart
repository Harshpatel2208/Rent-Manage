import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/use_cases/google_sign_in_use_case.dart';
import '../../domain/use_cases/login_use_case.dart';
import '../../domain/use_cases/register_use_case.dart';
import '../../domain/use_cases/send_otp_use_case.dart';
import '../../domain/use_cases/verify_otp_use_case.dart';

part 'auth_provider.g.dart';

// ---------------------------------------------------------------------------
// Auth state
// ---------------------------------------------------------------------------

/// The auth notifier manages the authenticated [UserEntity] state.
///
/// - `AsyncData(null)` → unauthenticated
/// - `AsyncData(user)` → authenticated
/// - `AsyncLoading()` → in-flight auth operation
/// - `AsyncError(e, st)` → failed auth attempt
@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  Future<UserEntity?> build() async {
    // Restore session on startup
    final repo = ref.read(authRepositoryProvider);
    return repo.getCurrentUser();
  }

  // -------------------------------------------------------------------------
  // Login
  // -------------------------------------------------------------------------

  Future<void> login({required String email, required String password}) async {
    state = const AsyncLoading();
    final useCase = LoginUseCase(ref.read(authRepositoryProvider));
    state = await AsyncValue.guard(
      () async {
        final result = await useCase(email: email, password: password);
        return result.user;
      },
    );
  }

  // -------------------------------------------------------------------------
  // Register
  // -------------------------------------------------------------------------

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    state = const AsyncLoading();
    final useCase = RegisterUseCase(ref.read(authRepositoryProvider));
    state = await AsyncValue.guard(
      () async {
        final result = await useCase(
          name: name,
          email: email,
          password: password,
          phone: phone,
        );
        return result.user;
      },
    );
  }

  // -------------------------------------------------------------------------
  // OTP
  // -------------------------------------------------------------------------

  /// Sends OTP — does not change auth state.
  Future<void> sendOtp({required String phone}) async {
    final useCase = SendOtpUseCase(ref.read(authRepositoryProvider));
    await useCase(phone: phone);
  }

  Future<void> verifyOtp({required String phone, required String otp}) async {
    state = const AsyncLoading();
    final useCase = VerifyOtpUseCase(ref.read(authRepositoryProvider));
    state = await AsyncValue.guard(
      () async {
        final result = await useCase(phone: phone, otp: otp);
        return result.user;
      },
    );
  }

  // -------------------------------------------------------------------------
  // Google Sign-In
  // -------------------------------------------------------------------------

  Future<void> googleSignIn() async {
    state = const AsyncLoading();
    final useCase = GoogleSignInUseCase(ref.read(authRepositoryProvider));
    state = await AsyncValue.guard(
      () async {
        final result = await useCase();
        return result.user;
      },
    );
  }

  // -------------------------------------------------------------------------
  // Logout
  // -------------------------------------------------------------------------

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  /// Returns `true` if the user is currently authenticated.
  bool get isAuthenticated => state.valueOrNull != null;
}
