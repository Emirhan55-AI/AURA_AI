import 'package:flutter_test/flutter_test.dart';

/// Analytics and monitoring tests
/// These tests verify event tracking, performance monitoring, and business metrics
void main() {
  group('Analytics Tests', () {
    group('Event Tracking', () {
      test('should track user interactions correctly', () {
        final analytics = MockAnalytics();
        
        // Track different types of events
        analytics.trackEvent('wardrobe_item_added', {
          'category': 'tops',
          'brand': 'Nike',
          'price': 29.99,
        });
        
        analytics.trackEvent('outfit_created', {
          'items_count': 3,
          'occasion': 'work',
        });
        
        analytics.trackEvent('search_performed', {
          'query': 'blue shirt',
          'results_count': 5,
        });

        // Verify events were tracked
        expect(analytics.getTrackedEvents(), hasLength(3));
        
        final addItemEvent = analytics.getTrackedEvents()[0];
        expect(addItemEvent.name, equals('wardrobe_item_added'));
        expect(addItemEvent.properties['category'], equals('tops'));
        expect(addItemEvent.properties['brand'], equals('Nike'));
      });

      test('should track user journey and funnel metrics', () {
        final analytics = MockAnalytics();
        
        // Simulate user journey
        analytics.trackEvent('app_opened', {});
        analytics.trackEvent('onboarding_started', {});
        analytics.trackEvent('onboarding_step_completed', {'step': 1});
        analytics.trackEvent('onboarding_step_completed', {'step': 2});
        analytics.trackEvent('onboarding_completed', {});
        analytics.trackEvent('first_item_added', {});

        // Calculate funnel metrics
        final funnelMetrics = analytics.calculateFunnelMetrics([
          'app_opened',
          'onboarding_started', 
          'onboarding_completed',
          'first_item_added',
        ]);

        expect(funnelMetrics['app_opened'], equals(1));
        expect(funnelMetrics['onboarding_started'], equals(1));
        expect(funnelMetrics['onboarding_completed'], equals(1));
        expect(funnelMetrics['first_item_added'], equals(1));
        
        // Conversion rates should be 100% for this test
        final appOpened = funnelMetrics['app_opened'] ?? 0;
        final onboardingStarted = funnelMetrics['onboarding_started'] ?? 0;
        if (appOpened > 0) {
          expect(onboardingStarted / appOpened, equals(1.0));
        }
      });

      test('should track error events with context', () {
        final analytics = MockAnalytics();
        
        // Track different types of errors
        analytics.trackError('network_error', {
          'endpoint': '/api/wardrobe/items',
          'status_code': 500,
          'error_message': 'Internal Server Error',
          'retry_count': 2,
        });
        
        analytics.trackError('validation_error', {
          'field': 'email',
          'error_type': 'invalid_format',
          'user_input': 'invalid-email',
        });

        final errorEvents = analytics.getErrorEvents();
        expect(errorEvents, hasLength(2));
        
        final networkError = errorEvents[0];
        expect(networkError.name, equals('network_error'));
        expect(networkError.properties['status_code'], equals(500));
      });
    });

    group('Performance Monitoring', () {
      test('should track app performance metrics', () {
        final performanceMonitor = MockPerformanceMonitor();
        
        // Track different performance metrics
        performanceMonitor.trackAppStartTime(Duration(milliseconds: 1500));
        performanceMonitor.trackScreenLoadTime('wardrobe_screen', Duration(milliseconds: 800));
        performanceMonitor.trackScreenLoadTime('outfit_screen', Duration(milliseconds: 1200));
        performanceMonitor.trackApiResponseTime('/api/wardrobe/items', Duration(milliseconds: 300));
        performanceMonitor.trackApiResponseTime('/api/outfits', Duration(milliseconds: 450));

        // Get performance metrics
        final metrics = performanceMonitor.getMetrics();
        
        expect(metrics.appStartTime.inMilliseconds, equals(1500));
        expect(metrics.averageScreenLoadTime.inMilliseconds, equals(1000)); // (800 + 1200) / 2
        expect(metrics.averageApiResponseTime.inMilliseconds, equals(375)); // (300 + 450) / 2
      });

      test('should detect performance issues', () {
        final performanceMonitor = MockPerformanceMonitor();
        
        // Track slow operations
        performanceMonitor.trackScreenLoadTime('slow_screen', Duration(milliseconds: 5000));
        performanceMonitor.trackApiResponseTime('/api/slow-endpoint', Duration(milliseconds: 3000));
        
        final issues = performanceMonitor.detectPerformanceIssues();
        
        expect(issues, hasLength(2));
        expect(issues[0].type, equals('slow_screen_load'));
        expect(issues[1].type, equals('slow_api_response'));
      });

      test('should track memory usage patterns', () {
        final performanceMonitor = MockPerformanceMonitor();
        
        // Simulate memory usage over time
        performanceMonitor.trackMemoryUsage(50.5); // 50.5 MB
        performanceMonitor.trackMemoryUsage(75.2); // 75.2 MB
        performanceMonitor.trackMemoryUsage(45.8); // 45.8 MB
        performanceMonitor.trackMemoryUsage(120.0); // 120.0 MB - potential memory leak
        
        final memoryMetrics = performanceMonitor.getMemoryMetrics();
        
        expect(memoryMetrics.peakUsage, equals(120.0));
        expect(memoryMetrics.averageUsage, equals(72.875)); // (50.5 + 75.2 + 45.8 + 120.0) / 4
        expect(memoryMetrics.hasMemoryWarning, isTrue); // > 100MB threshold
      });
    });

    group('Business Metrics', () {
      test('should calculate user engagement metrics', () {
        final businessMetrics = MockBusinessMetrics();
        
        // Track user sessions
        businessMetrics.trackUserSession('user1', Duration(minutes: 15));
        businessMetrics.trackUserSession('user1', Duration(minutes: 22));
        businessMetrics.trackUserSession('user2', Duration(minutes: 8));
        businessMetrics.trackUserSession('user2', Duration(minutes: 35));
        
        // Track feature usage
        businessMetrics.trackFeatureUsage('user1', 'wardrobe_add_item');
        businessMetrics.trackFeatureUsage('user1', 'outfit_creation');
        businessMetrics.trackFeatureUsage('user2', 'wardrobe_add_item');
        
        final metrics = businessMetrics.calculateEngagementMetrics();
        
        expect(metrics.averageSessionDuration.inMinutes, equals(20)); // (15+22+8+35)/4
        expect(metrics.totalActiveUsers, equals(2));
        expect(metrics.featuresUsedPerUser, equals(1.5)); // 3 features / 2 users
      });

      test('should track wardrobe-specific metrics', () {
        final businessMetrics = MockBusinessMetrics();
        
        // Track wardrobe activities
        businessMetrics.trackWardrobeActivity('user1', 'item_added', {'category': 'tops'});
        businessMetrics.trackWardrobeActivity('user1', 'item_added', {'category': 'bottoms'});
        businessMetrics.trackWardrobeActivity('user1', 'outfit_created', {'items_count': 3});
        businessMetrics.trackWardrobeActivity('user2', 'item_added', {'category': 'shoes'});
        
        final wardrobeMetrics = businessMetrics.getWardrobeMetrics();
        
        expect(wardrobeMetrics.totalItemsAdded, equals(3));
        expect(wardrobeMetrics.totalOutfitsCreated, equals(1));
        expect(wardrobeMetrics.mostPopularCategory, equals('tops')); // Assuming equal weight
      });

      test('should calculate retention metrics', () {
        final businessMetrics = MockBusinessMetrics();
        final today = DateTime.now();
        
        // Track user activity over days
        businessMetrics.trackDailyActiveUser('user1', today);
        businessMetrics.trackDailyActiveUser('user1', today.subtract(Duration(days: 1)));
        businessMetrics.trackDailyActiveUser('user1', today.subtract(Duration(days: 7)));
        
        businessMetrics.trackDailyActiveUser('user2', today);
        businessMetrics.trackDailyActiveUser('user2', today.subtract(Duration(days: 1)));
        
        businessMetrics.trackDailyActiveUser('user3', today.subtract(Duration(days: 7)));
        
        final retentionMetrics = businessMetrics.calculateRetentionMetrics();
        
        // Day 1 retention: users active today and yesterday
        expect(retentionMetrics.day1Retention, equals(2.0/3.0)); // 2 out of 3 users
        
        // Day 7 retention: users active today and 7 days ago
        expect(retentionMetrics.day7Retention, equals(1.0/2.0)); // 1 out of 2 users
      });
    });

    group('A/B Testing', () {
      test('should assign users to test variants', () {
        final abTesting = MockABTesting();
        
        // Create A/B test
        abTesting.createTest('onboarding_flow_v2', ['control', 'variant_a', 'variant_b'], [33, 33, 34]);
        
        // Assign users to variants
        final user1Variant = abTesting.assignUserToVariant('user1', 'onboarding_flow_v2');
        final user2Variant = abTesting.assignUserToVariant('user2', 'onboarding_flow_v2');
        final user3Variant = abTesting.assignUserToVariant('user3', 'onboarding_flow_v2');
        
        // Verify variants are assigned
        expect(['control', 'variant_a', 'variant_b'], contains(user1Variant));
        expect(['control', 'variant_a', 'variant_b'], contains(user2Variant));
        expect(['control', 'variant_a', 'variant_b'], contains(user3Variant));
        
        // Same user should get same variant
        final user1VariantAgain = abTesting.assignUserToVariant('user1', 'onboarding_flow_v2');
        expect(user1VariantAgain, equals(user1Variant));
      });

      test('should track conversion metrics per variant', () {
        final abTesting = MockABTesting();
        
        abTesting.createTest('add_item_button_color', ['blue', 'green'], [50, 50]);
        
        // Track conversions
        abTesting.trackConversion('user1', 'add_item_button_color', 'blue', 'item_added');
        abTesting.trackConversion('user2', 'add_item_button_color', 'blue', 'item_added');
        abTesting.trackConversion('user3', 'add_item_button_color', 'green', 'item_added');
        abTesting.trackConversion('user4', 'add_item_button_color', 'green', 'no_action');
        
        final results = abTesting.getTestResults('add_item_button_color');
        
        expect(results['blue']!['conversions'], equals(2));
        expect(results['green']!['conversions'], equals(1));
        expect(results['blue']!['total_users'], equals(2));
        expect(results['green']!['total_users'], equals(2));
      });
    });

    group('Real User Monitoring (RUM)', () {
      test('should collect real user metrics', () {
        final rum = MockRealUserMonitoring();
        
        // Track real user interactions
        rum.trackPageView('/wardrobe', Duration(milliseconds: 1200));
        rum.trackPageView('/outfits', Duration(milliseconds: 800));
        rum.trackUserInteraction('button_click', 'add_item_button', Duration(milliseconds: 150));
        rum.trackUserInteraction('scroll', 'wardrobe_list', Duration(milliseconds: 50));
        
        final metrics = rum.getRealUserMetrics();
        
        expect(metrics.averagePageLoadTime.inMilliseconds, equals(1000)); // (1200 + 800) / 2
        expect(metrics.averageInteractionTime.inMilliseconds, equals(100)); // (150 + 50) / 2
        expect(metrics.totalPageViews, equals(2));
        expect(metrics.totalInteractions, equals(2));
      });

      test('should detect user experience issues', () {
        final rum = MockRealUserMonitoring();
        
        // Simulate poor user experience
        rum.trackPageView('/slow-page', Duration(milliseconds: 8000)); // Very slow
        rum.trackUserInteraction('button_click', 'unresponsive_button', Duration(milliseconds: 2000)); // Laggy
        rum.trackError('javascript_error', {'message': 'Cannot read property of null'});
        
        final uxIssues = rum.detectUXIssues();
        
        expect(uxIssues, hasLength(3));
        expect(uxIssues[0].type, equals('slow_page_load'));
        expect(uxIssues[1].type, equals('laggy_interaction'));
        expect(uxIssues[2].type, equals('javascript_error'));
      });
    });
  });
}

// Mock implementations for testing

class AnalyticsEvent {
  final String name;
  final Map<String, dynamic> properties;
  final DateTime timestamp;

  AnalyticsEvent(this.name, this.properties, this.timestamp);
}

class MockAnalytics {
  final List<AnalyticsEvent> _events = [];
  final List<AnalyticsEvent> _errors = [];

  void trackEvent(String name, Map<String, dynamic> properties) {
    _events.add(AnalyticsEvent(name, properties, DateTime.now()));
  }

  void trackError(String name, Map<String, dynamic> properties) {
    _errors.add(AnalyticsEvent(name, properties, DateTime.now()));
  }

  List<AnalyticsEvent> getTrackedEvents() => _events;
  List<AnalyticsEvent> getErrorEvents() => _errors;

  Map<String, int> calculateFunnelMetrics(List<String> funnelSteps) {
    final metrics = <String, int>{};
    for (final step in funnelSteps) {
      metrics[step] = _events.where((event) => event.name == step).length;
    }
    return metrics;
  }
}

class PerformanceMetrics {
  final Duration appStartTime;
  final Duration averageScreenLoadTime;
  final Duration averageApiResponseTime;

  PerformanceMetrics({
    required this.appStartTime,
    required this.averageScreenLoadTime,
    required this.averageApiResponseTime,
  });
}

class PerformanceIssue {
  final String type;
  final Duration duration;
  final String details;

  PerformanceIssue(this.type, this.duration, this.details);
}

class MemoryMetrics {
  final double peakUsage;
  final double averageUsage;
  final bool hasMemoryWarning;

  MemoryMetrics({
    required this.peakUsage,
    required this.averageUsage,
    required this.hasMemoryWarning,
  });
}

class MockPerformanceMonitor {
  Duration? _appStartTime;
  final List<Duration> _screenLoadTimes = [];
  final List<Duration> _apiResponseTimes = [];
  final List<double> _memoryUsages = [];

  void trackAppStartTime(Duration duration) {
    _appStartTime = duration;
  }

  void trackScreenLoadTime(String screenName, Duration duration) {
    _screenLoadTimes.add(duration);
  }

  void trackApiResponseTime(String endpoint, Duration duration) {
    _apiResponseTimes.add(duration);
  }

  void trackMemoryUsage(double usageInMB) {
    _memoryUsages.add(usageInMB);
  }

  PerformanceMetrics getMetrics() {
    final avgScreenLoad = _screenLoadTimes.isEmpty
        ? Duration.zero
        : Duration(
            milliseconds: _screenLoadTimes
                .map((d) => d.inMilliseconds)
                .reduce((a, b) => a + b) ~/
                _screenLoadTimes.length,
          );

    final avgApiResponse = _apiResponseTimes.isEmpty
        ? Duration.zero
        : Duration(
            milliseconds: _apiResponseTimes
                .map((d) => d.inMilliseconds)
                .reduce((a, b) => a + b) ~/
                _apiResponseTimes.length,
          );

    return PerformanceMetrics(
      appStartTime: _appStartTime ?? Duration.zero,
      averageScreenLoadTime: avgScreenLoad,
      averageApiResponseTime: avgApiResponse,
    );
  }

  List<PerformanceIssue> detectPerformanceIssues() {
    final issues = <PerformanceIssue>[];

    // Detect slow screen loads (> 3 seconds)
    for (final duration in _screenLoadTimes) {
      if (duration.inMilliseconds > 3000) {
        issues.add(PerformanceIssue('slow_screen_load', duration, 'Screen load exceeded 3 seconds'));
      }
    }

    // Detect slow API responses (> 2 seconds)
    for (final duration in _apiResponseTimes) {
      if (duration.inMilliseconds > 2000) {
        issues.add(PerformanceIssue('slow_api_response', duration, 'API response exceeded 2 seconds'));
      }
    }

    return issues;
  }

  MemoryMetrics getMemoryMetrics() {
    if (_memoryUsages.isEmpty) {
      return MemoryMetrics(peakUsage: 0, averageUsage: 0, hasMemoryWarning: false);
    }

    final peak = _memoryUsages.reduce((a, b) => a > b ? a : b);
    final average = _memoryUsages.reduce((a, b) => a + b) / _memoryUsages.length;
    final hasWarning = peak > 100.0; // 100MB threshold

    return MemoryMetrics(
      peakUsage: peak,
      averageUsage: average,
      hasMemoryWarning: hasWarning,
    );
  }
}

class EngagementMetrics {
  final Duration averageSessionDuration;
  final int totalActiveUsers;
  final double featuresUsedPerUser;

  EngagementMetrics({
    required this.averageSessionDuration,
    required this.totalActiveUsers,
    required this.featuresUsedPerUser,
  });
}

class WardrobeMetrics {
  final int totalItemsAdded;
  final int totalOutfitsCreated;
  final String mostPopularCategory;

  WardrobeMetrics({
    required this.totalItemsAdded,
    required this.totalOutfitsCreated,
    required this.mostPopularCategory,
  });
}

class RetentionMetrics {
  final double day1Retention;
  final double day7Retention;
  final double day30Retention;

  RetentionMetrics({
    required this.day1Retention,
    required this.day7Retention,
    required this.day30Retention,
  });
}

class MockBusinessMetrics {
  final Map<String, List<Duration>> _userSessions = {};
  final Map<String, List<String>> _featureUsage = {};
  final List<Map<String, dynamic>> _wardrobeActivities = [];
  final Map<String, Set<DateTime>> _dailyActiveUsers = {};

  void trackUserSession(String userId, Duration duration) {
    _userSessions[userId] ??= [];
    _userSessions[userId]!.add(duration);
  }

  void trackFeatureUsage(String userId, String feature) {
    _featureUsage[userId] ??= [];
    _featureUsage[userId]!.add(feature);
  }

  void trackWardrobeActivity(String userId, String activity, Map<String, dynamic> properties) {
    _wardrobeActivities.add({
      'user_id': userId,
      'activity': activity,
      'properties': properties,
      'timestamp': DateTime.now(),
    });
  }

  void trackDailyActiveUser(String userId, DateTime date) {
    _dailyActiveUsers[userId] ??= {};
    _dailyActiveUsers[userId]!.add(date);
  }

  EngagementMetrics calculateEngagementMetrics() {
    final allSessions = _userSessions.values.expand((sessions) => sessions).toList();
    final avgSessionDuration = allSessions.isEmpty
        ? Duration.zero
        : Duration(
            minutes: allSessions
                .map((d) => d.inMinutes)
                .reduce((a, b) => a + b) ~/
                allSessions.length,
          );

    final totalUsers = _userSessions.keys.length;
    final totalFeatureUsages = _featureUsage.values.expand((features) => features).length;
    final featuresPerUser = totalUsers == 0 ? 0.0 : totalFeatureUsages / totalUsers;

    return EngagementMetrics(
      averageSessionDuration: avgSessionDuration,
      totalActiveUsers: totalUsers,
      featuresUsedPerUser: featuresPerUser,
    );
  }

  WardrobeMetrics getWardrobeMetrics() {
    final itemsAdded = _wardrobeActivities
        .where((activity) => activity['activity'] == 'item_added')
        .length;

    final outfitsCreated = _wardrobeActivities
        .where((activity) => activity['activity'] == 'outfit_created')
        .length;

    // Simple implementation - just return first category found
    final categoryActivity = _wardrobeActivities
        .where((activity) => activity['activity'] == 'item_added')
        .where((activity) => activity['properties']['category'] != null)
        .firstOrNull;

    final mostPopularCategory = (categoryActivity?['properties']['category'] as String?) ?? 'unknown';

    return WardrobeMetrics(
      totalItemsAdded: itemsAdded,
      totalOutfitsCreated: outfitsCreated,
      mostPopularCategory: mostPopularCategory,
    );
  }

  RetentionMetrics calculateRetentionMetrics() {
    final today = DateTime.now();
    final yesterday = today.subtract(Duration(days: 1));
    final sevenDaysAgo = today.subtract(Duration(days: 7));

    // Users active today
    final usersActiveToday = _dailyActiveUsers.entries
        .where((entry) => entry.value.any((date) => _isSameDay(date, today)))
        .map((entry) => entry.key)
        .toSet();

    // Users active yesterday
    final usersActiveYesterday = _dailyActiveUsers.entries
        .where((entry) => entry.value.any((date) => _isSameDay(date, yesterday)))
        .map((entry) => entry.key)
        .toSet();

    // Users active 7 days ago
    final usersActive7DaysAgo = _dailyActiveUsers.entries
        .where((entry) => entry.value.any((date) => _isSameDay(date, sevenDaysAgo)))
        .map((entry) => entry.key)
        .toSet();

    // Calculate retention
    final day1Retention = usersActiveYesterday.isEmpty
        ? 0.0
        : usersActiveToday.intersection(usersActiveYesterday).length / usersActiveYesterday.length;

    final day7Retention = usersActive7DaysAgo.isEmpty
        ? 0.0
        : usersActiveToday.intersection(usersActive7DaysAgo).length / usersActive7DaysAgo.length;

    return RetentionMetrics(
      day1Retention: day1Retention,
      day7Retention: day7Retention,
      day30Retention: 0.0, // Not implemented for this test
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
}

class MockABTesting {
  final Map<String, ABTest> _tests = {};
  final Map<String, Map<String, String>> _userVariants = {};

  void createTest(String testName, List<String> variants, List<int> weights) {
    _tests[testName] = ABTest(testName, variants, weights);
  }

  String assignUserToVariant(String userId, String testName) {
    _userVariants[testName] ??= {};
    
    if (_userVariants[testName]!.containsKey(userId)) {
      return _userVariants[testName]![userId]!;
    }

    final test = _tests[testName]!;
    final userHash = userId.hashCode.abs();
    final variantIndex = userHash % test.variants.length;
    final variant = test.variants[variantIndex];
    
    _userVariants[testName]![userId] = variant;
    return variant;
  }

  void trackConversion(String userId, String testName, String variant, String outcome) {
    final test = _tests[testName]!;
    test.trackConversion(userId, variant, outcome);
  }

  Map<String, Map<String, int>> getTestResults(String testName) {
    return _tests[testName]!.getResults();
  }
}

class ABTest {
  final String name;
  final List<String> variants;
  final List<int> weights;
  final Map<String, Map<String, int>> _results = {};

  ABTest(this.name, this.variants, this.weights) {
    for (final variant in variants) {
      _results[variant] = {'conversions': 0, 'total_users': 0};
    }
  }

  void trackConversion(String userId, String variant, String outcome) {
    _results[variant]!['total_users'] = _results[variant]!['total_users']! + 1;
    if (outcome == 'item_added') {
      _results[variant]!['conversions'] = _results[variant]!['conversions']! + 1;
    }
  }

  Map<String, Map<String, int>> getResults() => _results;
}

class RealUserMetrics {
  final Duration averagePageLoadTime;
  final Duration averageInteractionTime;
  final int totalPageViews;
  final int totalInteractions;

  RealUserMetrics({
    required this.averagePageLoadTime,
    required this.averageInteractionTime,
    required this.totalPageViews,
    required this.totalInteractions,
  });
}

class UXIssue {
  final String type;
  final String details;
  final DateTime timestamp;

  UXIssue(this.type, this.details, this.timestamp);
}

class MockRealUserMonitoring {
  final List<Duration> _pageLoadTimes = [];
  final List<Duration> _interactionTimes = [];
  final List<UXIssue> _uxIssues = [];
  int _totalPageViews = 0;
  int _totalInteractions = 0;

  void trackPageView(String page, Duration loadTime) {
    _totalPageViews++;
    _pageLoadTimes.add(loadTime);
  }

  void trackUserInteraction(String type, String element, Duration responseTime) {
    _totalInteractions++;
    _interactionTimes.add(responseTime);
  }

  void trackError(String type, Map<String, dynamic> details) {
    _uxIssues.add(UXIssue(type, details.toString(), DateTime.now()));
  }

  RealUserMetrics getRealUserMetrics() {
    final avgPageLoad = _pageLoadTimes.isEmpty
        ? Duration.zero
        : Duration(
            milliseconds: _pageLoadTimes
                .map((d) => d.inMilliseconds)
                .reduce((a, b) => a + b) ~/
                _pageLoadTimes.length,
          );

    final avgInteraction = _interactionTimes.isEmpty
        ? Duration.zero
        : Duration(
            milliseconds: _interactionTimes
                .map((d) => d.inMilliseconds)
                .reduce((a, b) => a + b) ~/
                _interactionTimes.length,
          );

    return RealUserMetrics(
      averagePageLoadTime: avgPageLoad,
      averageInteractionTime: avgInteraction,
      totalPageViews: _totalPageViews,
      totalInteractions: _totalInteractions,
    );
  }

  List<UXIssue> detectUXIssues() {
    final issues = List<UXIssue>.from(_uxIssues);

    // Detect slow page loads
    for (final duration in _pageLoadTimes) {
      if (duration.inMilliseconds > 5000) {
        issues.add(UXIssue('slow_page_load', 'Page load exceeded 5 seconds', DateTime.now()));
      }
    }

    // Detect laggy interactions
    for (final duration in _interactionTimes) {
      if (duration.inMilliseconds > 1000) {
        issues.add(UXIssue('laggy_interaction', 'Interaction response exceeded 1 second', DateTime.now()));
      }
    }

    return issues;
  }
}
