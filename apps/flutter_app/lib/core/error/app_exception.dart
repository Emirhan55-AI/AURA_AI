/// Core exception classes for Aura application
/// Provides a standardized way to handle and communicate errors throughout the app

/// Base exception class for all application-specific errors
/// Provides consistent error structure with user-friendly messaging
class AppException implements Exception {
  /// User-friendly error message
  final String message;
  
  /// Optional error code from API or system
  final String? code;
  
  /// Optional additional details for debugging
  final dynamic details;
  
  /// Optional original exception that caused this error
  final Exception? originalException;

  const AppException(
    this.message, {
    this.code,
    this.details,
    this.originalException,
  });

  @override
  String toString() {
    return 'AppException{message: $message, code: $code, details: $details}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppException &&
        other.message == message &&
        other.code == code;
  }

  @override
  int get hashCode => message.hashCode ^ code.hashCode;
}

/// Network-related errors (connectivity, timeouts, server errors)
class NetworkException extends AppException {
  NetworkException({
    String? message,
    String? code,
    dynamic details,
    Exception? originalException,
  }) : super(
          message ?? 'Connection issue. Please check your internet and try again.',
          code: code,
          details: details,
          originalException: originalException,
        );

  /// Specific constructor for server errors
  NetworkException.serverError({
    String? message,
    String? code,
    dynamic details,
  }) : super(
          message ?? 'Server is temporarily unavailable. Please try again in a moment.',
          code: code,
          details: details,
        );

  /// Specific constructor for timeout errors
  NetworkException.timeout({
    String? message,
    String? code,
  }) : super(
          message ?? 'Request timed out. Please check your connection and try again.',
          code: code,
        );
}

/// Authentication and authorization related errors
class AuthException extends AppException {
  AuthException({
    String? message,
    String? code,
    dynamic details,
    Exception? originalException,
  }) : super(
          message ?? 'Authentication failed. Please sign in again.',
          code: code,
          details: details,
          originalException: originalException,
        );

  /// Specific constructor for expired sessions
  AuthException.sessionExpired({
    String? message,
    String? code,
  }) : super(
          message ?? 'Your session has expired. Please sign in again.',
          code: code,
        );

  /// Specific constructor for invalid credentials
  AuthException.invalidCredentials({
    String? message,
    String? code,
  }) : super(
          message ?? 'Invalid email or password. Please try again.',
          code: code,
        );

  /// Specific constructor for insufficient permissions
  AuthException.forbidden({
    String? message,
    String? code,
  }) : super(
          message ?? 'You don\'t have permission to access this feature.',
          code: code,
        );
}

/// Local storage and caching related errors
class CacheException extends AppException {
  CacheException({
    String? message,
    String? code,
    dynamic details,
    Exception? originalException,
  }) : super(
          message ?? 'Unable to access stored data. Please try again.',
          code: code,
          details: details,
          originalException: originalException,
        );

  /// Specific constructor for storage full errors
  CacheException.storageFull({
    String? message,
    String? code,
  }) : super(
          message ?? 'Device storage is full. Please free up some space and try again.',
          code: code,
        );

  /// Specific constructor for corrupted data
  CacheException.corruptedData({
    String? message,
    String? code,
  }) : super(
          message ?? 'Stored data is corrupted. The app will refresh automatically.',
          code: code,
        );
}

/// Input validation and data format errors
class ValidationException extends AppException {
  ValidationException({
    String? message,
    String? code,
    dynamic details,
    Exception? originalException,
  }) : super(
          message ?? 'Please check your input and try again.',
          code: code,
          details: details,
          originalException: originalException,
        );

  /// Specific constructor for email validation
  ValidationException.invalidEmail({
    String? message,
    String? code,
  }) : super(
          message ?? 'Please enter a valid email address.',
          code: code,
        );

  /// Specific constructor for password validation
  ValidationException.weakPassword({
    String? message,
    String? code,
  }) : super(
          message ?? 'Password must be at least 8 characters with letters and numbers.',
          code: code,
        );

  /// Specific constructor for required field validation
  ValidationException.requiredField({
    String? fieldName,
    String? code,
  }) : super(
          'Please fill in ${fieldName ?? 'this field'}.',
          code: code,
        );
}

/// File and media related errors
class MediaException extends AppException {
  MediaException({
    String? message,
    String? code,
    dynamic details,
    Exception? originalException,
  }) : super(
          message ?? 'Unable to process media. Please try again.',
          code: code,
          details: details,
          originalException: originalException,
        );

  /// Specific constructor for unsupported file formats
  MediaException.unsupportedFormat({
    String? message,
    String? code,
  }) : super(
          message ?? 'This file format is not supported. Please choose a different file.',
          code: code,
        );

  /// Specific constructor for file size limits
  MediaException.fileTooLarge({
    String? message,
    String? code,
    String? maxSize,
  }) : super(
          message ?? 'File is too large. Maximum size allowed is ${maxSize ?? '10MB'}.',
          code: code,
        );
}

/// Server-related errors (HTTP errors, server failures)
class ServerException extends AppException {
  const ServerException({
    String? message,
    String? code,
    dynamic details,
    Exception? originalException,
  }) : super(
          message ?? 'Server error occurred. Please try again later.',
          code: code,
          details: details,
          originalException: originalException,
        );

  /// Named constructor for HTTP errors
  const ServerException.httpError({
    required int statusCode,
    String? message,
    String? code,
  }) : super(
          message ?? 'Server returned error $statusCode',
          code: code,
        );

  /// Named constructor for server unavailable
  const ServerException.unavailable({
    String? message,
    String? code,
  }) : super(
          message ?? 'Server is currently unavailable. Please try again later.',
          code: code,
        );
}

/// External service integration errors
class ServiceException extends AppException {
  ServiceException({
    String? message,
    String? code,
    dynamic details,
    Exception? originalException,
  }) : super(
          message ?? 'External service is temporarily unavailable. Please try again later.',
          code: code,
          details: details,
          originalException: originalException,
        );

  /// Specific constructor for API rate limiting
  ServiceException.rateLimited({
    String? message,
    String? code,
  }) : super(
          message ?? 'Too many requests. Please wait a moment and try again.',
          code: code,
        );

  /// Specific constructor for service maintenance
  ServiceException.maintenance({
    String? message,
    String? code,
  }) : super(
          message ?? 'Service is under maintenance. Please try again later.',
          code: code,
        );
}

/// Unknown or unexpected errors
class UnknownException extends AppException {
  UnknownException({
    String? message,
    String? code,
    dynamic details,
    Exception? originalException,
  }) : super(
          message ?? 'Something unexpected happened. Please try again.',
          code: code,
          details: details,
          originalException: originalException,
        );
}
