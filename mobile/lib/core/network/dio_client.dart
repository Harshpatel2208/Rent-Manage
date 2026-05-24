import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../constants/api_endpoints.dart';

part 'dio_client.g.dart';

// ---------------------------------------------------------------------------
// Secure storage provider (shared across the app)
// ---------------------------------------------------------------------------

/// Provides a singleton [FlutterSecureStorage] instance.
@Riverpod(keepAlive: true)
FlutterSecureStorage secureStorage(Ref ref) =>
    const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );

// ---------------------------------------------------------------------------
// Auth interceptor
// ---------------------------------------------------------------------------

/// Injects the Bearer token from secure storage into every outgoing request.
class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._storage);

  final FlutterSecureStorage _storage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: 'access_token');
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

// ---------------------------------------------------------------------------
// Retry interceptor
// ---------------------------------------------------------------------------

/// Retries failed requests up to [_maxRetries] times on network-level errors.
class _RetryInterceptor extends Interceptor {
  _RetryInterceptor(this._dio);

  final Dio _dio;
  static const int _maxRetries = 3;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final extra = err.requestOptions.extra;
    final retryCount = (extra['retry_count'] as int?) ?? 0;

    final isNetworkError =
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.connectionError;

    if (isNetworkError && retryCount < _maxRetries) {
      final delay = Duration(seconds: (retryCount + 1) * 2);
      await Future<void>.delayed(delay);

      err.requestOptions.extra['retry_count'] = retryCount + 1;
      try {
        final response = await _dio.fetch<dynamic>(err.requestOptions);
        handler.resolve(response);
        return;
      } on DioException catch (e) {
        handler.reject(e);
        return;
      }
    }
    handler.next(err);
  }
}

// ---------------------------------------------------------------------------
// Dio provider
// ---------------------------------------------------------------------------

/// Provides a fully-configured [Dio] singleton with auth, retry, and
/// (in debug mode) logging interceptors.
@Riverpod(keepAlive: true)
Dio dioClient(Ref ref) {
  final storage = ref.watch(secureStorageProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.addAll([
    _AuthInterceptor(storage),
    _RetryInterceptor(dio),
    if (kDebugMode)
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ),
  ]);

  return dio;
}
