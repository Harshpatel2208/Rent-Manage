import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/auth_response_model.dart';

part 'auth_remote_datasource.g.dart';

/// Remote data source for all authentication API calls.
abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });

  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  });

  Future<void> sendOtp({required String phone});

  Future<AuthResponseModel> verifyOtp({
    required String phone,
    required String otp,
  });

  Future<AuthResponseModel> googleSignIn({required String idToken});

  Future<AuthResponseModel> refreshToken({required String refreshToken});

  Future<void> logout();
}

/// Dio-based implementation of [AuthRemoteDataSource].
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.authLogin,
        data: {'email': email, 'password': password},
      );
      final payload = (response.data!['data'] as Map<String, dynamic>);
      return AuthResponseModel.fromJson(payload);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  @override
  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.authRegister,
        data: {
          'tenant_name': name,
          'email': email,
          'password': password,
          'phone': phone.isEmpty ? null : phone,
        },
      );
      final payload = (response.data!['data'] as Map<String, dynamic>);
      return AuthResponseModel.fromJson(payload);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  @override
  Future<void> sendOtp({required String phone}) async {
    try {
      await _dio.post<dynamic>(
        ApiEndpoints.authOtpSend,
        data: {'phone': phone},
      );
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  @override
  Future<AuthResponseModel> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.authOtpVerify,
        data: {'phone': phone, 'otp': otp},
      );
      final payload = (response.data!['data'] as Map<String, dynamic>);
      return AuthResponseModel.fromJson(payload);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  @override
  Future<AuthResponseModel> googleSignIn({required String idToken}) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.authGoogle,
        data: {'id_token': idToken},
      );
      final payload = (response.data!['data'] as Map<String, dynamic>);
      return AuthResponseModel.fromJson(payload);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  @override
  Future<AuthResponseModel> refreshToken({required String refreshToken}) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.authRefresh,
        data: {'refresh_token': refreshToken},
      );
      final payload = (response.data!['data'] as Map<String, dynamic>);
      return AuthResponseModel.fromJson(payload);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post<dynamic>(ApiEndpoints.authLogout);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Error mapping
  // ---------------------------------------------------------------------------

  Never _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      throw const NetworkException(message: 'No internet connection');
    }
    final statusCode = e.response?.statusCode;
    if (statusCode == 401 || statusCode == 403) {
      throw AuthException(
        message: _extractMessage(e) ?? 'Authentication failed',
      );
    }
    throw ServerException(
      message: _extractMessage(e) ?? 'An unexpected error occurred',
      statusCode: statusCode,
    );
  }

  String? _extractMessage(DioException e) {
    try {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        // Our backend uses { success: false, error: "..." }
        return (data['error'] ?? data['message']) as String?;
      }
    } catch (_) {}
    return e.message;
  }
}

// ---------------------------------------------------------------------------
// Riverpod provider
// ---------------------------------------------------------------------------

@riverpod
AuthRemoteDataSource authRemoteDataSource(Ref ref) =>
    AuthRemoteDataSourceImpl(ref.watch(dioClientProvider));
