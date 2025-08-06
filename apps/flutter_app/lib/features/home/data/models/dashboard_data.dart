/// Dashboard data models for home screen
class DashboardData {
  final String userName;
  final WeatherData weather;
  final QuickStatsData stats;
  final List<DailySuggestion> suggestions;
  final List<RecentActivity> activities;

  const DashboardData({
    required this.userName,
    required this.weather,
    required this.stats,
    required this.suggestions,
    required this.activities,
  });
}

/// Weather information for outfit suggestions
class WeatherData {
  final String city;
  final double temperature;
  final String condition;
  final String icon;
  final int humidity;
  final double windSpeed;

  const WeatherData({
    required this.city,
    required this.temperature,
    required this.condition,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
  });

  String get temperatureDisplay => '${temperature.round()}°C';
  String get windSpeedDisplay => '${windSpeed.toStringAsFixed(1)} km/h';
  String get humidityDisplay => '$humidity%';
}

/// Quick statistics about user's wardrobe
class QuickStatsData {
  final int totalItems;
  final int totalOutfits;
  final int favoriteItems;

  const QuickStatsData({
    required this.totalItems,
    required this.totalOutfits,
    required this.favoriteItems,
  });
}

/// Daily outfit suggestion
class DailySuggestion {
  final String id;
  final String title;
  final String description;
  final List<String> imageUrls;
  final String occasion;
  final double suitabilityScore;

  const DailySuggestion({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrls,
    required this.occasion,
    required this.suitabilityScore,
  });
}

/// Recent activity in the app
class RecentActivity {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final ActivityType type;
  final String? imageUrl;

  const RecentActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.type,
    this.imageUrl,
  });
}

/// Types of activities
enum ActivityType {
  outfitCreated,
  itemAdded,
  outfitWorn,
  itemFavorited,
  styleShared,
}

extension ActivityTypeExtension on ActivityType {
  String get displayName {
    switch (this) {
      case ActivityType.outfitCreated:
        return 'Outfit Created';
      case ActivityType.itemAdded:
        return 'Item Added';
      case ActivityType.outfitWorn:
        return 'Outfit Worn';
      case ActivityType.itemFavorited:
        return 'Item Favorited';
      case ActivityType.styleShared:
        return 'Style Shared';
    }
  }

  String get icon {
    switch (this) {
      case ActivityType.outfitCreated:
        return '👕';
      case ActivityType.itemAdded:
        return '➕';
      case ActivityType.outfitWorn:
        return '✨';
      case ActivityType.itemFavorited:
        return '❤️';
      case ActivityType.styleShared:
        return '📤';
    }
  }
}
