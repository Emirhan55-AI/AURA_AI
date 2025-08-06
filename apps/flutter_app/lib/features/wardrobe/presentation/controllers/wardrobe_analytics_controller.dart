import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/wardrobe_analytics.dart';
import '../../domain/repositories/wardrobe_analytics_repository.dart';
import '../../data/repositories/wardrobe_analytics_repository_impl.dart';
import '../../../../core/error/failure.dart';

part 'wardrobe_analytics_controller.g.dart';

// Repository provider
@Riverpod(keepAlive: true)
WardrobeAnalyticsRepository wardrobeAnalyticsRepository(WardrobeAnalyticsRepositoryRef ref) {
  return WardrobeAnalyticsRepositoryImpl();
}

/// State class for managing wardrobe analytics screen state
class WardrobeAnalyticsState {
  final AsyncValue<WardrobeAnalytics> analytics;
  final AnalyticsPeriod selectedPeriod;
  final AsyncValue<List<WardrobeRecommendation>> recommendations;
  final AsyncValue<Map<String, dynamic>> comparativeAnalytics;
  final AsyncValue<double> efficiencyScore;
  final AsyncValue<List<String>> insights;
  final bool isExporting;
  final String? exportUrl;
  final bool showDetailedView;
  final AsyncValue<void> operationState;

  const WardrobeAnalyticsState({
    required this.analytics,
    this.selectedPeriod = AnalyticsPeriod.month,
    required this.recommendations,
    required this.comparativeAnalytics,
    required this.efficiencyScore,
    required this.insights,
    this.isExporting = false,
    this.exportUrl,
    this.showDetailedView = false,
    required this.operationState,
  });

  /// Initial state with loading analytics
  factory WardrobeAnalyticsState.initial() {
    return WardrobeAnalyticsState(
      analytics: const AsyncValue<WardrobeAnalytics>.loading(),
      selectedPeriod: AnalyticsPeriod.month,
      recommendations: const AsyncValue<List<WardrobeRecommendation>>.loading(),
      comparativeAnalytics: const AsyncValue<Map<String, dynamic>>.loading(),
      efficiencyScore: const AsyncValue<double>.loading(),
      insights: const AsyncValue<List<String>>.loading(),
      operationState: const AsyncValue<void>.data(null),
    );
  }

  /// Copy with method for state updates
  WardrobeAnalyticsState copyWith({
    AsyncValue<WardrobeAnalytics>? analytics,
    AnalyticsPeriod? selectedPeriod,
    AsyncValue<List<WardrobeRecommendation>>? recommendations,
    AsyncValue<Map<String, dynamic>>? comparativeAnalytics,
    AsyncValue<double>? efficiencyScore,
    AsyncValue<List<String>>? insights,
    bool? isExporting,
    String? exportUrl,
    bool? showDetailedView,
    AsyncValue<void>? operationState,
  }) {
    return WardrobeAnalyticsState(
      analytics: analytics ?? this.analytics,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      recommendations: recommendations ?? this.recommendations,
      comparativeAnalytics: comparativeAnalytics ?? this.comparativeAnalytics,
      efficiencyScore: efficiencyScore ?? this.efficiencyScore,
      insights: insights ?? this.insights,
      isExporting: isExporting ?? this.isExporting,
      exportUrl: exportUrl ?? this.exportUrl,
      showDetailedView: showDetailedView ?? this.showDetailedView,
      operationState: operationState ?? this.operationState,
    );
  }
}

@riverpod
class WardrobeAnalyticsController extends _$WardrobeAnalyticsController {
  @override
  WardrobeAnalyticsState build() {
    // Initialize with loading state and trigger initial load
    final initialState = WardrobeAnalyticsState.initial();
    
    // Start loading data asynchronously
    Future.microtask(() {
      generateAnalytics();
      loadRecommendations();
      loadEfficiencyScore();
      loadInsights();
    });
    
    return initialState;
  }

  /// Repository instance
  WardrobeAnalyticsRepository get _repository => ref.read(wardrobeAnalyticsRepositoryProvider);

  /// Generate analytics for the selected period
  Future<void> generateAnalytics({AnalyticsPeriod? period}) async {
    final targetPeriod = period ?? state.selectedPeriod;
    
    // Update period if different
    if (targetPeriod != state.selectedPeriod) {
      state = state.copyWith(
        selectedPeriod: targetPeriod,
        analytics: const AsyncValue.loading(),
      );
    } else if (state.analytics.isLoading) {
      // Keep loading state if already loading
      state = state.copyWith(analytics: const AsyncValue.loading());
    }

    try {
      final analytics = await _repository.generateAnalytics(
        userId: 'current_user',
        period: targetPeriod,
      );
      
      state = state.copyWith(
        analytics: AsyncValue.data(analytics),
        selectedPeriod: targetPeriod,
      );
    } catch (error, stackTrace) {
      state = state.copyWith(
        analytics: AsyncValue.error(error, stackTrace),
      );
    }
  }

  /// Load recommendations
  Future<void> loadRecommendations() async {
    state = state.copyWith(
      recommendations: const AsyncValue.loading(),
    );

    try {
      final recommendations = await _repository.getRecommendations('current_user');
      
      state = state.copyWith(
        recommendations: AsyncValue.data(recommendations),
      );
    } catch (error, stackTrace) {
      state = state.copyWith(
        recommendations: AsyncValue.error(error, stackTrace),
      );
    }
  }

  /// Load comparative analytics
  Future<void> loadComparativeAnalytics() async {
    state = state.copyWith(
      comparativeAnalytics: const AsyncValue.loading(),
    );

    try {
      final comparative = await _repository.getComparativeAnalytics(
        userId: 'current_user',
        currentPeriod: state.selectedPeriod,
      );
      
      state = state.copyWith(
        comparativeAnalytics: AsyncValue.data(comparative),
      );
    } catch (error, stackTrace) {
      state = state.copyWith(
        comparativeAnalytics: AsyncValue.error(error, stackTrace),
      );
    }
  }

  /// Load efficiency score
  Future<void> loadEfficiencyScore() async {
    state = state.copyWith(
      efficiencyScore: const AsyncValue.loading(),
    );

    try {
      final score = await _repository.calculateEfficiencyScore('current_user');
      
      state = state.copyWith(
        efficiencyScore: AsyncValue.data(score),
      );
    } catch (error, stackTrace) {
      state = state.copyWith(
        efficiencyScore: AsyncValue.error(error, stackTrace),
      );
    }
  }

  /// Load insights
  Future<void> loadInsights() async {
    state = state.copyWith(
      insights: const AsyncValue.loading(),
    );

    try {
      final insights = await _repository.getInsights('current_user');
      
      state = state.copyWith(
        insights: AsyncValue.data(insights),
      );
    } catch (error, stackTrace) {
      state = state.copyWith(
        insights: AsyncValue.error(error, stackTrace),
      );
    }
  }

  /// Change analytics period
  Future<void> changePeriod(AnalyticsPeriod period) async {
    if (period != state.selectedPeriod) {
      await generateAnalytics(period: period);
      await loadComparativeAnalytics();
    }
  }

  /// Refresh all analytics data
  Future<void> refreshAnalytics() async {
    await Future.wait([
      generateAnalytics(),
      loadRecommendations(),
      loadComparativeAnalytics(),
      loadEfficiencyScore(),
      loadInsights(),
    ]);
  }

  /// Export analytics data
  Future<void> exportAnalytics({
    required List<String> sections,
    String format = 'pdf',
  }) async {
    if (state.isExporting) return;

    state = state.copyWith(
      isExporting: true,
      operationState: const AsyncValue.loading(),
    );

    try {
      final exportUrl = await _repository.exportAnalytics(
        userId: 'current_user',
        sections: sections,
        format: format,
      );
      
      state = state.copyWith(
        isExporting: false,
        exportUrl: exportUrl,
        operationState: const AsyncValue.data(null),
      );
    } catch (error, stackTrace) {
      state = state.copyWith(
        isExporting: false,
        operationState: AsyncValue.error(error, stackTrace),
      );
    }
  }

  /// Track item usage
  Future<void> trackItemUsage(String itemId) async {
    try {
      await _repository.trackItemUsage(
        userId: 'current_user',
        itemId: itemId,
      );
    } catch (error, stackTrace) {
      // Log error but don't update UI state for tracking
      print('Error tracking item usage: $error');
    }
  }

  /// Toggle detailed view
  void toggleDetailedView() {
    state = state.copyWith(
      showDetailedView: !state.showDetailedView,
    );
  }

  /// Clear export URL
  void clearExportUrl() {
    state = state.copyWith(exportUrl: null);
  }
}

// Additional providers for specific analytics data
@riverpod
Future<WardrobeAnalytics> currentAnalytics(CurrentAnalyticsRef ref) async {
  final controller = ref.watch(wardrobeAnalyticsControllerProvider);
  return controller.analytics.when(
    data: (analytics) => analytics,
    loading: () => throw const AsyncLoading<WardrobeAnalytics>(),
    error: (error, stackTrace) => throw AsyncError<WardrobeAnalytics>(error, stackTrace),
  );
}

@riverpod
Future<List<WardrobeRecommendation>> currentRecommendations(CurrentRecommendationsRef ref) async {
  final controller = ref.watch(wardrobeAnalyticsControllerProvider);
  return controller.recommendations.when(
    data: (recommendations) => recommendations,
    loading: () => throw const AsyncLoading<List<WardrobeRecommendation>>(),
    error: (error, stackTrace) => throw AsyncError<List<WardrobeRecommendation>>(error, stackTrace),
  );
}

@riverpod
Future<double> currentEfficiencyScore(CurrentEfficiencyScoreRef ref) async {
  final controller = ref.watch(wardrobeAnalyticsControllerProvider);
  return controller.efficiencyScore.when(
    data: (score) => score,
    loading: () => throw const AsyncLoading<double>(),
    error: (error, stackTrace) => throw AsyncError<double>(error, stackTrace),
  );
}

@riverpod
Future<List<String>> currentInsights(CurrentInsightsRef ref) async {
  final controller = ref.watch(wardrobeAnalyticsControllerProvider);
  return controller.insights.when(
    data: (insights) => insights,
    loading: () => throw const AsyncLoading<List<String>>(),
    error: (error, stackTrace) => throw AsyncError<List<String>>(error, stackTrace),
  );
}

// UI state providers
@riverpod
class AnalyticsViewMode extends _$AnalyticsViewMode {
  @override
  String build() => 'overview'; // overview, detailed, insights, recommendations
  
  void setMode(String mode) {
    state = mode;
  }
}

@riverpod
class AnalyticsChartType extends _$AnalyticsChartType {
  @override
  String build() => 'bar'; // bar, line, pie, heatmap
  
  void setType(String type) {
    state = type;
  }
}

