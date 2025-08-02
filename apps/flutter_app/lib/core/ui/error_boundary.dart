import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A comprehensive error boundary widget that catches and handles Flutter errors
/// providing a user-friendly interface and optional error reporting
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error, StackTrace? stackTrace)? errorBuilder;
  final void Function(Object error, StackTrace? stackTrace)? onError;
  final bool enableInProduction;
  final String? errorReportEmail;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
    this.onError,
    this.enableInProduction = false,
    this.errorReportEmail,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    
    // Set up global error handling
    if (widget.enableInProduction || kDebugMode) {
      FlutterError.onError = _handleFlutterError;
      
      // Handle errors in async contexts
      PlatformDispatcher.instance.onError = _handlePlatformError;
    }
  }

  void _handleFlutterError(FlutterErrorDetails details) {
    // Log the error
    FlutterError.presentError(details);
    
    // Update state to show error UI
    if (mounted) {
      setState(() {
        _error = details.exception;
        _stackTrace = details.stack;
        _hasError = true;
      });
    }

    // Call custom error handler
    widget.onError?.call(details.exception, details.stack);
  }

  bool _handlePlatformError(Object error, StackTrace stackTrace) {
    // Update state to show error UI
    if (mounted) {
      setState(() {
        _error = error;
        _stackTrace = stackTrace;
        _hasError = true;
      });
    }

    // Call custom error handler
    widget.onError?.call(error, stackTrace);
    
    return true; // Indicates error was handled
  }

  void _resetError() {
    setState(() {
      _error = null;
      _stackTrace = null;
      _hasError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      // Use custom error builder if provided
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(_error!, _stackTrace);
      }
      
      // Default error UI
      return _DefaultErrorView(
        error: _error!,
        stackTrace: _stackTrace,
        onRetry: _resetError,
        onReportError: widget.errorReportEmail != null ? _reportError : null,
      );
    }

    // Wrap child with error handling
    return _ErrorBoundaryWrapper(
      onError: (error, stackTrace) {
        setState(() {
          _error = error;
          _stackTrace = stackTrace;
          _hasError = true;
        });
        widget.onError?.call(error, stackTrace);
      },
      child: widget.child,
    );
  }

  void _reportError() {
    if (widget.errorReportEmail != null && _error != null) {
      // Create error report
      final errorReport = _createErrorReport();
      
      // TODO: Implement email sending or error reporting service
      debugPrint('Error Report:\n$errorReport');
      
      // Show confirmation to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error report generated. Check console for details.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  String _createErrorReport() {
    final buffer = StringBuffer();
    buffer.writeln('Aura App Error Report');
    buffer.writeln('Generated: ${DateTime.now().toIso8601String()}');
    buffer.writeln('');
    buffer.writeln('Error: $_error');
    buffer.writeln('');
    if (_stackTrace != null) {
      buffer.writeln('Stack Trace:');
      buffer.writeln(_stackTrace.toString());
    }
    buffer.writeln('');
    buffer.writeln('Device Info:');
    buffer.writeln('Platform: ${Theme.of(context).platform}');
    buffer.writeln('Debug Mode: $kDebugMode');
    
    return buffer.toString();
  }
}

/// Wrapper widget that catches errors from its child widget tree
class _ErrorBoundaryWrapper extends StatefulWidget {
  final Widget child;
  final void Function(Object error, StackTrace stackTrace) onError;

  const _ErrorBoundaryWrapper({
    required this.child,
    required this.onError,
  });

  @override
  State<_ErrorBoundaryWrapper> createState() => _ErrorBoundaryWrapperState();
}

class _ErrorBoundaryWrapperState extends State<_ErrorBoundaryWrapper> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Override error handling for this widget tree
    ErrorWidget.builder = (FlutterErrorDetails details) {
      widget.onError(details.exception, details.stack ?? StackTrace.current);
      return const SizedBox.shrink(); // Return empty widget
    };
  }
}

/// Default error view displayed when an error occurs
class _DefaultErrorView extends StatelessWidget {
  final Object error;
  final StackTrace? stackTrace;
  final VoidCallback onRetry;
  final VoidCallback? onReportError;

  const _DefaultErrorView({
    required this.error,
    required this.stackTrace,
    required this.onRetry,
    this.onReportError,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDebugMode = kDebugMode;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 40,
                  color: theme.colorScheme.error,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Error Title
              Text(
                'Something went wrong',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 12),
              
              // Error Message
              Text(
                isDebugMode
                    ? 'An unexpected error occurred:\n${error.toString()}'
                    : 'An unexpected error occurred. Please try again.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              
              // Stack trace in debug mode
              if (isDebugMode && stackTrace != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Stack Trace (Debug Mode):',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 150,
                        child: SingleChildScrollView(
                          child: Text(
                            stackTrace.toString(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 32),
              
              // Action Buttons
              Row(
                children: [
                  if (onReportError != null) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onReportError,
                        icon: const Icon(Icons.bug_report_outlined),
                        label: const Text('Report Issue'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Additional Help Text
              Text(
                'If this problem persists, please contact support.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Extension to make it easier to wrap widgets with error boundary
extension ErrorBoundaryExtension on Widget {
  Widget withErrorBoundary({
    Widget Function(Object error, StackTrace? stackTrace)? errorBuilder,
    void Function(Object error, StackTrace? stackTrace)? onError,
    bool enableInProduction = false,
    String? errorReportEmail,
  }) {
    return ErrorBoundary(
      errorBuilder: errorBuilder,
      onError: onError,
      enableInProduction: enableInProduction,
      errorReportEmail: errorReportEmail,
      child: this,
    );
  }
}
