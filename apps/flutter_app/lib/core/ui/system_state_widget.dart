import 'package:flutter/material.dart';

/// A configurable widget for displaying various system states
/// Used throughout the app for consistent presentation of loading, error, and empty states
/// Follows Aura's empathetic design principles with warm, user-friendly messaging
class SystemStateWidget extends StatelessWidget {
  /// Optional title text displayed prominently
  final String? title;
  
  /// Main message explaining the current state
  final String message;
  
  /// Optional path to illustration asset (for future use)
  final String? illustrationPath;
  
  /// Icon to display above the message
  final IconData? icon;
  
  /// Icon color override (uses theme primary color by default)
  final Color? iconColor;
  
  /// Icon size (default: 60)
  final double iconSize;
  
  /// Callback for retry action
  final VoidCallback? onRetry;
  
  /// Text for retry button (default: 'Try Again')
  final String? retryText;
  
  /// Callback for call-to-action button
  final VoidCallback? onCTA;
  
  /// Text for CTA button (default: 'Action')
  final String? ctaText;
  
  /// Whether to show the retry button with loading state
  final bool isRetrying;

  const SystemStateWidget({
    super.key,
    this.title,
    required this.message,
    this.illustrationPath,
    this.icon,
    this.iconColor,
    this.iconSize = 60,
    this.onRetry,
    this.retryText,
    this.onCTA,
    this.ctaText,
    this.isRetrying = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration or Icon
            if (illustrationPath != null)
              Image.asset(
                illustrationPath!,
                height: iconSize + 20,
                width: iconSize + 20,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.error_outline,
                  size: iconSize,
                  color: iconColor ?? colorScheme.error,
                ),
              )
            else if (icon != null)
              Icon(
                icon,
                size: iconSize,
                color: iconColor ?? colorScheme.primary,
              ),
            
            // Title
            if (title != null) ...[
              SizedBox(height: illustrationPath != null || icon != null ? 20 : 0),
              Text(
                title!,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            // Message
            SizedBox(height: title != null ? 12 : (illustrationPath != null || icon != null ? 20 : 0)),
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            // Action Buttons
            if (onRetry != null || onCTA != null) ...[
              const SizedBox(height: 32),
              
              // Retry Button
              if (onRetry != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isRetrying ? null : onRetry,
                    icon: isRetrying
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colorScheme.onPrimary,
                              ),
                            ),
                          )
                        : const Icon(Icons.refresh),
                    label: Text(
                      isRetrying ? 'Retrying...' : (retryText ?? 'Try Again'),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              
              // CTA Button
              if (onCTA != null) ...[
                SizedBox(height: onRetry != null ? 12 : 0),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onCTA,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: Text(ctaText ?? 'Action'),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

/// A simplified version of SystemStateWidget specifically for inline use
/// Useful for smaller spaces where full system state display isn't appropriate
class InlineStateWidget extends StatelessWidget {
  final String message;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onRetry;
  final String? retryText;
  final bool isRetrying;

  const InlineStateWidget({
    super.key,
    required this.message,
    this.icon,
    this.iconColor,
    this.onRetry,
    this.retryText,
    this.isRetrying = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 32,
              color: iconColor ?? colorScheme.primary,
            ),
            const SizedBox(height: 8),
          ],
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: isRetrying ? null : onRetry,
              icon: isRetrying
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh, size: 16),
              label: Text(
                isRetrying ? 'Retrying...' : (retryText ?? 'Try Again'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
