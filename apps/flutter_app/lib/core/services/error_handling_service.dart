import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../error/failure.dart';

part 'error_handling_service.g.dart';

/// Service for centralized error handling and user-friendly error messaging
/// Converts technical errors to user-friendly messages and manages error state
class ErrorHandlingService {
  final Map<String, AppError> _activeErrors = {};
  
  /// Handle an error and convert it to user-friendly format
  AppError handleError(
    Object error, {
    String? context,
    StackTrace? stackTrace,
    ErrorSeverity severity = ErrorSeverity.medium,
  }) {
    final appError = _convertToAppError(error, context, severity, stackTrace);
    
    if (context != null) {
      _activeErrors[context] = appError;
    }
    
    _logError(appError);
    return appError;
  }

  /// Get error for specific context
  AppError? getError(String context) => _activeErrors[context];

  /// Check if context has an error
  bool hasError(String context) => _activeErrors.containsKey(context);

  /// Clear error for specific context
  void clearError(String context) {
    _activeErrors.remove(context);
  }

  /// Clear all errors
  void clearAllErrors() {
    _activeErrors.clear();
  }

  /// Get all active errors
  Map<String, AppError> get activeErrors => Map.unmodifiable(_activeErrors);

  /// Convert any error to AppError
  AppError _convertToAppError(
    Object error,
    String? context,
    ErrorSeverity severity,
    StackTrace? stackTrace,
  ) {
    if (error is AppError) {
      return error;
    }

    if (error is Failure) {
      return AppError(
        message: _getFailureMessage(error),
        technicalMessage: error.toString(),
        code: _getFailureCode(error),
        severity: severity,
        context: context,
        stackTrace: stackTrace,
      );
    }

    // Handle common exception types
    final userMessage = _getUserFriendlyMessage(error);
    
    return AppError(
      message: userMessage,
      technicalMessage: error.toString(),
      code: _getErrorCode(error),
      severity: severity,
      context: context,
      stackTrace: stackTrace,
    );
  }

  /// Get user-friendly message from Failure
  String _getFailureMessage(Failure failure) {
    switch (failure.runtimeType) {
      case const (NetworkFailure):
        return 'Network connection problem. Please check your internet connection.';
      case const (AuthFailure):
        return 'Authentication failed. Please sign in again.';
      case const (ServiceFailure):
        return 'Server error. Please try again later.';
      case const (CacheFailure):
        return 'Local storage error. The app may need to refresh.';
      case const (ValidationFailure):
        return 'Invalid input. Please check your information.';
      default:
        return failure.message ?? 'An unexpected error occurred.';
    }
  }

  /// Get error code from Failure
  String _getFailureCode(Failure failure) {
    switch (failure.runtimeType) {
      case const (NetworkFailure):
        return 'NETWORK_ERROR';
      case const (AuthFailure):
        return 'AUTH_ERROR';
      case const (ServiceFailure):
        return 'SERVER_ERROR';
      case const (CacheFailure):
        return 'CACHE_ERROR';
      case const (ValidationFailure):
        return 'VALIDATION_ERROR';
      default:
        return 'UNKNOWN_ERROR';
    }
  }

  /// Get user-friendly message from general exceptions
  String _getUserFriendlyMessage(Object error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('network') || errorString.contains('socket')) {
      return 'Network connection problem. Please check your internet connection.';
    }
    
    if (errorString.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }
    
    if (errorString.contains('permission') || errorString.contains('denied')) {
      return 'Permission denied. Please check app permissions.';
    }
    
    if (errorString.contains('storage') || errorString.contains('disk')) {
      return 'Storage error. Please check available space.';
    }

    if (errorString.contains('format') || errorString.contains('parse')) {
      return 'Data format error. Please try refreshing.';
    }

    return 'An unexpected error occurred. Please try again.';
  }

  /// Get error code from general exceptions
  String _getErrorCode(Object error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('network') || errorString.contains('socket')) {
      return 'NETWORK_ERROR';
    }
    
    if (errorString.contains('timeout')) {
      return 'TIMEOUT_ERROR';
    }
    
    if (errorString.contains('permission')) {
      return 'PERMISSION_ERROR';
    }
    
    if (errorString.contains('storage')) {
      return 'STORAGE_ERROR';
    }

    if (errorString.contains('format')) {
      return 'FORMAT_ERROR';
    }

    return 'UNKNOWN_ERROR';
  }

  /// Log error for debugging
  void _logError(AppError error) {
    debugPrint('AppError [${error.code}]: ${error.message}');
    if (error.context != null) {
      debugPrint('Context: ${error.context}');
    }
    if (error.stackTrace != null) {
      debugPrint('Stack trace: ${error.stackTrace}');
    }
  }
}

/// Application error model with user-friendly messaging
class AppError {
  final String message;
  final String technicalMessage;
  final String code;
  final ErrorSeverity severity;
  final String? context;
  final StackTrace? stackTrace;
  final DateTime timestamp;

  AppError({
    required this.message,
    required this.technicalMessage,
    required this.code,
    required this.severity,
    this.context,
    this.stackTrace,
  }) : timestamp = DateTime.now();

  /// Check if error is critical
  bool get isCritical => severity == ErrorSeverity.critical;

  /// Check if error requires user action
  bool get requiresUserAction => severity != ErrorSeverity.low;

  /// Get color representation of severity
  String get severityColor {
    switch (severity) {
      case ErrorSeverity.low:
        return '#FFA726'; // Orange
      case ErrorSeverity.medium:
        return '#EF5350'; // Red
      case ErrorSeverity.critical:
        return '#D32F2F'; // Dark Red
    }
  }

  @override
  String toString() {
    return 'AppError(message: $message, code: $code, severity: $severity, context: $context)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is AppError &&
      other.message == message &&
      other.code == code &&
      other.severity == severity &&
      other.context == context;
  }

  @override
  int get hashCode {
    return message.hashCode ^
      code.hashCode ^
      severity.hashCode ^
      context.hashCode;
  }
}

/// Error severity levels
enum ErrorSeverity {
  low,     // Info/warning level
  medium,  // Standard errors that affect user experience
  critical // Errors that prevent app functionality
}

/// Predefined error contexts
class ErrorContexts {
  static const String authentication = 'authentication';
  static const String userProfile = 'user_profile';
  static const String wardrobe = 'wardrobe';
  static const String styleAnalysis = 'style_analysis';
  static const String socialFeed = 'social_feed';
  static const String fileUpload = 'file_upload';
  static const String dataSync = 'data_sync';
  static const String onboarding = 'onboarding';
  static const String settings = 'settings';
  static const String appInitialization = 'app_initialization';
  static const String navigation = 'navigation';
}

/// Provider for ErrorHandlingService instance
@riverpod
ErrorHandlingService errorHandlingService(ErrorHandlingServiceRef ref) {
  return ErrorHandlingService();
}

/// Provider for active errors state
@riverpod
class ErrorState extends _$ErrorState {
  @override
  Map<String, AppError> build() {
    final service = ref.read(errorHandlingServiceProvider);
    return service.activeErrors;
  }

  /// Handle a new error
  AppError handleError(
    Object error, {
    String? context,
    StackTrace? stackTrace,
    ErrorSeverity severity = ErrorSeverity.medium,
  }) {
    final service = ref.read(errorHandlingServiceProvider);
    final appError = service.handleError(
      error,
      context: context,
      stackTrace: stackTrace,
      severity: severity,
    );
    ref.invalidateSelf();
    return appError;
  }

  /// Clear error for specific context
  void clearError(String context) {
    final service = ref.read(errorHandlingServiceProvider);
    service.clearError(context);
    ref.invalidateSelf();
  }

  /// Clear all errors
  void clearAllErrors() {
    final service = ref.read(errorHandlingServiceProvider);
    service.clearAllErrors();
    ref.invalidateSelf();
  }
}

/// Provider for checking if context has error
@riverpod
AppError? contextError(ContextErrorRef ref, String context) {
  final errorState = ref.watch(errorStateProvider);
  return errorState[context];
}

/// Provider for checking if any errors are active
@riverpod
bool hasAnyErrors(HasAnyErrorsRef ref) {
  final errorState = ref.watch(errorStateProvider);
  return errorState.isNotEmpty;
}
