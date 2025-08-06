import 'package:flutter/material.dart';
import '../../../domain/models/planned_outfit.dart';

class WeatherWidget extends StatelessWidget {
  final WeatherData weather;

  const WeatherWidget({
    super.key,
    required this.weather,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Weather icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getWeatherColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getWeatherIcon(),
                color: _getWeatherColor(),
                size: 24,
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Weather info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${weather.temperature}°C',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    weather.description.isNotEmpty 
                        ? weather.description
                        : _getConditionDescription(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            
            // Additional info
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.water_drop,
                      size: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${weather.humidity}%',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _getOutfitSuggestion(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getWeatherIcon() {
    switch (weather.condition) {
      case WeatherCondition.sunny:
        return Icons.wb_sunny;
      case WeatherCondition.cloudy:
        return Icons.cloud;
      case WeatherCondition.rainy:
        return Icons.umbrella;
      case WeatherCondition.snowy:
        return Icons.ac_unit;
      case WeatherCondition.windy:
        return Icons.air;
      case WeatherCondition.stormy:
        return Icons.flash_on;
      case WeatherCondition.foggy:
        return Icons.foggy;
      case WeatherCondition.partlyCloudyDay:
        return Icons.wb_cloudy;
      case WeatherCondition.partlyCloudyNight:
        return Icons.nights_stay;
      case WeatherCondition.clearNight:
        return Icons.brightness_2;
    }
  }

  Color _getWeatherColor() {
    switch (weather.condition) {
      case WeatherCondition.sunny:
        return Colors.orange;
      case WeatherCondition.cloudy:
      case WeatherCondition.partlyCloudyDay:
        return Colors.grey;
      case WeatherCondition.rainy:
        return Colors.blue;
      case WeatherCondition.snowy:
        return Colors.lightBlue;
      case WeatherCondition.windy:
        return Colors.teal;
      case WeatherCondition.stormy:
        return Colors.deepPurple;
      case WeatherCondition.foggy:
        return Colors.blueGrey;
      case WeatherCondition.partlyCloudyNight:
      case WeatherCondition.clearNight:
        return Colors.indigo;
    }
  }

  String _getConditionDescription() {
    switch (weather.condition) {
      case WeatherCondition.sunny:
        return 'Sunny';
      case WeatherCondition.cloudy:
        return 'Cloudy';
      case WeatherCondition.rainy:
        return 'Rainy';
      case WeatherCondition.snowy:
        return 'Snowy';
      case WeatherCondition.windy:
        return 'Windy';
      case WeatherCondition.stormy:
        return 'Stormy';
      case WeatherCondition.foggy:
        return 'Foggy';
      case WeatherCondition.partlyCloudyDay:
        return 'Partly Cloudy';
      case WeatherCondition.partlyCloudyNight:
        return 'Partly Cloudy';
      case WeatherCondition.clearNight:
        return 'Clear Night';
    }
  }

  String _getOutfitSuggestion() {
    if (weather.temperature >= 25) {
      return 'Light clothing';
    } else if (weather.temperature >= 15) {
      return 'Moderate layers';
    } else if (weather.temperature >= 5) {
      return 'Warm clothing';
    } else {
      return 'Heavy layers';
    }
  }
}
