import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'failure.dart';

/// Utility class for converting exceptions to failures
/// Provides consistent error mapping across the application
class FailureMapper {
  /// Maps various exception types to appropriate Failure instances
  static Failure fromException(Object exception) {
    switch (exception.runtimeType) {
      case const (SocketException):
        return const NetworkFailure.noConnection();
      
      case const (HttpException):
        return const NetworkFailure.serverError();
      
      case const (TimeoutException):
        return const NetworkFailure.timeout();
      
      case const (FormatException):
        return const ValidationFailure.requiredField();
      
      case const (ArgumentError):
        return const ValidationFailure.requiredField();
      
      case const (PostgrestException):
        return _mapPostgrestException(exception as PostgrestException);
      
      case const (AuthException):
        return _mapAuthException(exception as AuthException);
      
      case const (StorageException):
        return const ServiceFailure.maintenance();
      
      default:
        return const UnknownFailure();
    }
  }

  /// Maps Supabase Postgrest exceptions to domain failures
  static Failure _mapPostgrestException(PostgrestException exception) {
    switch (exception.code) {
      case '23505': // Unique violation
        return const ValidationFailure.requiredField();
      
      case '23503': // Foreign key violation
        return const ValidationFailure.requiredField();
      
      case '23514': // Check violation
        return const ValidationFailure.requiredField();
      
      case '42501': // Insufficient privilege (RLS)
        return const AuthFailure.forbidden();
      
      case '42P01': // Table doesn't exist
        return const ServiceFailure.maintenance();
      
      case 'PGRST116': // Multiple/single row error
        return const ValidationFailure.requiredField();
      
      default:
        if (exception.message.contains('RLS')) {
          return const AuthFailure.forbidden();
        } else if (exception.message.contains('duplicate')) {
          return const ValidationFailure.requiredField();
        } else {
          return const ServiceFailure.maintenance();
        }
    }
  }

  /// Maps Supabase Auth exceptions to domain failures
  static Failure _mapAuthException(AuthException exception) {
    switch (exception.message.toLowerCase()) {
      case String msg when msg.contains('invalid login'):
        return const AuthFailure.invalidCredentials();
      
      case String msg when msg.contains('email not confirmed'):
        return const AuthFailure.invalidCredentials();
      
      case String msg when msg.contains('user not found'):
        return const AuthFailure.invalidCredentials();
      
      case String msg when msg.contains('token'):
        return const AuthFailure.sessionExpired();
      
      case String msg when msg.contains('password'):
        return const ValidationFailure.weakPassword();
      
      case String msg when msg.contains('signup'):
        return const AuthFailure.forbidden();
      
      default:
        return const AuthFailure.invalidCredentials();
    }
  }

  /// Maps network-related exceptions
  static Failure fromNetworkException(Object exception) {
    if (exception is SocketException) {
      return const NetworkFailure.noConnection();
    }
    
    if (exception is TimeoutException) {
      return const NetworkFailure.timeout();
    }
    
    return fromException(exception);
  }

  /// Maps validation-related exceptions
  static Failure fromValidationException(Object exception) {
    if (exception is FormatException) {
      return const ValidationFailure.invalidEmail();
    }
    
    if (exception is ArgumentError) {
      return const ValidationFailure.requiredField();
    }
    
    if (exception is RangeError) {
      return const ValidationFailure.requiredField();
    }
    
    return fromException(exception);
  }

  /// Maps service-related exceptions
  static Failure fromServiceException(Object exception, {String? service}) {
    if (exception is StateError) {
      return const ServiceFailure.maintenance();
    }
    
    if (exception is UnsupportedError) {
      return const ServiceFailure.maintenance();
    }
    
    return const ServiceFailure.maintenance();
  }

  /// Creates a cache-related failure
  static Failure fromCacheException(Object exception) {
    if (exception.toString().contains('not found')) {
      return const CacheFailure.corrupted();
    }
    
    if (exception.toString().contains('permission')) {
      return const CacheFailure.corrupted();
    }
    
    if (exception.toString().contains('space') || exception.toString().contains('storage')) {
      return const CacheFailure.storageFull();
    }
    
    return const CacheFailure.corrupted();
  }

  /// Determines if an exception should be retried
  static bool shouldRetry(Object exception) {
    if (exception is SocketException) {
      return true; // Network issues are usually temporary
    }
    
    if (exception is TimeoutException) {
      return true; // Timeouts can be retried
    }
    
    if (exception is PostgrestException) {
      // Don't retry validation errors or auth errors
      return !['23505', '23503', '23514', '42501'].contains(exception.code);
    }
    
    if (exception is AuthException) {
      // Don't retry auth errors except token-related ones
      return exception.message.toLowerCase().contains('token');
    }
    
    return false; // Conservative approach for unknown exceptions
  }

  /// Gets user-friendly error message from exception
  static String getUserMessage(Object exception) {
    final failure = fromException(exception);
    return failure.message;
  }

  /// Gets error code from exception for logging/analytics
  static String getErrorCode(Object exception) {
    if (exception is PostgrestException) {
      return 'PGST_${exception.code}';
    }
    
    if (exception is AuthException) {
      return 'AUTH_${exception.statusCode ?? "UNKNOWN"}';
    }
    
    if (exception is StorageException) {
      return 'STORAGE_${exception.statusCode ?? "UNKNOWN"}';
    }
    
    return exception.runtimeType.toString().toUpperCase();
  }
}
