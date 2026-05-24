import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

/// Sealed domain-layer failure hierarchy.
///
/// Every use-case returns `Either<Failure, T>` so that callers can pattern-
/// match exhaustively without resorting to try/catch.
@freezed
sealed class Failure with _$Failure {
  // ---------------------------------------------------------------------------
  // Remote / HTTP errors
  // ---------------------------------------------------------------------------

  /// A non-success HTTP response from the server.
  const factory Failure.server({
    required String message,
    int? statusCode,
  }) = ServerFailure;

  // ---------------------------------------------------------------------------
  // Connectivity
  // ---------------------------------------------------------------------------

  /// No network connection or request timed out.
  const factory Failure.network({
    required String message,
  }) = NetworkFailure;

  // ---------------------------------------------------------------------------
  // Local storage
  // ---------------------------------------------------------------------------

  /// An error reading or writing to the local SQLite / secure-storage.
  const factory Failure.cache({
    required String message,
  }) = CacheFailure;

  // ---------------------------------------------------------------------------
  // Authentication
  // ---------------------------------------------------------------------------

  /// Invalid credentials, expired token, or missing auth state.
  const factory Failure.auth({
    required String message,
  }) = AuthFailure;

  // ---------------------------------------------------------------------------
  // Sync conflicts
  // ---------------------------------------------------------------------------

  /// The remote rejected the mutation due to a data conflict.
  const factory Failure.conflict({
    required String message,
    required String entityType,
    required String entityId,
  }) = ConflictFailure;
}
