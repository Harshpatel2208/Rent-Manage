import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/auth_tokens.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

part 'auth_repository_impl.g.dart';

/// Concrete implementation of [AuthRepository].
///
/// Strategy:
/// - All network calls go through [AuthRemoteDataSource].
/// - On success, tokens + user info are saved to [AuthLocalDataSource].
/// - Exceptions from the data layer are re-thrown as domain [Failure]s via
///   the `_mapException` helper.
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote, this._local);

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  // -------------------------------------------------------------------------
  // Login
  // -------------------------------------------------------------------------

  @override
  Future<({AuthTokens tokens, UserEntity user})> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _remote.login(email: email, password: password);
      await _persistSession(response.toTokens(), response.user.toEntity());
      return (tokens: response.toTokens(), user: response.user.toEntity());
    } on AuthException catch (e) {
      throw AuthFailure(message: e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(message: e.message);
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message, statusCode: e.statusCode);
    }
  }

  // -------------------------------------------------------------------------
  // Register
  // -------------------------------------------------------------------------

  @override
  Future<({AuthTokens tokens, UserEntity user})> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      final response = await _remote.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
      await _persistSession(response.toTokens(), response.user.toEntity());
      return (tokens: response.toTokens(), user: response.user.toEntity());
    } on AuthException catch (e) {
      throw AuthFailure(message: e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(message: e.message);
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message, statusCode: e.statusCode);
    }
  }

  // -------------------------------------------------------------------------
  // OTP
  // -------------------------------------------------------------------------

  @override
  Future<void> sendOtp({required String phone}) async {
    try {
      await _remote.sendOtp(phone: phone);
    } on NetworkException catch (e) {
      throw NetworkFailure(message: e.message);
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message, statusCode: e.statusCode);
    }
  }

  @override
  Future<({AuthTokens tokens, UserEntity user})> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final response = await _remote.verifyOtp(phone: phone, otp: otp);
      await _persistSession(response.toTokens(), response.user.toEntity());
      return (tokens: response.toTokens(), user: response.user.toEntity());
    } on AuthException catch (e) {
      throw AuthFailure(message: e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(message: e.message);
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message, statusCode: e.statusCode);
    }
  }

  // -------------------------------------------------------------------------
  // Google Sign-In
  // -------------------------------------------------------------------------

  @override
  Future<({AuthTokens tokens, UserEntity user})> googleSignIn() async {
    try {
      final googleSignIn = GoogleSignIn();
      final account = await googleSignIn.signIn();
      if (account == null) {
        throw const AuthFailure(message: 'Google sign-in cancelled');
      }
      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) {
        throw const AuthFailure(message: 'Failed to obtain Google ID token');
      }

      final response = await _remote.googleSignIn(idToken: idToken);
      await _persistSession(response.toTokens(), response.user.toEntity());
      return (tokens: response.toTokens(), user: response.user.toEntity());
    } on AuthFailure {
      rethrow;
    } on AuthException catch (e) {
      throw AuthFailure(message: e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(message: e.message);
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message, statusCode: e.statusCode);
    }
  }

  // -------------------------------------------------------------------------
  // Token refresh
  // -------------------------------------------------------------------------

  @override
  Future<AuthTokens> refreshToken({required String refreshToken}) async {
    try {
      final response = await _remote.refreshToken(refreshToken: refreshToken);
      await _local.saveAccessToken(response.accessToken);
      await _local.saveRefreshToken(response.refreshToken);
      return response.toTokens();
    } on AuthException catch (e) {
      throw AuthFailure(message: e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(message: e.message);
    } on ServerException catch (e) {
      throw ServerFailure(message: e.message, statusCode: e.statusCode);
    }
  }

  // -------------------------------------------------------------------------
  // Logout
  // -------------------------------------------------------------------------

  @override
  Future<void> logout() async {
    try {
      await _remote.logout();
    } catch (_) {
      // Ignore remote errors on logout — clear locally regardless.
    } finally {
      await _local.clearAll();
    }
  }

  // -------------------------------------------------------------------------
  // Current user
  // -------------------------------------------------------------------------

  @override
  Future<UserEntity?> getCurrentUser() async {
    final id = await _local.getUserId();
    if (id == null) return null;

    final email = await _local.getUserEmail() ?? '';
    final tenantId = await _local.getTenantId() ?? '';
    final role = await _local.getUserRole() ?? 'viewer';

    return UserEntity(
      id: id,
      tenantId: tenantId,
      email: email,
      role: role == 'admin' ? UserRole.admin : UserRole.viewer,
      createdAt: DateTime.now(), // Not persisted; use server data if needed
    );
  }

  // -------------------------------------------------------------------------
  // Private
  // -------------------------------------------------------------------------

  Future<void> _persistSession(AuthTokens tokens, UserEntity user) async {
    await Future.wait([
      _local.saveAccessToken(tokens.accessToken),
      _local.saveRefreshToken(tokens.refreshToken),
      _local.saveUserId(user.id),
      _local.saveTenantId(user.tenantId),
      _local.saveUserRole(user.role.name),
      _local.saveUserEmail(user.email),
    ]);
  }
}

// ---------------------------------------------------------------------------
// Riverpod provider
// ---------------------------------------------------------------------------

@riverpod
AuthRepository authRepository(Ref ref) => AuthRepositoryImpl(
      ref.watch(authRemoteDataSourceProvider),
      ref.watch(authLocalDataSourceProvider),
    );
