import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../outfits/domain/entities/outfit.dart';
import '../widgets/planner/combination_drag_target.dart'; // For PlannedOutfit and WeatherData

part 'wardrobe_planner_controller.g.dart';

/// State class for managing wardrobe planner screen state
class WardrobePlannerState {
  final AsyncValue<List<PlannedOutfit>> plannedOutfits;
  final AsyncValue<Map<DateTime, WeatherData>> weatherData;
  final DateTime? selectedDate;
  final PlannedOutfit? pendingDropPlan;
  final AsyncValue<void> operationState;
  final List<Outfit> availableOutfits;
  final Outfit? draggingOutfit;

  const WardrobePlannerState({
    required this.plannedOutfits,
    required this.weatherData,
    this.selectedDate,
    this.pendingDropPlan,
    required this.operationState,
    required this.availableOutfits,
    this.draggingOutfit,
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
  }) {
    return WardrobePlannerState(
      plannedOutfits: plannedOutfits ?? this.plannedOutfits,
      weatherData: weatherData ?? this.weatherData,
      selectedDate: selectedDate ?? this.selectedDate,
      pendingDropPlan: pendingDropPlan ?? this.pendingDropPlan,
      operationState: operationState ?? this.operationState,
      availableOutfits: availableOutfits ?? this.availableOutfits,
      draggingOutfit: draggingOutfit ?? this.draggingOutfit,
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
    });
    
    return initialState;
  }

  /// Loads planned outfits from the repository
  Future<void> loadPlannedOutfits() async {
    try {
      state = state.copyWith(
        plannedOutfits: const AsyncValue<List<PlannedOutfit>>.loading(),
      );

      // TODO: Replace with actual repository call when implemented
      // For now, use placeholder data
      await Future<void>.delayed(const Duration(seconds: 1));
      
      final now = DateTime.now();
      final mockPlannedOutfits = [
        PlannedOutfit(
          id: 'planned1',
          date: DateTime(now.year, now.month, now.day + 1),
          outfitId: 'outfit1',
          outfit: _createMockOutfit('outfit1', 'Casual Friday'),
        ),
        PlannedOutfit(
          id: 'planned2',
          date: DateTime(now.year, now.month, now.day + 3),
          outfitId: 'outfit2',
          outfit: _createMockOutfit('outfit2', 'Summer Dress'),
        ),
      ];

      state = state.copyWith(
        plannedOutfits: AsyncValue<List<PlannedOutfit>>.data(mockPlannedOutfits),
      );
    } catch (e, stackTrace) {
      state = state.copyWith(
        plannedOutfits: AsyncValue<List<PlannedOutfit>>.error(e, stackTrace),
      );
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

      // TODO: Replace with actual weather service call
      await Future<void>.delayed(const Duration(milliseconds: 800));
      
      final weatherMap = <DateTime, WeatherData>{};
      for (int i = 0; i < dates.length; i++) {
        final date = _normalizeDate(dates[i]);
        weatherMap[date] = WeatherData(
          condition: ['sunny', 'cloudy', 'rainy'][i % 3],
          temperature: 18 + (i % 15),
          description: ['Sunny', 'Cloudy', 'Light Rain'][i % 3],
          icon: [Icons.wb_sunny, Icons.cloud, Icons.umbrella][i % 3],
        );
      }

      state = state.copyWith(
        weatherData: AsyncValue<Map<DateTime, WeatherData>>.data(weatherMap),
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

  /// Handles the start of dragging an outfit
  void startDraggingOutfit(Outfit outfit) {
    state = state.copyWith(draggingOutfit: outfit);
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
          outfit: outfit,
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

      await _savePlannedOutfit(plan.date, plan.outfit);
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

      // TODO: Replace with actual repository call
      await Future<void>.delayed(const Duration(milliseconds: 500));

      // Remove from current state
      final currentPlans = state.plannedOutfits.valueOrNull ?? [];
      final updatedPlans = currentPlans.where((plan) => plan.id != planId).toList();

      state = state.copyWith(
        plannedOutfits: AsyncValue<List<PlannedOutfit>>.data(updatedPlans),
        operationState: const AsyncValue<void>.data(null),
      );
    } catch (e, stackTrace) {
      state = state.copyWith(
        operationState: AsyncValue<void>.error(e, stackTrace),
      );
    }
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
    // TODO: Implement retry logic based on what the last operation was
    // For now, just reset the operation state
    state = state.copyWith(
      operationState: const AsyncValue<void>.data(null),
    );
  }

  /// Internal method to save a planned outfit
  Future<void> _savePlannedOutfit(DateTime date, Outfit outfit) async {
    // TODO: Replace with actual repository call
    await Future<void>.delayed(const Duration(milliseconds: 500));

    final normalizedDate = _normalizeDate(date);
    final newPlan = PlannedOutfit(
      id: 'plan_${DateTime.now().millisecondsSinceEpoch}',
      date: normalizedDate,
      outfitId: outfit.id,
      outfit: outfit,
    );

    // Add to current plans
    final currentPlans = state.plannedOutfits.valueOrNull ?? [];
    final updatedPlans = [...currentPlans, newPlan];

    state = state.copyWith(
      plannedOutfits: AsyncValue<List<PlannedOutfit>>.data(updatedPlans),
      operationState: const AsyncValue<void>.data(null),
    );
  }

  /// Checks if a weather warning should be shown
  bool _shouldShowWeatherWarning(WeatherData weather) {
    return weather.temperature > 30 || 
           weather.temperature < 5 || 
           weather.condition.toLowerCase().contains('rain');
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
}
