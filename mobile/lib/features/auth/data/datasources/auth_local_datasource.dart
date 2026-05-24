import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';

part 'auth_local_datasource.g.dart';

// ---------------------------------------------------------------------------
// Keys
// ---------------------------------------------------------------------------
const _kAccessToken = 'access_token';
const _kRefreshToken = 'refresh_token';
const _kUserId = 'user_id';
const _kTenantId = 'tenant_id';
const _kUserRole = 'user_role';
const _kUserEmail = 'user_email';

/// Local data source backed by [FlutterSecureStorage].
///
/// Handles persisting and retrieving authentication tokens and basic
/// user identity so the app can restore session across restarts.
class AuthLocalDataSource {
  const AuthLocalDataSource(this._storage);

  final FlutterSecureStorage _storage;

  // -------------------------------------------------------------------------
  // Save
  // -------------------------------------------------------------------------

  Future<void> saveAccessToken(String token) =>
      _storage.write(key: _kAccessToken, value: token);

  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: _kRefreshToken, value: token);

  Future<void> saveUserId(String id) =>
      _storage.write(key: _kUserId, value: id);

  Future<void> saveTenantId(String id) =>
      _storage.write(key: _kTenantId, value: id);

  Future<void> saveUserRole(String role) =>
      _storage.write(key: _kUserRole, value: role);

  Future<void> saveUserEmail(String email) =>
      _storage.write(key: _kUserEmail, value: email);

  // -------------------------------------------------------------------------
  // Read
  // -------------------------------------------------------------------------

  Future<String?> getAccessToken() => _storage.read(key: _kAccessToken);

  Future<String?> getRefreshToken() => _storage.read(key: _kRefreshToken);

  Future<String?> getUserId() => _storage.read(key: _kUserId);

  Future<String?> getTenantId() => _storage.read(key: _kTenantId);

  Future<String?> getUserRole() => _storage.read(key: _kUserRole);

  Future<String?> getUserEmail() => _storage.read(key: _kUserEmail);

  /// Returns `true` if a valid access token exists in storage.
  Future<bool> hasValidSession() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // -------------------------------------------------------------------------
  // Clear
  // -------------------------------------------------------------------------

  /// Deletes all auth credentials (on logout).
  Future<void> clearAll() async {
    try {
      await Future.wait([
        _storage.delete(key: _kAccessToken),
        _storage.delete(key: _kRefreshToken),
        _storage.delete(key: _kUserId),
        _storage.delete(key: _kTenantId),
        _storage.delete(key: _kUserRole),
        _storage.delete(key: _kUserEmail),
      ]);
    } catch (e) {
      throw CacheException(message: 'Failed to clear auth credentials: $e');
    }
  }
}

// ---------------------------------------------------------------------------
// Riverpod provider
// ---------------------------------------------------------------------------

@riverpod
AuthLocalDataSource authLocalDataSource(Ref ref) =>
    AuthLocalDataSource(ref.watch(secureStorageProvider));
