import 'failure.dart';

/// Failure related to server/backend errors
class ServerFailure extends Failure {
  const ServerFailure({
    required String message,
    String? code,
    dynamic details,
  }) : super(
          message: message,
          code: code,
          details: details,
        );
}

/// Failure related to network connectivity issues
class NetworkFailure extends Failure {
  const NetworkFailure({
    required String message,
    String? code,
    dynamic details,
  }) : super(
          message: message,
          code: code,
          details: details,
        );
}

/// Failure related to database operations
class DatabaseFailure extends Failure {
  const DatabaseFailure({
    required String message,
    String? code,
    dynamic details,
  }) : super(
          message: message,
          code: code,
          details: details,
        );
}

/// Failure related to authentication and authorization
class AuthFailure extends Failure {
  const AuthFailure({
    required String message,
    String? code,
    dynamic details,
  }) : super(
          message: message,
          code: code,
          details: details,
        );
          
  /// Convenient constructor for unauthenticated errors
  const AuthFailure.notAuthenticated()
      : super(
          message: 'User not authenticated',
          code: 'AUTH_REQUIRED',
        );
}

/// Failure related to validation errors
class ValidationFailure extends Failure {
  const ValidationFailure({
    required String message,
    String? code,
    dynamic details,
  }) : super(
          message: message,
          code: code,
          details: details,
        );
}

/// Failure related to cache operations
class CacheFailure extends Failure {
  const CacheFailure({
    required String message,
    String? code,
    dynamic details,
  }) : super(
          message: message,
          code: code,
          details: details,
        );
}

/// Unknown/unspecified failure
class UnknownFailure extends Failure {
  const UnknownFailure({
    required String message,
    String? code,
    dynamic details,
  }) : super(
          message: message,
          code: code,
          details: details,
        );
}
