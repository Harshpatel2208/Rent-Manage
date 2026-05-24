// Custom exception classes for the data layer.
//
// These are caught in repository implementations and mapped to [Failure]
// sealed variants for the domain layer.

/// Thrown when the server returns a non-2xx HTTP status code.
class ServerException implements Exception {
  const ServerException({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() =>
      'ServerException(statusCode: $statusCode, message: $message)';
}

/// Thrown when there is no network connectivity or a timeout occurs.
class NetworkException implements Exception {
  const NetworkException({required this.message});

  final String message;

  @override
  String toString() => 'NetworkException(message: $message)';
}

/// Thrown when a local database or secure-storage operation fails.
class CacheException implements Exception {
  const CacheException({required this.message});

  final String message;

  @override
  String toString() => 'CacheException(message: $message)';
}

/// Thrown when an authentication error occurs (invalid/expired tokens, etc.).
class AuthException implements Exception {
  const AuthException({required this.message});

  final String message;

  @override
  String toString() => 'AuthException(message: $message)';
}
