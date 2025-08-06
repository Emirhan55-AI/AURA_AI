import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/planned_outfit.dart';
import '../../domain/repositories/wardrobe_planner_repository.dart';
import '../../data/repositories/wardrobe_planner_repository_impl.dart';
import '../../../outfits/domain/entities/outfit.dart';
import '../../../../core/error/failure.dart';

part 'wardrobe_planner_controller.g.dart';

// Repository provider
@Riverpod(keepAlive: true)
WardrobePlannerRepository wardrobePlannerRepository(WardrobePlannerRepositoryRef ref) {
  return WardrobePlannerRepositoryImpl();
}

/// State class for managing wardrobe planner screen state
class WardrobePlannerState {
  final AsyncValue<List<PlannedOutfit>> plannedOutfits;
  final AsyncValue<Map<DateTime, WeatherData>> weatherData;
  final DateTime? selectedDate;
  final PlannedOutfit? pendingDropPlan;
  final AsyncValue<void> operationState;
  final List<Outfit> availableOutfits;
  final Outfit? draggingOutfit;
  final Map<String, dynamic>? stats;
  final bool isWeekView;

  const WardrobePlannerState({
    required this.plannedOutfits,
    required this.weatherData,
    this.selectedDate,
    this.pendingDropPlan,
    required this.operationState,
    required this.availableOutfits,
    this.draggingOutfit,
    this.stats,
    this.isWeekView = true,
  });

  /// Initial state with loading planned outfits
  factory WardrobePlannerState.initial() {
    return WardrobePlannerState(
      plannedOutfits: const AsyncValue<List<PlannedOutfit>>.loading(),
      weatherData: const AsyncValue<Map<DateTime, WeatherData>>.data({}),
      selectedDate: DateTime.now(),
      pendingDropPlan: null,
      operationState: const AsyncValue<void>.data(null),
      availableOutfits: [],
      draggingOutfit: null,
      stats: null,
      isWeekView: true,
    );
  }

  /// Copy with method for state updates
  WardrobePlannerState copyWith({
    AsyncValue<List<PlannedOutfit>>? plannedOutfits,
    AsyncValue<Map<DateTime, WeatherData>>? weatherData,
    DateTime? selectedDate,
    PlannedOutfit? pendingDropPlan,
    AsyncValue<void>? operationState,
    List<Outfit>? availableOutfits,
    Outfit? draggingOutfit,
    Map<String, dynamic>? stats,
    bool? isWeekView,
  }) {
    return WardrobePlannerState(
      plannedOutfits: plannedOutfits ?? this.plannedOutfits,
      weatherData: weatherData ?? this.weatherData,
      selectedDate: selectedDate ?? this.selectedDate,
      pendingDropPlan: pendingDropPlan ?? this.pendingDropPlan,
      operationState: operationState ?? this.operationState,
      availableOutfits: availableOutfits ?? this.availableOutfits,
      draggingOutfit: draggingOutfit ?? this.draggingOutfit,
      stats: stats ?? this.stats,
      isWeekView: isWeekView ?? this.isWeekView,
    );
  }
}

@riverpod
class WardrobePlannerController extends _$WardrobePlannerController {
  @override
  WardrobePlannerState build() {
    // Initialize with loading state and trigger initial load
    final initialState = WardrobePlannerState.initial();
    
    // Start loading data asynchronously
    Future.microtask(() {
      loadPlannedOutfits();
      loadAvailableOutfits();
      _loadInitialWeatherData();
      loadPlanningStats();
    });
    
    return initialState;
  }

  /// Loads planned outfits from the repository
  Future<void> loadPlannedOutfits() async {
    try {
      state = state.copyWith(
        plannedOutfits: const AsyncValue<List<PlannedOutfit>>.loading(),
      );

      final repository = ref.read(wardrobePlannerRepositoryProvider);
      final now = DateTime.now();
      final startDate = now.subtract(const Duration(days: 7));
      final endDate = now.add(const Duration(days: 14));
      
      final result = await repository.getPlannedOutfits(
        startDate: startDate,
        endDate: endDate,
      );

      result.fold(
        (Failure failure) => state = state.copyWith(
          plannedOutfits: AsyncValue<List<PlannedOutfit>>.error(
            failure.message, 
            StackTrace.current,
          ),
        ),
        (List<PlannedOutfit> outfits) => state = state.copyWith(
          plannedOutfits: AsyncValue<List<PlannedOutfit>>.data(outfits),
        ),
      );
    } catch (e, stackTrace) {
      state = state.copyWith(
        plannedOutfits: AsyncValue<List<PlannedOutfit>>.error(e, stackTrace),
      );
    }
  }

  /// Loads planning statistics
  Future<void> loadPlanningStats() async {
    try {
      final repository = ref.read(wardrobePlannerRepositoryProvider);
      final result = await repository.getPlanningStats();
      
      result.fold(
        (failure) => <String, String>{}, // Silently handle stats error
        (stats) => state = state.copyWith(stats: stats),
      );
    } catch (e) {
      // Silently handle error for stats as it's not critical
    }
  }

  /// Loads available outfits that can be dragged to the calendar
  Future<void> loadAvailableOutfits() async {
    try {
      // TODO: Replace with actual repository call when implemented
      await Future<void>.delayed(const Duration(milliseconds: 500));
      
      final mockOutfits = [
        _createMockOutfit('outfit1', 'Casual Friday'),
        _createMockOutfit('outfit2', 'Summer Dress'),
        _createMockOutfit('outfit3', 'Business Look'),
        _createMockOutfit('outfit4', 'Weekend Casual'),
        _createMockOutfit('outfit5', 'Date Night'),
      ];

      state = state.copyWith(availableOutfits: mockOutfits);
    } catch (e) {
      // Handle error silently for available outfits as it's not critical
    }
  }

  /// Loads weather data for the next 7 days
  Future<void> loadWeatherData(List<DateTime> dates) async {
    try {
      state = state.copyWith(
        weatherData: const AsyncValue<Map<DateTime, WeatherData>>.loading(),
      );

      final repository = ref.read(wardrobePlannerRepositoryProvider);
      final startDate = dates.first;
      final endDate = dates.last;
      
      final result = await repository.getWeatherData(
        startDate: startDate,
        endDate: endDate,
      );

      result.fold(
        (Failure failure) => state = state.copyWith(
          weatherData: AsyncValue<Map<DateTime, WeatherData>>.error(
            failure.message,
            StackTrace.current,
          ),
        ),
        (Map<DateTime, WeatherData> weatherMap) => state = state.copyWith(
          weatherData: AsyncValue<Map<DateTime, WeatherData>>.data(weatherMap),
        ),
      );
    } catch (e, stackTrace) {
      state = state.copyWith(
        weatherData: AsyncValue<Map<DateTime, WeatherData>>.error(e, stackTrace),
      );
    }
  }

  /// Loads initial weather data for the current week
  Future<void> _loadInitialWeatherData() async {
    final now = DateTime.now();
    final dates = List.generate(7, (index) => 
      DateTime(now.year, now.month, now.day + index));
    await loadWeatherData(dates);
  }

  /// Updates the selected date
  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  /// Toggles between week and month view
  void toggleView() {
    state = state.copyWith(isWeekView: !state.isWeekView);
  }

  /// Handles the start of dragging an outfit
  void startDraggingOutfit(Outfit outfit) {
    state = state.copyWith(draggingOutfit: outfit);
  }

  /// Sets the dragging outfit state (null to clear)
  void setDraggingOutfit(Outfit? outfit) {
    state = state.copyWith(draggingOutfit: outfit);
  }

  /// Sets the selected date
  void setSelectedDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  /// Toggles view mode between week and month
  void toggleViewMode() {
    state = state.copyWith(isWeekView: !state.isWeekView);
  }

  /// Loads initial data for the screen
  Future<void> loadInitialData() async {
    await Future.wait([
      loadPlannedOutfits(),
      loadWeatherData(),
      loadAvailableOutfits(),
      loadPlanningStats(),
    ]);
  }

  /// Refreshes all data
  Future<void> refreshData() async {
    await loadInitialData();
  }

  /// Plans an outfit for a specific date
  Future<void> planOutfitForDate(Outfit outfit, DateTime date) async {
    await dropOutfit(date, outfit);
  }

  /// Deletes a planned outfit
  Future<void> deletePlannedOutfit(String plannedOutfitId) async {
    try {
      state = state.copyWith(
        operationState: const AsyncValue<void>.loading(),
      );

      final repository = ref.read(wardrobePlannerRepositoryProvider);
      final result = await repository.deletePlannedOutfit(plannedOutfitId);

      await result.fold(
        (failure) async {
          state = state.copyWith(
            operationState: AsyncValue<void>.error(failure, StackTrace.current),
          );
        },
        (_) async {
          // Refresh the planned outfits after deletion
          await loadPlannedOutfits();
          state = state.copyWith(
            operationState: const AsyncValue<void>.data(null),
          );
        },
      );
    } catch (e, stackTrace) {
      state = state.copyWith(
        operationState: AsyncValue<void>.error(e, stackTrace),
      );
    }
  }

  /// Handles dropping an outfit onto a date
  Future<void> dropOutfit(DateTime date, Outfit outfit) async {
    try {
      state = state.copyWith(
        operationState: const AsyncValue<void>.loading(),
        draggingOutfit: null,
      );

      // Check for weather warnings
      final normalizedDate = _normalizeDate(date);
      final weather = state.weatherData.valueOrNull?[normalizedDate];
      
      if (weather != null && _shouldShowWeatherWarning(weather)) {
        // Set pending drop plan for UI to show confirmation dialog
        final pendingPlan = PlannedOutfit(
          id: 'pending_${DateTime.now().millisecondsSinceEpoch}',
          date: normalizedDate,
          outfitId: outfit.id,
          outfitName: outfit.name,
          clothingItemIds: outfit.clothingItemIds,
          createdAt: DateTime.now(),
        );
        
        state = state.copyWith(
          pendingDropPlan: pendingPlan,
          operationState: const AsyncValue<void>.data(null),
        );
        return;
      }

      // Proceed with direct drop if no weather warning
      await _savePlannedOutfit(date, outfit);
    } catch (e, stackTrace) {
      state = state.copyWith(
        operationState: AsyncValue<void>.error(e, stackTrace),
        draggingOutfit: null,
      );
    }
  }

  /// Confirms a pending drop plan after weather warning acknowledgment
  Future<void> confirmDropPlan(PlannedOutfit plan) async {
    try {
      state = state.copyWith(
        operationState: const AsyncValue<void>.loading(),
        pendingDropPlan: null,
      );

      final outfitForPlan = Outfit(
        id: plan.outfitId,
        userId: 'user1', // TODO: Get from auth
        name: plan.outfitName ?? 'Untitled Outfit',
        clothingItemIds: plan.clothingItemIds,
        createdAt: plan.createdAt,
        updatedAt: plan.createdAt,
      );

      await _savePlannedOutfit(plan.date, outfitForPlan);
    } catch (e, stackTrace) {
      state = state.copyWith(
        operationState: AsyncValue<void>.error(e, stackTrace),
      );
    }
  }

  /// Cancels a pending drop plan
  void cancelPendingDrop() {
    state = state.copyWith(pendingDropPlan: null);
  }

  /// Removes a planned outfit
  Future<void> removePlannedOutfit(String planId) async {
    try {
      state = state.copyWith(
        operationState: const AsyncValue<void>.loading(),
      );

      final repository = ref.read(wardrobePlannerRepositoryProvider);
      final result = await repository.deletePlannedOutfit(planId);

      result.fold(
        (failure) => state = state.copyWith(
          operationState: AsyncValue<void>.error(
            failure.message,
            StackTrace.current,
          ),
        ),
        (_) {
          // Remove from current state
          final currentPlans = state.plannedOutfits.valueOrNull ?? [];
          final updatedPlans = currentPlans.where((plan) => plan.id != planId).toList();
          
          state = state.copyWith(
            plannedOutfits: AsyncValue<List<PlannedOutfit>>.data(updatedPlans),
            operationState: const AsyncValue<void>.data(null),
          );
        },
      );
    } catch (e, stackTrace) {
      state = state.copyWith(
        operationState: AsyncValue<void>.error(e, stackTrace),
      );
    }
  }

  /// Mark outfit as completed
  Future<void> markOutfitCompleted(String planId) async {
    try {
      final repository = ref.read(wardrobePlannerRepositoryProvider);
      final result = await repository.markOutfitCompleted(planId);
      
      result.fold(
        (failure) => state = state.copyWith(
          operationState: AsyncValue<void>.error(
            failure.message,
            StackTrace.current,
          ),
        ),
        (completedOutfit) {
          final currentPlans = state.plannedOutfits.valueOrNull ?? [];
          final updatedPlans = currentPlans.map((plan) => 
            plan.id == completedOutfit.id ? completedOutfit : plan
          ).toList();
          
          state = state.copyWith(
            plannedOutfits: AsyncValue<List<PlannedOutfit>>.data(updatedPlans),
          );
        },
      );
    } catch (e, stackTrace) {
      state = state.copyWith(
        operationState: AsyncValue<void>.error(e, stackTrace),
      );
    }
  }

  /// Get weather-based suggestions for a date
  Future<List<String>> getWeatherSuggestions(DateTime date) async {
    final repository = ref.read(wardrobePlannerRepositoryProvider);
    final result = await repository.getWeatherBasedSuggestions(
      date: date,
      availableItems: [], // Would be populated from wardrobe
    );
    
    return result.fold(
      (failure) => ['Failed to load suggestions'],
      (suggestions) => suggestions,
    );
  }

  /// Retries loading planned outfits
  Future<void> retryLoadPlannedOutfits() async {
    await loadPlannedOutfits();
  }

  /// Retries loading weather data
  Future<void> retryLoadWeatherData() async {
    await _loadInitialWeatherData();
  }

  /// Retries the last failed operation
  Future<void> retryLastOperation() async {
    // Reset the operation state
    state = state.copyWith(
      operationState: const AsyncValue<void>.data(null),
    );
  }

  /// Internal method to save a planned outfit
  Future<void> _savePlannedOutfit(DateTime date, Outfit outfit) async {
    final repository = ref.read(wardrobePlannerRepositoryProvider);
    final normalizedDate = _normalizeDate(date);
    
    final newPlan = PlannedOutfit(
      id: 'plan_${DateTime.now().millisecondsSinceEpoch}',
      date: normalizedDate,
      outfitId: outfit.id,
      outfitName: outfit.name,
      clothingItemIds: outfit.clothingItemIds,
      createdAt: DateTime.now(),
    );

    final result = await repository.createPlannedOutfit(newPlan);
    
    result.fold(
      (failure) => state = state.copyWith(
        operationState: AsyncValue<void>.error(
          failure.message,
          StackTrace.current,
        ),
      ),
      (createdOutfit) {
        final currentPlans = state.plannedOutfits.valueOrNull ?? [];
        final updatedPlans = [...currentPlans, createdOutfit];
        
        state = state.copyWith(
          plannedOutfits: AsyncValue<List<PlannedOutfit>>.data(updatedPlans),
          operationState: const AsyncValue<void>.data(null),
        );
      },
    );
  }

  /// Checks if a weather warning should be shown
  bool _shouldShowWeatherWarning(WeatherData weather) {
    return weather.temperature > 30 || 
           weather.temperature < 5 || 
           weather.condition == WeatherCondition.rainy ||
           weather.condition == WeatherCondition.stormy;
  }

  /// Creates a mock outfit for testing
  Outfit _createMockOutfit(String id, String name) {
    final now = DateTime.now();
    return Outfit(
      id: id,
      userId: 'user1',
      name: name,
      clothingItemIds: ['item1', 'item2'],
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Normalizes a date to remove time component
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Convenience getters
  PlannedOutfit? getOutfitForDate(DateTime date) {
    final outfits = state.plannedOutfits.valueOrNull ?? [];
    return outfits.where((outfit) =>
      outfit.date.day == date.day &&
      outfit.date.month == date.month &&
      outfit.date.year == date.year
    ).firstOrNull;
  }

  WeatherData? getWeatherForDate(DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);
    return state.weatherData.valueOrNull?[dateKey];
  }

  List<PlannedOutfit> getOutfitsForWeek(DateTime weekStart) {
    final outfits = state.plannedOutfits.valueOrNull ?? [];
    final weekEnd = weekStart.add(const Duration(days: 6));
    return outfits.where((outfit) =>
      outfit.date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
      outfit.date.isBefore(weekEnd.add(const Duration(days: 1)))
    ).toList();
  }

  bool hasOutfitForDate(DateTime date) {
    return getOutfitForDate(date) != null;
  }
}

// Additional providers for specific data
@Riverpod(keepAlive: true)
Future<PlannedOutfit?> plannedOutfitForDate(
  PlannedOutfitForDateRef ref,
  DateTime date,
) async {
  final repository = ref.watch(wardrobePlannerRepositoryProvider);
  final result = await repository.getPlannedOutfitForDate(date);
  return result.fold((failure) => null, (outfit) => outfit);
}

@Riverpod(keepAlive: true)
Future<List<PlannedOutfit>> recentlyCompletedOutfits(
  RecentlyCompletedOutfitsRef ref, {
  int limit = 5,
}) async {
  final repository = ref.watch(wardrobePlannerRepositoryProvider);
  final result = await repository.getRecentlyCompletedOutfits(limit: limit);
  return result.fold((failure) => [], (outfits) => outfits);
}
