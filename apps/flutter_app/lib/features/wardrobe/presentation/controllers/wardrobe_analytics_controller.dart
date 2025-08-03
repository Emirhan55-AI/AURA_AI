import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/analytics/models.dart';
import '../widgets/analytics/mock_data.dart';

// Manual providers for analytics data
final wardrobeAnalyticsProvider = FutureProvider<WardrobeAnalyticsData?>((ref) async {
  // Simulate API call delay
  await Future<void>.delayed(const Duration(seconds: 1));
  return MockAnalyticsData.sampleData;
});

final wardrobeInsightsProvider = FutureProvider<List<Insight>>((ref) async {
  await Future<void>.delayed(const Duration(milliseconds: 800));
  return MockAnalyticsData.sampleInsights;
});

final wardrobeShoppingGuidesProvider = FutureProvider<List<ShoppingGuideItem>>((ref) async {
  await Future<void>.delayed(const Duration(milliseconds: 600));
  return MockAnalyticsData.sampleShoppingGuide;
});

// UI state provider
final analyticsUIStateProvider = StateProvider<Map<String, dynamic>>((ref) {
  return {
    'selectedTab': 'statistics',
    'currentTimeRange': TimeRange.allTime,
  };
});

// Helper methods for refreshing data
class AnalyticsHelper {
  static void refreshAnalytics(WidgetRef ref) {
    ref.invalidate(wardrobeAnalyticsProvider);
  }

  static void selectTab(WidgetRef ref, String tabName) {
    final currentState = ref.read(analyticsUIStateProvider);
    ref.read(analyticsUIStateProvider.notifier).state = {
      ...currentState,
      'selectedTab': tabName,
    };
  }

  static void changeTimeRange(WidgetRef ref, TimeRange timeRange) {
    final currentState = ref.read(analyticsUIStateProvider);
    ref.read(analyticsUIStateProvider.notifier).state = {
      ...currentState,
      'currentTimeRange': timeRange,
    };
    
    // Trigger analytics refresh
    ref.invalidate(wardrobeAnalyticsProvider);
  }
}
