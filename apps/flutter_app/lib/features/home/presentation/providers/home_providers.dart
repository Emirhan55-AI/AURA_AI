import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/dashboard_data.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';

/// Home Dashboard Provider for managing dashboard state
/// Provides dashboard data including weather, stats, suggestions, and activities
final homeControllerProvider = FutureProvider<DashboardData>((ref) async {
  // Get authenticated user
  final authState = ref.watch(authControllerProvider);
  final user = authState.asData?.value;
  
  // Simulate loading data from various sources
  await Future<void>.delayed(const Duration(milliseconds: 800));
  
  return DashboardData(
    userName: _getUserName(user),
    weather: _getMockWeatherData(),
    stats: _getMockStatsData(),
    suggestions: _getMockSuggestions(),
    activities: _getMockRecentActivities(),
  );
});

/// Dashboard refresh provider for triggering data refresh
final dashboardRefreshProvider = Provider<void Function()>((ref) {
  return () {
    ref.invalidate(homeControllerProvider);
  };
});

/// Get user display name safely
String _getUserName(dynamic user) {
  if (user?.displayName != null) return user!.displayName! as String;
  if (user?.email != null) return (user!.email! as String).split('@')[0];
  return 'Fashionista';
}

/// Mock weather data with realistic variations
WeatherData _getMockWeatherData() {
  final weatherConditions = [
    ('Sunny', 'sunny', 25.0, 45, 8.2),
    ('Partly Cloudy', 'partly_cloudy', 22.5, 65, 12.3),
    ('Cloudy', 'cloudy', 18.0, 75, 15.1),
    ('Rainy', 'rainy', 16.5, 85, 20.4),
  ];
  
  final randomCondition = weatherConditions[DateTime.now().day % weatherConditions.length];
  
  return WeatherData(
    city: 'Istanbul',
    temperature: randomCondition.$3,
    condition: randomCondition.$1,
    icon: randomCondition.$2,
    humidity: randomCondition.$4,
    windSpeed: randomCondition.$5,
  );
}

/// Mock statistics with realistic numbers
QuickStatsData _getMockStatsData() {
  final baseItems = 120 + (DateTime.now().day % 50);
  return QuickStatsData(
    totalItems: baseItems,
    totalOutfits: (baseItems * 0.18).round(),
    favoriteItems: (baseItems * 0.12).round(),
  );
}

/// Mock daily suggestions with variety
List<DailySuggestion> _getMockSuggestions() {
  return [
    DailySuggestion(
      id: '1',
      title: 'Perfect Morning Look',
      description: 'A fresh casual outfit that matches today\'s weather and your schedule',
      imageUrls: [
        'https://images.unsplash.com/photo-1434389677669-e08b4cac3105?w=400&h=600&fit=crop',
        'https://images.unsplash.com/photo-1515372039744-b8f02a3ae446?w=400&h=600&fit=crop',
      ],
      occasion: 'Casual',
      suitabilityScore: 0.95,
    ),
    DailySuggestion(
      id: '2',
      title: 'Business Chic',
      description: 'Professional attire perfect for meetings and networking events',
      imageUrls: [
        'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=400&h=600&fit=crop',
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=600&fit=crop',
      ],
      occasion: 'Business',
      suitabilityScore: 0.92,
    ),
    DailySuggestion(
      id: '3',
      title: 'Evening Elegance',
      description: 'Sophisticated evening wear for dinner dates and social events',
      imageUrls: [
        'https://images.unsplash.com/photo-1469334031218-e382a71b716b?w=400&h=600&fit=crop',
        'https://images.unsplash.com/photo-1583849088932-3f9b3ac367c6?w=400&h=600&fit=crop',
      ],
      occasion: 'Evening',
      suitabilityScore: 0.88,
    ),
  ];
}

/// Mock recent activities with realistic data
List<RecentActivity> _getMockRecentActivities() {
  final now = DateTime.now();
  return [
    RecentActivity(
      id: '1',
      title: 'New Item Added',
      description: 'Navy Blue Blazer added to your wardrobe',
      timestamp: now.subtract(const Duration(hours: 2)),
      type: ActivityType.itemAdded,
      imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop',
    ),
    RecentActivity(
      id: '2',
      title: 'Outfit Created',
      description: 'Business Casual look for tomorrow\'s meeting',
      timestamp: now.subtract(const Duration(hours: 6)),
      type: ActivityType.outfitCreated,
      imageUrl: 'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=200&h=200&fit=crop',
    ),
    RecentActivity(
      id: '3',
      title: 'Style Shared',
      description: 'Shared your weekend outfit with the community',
      timestamp: now.subtract(const Duration(days: 1)),
      type: ActivityType.styleShared,
      imageUrl: 'https://images.unsplash.com/photo-1434389677669-e08b4cac3105?w=200&h=200&fit=crop',
    ),
    RecentActivity(
      id: '4',
      title: 'Item Favorited',
      description: 'Added Summer Dress to favorites',
      timestamp: now.subtract(const Duration(days: 2)),
      type: ActivityType.itemFavorited,
      imageUrl: 'https://images.unsplash.com/photo-1515372039744-b8f02a3ae446?w=200&h=200&fit=crop',
    ),
    RecentActivity(
      id: '5',
      title: 'Outfit Worn',
      description: 'Wore your Casual Friday look',
      timestamp: now.subtract(const Duration(days: 3)),
      type: ActivityType.outfitWorn,
      imageUrl: 'https://images.unsplash.com/photo-1469334031218-e382a71b716b?w=200&h=200&fit=crop',
    ),
  ];
}
