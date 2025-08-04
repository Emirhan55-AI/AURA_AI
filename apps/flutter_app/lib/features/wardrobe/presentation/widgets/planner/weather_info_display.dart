import 'package:flutter/material.dart';
import 'combination_drag_target.dart';

/// A widget to display weather information for a date
/// Shows an icon representing the weather condition and temperature
class WeatherInfoDisplay extends StatelessWidget {
  final WeatherData weatherData;
  final bool compact;

  const WeatherInfoDisplay({
    super.key,
    required this.weatherData,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(compact ? 8 : 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: compact ? _buildCompactLayout(theme) : _buildFullLayout(theme),
    );
  }

  Widget _buildCompactLayout(ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          weatherData.icon,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          '${weatherData.temperature}${weatherData.temperatureUnit}',
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFullLayout(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          weatherData.icon,
          size: 32,
          color: _getWeatherColor(colorScheme),
        ),
        const SizedBox(height: 8),
        Text(
          '${weatherData.temperature}${weatherData.temperatureUnit}',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          weatherData.description,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Color _getWeatherColor(ColorScheme colorScheme) {
    switch (weatherData.condition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return Colors.orange;
      case 'cloudy':
      case 'overcast':
        return Colors.grey;
      case 'rainy':
      case 'rain':
        return Colors.blue;
      case 'snowy':
      case 'snow':
        return Colors.lightBlue;
      case 'stormy':
      case 'thunderstorm':
        return Colors.deepPurple;
      default:
        return colorScheme.onSurfaceVariant;
    }
  }
}
