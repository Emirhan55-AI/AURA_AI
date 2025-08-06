import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'outfit_plan.freezed.dart';
part 'outfit_plan.g.dart';

/// Enum representing different planning contexts
enum PlanningContext {
  daily,
  weekly,
  special,
  travel,
  work,
  casual,
  formal,
  seasonal,
}

/// Enum representing outfit plan status
enum OutfitPlanStatus {
  draft,
  planned,
  confirmed,
  worn,
  skipped,
  cancelled,
  modified,
}

/// Enum representing weather conditions for outfit planning
enum WeatherCondition {
  sunny,
  cloudy,
  partlyCloudy,
  rainy,
  snowy,
  stormy,
  foggy,
  windy,
  hot,
  cold,
  mild,
}

/// Enum representing occasion types
enum OccasionType {
  work,
  casual,
  formal,
  party,
  date,
  gym,
  workout,
  travel,
  meeting,
  dinner,
  shopping,
  outdoor,
  indoor,
  special,
}

/// Data model representing a planned outfit
@freezed
class OutfitPlan with _$OutfitPlan {
  const factory OutfitPlan({
    required String id,
    required String userId,
    required DateTime plannedDate,
    required String title,
    String? description,
    required List<String> clothingItemIds,
    String? combinationId,
    @Default(OutfitPlanStatus.planned) OutfitPlanStatus status,
    @Default(PlanningContext.daily) PlanningContext context,
    OccasionType? occasionType,
    @Default([]) List<WeatherCondition> expectedWeather,
    String? location,
    String? notes,
    @Default([]) List<String> tags,
    String? outfitImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? wornAt,
    @Default(false) bool isRecurring,
    RecurringPattern? recurringPattern,
    @Default(0) int priority,
    String? colorScheme,
    String? styleTheme,
    @Default(0.0) double confidenceScore,
    @Default([]) List<String> alternatives,
    String? reasonForChoice,
    @Default({}) Map<String, dynamic> weatherData,
    @Default(false) bool isBackup,
    String? originalPlanId,
  }) = _OutfitPlan;

  factory OutfitPlan.fromJson(Map<String, dynamic> json) => _$OutfitPlanFromJson(json);
}

/// Data model for recurring outfit patterns
@freezed
class RecurringPattern with _$RecurringPattern {
  const factory RecurringPattern({
    required RecurrenceType type,
    @Default(1) int interval,
    @Default([]) List<int> daysOfWeek, // 1=Monday, 7=Sunday
    @Default([]) List<int> daysOfMonth,
    DateTime? endDate,
    int? occurrences,
    @Default([]) List<DateTime> exceptions,
  }) = _RecurringPattern;

  factory RecurringPattern.fromJson(Map<String, dynamic> json) => _$RecurringPatternFromJson(json);
}

/// Enum for recurrence types
enum RecurrenceType {
  daily,
  weekly,
  monthly,
  yearly,
  custom,
}

/// Data model for outfit planning suggestions
@freezed
class OutfitSuggestion with _$OutfitSuggestion {
  const factory OutfitSuggestion({
    required String id,
    required List<String> clothingItemIds,
    required String title,
    String? description,
    required double matchScore,
    @Default([]) List<String> reasons,
    String? style,
    String? occasion,
    @Default([]) List<WeatherCondition> suitableWeather,
    String? colorPalette,
    @Default(0) int popularity,
    @Default(false) bool isPersonalized,
    DateTime? createdAt,
    String? imageUrl,
    @Default({}) Map<String, dynamic> metadata,
  }) = _OutfitSuggestion;

  factory OutfitSuggestion.fromJson(Map<String, dynamic> json) => _$OutfitSuggestionFromJson(json);
}

/// Data model for weekly outfit planning
@freezed
class WeeklyOutfitPlan with _$WeeklyOutfitPlan {
  const factory WeeklyOutfitPlan({
    required String id,
    required String userId,
    required DateTime weekStart,
    required DateTime weekEnd,
    @Default({}) Map<String, OutfitPlan> dailyPlans, // Day key (e.g., 'monday') -> OutfitPlan
    String? theme,
    @Default([]) List<String> goals,
    String? notes,
    @Default(0.0) double completionRate,
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default(false) bool isTemplate,
    String? templateName,
  }) = _WeeklyOutfitPlan;

  factory WeeklyOutfitPlan.fromJson(Map<String, dynamic> json) => _$WeeklyOutfitPlanFromJson(json);
}

/// Data model for outfit planning analytics
@freezed
class PlanningAnalytics with _$PlanningAnalytics {
  const factory PlanningAnalytics({
    required String userId,
    required DateTime period,
    @Default(0) int totalPlans,
    @Default(0) int completedPlans,
    @Default(0) int skippedPlans,
    @Default(0) int modifiedPlans,
    @Default(0.0) double completionRate,
    @Default({}) Map<String, int> occasionBreakdown,
    @Default({}) Map<String, int> weatherBreakdown,
    @Default({}) Map<String, double> stylePreferences,
    @Default([]) List<String> mostUsedItems,
    @Default([]) List<String> leastUsedItems,
    @Default(0.0) double averageConfidence,
    @Default(0) int streakDays,
    @Default({}) Map<String, dynamic> trends,
  }) = _PlanningAnalytics;

  factory PlanningAnalytics.fromJson(Map<String, dynamic> json) => _$PlanningAnalyticsFromJson(json);
}

/// Extension methods for OutfitPlan
extension OutfitPlanExtensions on OutfitPlan {
  /// Check if the plan is for today
  bool get isToday {
    final now = DateTime.now();
    return plannedDate.year == now.year &&
           plannedDate.month == now.month &&
           plannedDate.day == now.day;
  }

  /// Check if the plan is in the past
  bool get isPast {
    return plannedDate.isBefore(DateTime.now());
  }

  /// Check if the plan is in the future
  bool get isFuture {
    return plannedDate.isAfter(DateTime.now());
  }

  /// Get days until the planned date
  int get daysUntil {
    final now = DateTime.now();
    final difference = plannedDate.difference(DateTime(now.year, now.month, now.day));
    return difference.inDays;
  }

  /// Check if the plan can be modified
  bool get canModify {
    return status != OutfitPlanStatus.worn && 
           (isFuture || isToday);
  }

  /// Check if the plan can be marked as worn
  bool get canMarkWorn {
    return status != OutfitPlanStatus.worn && 
           (isToday || isPast);
  }

  /// Get formatted date string
  String get formattedDate {
    final now = DateTime.now();
    final difference = daysUntil;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference == -1) {
      return 'Yesterday';
    } else if (difference > 1 && difference <= 7) {
      return 'In $difference days';
    } else if (difference < -1 && difference >= -7) {
      return '${-difference} days ago';
    } else {
      return '${plannedDate.day}/${plannedDate.month}/${plannedDate.year}';
    }
  }

  /// Get status color for UI
  Color get statusColor {
    switch (status) {
      case OutfitPlanStatus.planned:
        return const Color(0xFF2196F3); // Blue
      case OutfitPlanStatus.confirmed:
        return const Color(0xFF4CAF50); // Green
      case OutfitPlanStatus.worn:
        return const Color(0xFF9C27B0); // Purple
      case OutfitPlanStatus.skipped:
        return const Color(0xFF757575); // Grey
      case OutfitPlanStatus.modified:
        return const Color(0xFFFF9800); // Orange
    }
  }

  /// Get occasion color for UI
  Color get occasionColor {
    switch (occasionType) {
      case OccasionType.work:
        return const Color(0xFF1976D2); // Dark Blue
      case OccasionType.casual:
        return const Color(0xFF4CAF50); // Green
      case OccasionType.formal:
        return const Color(0xFF424242); // Dark Grey
      case OccasionType.party:
        return const Color(0xFFE91E63); // Pink
      case OccasionType.date:
        return const Color(0xFFE91E63); // Pink
      case OccasionType.workout:
        return const Color(0xFFFF5722); // Deep Orange
      case OccasionType.travel:
        return const Color(0xFF795548); // Brown
      case OccasionType.meeting:
        return const Color(0xFF607D8B); // Blue Grey
      case OccasionType.dinner:
        return const Color(0xFF9C27B0); // Purple
      case OccasionType.shopping:
        return const Color(0xFF00BCD4); // Cyan
      case OccasionType.outdoor:
        return const Color(0xFF8BC34A); // Light Green
      case OccasionType.indoor:
        return const Color(0xFF3F51B5); // Indigo
      case OccasionType.special:
        return const Color(0xFFFFD700); // Gold
      case null:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  /// Get weather icon for display
  String get weatherIcon {
    if (expectedWeather.isEmpty) return '🌤️';
    
    switch (expectedWeather.first) {
      case WeatherCondition.sunny:
        return '☀️';
      case WeatherCondition.cloudy:
        return '☁️';
      case WeatherCondition.rainy:
        return '🌧️';
      case WeatherCondition.snowy:
        return '❄️';
      case WeatherCondition.windy:
        return '💨';
      case WeatherCondition.hot:
        return '🔥';
      case WeatherCondition.cold:
        return '🥶';
      case WeatherCondition.mild:
        return '🌤️';
    }
  }

  /// Get priority level text
  String get priorityText {
    if (priority >= 8) return 'High';
    if (priority >= 5) return 'Medium';
    if (priority >= 2) return 'Low';
    return 'None';
  }

  /// Get confidence level text
  String get confidenceText {
    if (confidenceScore >= 0.8) return 'Very Confident';
    if (confidenceScore >= 0.6) return 'Confident';
    if (confidenceScore >= 0.4) return 'Moderate';
    if (confidenceScore >= 0.2) return 'Low Confidence';
    return 'Very Low';
  }

  /// Calculate completion percentage for recurring plans
  double get completionPercentage {
    if (!isRecurring || recurringPattern == null) return 100.0;
    
    // Mock calculation - in real app would track actual completions
    switch (status) {
      case OutfitPlanStatus.worn:
        return 100.0;
      case OutfitPlanStatus.confirmed:
        return 80.0;
      case OutfitPlanStatus.planned:
        return 50.0;
      case OutfitPlanStatus.modified:
        return 70.0;
      case OutfitPlanStatus.skipped:
        return 0.0;
    }
  }
}

/// Extension methods for WeeklyOutfitPlan
extension WeeklyOutfitPlanExtensions on WeeklyOutfitPlan {
  /// Get the number of planned days
  int get plannedDays => dailyPlans.length;

  /// Get the number of completed plans
  int get completedPlans {
    return dailyPlans.values
        .where((plan) => plan.status == OutfitPlanStatus.worn)
        .length;
  }

  /// Calculate actual completion rate
  double get actualCompletionRate {
    if (dailyPlans.isEmpty) return 0.0;
    return completedPlans / dailyPlans.length;
  }

  /// Check if the week is current
  bool get isCurrentWeek {
    final now = DateTime.now();
    return now.isAfter(weekStart.subtract(const Duration(days: 1))) &&
           now.isBefore(weekEnd.add(const Duration(days: 1)));
  }

  /// Get week display string
  String get weekDisplay {
    return '${weekStart.day}/${weekStart.month} - ${weekEnd.day}/${weekEnd.month}/${weekEnd.year}';
  }

  /// Get missing days (days without plans)
  List<String> get missingDays {
    const weekDays = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    return weekDays.where((day) => !dailyPlans.containsKey(day)).toList();
  }

  /// Get plans sorted by date
  List<MapEntry<String, OutfitPlan>> get sortedPlans {
    final entries = dailyPlans.entries.toList();
    const dayOrder = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    
    entries.sort((a, b) {
      final indexA = dayOrder.indexOf(a.key);
      final indexB = dayOrder.indexOf(b.key);
      return indexA.compareTo(indexB);
    });
    
    return entries;
  }
}

/// Extension methods for OutfitSuggestion
extension OutfitSuggestionExtensions on OutfitSuggestion {
  /// Get match score as percentage
  String get matchPercentage => '${(matchScore * 100).toStringAsFixed(0)}%';

  /// Check if this is a high-quality suggestion
  bool get isHighQuality => matchScore >= 0.8;

  /// Get score color for UI
  Color get scoreColor {
    if (matchScore >= 0.8) return const Color(0xFF4CAF50); // Green
    if (matchScore >= 0.6) return const Color(0xFF2196F3); // Blue
    if (matchScore >= 0.4) return const Color(0xFFFF9800); // Orange
    return const Color(0xFFF44336); // Red
  }

  /// Get top reasons (limit to 3)
  List<String> get topReasons => reasons.take(3).toList();
}

/// Extension methods for OutfitPlanStatus
extension OutfitPlanStatusExtensions on OutfitPlanStatus {
  String get displayName {
    switch (this) {
      case OutfitPlanStatus.draft:
        return 'Draft';
      case OutfitPlanStatus.planned:
        return 'Planned';
      case OutfitPlanStatus.confirmed:
        return 'Confirmed';
      case OutfitPlanStatus.worn:
        return 'Worn';
      case OutfitPlanStatus.skipped:
        return 'Skipped';
      case OutfitPlanStatus.cancelled:
        return 'Cancelled';
      case OutfitPlanStatus.modified:
        return 'Modified';
    }
  }
}

/// Extension methods for OccasionType
extension OccasionTypeExtensions on OccasionType {
  String get displayName {
    switch (this) {
      case OccasionType.work:
        return 'Work';
      case OccasionType.casual:
        return 'Casual';
      case OccasionType.formal:
        return 'Formal';
      case OccasionType.party:
        return 'Party';
      case OccasionType.date:
        return 'Date';
      case OccasionType.gym:
        return 'Gym';
      case OccasionType.workout:
        return 'Workout';
      case OccasionType.travel:
        return 'Travel';
      case OccasionType.meeting:
        return 'Meeting';
      case OccasionType.dinner:
        return 'Dinner';
      case OccasionType.shopping:
        return 'Shopping';
      case OccasionType.outdoor:
        return 'Outdoor';
      case OccasionType.indoor:
        return 'Indoor';
      case OccasionType.special:
        return 'Special';
    }
  }
}

/// Extension methods for WeatherCondition
extension WeatherConditionExtensions on WeatherCondition {
  String get displayName {
    switch (this) {
      case WeatherCondition.sunny:
        return 'Sunny';
      case WeatherCondition.cloudy:
        return 'Cloudy';
      case WeatherCondition.partlyCloudy:
        return 'Partly Cloudy';
      case WeatherCondition.rainy:
        return 'Rainy';
      case WeatherCondition.snowy:
        return 'Snowy';
      case WeatherCondition.stormy:
        return 'Stormy';
      case WeatherCondition.foggy:
        return 'Foggy';
      case WeatherCondition.windy:
        return 'Windy';
      case WeatherCondition.hot:
        return 'Hot';
      case WeatherCondition.cold:
        return 'Cold';
      case WeatherCondition.mild:
        return 'Mild';
    }
  }
}

/// Extension methods for List<WeatherCondition>
extension WeatherConditionListExtensions on List<WeatherCondition> {
  String get displayName {
    if (isEmpty) return 'Any Weather';
    if (length == 1) return first.displayName;
    return map((w) => w.displayName).join(', ');
  }
}
