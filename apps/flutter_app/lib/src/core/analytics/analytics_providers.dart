import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'analytics_service.dart';

/// Provider for the analytics service singleton
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

/// Provider for analytics summary
final analyticsSummaryProvider = FutureProvider<AnalyticsSummary>((ref) async {
  final analyticsService = ref.read(analyticsServiceProvider);
  return await analyticsService.getAnalyticsSummary();
});

/// Analytics controller for managing analytics state
final analyticsControllerProvider = StateNotifierProvider<AnalyticsController, AnalyticsState>((ref) {
  final analyticsService = ref.read(analyticsServiceProvider);
  return AnalyticsController(analyticsService);
});

/// Analytics state
class AnalyticsState {
  final bool isInitialized;
  final bool isLoading;
  final String? error;
  final AnalyticsSummary? summary;

  const AnalyticsState({
    this.isInitialized = false,
    this.isLoading = false,
    this.error,
    this.summary,
  });

  AnalyticsState copyWith({
    bool? isInitialized,
    bool? isLoading,
    String? error,
    AnalyticsSummary? summary,
  }) {
    return AnalyticsState(
      isInitialized: isInitialized ?? this.isInitialized,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      summary: summary ?? this.summary,
    );
  }
}

/// Analytics controller
class AnalyticsController extends StateNotifier<AnalyticsState> {
  final AnalyticsService _analyticsService;

  AnalyticsController(this._analyticsService) : super(const AnalyticsState());

  /// Initialize analytics
  Future<void> initialize() async {
    if (state.isInitialized) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      await _analyticsService.initialize();
      await _loadSummary();
      state = state.copyWith(
        isInitialized: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Track event through controller
  Future<void> trackEvent(String eventName, [Map<String, dynamic>? parameters]) async {
    try {
      await _analyticsService.trackEvent(eventName, parameters);
      await _loadSummary();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Set user property through controller
  Future<void> setUserProperty(String name, String value) async {
    try {
      await _analyticsService.setUserProperty(name, value);
      await _loadSummary();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Load analytics summary
  Future<void> _loadSummary() async {
    try {
      final summary = await _analyticsService.getAnalyticsSummary();
      state = state.copyWith(summary: summary);
    } catch (e) {
      // Don't update error state for summary loading failures
      // as they're not critical
    }
  }

  /// Clear analytics data
  Future<void> clearData() async {
    try {
      await _analyticsService.clearAnalyticsData();
      await _loadSummary();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Export analytics data
  Future<Map<String, dynamic>?> exportData() async {
    try {
      return await _analyticsService.exportAnalyticsData();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }
}
