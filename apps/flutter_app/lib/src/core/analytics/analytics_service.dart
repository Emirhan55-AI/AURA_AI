import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Comprehensive analytics service for user behavior tracking and performance monitoring
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  SharedPreferences? _prefs;
  final List<AnalyticsEvent> _eventQueue = [];
  final Map<String, dynamic> _userProperties = {};
  bool _isInitialized = false;

  /// Initialize analytics service
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadUserProperties();
      await _loadQueuedEvents();
      _isInitialized = true;
      
      // Track app session start
      await trackEvent('app_session_start', {
        'timestamp': DateTime.now().toIso8601String(),
        'platform': defaultTargetPlatform.name,
      });
      
      developer.log('Analytics service initialized successfully');
    } catch (e) {
      developer.log('Failed to initialize analytics service: $e');
    }
  }

  /// Track a custom event with parameters
  Future<void> trackEvent(String eventName, [Map<String, dynamic>? parameters]) async {
    if (!_isInitialized) {
      developer.log('Analytics not initialized, queueing event: $eventName');
    }

    final event = AnalyticsEvent(
      name: eventName,
      parameters: parameters ?? {},
      timestamp: DateTime.now(),
      sessionId: await _getSessionId(),
      userId: await _getUserId(),
    );

    _eventQueue.add(event);
    await _persistEvent(event);

    // In debug mode, log the event
    if (kDebugMode) {
      developer.log(
        'Analytics Event: $eventName',
        name: 'Analytics',
        error: parameters?.toString(),
      );
    }

    // Process event queue periodically
    if (_eventQueue.length >= 10) {
      await _processEventQueue();
    }
  }

  /// Set user property for analytics
  Future<void> setUserProperty(String name, String value) async {
    _userProperties[name] = value;
    await _persistUserProperties();
    
    developer.log('User property set: $name = $value');
  }

  /// Track user journey through onboarding
  Future<void> trackOnboardingProgress(String step, Map<String, dynamic>? data) async {
    await trackEvent('onboarding_progress', {
      'step': step,
      'timestamp': DateTime.now().toIso8601String(),
      ...?data,
    });
  }

  /// Track wardrobe interactions
  Future<void> trackWardrobeAction(String action, Map<String, dynamic>? data) async {
    await trackEvent('wardrobe_action', {
      'action': action,
      'timestamp': DateTime.now().toIso8601String(),
      ...?data,
    });
  }

  /// Track outfit creation events
  Future<void> trackOutfitCreation(Map<String, dynamic> outfitData) async {
    await trackEvent('outfit_created', {
      'item_count': outfitData['items']?.length ?? 0,
      'category': outfitData['category'],
      'style': outfitData['style'],
      'timestamp': DateTime.now().toIso8601String(),
      ...outfitData,
    });
  }

  /// Track style assistant usage
  Future<void> trackStyleAssistantUsage(String action, Map<String, dynamic>? data) async {
    await trackEvent('style_assistant_usage', {
      'action': action,
      'timestamp': DateTime.now().toIso8601String(),
      ...?data,
    });
  }

  /// Track feature usage
  Future<void> trackFeatureUsage(String featureName, Map<String, dynamic>? data) async {
    await trackEvent('feature_usage', {
      'feature': featureName,
      'timestamp': DateTime.now().toIso8601String(),
      ...?data,
    });
  }

  /// Track performance metrics
  Future<void> trackPerformanceMetric(String metricName, double value, Map<String, dynamic>? data) async {
    await trackEvent('performance_metric', {
      'metric_name': metricName,
      'value': value,
      'timestamp': DateTime.now().toIso8601String(),
      ...?data,
    });
  }

  /// Track errors and crashes
  Future<void> trackError(String errorType, String message, [Map<String, dynamic>? data]) async {
    await trackEvent('error_occurred', {
      'error_type': errorType,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
      'stack_trace': StackTrace.current.toString(),
      ...?data,
    });
  }

  /// Track user engagement metrics
  Future<void> trackEngagement(String engagementType, Duration duration, [Map<String, dynamic>? data]) async {
    await trackEvent('user_engagement', {
      'engagement_type': engagementType,
      'duration_seconds': duration.inSeconds,
      'timestamp': DateTime.now().toIso8601String(),
      ...?data,
    });
  }

  /// Track conversion events
  Future<void> trackConversion(String conversionType, Map<String, dynamic>? data) async {
    await trackEvent('conversion', {
      'conversion_type': conversionType,
      'timestamp': DateTime.now().toIso8601String(),
      ...?data,
    });
  }

  /// Track app lifecycle events
  Future<void> trackAppLifecycle(String lifecycle, [Map<String, dynamic>? data]) async {
    await trackEvent('app_lifecycle', {
      'lifecycle': lifecycle,
      'timestamp': DateTime.now().toIso8601String(),
      ...?data,
    });
  }

  /// Get analytics summary
  Future<AnalyticsSummary> getAnalyticsSummary() async {
    final totalEvents = _eventQueue.length;
    final recentEvents = _eventQueue.where(
      (event) => event.timestamp.isAfter(
        DateTime.now().subtract(const Duration(days: 7)),
      ),
    ).length;
    
    final uniqueEvents = _eventQueue.map((e) => e.name).toSet().length;
    final sessionCount = _eventQueue.map((e) => e.sessionId).toSet().length;
    
    return AnalyticsSummary(
      totalEvents: totalEvents,
      recentEvents: recentEvents,
      uniqueEventTypes: uniqueEvents,
      sessionCount: sessionCount,
      userProperties: Map.from(_userProperties),
      lastEventTime: _eventQueue.isNotEmpty ? _eventQueue.last.timestamp : null,
    );
  }

  /// Export analytics data
  Future<Map<String, dynamic>> exportAnalyticsData() async {
    return {
      'events': _eventQueue.map((e) => e.toJson()).toList(),
      'user_properties': _userProperties,
      'export_timestamp': DateTime.now().toIso8601String(),
      'total_events': _eventQueue.length,
    };
  }

  /// Clear analytics data (for privacy compliance)
  Future<void> clearAnalyticsData() async {
    _eventQueue.clear();
    _userProperties.clear();
    await _prefs?.remove('analytics_events');
    await _prefs?.remove('analytics_user_properties');
    
    developer.log('Analytics data cleared');
  }

  /// Process event queue (batch send to analytics service)
  Future<void> _processEventQueue() async {
    if (_eventQueue.isEmpty) return;

    try {
      // In a real implementation, send events to analytics service
      // For now, we'll just log and simulate processing
      developer.log('Processing ${_eventQueue.length} analytics events');
      
      // Simulate successful processing by keeping only recent events
      final cutoffTime = DateTime.now().subtract(const Duration(days: 30));
      _eventQueue.removeWhere((event) => event.timestamp.isBefore(cutoffTime));
      
      await _persistEvents();
    } catch (e) {
      developer.log('Failed to process event queue: $e');
    }
  }

  /// Get or create session ID
  Future<String> _getSessionId() async {
    const sessionKey = 'analytics_session_id';
    const sessionTimeKey = 'analytics_session_time';
    
    final existingSession = _prefs?.getString(sessionKey);
    final sessionTime = _prefs?.getInt(sessionTimeKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // Session expires after 30 minutes of inactivity
    if (existingSession != null && (now - sessionTime) < (30 * 60 * 1000)) {
      await _prefs?.setInt(sessionTimeKey, now);
      return existingSession;
    }
    
    // Create new session
    final newSessionId = 'session_${now}_${DateTime.now().hashCode}';
    await _prefs?.setString(sessionKey, newSessionId);
    await _prefs?.setInt(sessionTimeKey, now);
    
    return newSessionId;
  }

  /// Get or create user ID
  Future<String> _getUserId() async {
    const userIdKey = 'analytics_user_id';
    
    final existingUserId = _prefs?.getString(userIdKey);
    if (existingUserId != null) {
      return existingUserId;
    }
    
    // Create new user ID
    final newUserId = 'user_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().hashCode}';
    await _prefs?.setString(userIdKey, newUserId);
    
    return newUserId;
  }

  /// Persist event to local storage
  Future<void> _persistEvent(AnalyticsEvent event) async {
    await _persistEvents();
  }

  /// Persist all events to local storage
  Future<void> _persistEvents() async {
    try {
      final eventsJson = _eventQueue.map((e) => e.toJson()).toList();
      await _prefs?.setString('analytics_events', jsonEncode(eventsJson));
    } catch (e) {
      developer.log('Failed to persist events: $e');
    }
  }

  /// Load events from local storage
  Future<void> _loadQueuedEvents() async {
    try {
      final eventsJson = _prefs?.getString('analytics_events');
      if (eventsJson != null) {
        final eventsList = jsonDecode(eventsJson) as List;
        _eventQueue.clear();
        _eventQueue.addAll(
          eventsList.map((e) => AnalyticsEvent.fromJson(e as Map<String, dynamic>)),
        );
      }
    } catch (e) {
      developer.log('Failed to load queued events: $e');
    }
  }

  /// Persist user properties to local storage
  Future<void> _persistUserProperties() async {
    try {
      await _prefs?.setString('analytics_user_properties', jsonEncode(_userProperties));
    } catch (e) {
      developer.log('Failed to persist user properties: $e');
    }
  }

  /// Load user properties from local storage
  Future<void> _loadUserProperties() async {
    try {
      final propertiesJson = _prefs?.getString('analytics_user_properties');
      if (propertiesJson != null) {
        final properties = jsonDecode(propertiesJson) as Map<String, dynamic>;
        _userProperties.addAll(properties);
      }
    } catch (e) {
      developer.log('Failed to load user properties: $e');
    }
  }
}

/// Analytics event model
class AnalyticsEvent {
  final String name;
  final Map<String, dynamic> parameters;
  final DateTime timestamp;
  final String sessionId;
  final String userId;

  AnalyticsEvent({
    required this.name,
    required this.parameters,
    required this.timestamp,
    required this.sessionId,
    required this.userId,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'parameters': parameters,
    'timestamp': timestamp.toIso8601String(),
    'session_id': sessionId,
    'user_id': userId,
  };

  factory AnalyticsEvent.fromJson(Map<String, dynamic> json) => AnalyticsEvent(
    name: json['name'] as String,
    parameters: Map<String, dynamic>.from(json['parameters'] as Map),
    timestamp: DateTime.parse(json['timestamp'] as String),
    sessionId: json['session_id'] as String,
    userId: json['user_id'] as String,
  );
}

/// Analytics summary model
class AnalyticsSummary {
  final int totalEvents;
  final int recentEvents;
  final int uniqueEventTypes;
  final int sessionCount;
  final Map<String, dynamic> userProperties;
  final DateTime? lastEventTime;

  AnalyticsSummary({
    required this.totalEvents,
    required this.recentEvents,
    required this.uniqueEventTypes,
    required this.sessionCount,
    required this.userProperties,
    this.lastEventTime,
  });

  Map<String, dynamic> toJson() => {
    'total_events': totalEvents,
    'recent_events': recentEvents,
    'unique_event_types': uniqueEventTypes,
    'session_count': sessionCount,
    'user_properties': userProperties,
    'last_event_time': lastEventTime?.toIso8601String(),
  };

  @override
  String toString() {
    return 'AnalyticsSummary('
        'totalEvents: $totalEvents, '
        'recentEvents: $recentEvents, '
        'uniqueEventTypes: $uniqueEventTypes, '
        'sessionCount: $sessionCount, '
        'lastEventTime: $lastEventTime)';
  }
}
