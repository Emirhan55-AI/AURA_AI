import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Aura Score Display Widget - Shows user's Aura Score with level and progress
/// 
/// Displays:
/// - Current Aura Score with animated counter
/// - Current level badge
/// - Progress bar towards next level
/// - Next level preview
class AuraScoreDisplay extends StatefulWidget {
  final int score;
  final String level;
  final double progress; // 0.0 to 1.0

  const AuraScoreDisplay({
    super.key,
    required this.score,
    required this.level,
    required this.progress,
  });

  @override
  State<AuraScoreDisplay> createState() => _AuraScoreDisplayState();
}

class _AuraScoreDisplayState extends State<AuraScoreDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  late Animation<int> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scoreAnimation = IntTween(
      begin: 0,
      end: widget.score,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withOpacity(0.3),
            colorScheme.secondaryContainer.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Title and info icon
          _buildHeader(theme, colorScheme),
          const SizedBox(height: 20),

          // Score display with circular progress
          _buildScoreDisplay(theme, colorScheme),
          const SizedBox(height: 24),

          // Level badge and next level info
          _buildLevelInfo(theme, colorScheme),
          const SizedBox(height: 20),

          // Progress bar
          _buildProgressBar(theme, colorScheme),
        ],
      ),
    );
  }

  /// Builds the header with title and info icon
  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Aura Score',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
            fontFamily: 'Urbanist',
          ),
        ),
        IconButton(
          onPressed: () {
            _showAuraScoreInfo(context, theme, colorScheme);
          },
          icon: Icon(
            Icons.info_outline,
            color: colorScheme.onSurfaceVariant,
            size: 20,
          ),
          style: IconButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(24, 24),
          ),
        ),
      ],
    );
  }

  /// Builds the main score display with circular progress
  Widget _buildScoreDisplay(ThemeData theme, ColorScheme colorScheme) {
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
          ),

          // Animated circular progress
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return CustomPaint(
                size: const Size(160, 160),
                painter: _CircularProgressPainter(
                  progress: _progressAnimation.value,
                  primaryColor: colorScheme.primary,
                  secondaryColor: colorScheme.secondary,
                  backgroundColor: colorScheme.outline.withOpacity(0.2),
                ),
              );
            },
          ),

          // Score text in center
          AnimatedBuilder(
            animation: _scoreAnimation,
            builder: (context, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_scoreAnimation.value}',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                      fontFamily: 'Urbanist',
                    ),
                  ),
                  Text(
                    'Points',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// Builds the level badge and next level info
  Widget _buildLevelInfo(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        // Current level badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary,
                colorScheme.secondary,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome,
                color: colorScheme.onPrimary,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                widget.level,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Next level info
        Text(
          '${((1 - widget.progress) * 1000).round()} points to Style Guru',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Builds the progress bar towards next level
  Widget _buildProgressBar(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress to next level',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(widget.progress * 100).round()}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Animated progress bar
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return Container(
              height: 8,
              decoration: BoxDecoration(
                color: colorScheme.outline.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _progressAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Shows info dialog about Aura Score
  void _showAuraScoreInfo(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text(
          'About Aura Score',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        content: Text(
          'Your Aura Score reflects your style journey and community engagement. Earn points by:\n\n'
          '• Creating outfit combinations\n'
          '• Sharing your style\n'
          '• Engaging with the community\n'
          '• Completing style challenges\n\n'
          'Higher scores unlock exclusive features and recognition!',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Got it',
              style: TextStyle(color: colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for circular progress indicator
class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;

  _CircularProgressPainter({
    required this.progress,
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..shader = LinearGradient(
          colors: [primaryColor, secondaryColor],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..strokeWidth = 8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      const startAngle = -math.pi / 2; // Start from top
      final sweepAngle = 2 * math.pi * progress;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
