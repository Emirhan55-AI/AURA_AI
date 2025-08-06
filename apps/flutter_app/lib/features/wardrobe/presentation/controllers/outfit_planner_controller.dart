import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/outfit_plan.dart';
import '../../domain/repositories/outfit_planner_repository.dart';
import '../../data/repositories/outfit_planner_repository_impl.dart';
import '../../domain/models/clothing_item.dart';

part 'outfit_planner_controller.g.dart';

@riverpod
class PlannerViewMode extends _$PlannerViewMode {
  @override
  PlanningView build() => PlanningView.calendar;
  
  void change(PlanningView view) {
    state = view;
  }
}

@riverpod
OutfitPlannerRepository outfitPlannerRepository(OutfitPlannerRepositoryRef ref) {
  return OutfitPlannerRepositoryImpl();
}

/// State class for managing outfit planner screen state
class OutfitPlannerState {
  final AsyncValue<List<OutfitPlan>> dailyPlans;
  final AsyncValue<List<OutfitPlan>> weeklyPlans;
  final AsyncValue<WeeklyOutfitPlan?> currentWeekPlan;
  final AsyncValue<List<OutfitSuggestion>> suggestions;
  final AsyncValue<List<ClothingItem>> clothingItems;
  final AsyncValue<Map<String, List<ClothingItem>>> itemsByCategory;
  final AsyncValue<PlanningAnalytics> analytics;
  final DateTime selectedDate;
  final PlanningView currentView;
  final OutfitPlan? selectedPlan;
  final bool isCreatingPlan;
  final bool isEditingPlan;
  final AsyncValue<void> operationState;
  final Map<String, dynamic> filters;
  final AsyncValue<Map<String, dynamic>> weatherData;
  final String? searchQuery;

  const OutfitPlannerState({
    required this.dailyPlans,
    required this.weeklyPlans,
    required this.currentWeekPlan,
    required this.suggestions,
    required this.clothingItems,
    required this.itemsByCategory,
    required this.analytics,
    required this.selectedDate,
    this.currentView = PlanningView.calendar,
    this.selectedPlan,
    this.isCreatingPlan = false,
    this.isEditingPlan = false,
    required this.operationState,
    this.filters = const {},
    required this.weatherData,
    this.searchQuery,
  });

  /// Initial state with loading data
  factory OutfitPlannerState.initial() {
    return OutfitPlannerState(
      dailyPlans: const AsyncValue<List<OutfitPlan>>.loading(),
      weeklyPlans: const AsyncValue<List<OutfitPlan>>.loading(),
      currentWeekPlan: const AsyncValue<WeeklyOutfitPlan?>.loading(),
      suggestions: const AsyncValue<List<OutfitSuggestion>>.loading(),
      clothingItems: const AsyncValue<List<ClothingItem>>.loading(),
      itemsByCategory: const AsyncValue<Map<String, List<ClothingItem>>>.loading(),
      analytics: const AsyncValue<PlanningAnalytics>.loading(),
      selectedDate: DateTime.now(),
      operationState: const AsyncValue<void>.data(null),
      weatherData: const AsyncValue<Map<String, dynamic>>.loading(),
    );
  }

  /// Copy with method for state updates
  OutfitPlannerState copyWith({
    AsyncValue<List<OutfitPlan>>? dailyPlans,
    AsyncValue<List<OutfitPlan>>? weeklyPlans,
    AsyncValue<WeeklyOutfitPlan?>? currentWeekPlan,
    AsyncValue<List<OutfitSuggestion>>? suggestions,
    AsyncValue<List<ClothingItem>>? clothingItems,
    AsyncValue<Map<String, List<ClothingItem>>>? itemsByCategory,
    AsyncValue<PlanningAnalytics>? analytics,
    DateTime? selectedDate,
    PlanningView? currentView,
    OutfitPlan? selectedPlan,
    bool? isCreatingPlan,
    bool? isEditingPlan,
    AsyncValue<void>? operationState,
    Map<String, dynamic>? filters,
    AsyncValue<Map<String, dynamic>>? weatherData,
    String? searchQuery,
  }) {
    return OutfitPlannerState(
      dailyPlans: dailyPlans ?? this.dailyPlans,
      weeklyPlans: weeklyPlans ?? this.weeklyPlans,
      currentWeekPlan: currentWeekPlan ?? this.currentWeekPlan,
      suggestions: suggestions ?? this.suggestions,
      clothingItems: clothingItems ?? this.clothingItems,
      itemsByCategory: itemsByCategory ?? this.itemsByCategory,
      analytics: analytics ?? this.analytics,
      selectedDate: selectedDate ?? this.selectedDate,
      currentView: currentView ?? this.currentView,
      selectedPlan: selectedPlan ?? this.selectedPlan,
      isCreatingPlan: isCreatingPlan ?? this.isCreatingPlan,
      isEditingPlan: isEditingPlan ?? this.isEditingPlan,
      operationState: operationState ?? this.operationState,
      filters: filters ?? this.filters,
      weatherData: weatherData ?? this.weatherData,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// Enum for different planning views
enum PlanningView {
  calendar,
  timeline,
  suggestions,
  weekly,
  analytics,
}

@riverpod
class OutfitPlannerController extends _$OutfitPlannerController {
  @override
  OutfitPlannerState build() {
    // Initialize with loading state and trigger initial load
    final initialState = OutfitPlannerState.initial();
    
    // Start loading data asynchronously
    Future.microtask(() {
      loadDailyPlans();
      loadWeeklyPlans();
      loadCurrentWeekPlan();
      loadSuggestions();
      loadClothingItems();
      loadAnalytics();
      loadWeatherData();
    });
    
    return initialState;
  }

  /// Repository instance
  OutfitPlannerRepository get _repository => ref.read(outfitPlannerRepositoryProvider);

  /// Load daily plans for selected date
  Future<void> loadDailyPlans({DateTime? date}) async {
    final targetDate = date ?? state.selectedDate;
    
    state = state.copyWith(
      dailyPlans: const AsyncValue.loading(),
      selectedDate: targetDate,
    );

    try {
      final plans = await _repository.getPlansForDate(targetDate);
      
      state = state.copyWith(
        dailyPlans: AsyncValue.data(plans),
      );
    } catch (error, stackTrace) {
      state = state.copyWith(
        dailyPlans: AsyncValue.error(error, stackTrace),
      );
    }
  }

  /// Load weekly plans for current week
  Future<void> loadWeeklyPlans() async {
    state = state.copyWith(
      weeklyPlans: const AsyncValue.loading(),
    );

    try {
      final startOfWeek = _getStartOfWeek(state.selectedDate);
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      final plans = await _repository.getPlansForDateRange(startOfWeek, endOfWeek);
      
      state = state.copyWith(
        weeklyPlans: AsyncValue.data(plans),
      );
    } catch (error, stackTrace) {
      state = state.copyWith(
        weeklyPlans: AsyncValue.error(error, stackTrace),
      );
    }
  }

  /// Load current week plan
  Future<void> loadCurrentWeekPlan({DateTime? weekStart}) async {
    final targetWeekStart = weekStart ?? _getStartOfWeek(state.selectedDate);
    
    state = state.copyWith(
      currentWeekPlan: const AsyncValue.loading(),
    );

    try {
      final weekPlan = await _repository.getWeeklyPlan(targetWeekStart);
      
      state = state.copyWith(
        currentWeekPlan: AsyncValue.data(weekPlan),
      );
    } catch (error, stackTrace) {
      state = state.copyWith(
        currentWeekPlan: AsyncValue.error(error, stackTrace),
      );
    }
  }

  /// Load outfit suggestions
  Future<void> loadSuggestions({
    DateTime? date,
    OccasionType? occasion,
    List<WeatherCondition>? weather,
  }) async {
    state = state.copyWith(
      suggestions: const AsyncValue.loading(),
    );

    try {
      final suggestions = await _repository.getOutfitSuggestions(
        date: date ?? state.selectedDate,
        occasion: occasion,
        weather: weather,
        limit: 12,
      );
      
      state = state.copyWith(
        suggestions: AsyncValue.data(suggestions),
      );
    } catch (error, stackTrace) {
      state = state.copyWith(
        suggestions: AsyncValue.error(error, stackTrace),
      );
    }
  }

  /// Load smart AI suggestions
  Future<void> loadSmartSuggestions({
    DateTime? date,
    OccasionType? occasion,
    List<WeatherCondition>? weather,
    String? location,
  }) async {
    state = state.copyWith(
      suggestions: const AsyncValue.loading(),
    );

    try {
      final suggestions = await _repository.generateSmartSuggestions(
        userId: 'current_user',
        date: date ?? state.selectedDate,
        occasion: occasion,
        weather: weather,
        location: location,
      );
      
      state = state.copyWith(
        suggestions: AsyncValue.data(suggestions),
      );
    } catch (error, stackTrace) {
      state = state.copyWith(
        suggestions: AsyncValue.error(error, stackTrace),
      );
    }
  }

  /// Load clothing items
  Future<void> loadClothingItems() async {
    state = state.copyWith(
      clothingItems: const AsyncValue.loading(),
      itemsByCategory: const AsyncValue.loading(),
    );

    try {
      final items = await _repository.getAvailableClothingItems('current_user');
      final itemsByCategory = await _repository.getClothingItemsByCategory('current_user');
      
      state = state.copyWith(
        clothingItems: AsyncValue.data(items),
        itemsByCategory: AsyncValue.data(itemsByCategory),
      );
    } catch (error, stackTrace) {
      state = state.copyWith(
        clothingItems: AsyncValue.error(error, stackTrace),
        itemsByCategory: AsyncValue.error(error, stackTrace),
      );
    }
  }

  /// Load planning analytics
  Future<void> loadAnalytics() async {
    state = state.copyWith(
      analytics: const AsyncValue.loading(),
    );

    try {
      final analytics = await _repository.getPlanningAnalytics(
        'current_user',
        state.selectedDate,
      );
      
      state = state.copyWith(
        analytics: AsyncValue.data(analytics),
      );
    } catch (error, stackTrace) {
      state = state.copyWith(
        analytics: AsyncValue.error(error, stackTrace),
      );
    }
  }

  /// Load weather data
  Future<void> loadWeatherData({DateTime? date, String? location}) async {
    state = state.copyWith(
      weatherData: const AsyncValue.loading(),
    );

    try {
      final weatherData = await _repository.getWeatherData(
        date ?? state.selectedDate,
        location,
      );
      
      state = state.copyWith(
        weatherData: AsyncValue.data(weatherData),
      );
    } catch (error, stackTrace) {
      state = state.copyWith(
        weatherData: AsyncValue.error(error, stackTrace),
      );
    }
  }

  /// Create new outfit plan
  Future<void> createOutfitPlan(OutfitPlan plan) async {
    state = state.copyWith(
      isCreatingPlan: true,
      operationState: const AsyncValue.loading(),
    );

    try {
      final createdPlan = await _repository.createOutfitPlan(plan);
      
      // Update the daily plans if the created plan is for the selected date
      if (_isSameDate(createdPlan.plannedDate, state.selectedDate)) {
        await loadDailyPlans();
      }
      
      // Update weekly plans if needed
      if (_isInSameWeek(createdPlan.plannedDate, state.selectedDate)) {
        await loadWeeklyPlans();
      }
      
      state = state.copyWith(
        isCreatingPlan: false,
        operationState: const AsyncValue.data(null),
        selectedPlan: createdPlan,
      );
    } catch (error, stackTrace) {
      state = state.copyWith(
        isCreatingPlan: false,
        operationState: AsyncValue.error(error, stackTrace),
      );
    }
  }

  /// Update existing outfit plan
  Future<void> updateOutfitPlan(OutfitPlan plan) async {
    state = state.copyWith(
      isEditingPlan: true,
      operationState: const AsyncValue.loading(),
    );

    try {
      final updatedPlan = await _repository.updateOutfitPlan(plan);
      
      // Refresh relevant data
      await loadDailyPlans();
      await loadWeeklyPlans();
      
      state = state.copyWith(
        isEditingPlan: false,
        operationState: const AsyncValue.data(null),
        selectedPlan: updatedPlan,
      );
    } catch (error, stackTrace) {
      state = state.copyWith(
        isEditingPlan: false,
        operationState: AsyncValue.error(error, stackTrace),
      );
    }
  }

  /// Delete outfit plan
  Future<void> deleteOutfitPlan(String planId) async {
    state = state.copyWith(
      operationState: const AsyncValue.loading(),
    );

    try {
      await _repository.deleteOutfitPlan(planId);
      
      // Refresh relevant data
      await loadDailyPlans();
      await loadWeeklyPlans();
      
      state = state.copyWith(
        operationState: const AsyncValue.data(null),
        selectedPlan: null,
      );
    } catch (error, stackTrace) {
      state = state.copyWith(
        operationState: AsyncValue.error(error, stackTrace),
      );
    }
  }

  /// Mark plan as worn
  Future<void> markPlanAsWorn(String planId) async {
    state = state.copyWith(
      operationState: const AsyncValue.loading(),
    );

    try {
      await _repository.markPlanAsWorn(planId, DateTime.now());
      
      // Refresh data
      await loadDailyPlans();
      await loadWeeklyPlans();
      await loadAnalytics();
      
      state = state.copyWith(
        operationState: const AsyncValue.data(null),
      );
    } catch (error, stackTrace) {
      state = state.copyWith(
        operationState: AsyncValue.error(error, stackTrace),
      );
    }
  }

  /// Skip plan
  Future<void> skipPlan(String planId, String reason) async {
    state = state.copyWith(
      operationState: const AsyncValue.loading(),
    );

    try {
      await _repository.skipPlan(planId, reason);
      
      // Refresh data
      await loadDailyPlans();
      await loadWeeklyPlans();
      await loadAnalytics();
      
      state = state.copyWith(
        operationState: const AsyncValue.data(null),
      );
    } catch (error, stackTrace) {
      state = state.copyWith(
        operationState: AsyncValue.error(error, stackTrace),
      );
    }
  }

  /// Clone plan to new date
  Future<void> clonePlan(String planId, DateTime newDate) async {
    state = state.copyWith(
      operationState: const AsyncValue.loading(),
    );

    try {
      final clonedPlan = await _repository.clonePlan(planId, newDate);
      
      // Refresh data if cloned to selected date
      if (_isSameDate(newDate, state.selectedDate)) {
        await loadDailyPlans();
      }
      
      state = state.copyWith(
        operationState: const AsyncValue.data(null),
        selectedPlan: clonedPlan,
      );
    } catch (error, stackTrace) {
      state = state.copyWith(
        operationState: AsyncValue.error(error, stackTrace),
      );
    }
  }

  /// Create weekly plan
  Future<void> createWeeklyPlan(WeeklyOutfitPlan weeklyPlan) async {
    state = state.copyWith(
      operationState: const AsyncValue.loading(),
    );

    try {
      final createdPlan = await _repository.createWeeklyPlan(weeklyPlan);
      
      // Refresh weekly data
      await loadWeeklyPlans();
      await loadCurrentWeekPlan();
      
      state = state.copyWith(
        operationState: const AsyncValue.data(null),
        currentWeekPlan: AsyncValue.data(createdPlan),
      );
    } catch (error, stackTrace) {
      state = state.copyWith(
        operationState: AsyncValue.error(error, stackTrace),
      );
    }
  }

  /// Apply weekly plan template
  Future<void> applyWeeklyPlanTemplate(String templateId, DateTime weekStart) async {
    state = state.copyWith(
      operationState: const AsyncValue.loading(),
    );

    try {
      final appliedPlan = await _repository.applyWeeklyPlanTemplate(templateId, weekStart);
      
      // Refresh data
      await loadWeeklyPlans();
      await loadCurrentWeekPlan(weekStart: weekStart);
      
      state = state.copyWith(
        operationState: const AsyncValue.data(null),
        currentWeekPlan: AsyncValue.data(appliedPlan),
      );
    } catch (error, stackTrace) {
      state = state.copyWith(
        operationState: AsyncValue.error(error, stackTrace),
      );
    }
  }

  /// Change selected date
  void changeSelectedDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
    
    // Load data for new date
    Future.microtask(() {
      loadDailyPlans(date: date);
      loadWeatherData(date: date);
      loadSuggestions(date: date);
    });
  }

  /// Change planning view
  void changePlanningView(PlanningView view) {
    state = state.copyWith(currentView: view);
    
    // Load specific data based on view
    switch (view) {
      case PlanningView.weekly:
        loadWeeklyPlans();
        loadCurrentWeekPlan();
        break;
      case PlanningView.suggestions:
        loadSuggestions();
        break;
      case PlanningView.analytics:
        loadAnalytics();
        break;
      default:
        break;
    }
  }

  /// Select plan
  void selectPlan(OutfitPlan? plan) {
    state = state.copyWith(selectedPlan: plan);
  }

  /// Start creating plan
  void startCreatingPlan() {
    state = state.copyWith(
      isCreatingPlan: true,
      selectedPlan: null,
    );
  }

  /// Cancel creating plan
  void cancelCreatingPlan() {
    state = state.copyWith(
      isCreatingPlan: false,
      selectedPlan: null,
    );
  }

  /// Start editing plan
  void startEditingPlan(OutfitPlan plan) {
    state = state.copyWith(
      isEditingPlan: true,
      selectedPlan: plan,
    );
  }

  /// Cancel editing plan
  void cancelEditingPlan() {
    state = state.copyWith(
      isEditingPlan: false,
    );
  }

  /// Update filters
  void updateFilters(Map<String, dynamic> filters) {
    state = state.copyWith(filters: filters);
    
    // Refresh suggestions with new filters
    if (filters.containsKey('occasion') || filters.containsKey('weather')) {
      loadSuggestions(
        occasion: filters['occasion'],
        weather: filters['weather'],
      );
    }
  }

  /// Search plans
  Future<void> searchPlans(String query) async {
    state = state.copyWith(
      searchQuery: query,
      dailyPlans: const AsyncValue.loading(),
    );

    try {
      if (query.isEmpty) {
        await loadDailyPlans();
      } else {
        final results = await _repository.searchPlans(
          userId: 'current_user',
          query: query,
        );
        
        state = state.copyWith(
          dailyPlans: AsyncValue.data(results),
        );
      }
    } catch (error, stackTrace) {
      state = state.copyWith(
        dailyPlans: AsyncValue.error(error, stackTrace),
      );
    }
  }

  /// Refresh all data
  Future<void> refreshAll() async {
    await Future.wait([
      loadDailyPlans(),
      loadWeeklyPlans(),
      loadCurrentWeekPlan(),
      loadSuggestions(),
      loadClothingItems(),
      loadAnalytics(),
      loadWeatherData(),
    ]);
  }

  /// Clear operation state
  void clearOperationState() {
    state = state.copyWith(
      operationState: const AsyncValue.data(null),
    );
  }

  // Helper methods
  DateTime _getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  bool _isInSameWeek(DateTime date1, DateTime date2) {
    final startOfWeek1 = _getStartOfWeek(date1);
    final startOfWeek2 = _getStartOfWeek(date2);
    return _isSameDate(startOfWeek1, startOfWeek2);
  }
}

// Additional providers for specific outfit planner data
@riverpod
Future<List<OutfitPlan>> currentDayPlans(CurrentDayPlansRef ref) async {
  final controller = ref.watch(outfitPlannerControllerProvider);
  return controller.dailyPlans.when(
    data: (plans) => plans,
    loading: () => throw const AsyncLoading<List<OutfitPlan>>(),
    error: (error, stackTrace) => throw AsyncError<List<OutfitPlan>>(error, stackTrace),
  );
}

@riverpod
Future<List<OutfitSuggestion>> currentSuggestions(CurrentSuggestionsRef ref) async {
  final controller = ref.watch(outfitPlannerControllerProvider);
  return controller.suggestions.when(
    data: (suggestions) => suggestions,
    loading: () => throw const AsyncLoading<List<OutfitSuggestion>>(),
    error: (error, stackTrace) => throw AsyncError<List<OutfitSuggestion>>(error, stackTrace),
  );
}

@riverpod
Future<WeeklyOutfitPlan?> currentWeeklyPlan(CurrentWeeklyPlanRef ref) async {
  final controller = ref.watch(outfitPlannerControllerProvider);
  return controller.currentWeekPlan.when(
    data: (plan) => plan,
    loading: () => throw const AsyncLoading<WeeklyOutfitPlan?>(),
    error: (error, stackTrace) => throw AsyncError<WeeklyOutfitPlan?>(error, stackTrace),
  );
}

@riverpod
class SelectedPlanDate extends _$SelectedPlanDate {
  @override
  DateTime build() => DateTime.now();
  
  void setDate(DateTime date) {
    state = date;
  }
}
