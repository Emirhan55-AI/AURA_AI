import 'package:flutter/material.dart';
import '../error/app_exception.dart';
import '../error/failure.dart';
import 'system_state_widget.dart';

/// A comprehensive error view component that provides empathetic error handling
/// Designed with Aura's user-friendly approach to error communication
/// Automatically maps different error types to appropriate messaging and actions
class ErrorView extends StatelessWidget {
  /// The error or exception to display
  final Object error;
  
  /// Optional stack trace for debugging
  final StackTrace? stackTrace;
  
  /// Callback for retry action
  final VoidCallback? onRetry;
  
  /// Whether the retry action is currently in progress
  final bool isRetrying;
  
  /// Custom retry button text
  final String? retryText;
  
  /// Callback for alternative action (e.g., "Go Back", "Contact Support")
  final VoidCallback? onAlternativeAction;
  
  /// Text for alternative action button
  final String? alternativeActionText;
  
  /// Whether to show technical details (for debugging)
  final bool showTechnicalDetails;
  
  /// Whether this is displayed in a compact space
  final bool isCompact;

  const ErrorView({
    super.key,
    required this.error,
    this.stackTrace,
    this.onRetry,
    this.isRetrying = false,
    this.retryText,
    this.onAlternativeAction,
    this.alternativeActionText,
    this.showTechnicalDetails = false,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final errorInfo = _getErrorInfo(context);
    
    if (isCompact) {
      return InlineStateWidget(
        message: errorInfo.message,
        icon: errorInfo.icon,
        iconColor: errorInfo.iconColor,
        onRetry: onRetry,
        isRetrying: isRetrying,
        retryText: retryText,
      );
    }

    return SystemStateWidget(
      title: errorInfo.title,
      message: errorInfo.message,
      icon: errorInfo.icon,
      iconColor: errorInfo.iconColor,
      onRetry: onRetry,
      isRetrying: isRetrying,
      retryText: retryText,
      onCTA: onAlternativeAction,
      ctaText: alternativeActionText,
    );
  }

  ErrorInfo _getErrorInfo(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Handle AppException types
    if (error is AppException) {
      final appException = error as AppException;
      return ErrorInfo(
        title: _getExceptionTitle(appException),
        message: appException.message,
        icon: _getExceptionIcon(appException),
        iconColor: _getExceptionColor(appException, colorScheme),
      );
    }

    // Handle Failure types
    if (error is Failure) {
      final failure = error as Failure;
      return ErrorInfo(
        title: _getFailureTitle(failure),
        message: failure.message,
        icon: _getFailureIcon(failure),
        iconColor: _getFailureColor(failure, colorScheme),
      );
    }

    // Handle generic errors
    return ErrorInfo(
      title: 'Something went wrong',
      message: 'We encountered an unexpected issue. Please try again or contact support if the problem persists.',
      icon: Icons.error_outline,
      iconColor: colorScheme.error,
    );
  }

  String _getExceptionTitle(AppException exception) {
    switch (exception.runtimeType) {
      case NetworkException:
        return 'Connection Issue';
      case AuthException:
        return 'Authentication Required';
      case ValidationException:
        return 'Invalid Input';
      case CacheException:
        return 'Storage Issue';
      case ServiceException:
        return 'Service Unavailable';
      default:
        return 'Something went wrong';
    }
  }

  IconData _getExceptionIcon(AppException exception) {
    switch (exception.runtimeType) {
      case NetworkException:
        return Icons.wifi_off_outlined;
      case AuthException:
        return Icons.lock_outline;
      case ValidationException:
        return Icons.info_outline;
      case CacheException:
        return Icons.storage_outlined;
      case ServiceException:
        return Icons.cloud_off_outlined;
      default:
        return Icons.error_outline;
    }
  }

  Color _getExceptionColor(AppException exception, ColorScheme colorScheme) {
    switch (exception.runtimeType) {
      case NetworkException:
        return colorScheme.secondary;
      case AuthException:
        return colorScheme.tertiary;
      case ValidationException:
        return colorScheme.primary;
      case CacheException:
        return colorScheme.secondary;
      case ServiceException:
        return colorScheme.error;
      default:
        return colorScheme.error;
    }
  }

  String _getFailureTitle(Failure failure) {
    switch (failure.runtimeType) {
      case NetworkFailure:
        return 'Connection Issue';
      case AuthFailure:
        return 'Authentication Required';
      case ValidationFailure:
        return 'Invalid Input';
      case CacheFailure:
        return 'Storage Issue';
      case ServiceFailure:
        return 'Service Unavailable';
      case UnknownFailure:
        return 'Unexpected Issue';
      default:
        return 'Something went wrong';
    }
  }

  IconData _getFailureIcon(Failure failure) {
    switch (failure.runtimeType) {
      case NetworkFailure:
        return Icons.wifi_off_outlined;
      case AuthFailure:
        return Icons.lock_outline;
      case ValidationFailure:
        return Icons.info_outline;
      case CacheFailure:
        return Icons.storage_outlined;
      case ServiceFailure:
        return Icons.cloud_off_outlined;
      case UnknownFailure:
        return Icons.help_outline;
      default:
        return Icons.error_outline;
    }
  }

  Color _getFailureColor(Failure failure, ColorScheme colorScheme) {
    switch (failure.runtimeType) {
      case NetworkFailure:
        return colorScheme.secondary;
      case AuthFailure:
        return colorScheme.tertiary;
      case ValidationFailure:
        return colorScheme.primary;
      case CacheFailure:
        return colorScheme.secondary;
      case ServiceFailure:
        return colorScheme.error;
      case UnknownFailure:
        return colorScheme.outline;
      default:
        return colorScheme.error;
    }
  }
}

/// Helper class to hold error display information
class ErrorInfo {
  final String title;
  final String message;
  final IconData icon;
  final Color iconColor;

  const ErrorInfo({
    required this.title,
    required this.message,
    required this.icon,
    required this.iconColor,
  });
}

/// Predefined error views for common scenarios
class CommonErrorViews {
  static ErrorView noInternet({
    VoidCallback? onRetry,
    bool isRetrying = false,
  }) =>
      ErrorView(
        error: NetworkException(
          message: 'Please check your connection and try again.',
        ),
        onRetry: onRetry,
        isRetrying: isRetrying,
        alternativeActionText: 'Settings',
      );

  static ErrorView sessionExpired({
    VoidCallback? onRetry,
    VoidCallback? onLogin,
  }) =>
      ErrorView(
        error: AuthException(
          message: 'Your session has expired. Please sign in again.',
        ),
        onRetry: onRetry,
        onAlternativeAction: onLogin,
        alternativeActionText: 'Sign In',
      );

  static ErrorView serverMaintenance({
    VoidCallback? onRetry,
    bool isRetrying = false,
  }) =>
      ErrorView(
        error: ServiceException(
          message: 'We\'re performing maintenance. Please try again later.',
        ),
        onRetry: onRetry,
        isRetrying: isRetrying,
        retryText: 'Check Again',
      );

  static ErrorView rateLimited({
    VoidCallback? onRetry,
    bool isRetrying = false,
  }) =>
      ErrorView(
        error: ServiceException(
          message: 'You\'re doing that too quickly. Please wait a moment and try again.',
        ),
        onRetry: onRetry,
        isRetrying: isRetrying,
        retryText: 'Try Again',
      );

  static ErrorView notFound({
    VoidCallback? onGoBack,
  }) =>
      ErrorView(
        error: ServiceException(
          message: 'The content you\'re looking for doesn\'t exist or has been moved.',
        ),
        onAlternativeAction: onGoBack,
        alternativeActionText: 'Go Back',
      );

  static ErrorView permissionDenied({
    VoidCallback? onRequestPermission,
    VoidCallback? onGoToSettings,
  }) =>
      ErrorView(
        error: AuthException(
          message: 'We need permission to access this feature. Please grant the required permissions.',
        ),
        onRetry: onRequestPermission,
        retryText: 'Grant Permission',
        onAlternativeAction: onGoToSettings,
        alternativeActionText: 'Settings',
      );
}

/// Error boundary widget that catches and displays errors
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error, StackTrace? stackTrace)? errorBuilder;
  final void Function(Object error, StackTrace? stackTrace)? onError;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
    this.onError,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();
    FlutterError.onError = (FlutterErrorDetails details) {
      if (mounted) {
        setState(() {
          _error = details.exception;
          _stackTrace = details.stack;
        });
        widget.onError?.call(details.exception, details.stack);
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(_error!, _stackTrace) ??
          ErrorView(
            error: _error!,
            stackTrace: _stackTrace,
            onRetry: () {
              setState(() {
                _error = null;
                _stackTrace = null;
              });
            },
          );
    }

    return widget.child;
  }
}
