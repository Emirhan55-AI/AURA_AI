/// Failure classes for Clean Architecture pattern
/// Represents the result of operations that can either succeed or fail
/// Used in the domain layer to handle errors without throwing exceptions

import 'app_exception.dart';

/// Base failure class for representing operation failures
/// Contains user-friendly message and optional technical details
abstract class Failure {
  /// User-friendly error message
  final String message;
  
  /// Optional error code for debugging and logging
  final String? code;
  
  /// Optional additional details
  final dynamic details;

  const Failure({
    required this.message,
    this.code,
    this.details,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure &&
        other.message == message &&
        other.code == code;
  }

  @override
  int get hashCode => message.hashCode ^ code.hashCode;

  @override
  String toString() => 'Failure{message: $message, code: $code}';
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    String? message,
    String? code,
    dynamic details,
  }) : super(
          message: message ?? 'Network connection failed. Please try again.',
          code: code,
          details: details,
        );

  /// Named constructor for server errors
  const NetworkFailure.serverError({
    String? code,
    dynamic details,
  }) : super(
          message: 'Server error occurred. Please try again later.',
          code: code,
          details: details,
        );

  /// Named constructor for no internet connection
  const NetworkFailure.noConnection({
    String? code,
  }) : super(
          message: 'No internet connection. Please check your network settings.',
          code: code,
        );

  /// Named constructor for request timeout
  const NetworkFailure.timeout({
    String? code,
  }) : super(
          message: 'Request timed out. Please try again.',
          code: code,
        );
}

/// Authentication-related failures
class AuthFailure extends Failure {
  const AuthFailure({
    String? message,
    String? code,
    dynamic details,
  }) : super(
          message: message ?? 'Authentication failed.',
          code: code,
          details: details,
        );

  /// Named constructor for invalid credentials
  const AuthFailure.invalidCredentials({
    String? code,
  }) : super(
          message: 'Invalid email or password.',
          code: code,
        );

  /// Named constructor for expired session
  const AuthFailure.sessionExpired({
    String? code,
  }) : super(
          message: 'Your session has expired. Please sign in again.',
          code: code,
        );

  /// Named constructor for insufficient permissions
  const AuthFailure.forbidden({
    String? code,
  }) : super(
          message: 'You don\'t have permission to perform this action.',
          code: code,
        );
}

/// Local storage and cache-related failures
class CacheFailure extends Failure {
  const CacheFailure({
    String? message,
    String? code,
    dynamic details,
  }) : super(
          message: message ?? 'Unable to access local storage.',
          code: code,
          details: details,
        );

  /// Named constructor for storage full
  const CacheFailure.storageFull({
    String? code,
  }) : super(
          message: 'Device storage is full. Please free up space.',
          code: code,
        );

  /// Named constructor for corrupted cache
  const CacheFailure.corrupted({
    String? code,
  }) : super(
          message: 'Local data is corrupted. App will refresh.',
          code: code,
        );
}

/// Input validation failures
class ValidationFailure extends Failure {
  const ValidationFailure({
    String? message,
    String? code,
    dynamic details,
  }) : super(
          message: message ?? 'Invalid input provided.',
          code: code,
          details: details,
        );

  /// Named constructor for email validation
  const ValidationFailure.invalidEmail({
    String? code,
  }) : super(
          message: 'Please enter a valid email address.',
          code: code,
        );

  /// Named constructor for password validation
  const ValidationFailure.weakPassword({
    String? code,
  }) : super(
          message: 'Password must be at least 8 characters.',
          code: code,
        );

  /// Named constructor for required fields
  const ValidationFailure.requiredField({
    String? fieldName,
    String? code,
  }) : super(
          message: '${fieldName ?? 'Field'} is required.',
          code: code,
        );
}

/// External service failures
class ServiceFailure extends Failure {
  const ServiceFailure({
    String? message,
    String? code,
    dynamic details,
  }) : super(
          message: message ?? 'External service unavailable.',
          code: code,
          details: details,
        );

  /// Named constructor for rate limiting
  const ServiceFailure.rateLimited({
    String? code,
  }) : super(
          message: 'Too many requests. Please wait and try again.',
          code: code,
        );

  /// Named constructor for service maintenance
  const ServiceFailure.maintenance({
    String? code,
  }) : super(
          message: 'Service is under maintenance.',
          code: code,
        );
}

/// Unknown or unexpected failures
class UnknownFailure extends Failure {
  const UnknownFailure({
    String? message,
    String? code,
    dynamic details,
  }) : super(
          message: message ?? 'An unexpected error occurred.',
          code: code,
          details: details,
        );
}

/// Utility class for converting exceptions to failures
class FailureMapper {
  /// Converts common exceptions to appropriate failure types
  static Failure fromException(Exception exception) {
    if (exception is NetworkException) {
      return NetworkFailure(
        message: exception.message,
        code: exception.code,
        details: exception.details,
      );
    } else if (exception is AuthException) {
      return AuthFailure(
        message: exception.message,
        code: exception.code,
        details: exception.details,
      );
    } else if (exception is CacheException) {
      return CacheFailure(
        message: exception.message,
        code: exception.code,
        details: exception.details,
      );
    } else if (exception is ValidationException) {
      return ValidationFailure(
        message: exception.message,
        code: exception.code,
        details: exception.details,
      );
    } else if (exception is ServiceException) {
      return ServiceFailure(
        message: exception.message,
        code: exception.code,
        details: exception.details,
      );
    } else {
      return UnknownFailure(
        message: 'Something went wrong. Please try again.',
        details: exception.toString(),
      );
    }
  }
}
