import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../lib/src/core/analytics/analytics_service.dart';
import '../../../lib/src/core/analytics/analytics_providers.dart';

void main() {
  group('Analytics Service Tests', () {
    late AnalyticsService analyticsService;

    setUp(() async {
      // Initialize shared preferences mock
      SharedPreferences.setMockInitialValues({});
      analyticsService = AnalyticsService();
    });

    test('should initialize successfully', () async {
      await analyticsService.initialize();
      
      final summary = await analyticsService.getAnalyticsSummary();
      expect(summary, isNotNull);
      expect(summary.totalEvents, greaterThanOrEqualTo(1)); // Should have session start event
    });

    test('should track events correctly', () async {
      await analyticsService.initialize();
      
      await analyticsService.trackEvent('test_event', {
        'parameter1': 'value1',
        'parameter2': 42,
      });
      
      final summary = await analyticsService.getAnalyticsSummary();
      expect(summary.totalEvents, greaterThan(1)); // Session start + test event
    });

    test('should set user properties', () async {
      await analyticsService.initialize();
      
      await analyticsService.setUserProperty('user_level', 'advanced');
      await analyticsService.setUserProperty('user_type', 'premium');
      
      final summary = await analyticsService.getAnalyticsSummary();
      expect(summary.userProperties['user_level'], 'advanced');
      expect(summary.userProperties['user_type'], 'premium');
    });

    test('should track onboarding progress', () async {
      await analyticsService.initialize();
      
      await analyticsService.trackOnboardingProgress('welcome_screen', {
        'screen_time': 5.2,
      });
      
      await analyticsService.trackOnboardingProgress('style_preferences', {
        'selections': ['casual', 'formal'],
      });
      
      final summary = await analyticsService.getAnalyticsSummary();
      expect(summary.totalEvents, greaterThan(2));
    });

    test('should track wardrobe actions', () async {
      await analyticsService.initialize();
      
      await analyticsService.trackWardrobeAction('add_item', {
        'category': 'tops',
        'color': 'blue',
        'brand': 'sample_brand',
      });
      
      await analyticsService.trackWardrobeAction('delete_item', {
        'item_id': 'item_123',
      });
      
      final summary = await analyticsService.getAnalyticsSummary();
      expect(summary.totalEvents, greaterThan(2));
    });

    test('should track outfit creation', () async {
      await analyticsService.initialize();
      
      await analyticsService.trackOutfitCreation({
        'items': ['item1', 'item2', 'item3'],
        'category': 'casual',
        'style': 'bohemian',
        'season': 'spring',
      });
      
      final summary = await analyticsService.getAnalyticsSummary();
      expect(summary.totalEvents, greaterThan(1));
    });

    test('should export analytics data', () async {
      await analyticsService.initialize();
      
      // Add some test data
      await analyticsService.trackEvent('test_export_event');
      await analyticsService.setUserProperty('test_property', 'test_value');
      
      final exportData = await analyticsService.exportAnalyticsData();
      
      expect(exportData, isNotNull);
      expect(exportData['events'], isA<List>());
      expect(exportData['user_properties'], isA<Map>());
      expect(exportData['total_events'], isA<int>());
      expect(exportData['export_timestamp'], isA<String>());
    });

    test('should clear analytics data', () async {
      await analyticsService.initialize();
      
      // Add some test data
      await analyticsService.trackEvent('test_clear_event');
      await analyticsService.setUserProperty('test_property', 'test_value');
      
      // Verify data exists
      var summary = await analyticsService.getAnalyticsSummary();
      expect(summary.totalEvents, greaterThan(1));
      expect(summary.userProperties.isNotEmpty, true);
      
      // Clear data
      await analyticsService.clearAnalyticsData();
      
      // Verify data is cleared
      summary = await analyticsService.getAnalyticsSummary();
      expect(summary.totalEvents, 0);
      expect(summary.userProperties.isEmpty, true);
    });

    test('should generate analytics summary correctly', () async {
      await analyticsService.initialize();
      
      // Add various events
      await analyticsService.trackEvent('event1');
      await analyticsService.trackEvent('event2');
      await analyticsService.trackEvent('event1'); // Duplicate type
      
      final summary = await analyticsService.getAnalyticsSummary();
      
      expect(summary.totalEvents, greaterThanOrEqualTo(4)); // session_start + 3 events
      expect(summary.uniqueEventTypes, greaterThanOrEqualTo(3)); // session_start, event1, event2
      expect(summary.sessionCount, greaterThanOrEqualTo(1));
      expect(summary.lastEventTime, isNotNull);
    });
  });

  group('Analytics Providers Tests', () {
    test('should provide analytics service', () {
      final container = ProviderContainer();
      
      final analyticsService = container.read(analyticsServiceProvider);
      
      expect(analyticsService, isA<AnalyticsService>());
      
      container.dispose();
    });

    test('should manage analytics state correctly', () async {
      final container = ProviderContainer();
      
      final controller = container.read(analyticsControllerProvider.notifier);
      var state = container.read(analyticsControllerProvider);
      
      // Initial state
      expect(state.isInitialized, false);
      expect(state.isLoading, false);
      expect(state.error, isNull);
      
      // Initialize
      await controller.initialize();
      state = container.read(analyticsControllerProvider);
      
      expect(state.isInitialized, true);
      expect(state.isLoading, false);
      
      container.dispose();
    });
  });
}
