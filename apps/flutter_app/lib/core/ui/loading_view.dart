import 'package:flutter/material.dart';

/// A comprehensive loading view component that provides various loading states
/// Designed with Aura's empathetic approach to user feedback
/// Supports different loading types with customizable messages and animations
class LoadingView extends StatelessWidget {
  /// The loading message to display to users
  final String message;
  
  /// Optional subtitle for additional context
  final String? subtitle;
  
  /// Type of loading animation/style
  final LoadingType type;
  
  /// Size of the loading indicator
  final double size;
  
  /// Whether to show a background overlay
  final bool showOverlay;
  
  /// Custom background color for overlay
  final Color? overlayColor;
  
  /// Whether to allow dismissing the loading view by tapping outside
  final bool dismissible;

  const LoadingView({
    super.key,
    this.message = 'Loading...',
    this.subtitle,
    this.type = LoadingType.circular,
    this.size = 40,
    this.showOverlay = false,
    this.overlayColor,
    this.dismissible = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget loadingContent = Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Loading Animation
            _buildLoadingIndicator(context),
            
            // Loading Message
            const SizedBox(height: 24),
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            
            // Subtitle
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );

    if (showOverlay) {
      return Material(
        color: overlayColor ?? colorScheme.surface.withOpacity(0.8),
        child: dismissible
            ? GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: loadingContent,
              )
            : loadingContent,
      );
    }

    return loadingContent;
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    switch (type) {
      case LoadingType.circular:
        return SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
        );
        
      case LoadingType.linear:
        return SizedBox(
          width: size * 2,
          child: LinearProgressIndicator(
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
        );
        
      case LoadingType.dots:
        return SizedBox(
          width: size,
          height: size,
          child: _DotsLoadingIndicator(
            color: colorScheme.primary,
            size: size / 4,
          ),
        );
        
      case LoadingType.pulse:
        return SizedBox(
          width: size,
          height: size,
          child: _PulseLoadingIndicator(
            color: colorScheme.primary,
            size: size,
          ),
        );
    }
  }
}

/// Predefined loading views for common scenarios with empathetic messaging
class CommonLoadingViews {
  static const LoadingView initializing = LoadingView(
    message: 'Setting things up for you...',
    subtitle: 'This will just take a moment',
    type: LoadingType.pulse,
  );

  static const LoadingView authenticating = LoadingView(
    message: 'Signing you in...',
    subtitle: 'Verifying your credentials',
    type: LoadingType.circular,
  );

  static const LoadingView syncing = LoadingView(
    message: 'Syncing your data...',
    subtitle: 'Making sure everything is up to date',
    type: LoadingType.dots,
  );

  static const LoadingView processing = LoadingView(
    message: 'Processing your request...',
    subtitle: 'We\'re working on it',
    type: LoadingType.linear,
  );

  static const LoadingView uploading = LoadingView(
    message: 'Uploading files...',
    subtitle: 'Please keep the app open',
    type: LoadingType.linear,
  );

  static const LoadingView downloading = LoadingView(
    message: 'Downloading content...',
    subtitle: 'This may take a few moments',
    type: LoadingType.linear,
  );
}

/// Types of loading animations available
enum LoadingType {
  circular,
  linear,
  dots,
  pulse,
}

/// Custom dots loading animation
class _DotsLoadingIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const _DotsLoadingIndicator({
    required this.color,
    required this.size,
  });

  @override
  State<_DotsLoadingIndicator> createState() => _DotsLoadingIndicatorState();
}

class _DotsLoadingIndicatorState extends State<_DotsLoadingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );

    _animations = _controllers
        .map((controller) => Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: controller,
                curve: Curves.easeInOut,
              ),
            ))
        .toList();

    _startAnimations();
  }

  void _startAnimations() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: widget.size * 0.2),
              child: Opacity(
                opacity: 0.3 + (_animations[index].value * 0.7),
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

/// Custom pulse loading animation
class _PulseLoadingIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const _PulseLoadingIndicator({
    required this.color,
    required this.size,
  });

  @override
  State<_PulseLoadingIndicator> createState() => _PulseLoadingIndicatorState();
}

class _PulseLoadingIndicatorState extends State<_PulseLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}
