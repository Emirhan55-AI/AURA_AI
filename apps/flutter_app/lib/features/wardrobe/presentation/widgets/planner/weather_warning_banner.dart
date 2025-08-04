import 'package:flutter/material.dart';

/// A widget to display weather warnings/alerts
/// Shows a warning icon and message with distinct styling
class WeatherWarningBanner extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color? color;
  final VoidCallback? onDismiss;

  const WeatherWarningBanner({
    super.key,
    required this.message,
    this.icon = Icons.warning_amber,
    this.color,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final warningColor = color ?? Colors.orange;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: warningColor.withOpacity(0.1),
        border: Border.all(
          color: warningColor.withOpacity(0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: warningColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: 8),
            InkWell(
              onTap: onDismiss,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Factory constructor for temperature warning
  factory WeatherWarningBanner.temperature({
    required int temperature,
    required String unit,
    VoidCallback? onDismiss,
  }) {
    String message;
    IconData icon;
    Color color;

    if (temperature > 30) {
      message = 'Very hot weather ($temperature$unit). Consider light, breathable fabrics.';
      icon = Icons.wb_sunny;
      color = Colors.red;
    } else if (temperature < 0) {
      message = 'Freezing weather ($temperature$unit). Dress warmly with layers.';
      icon = Icons.ac_unit;
      color = Colors.blue;
    } else if (temperature < 10) {
      message = 'Cold weather ($temperature$unit). Consider warm clothing.';
      icon = Icons.thermostat;
      color = Colors.blue;
    } else {
      message = 'Perfect weather ($temperature$unit) for most outfits.';
      icon = Icons.check_circle_outline;
      color = Colors.green;
    }

    return WeatherWarningBanner(
      message: message,
      icon: icon,
      color: color,
      onDismiss: onDismiss,
    );
  }

  /// Factory constructor for rain warning
  factory WeatherWarningBanner.rain({
    VoidCallback? onDismiss,
  }) {
    return WeatherWarningBanner(
      message: 'Rain expected. Consider waterproof outerwear and avoid delicate fabrics.',
      icon: Icons.umbrella,
      color: Colors.blue,
      onDismiss: onDismiss,
    );
  }

  /// Factory constructor for wind warning
  factory WeatherWarningBanner.wind({
    VoidCallback? onDismiss,
  }) {
    return WeatherWarningBanner(
      message: 'Windy conditions expected. Secure loose clothing and accessories.',
      icon: Icons.air,
      color: Colors.grey,
      onDismiss: onDismiss,
    );
  }
}
