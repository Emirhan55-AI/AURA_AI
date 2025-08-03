import 'package:flutter/material.dart';

/// System State Widget for handling different UI states
/// Used throughout the app to show loading, error, and empty states consistently
class SystemStateWidget extends StatelessWidget {
  final Widget? child;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final SystemStateType type;

  const SystemStateWidget._({
    super.key,
    this.child,
    this.message,
    this.actionLabel,
    this.onAction,
    required this.type,
  });

  /// Creates a loading state widget
  factory SystemStateWidget.loading({
    Key? key,
    String message = 'Loading...',
  }) {
    return SystemStateWidget._(
      key: key,
      message: message,
      type: SystemStateType.loading,
    );
  }

  /// Creates an error state widget
  factory SystemStateWidget.error({
    Key? key,
    String message = 'An error occurred',
    String actionLabel = 'Retry',
    VoidCallback? onAction,
  }) {
    return SystemStateWidget._(
      key: key,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
      type: SystemStateType.error,
    );
  }

  /// Creates an empty state widget
  factory SystemStateWidget.empty({
    Key? key,
    String message = 'No data available',
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return SystemStateWidget._(
      key: key,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
      type: SystemStateType.empty,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    switch (type) {
      case SystemStateType.loading:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        );
        
      case SystemStateType.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                if (message != null)
                  Text(
                    message!,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                if (onAction != null && actionLabel != null) ...[
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: onAction,
                    child: Text(actionLabel!),
                  ),
                ],
              ],
            ),
          ),
        );
        
      case SystemStateType.empty:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                if (message != null)
                  Text(
                    message!,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                if (onAction != null && actionLabel != null) ...[
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: onAction,
                    child: Text(actionLabel!),
                  ),
                ],
              ],
            ),
          ),
        );
    }
  }
}

enum SystemStateType {
  loading,
  error,
  empty,
}
