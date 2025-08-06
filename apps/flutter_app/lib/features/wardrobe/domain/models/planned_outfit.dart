/// WeatherCondition enum for different weather types
enum WeatherCondition {
  sunny,
  cloudy,
  rainy,
  snowy,
  windy,
  stormy,
  foggy,
  partlyCloudyDay,
  partlyCloudyNight,
  clearNight,
}

/// WeatherData model for weather information
class WeatherData {
  final WeatherCondition condition;
  final int temperature;
  final int humidity;
  final String description;
  final DateTime date;

  const WeatherData({
    required this.condition,
    required this.temperature,
    required this.humidity,
    required this.description,
    required this.date,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      condition: WeatherCondition.values.firstWhere(
        (e) => e.toString().split('.').last == json['condition'],
        orElse: () => WeatherCondition.sunny,
      ),
      temperature: json['temperature'] ?? 20,
      humidity: json['humidity'] ?? 50,
      description: json['description'] ?? '',
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'condition': condition.toString().split('.').last,
      'temperature': temperature,
      'humidity': humidity,
      'description': description,
      'date': date.toIso8601String(),
    };
  }
}

/// OutfitStatus enum for planned outfit states
enum OutfitStatus {
  planned,
  completed,
  cancelled,
  postponed,
}

/// PlannedOutfit model for outfit planning
class PlannedOutfit {
  final String id;
  final DateTime date;
  final String outfitId;
  final String outfitName;
  final String? outfitImageUrl;
  final List<String> clothingItemIds;
  final String? notes;
  final List<String> tags;
  final OutfitStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final WeatherData? expectedWeather;
  final bool isWeatherWarning;

  const PlannedOutfit({
    required this.id,
    required this.date,
    required this.outfitId,
    required this.outfitName,
    this.outfitImageUrl,
    required this.clothingItemIds,
    this.notes,
    required this.tags,
    this.status = OutfitStatus.planned,
    required this.createdAt,
    this.completedAt,
    this.expectedWeather,
    this.isWeatherWarning = false,
  });

  factory PlannedOutfit.fromJson(Map<String, dynamic> json) {
    return PlannedOutfit(
      id: json['id'],
      date: DateTime.parse(json['date']),
      outfitId: json['outfitId'],
      outfitName: json['outfitName'],
      outfitImageUrl: json['outfitImageUrl'],
      clothingItemIds: List<String>.from(json['clothingItemIds']),
      notes: json['notes'],
      tags: List<String>.from(json['tags'] ?? []),
      status: OutfitStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => OutfitStatus.planned,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'])
          : null,
      expectedWeather: json['expectedWeather'] != null
          ? WeatherData.fromJson(json['expectedWeather'])
          : null,
      isWeatherWarning: json['isWeatherWarning'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'outfitId': outfitId,
      'outfitName': outfitName,
      'outfitImageUrl': outfitImageUrl,
      'clothingItemIds': clothingItemIds,
      'notes': notes,
      'tags': tags,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'expectedWeather': expectedWeather?.toJson(),
      'isWeatherWarning': isWeatherWarning,
    };
  }

  PlannedOutfit copyWith({
    String? id,
    DateTime? date,
    String? outfitId,
    String? outfitName,
    String? outfitImageUrl,
    List<String>? clothingItemIds,
    String? notes,
    List<String>? tags,
    OutfitStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
    WeatherData? expectedWeather,
    bool? isWeatherWarning,
  }) {
    return PlannedOutfit(
      id: id ?? this.id,
      date: date ?? this.date,
      outfitId: outfitId ?? this.outfitId,
      outfitName: outfitName ?? this.outfitName,
      outfitImageUrl: outfitImageUrl ?? this.outfitImageUrl,
      clothingItemIds: clothingItemIds ?? this.clothingItemIds,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      expectedWeather: expectedWeather ?? this.expectedWeather,
      isWeatherWarning: isWeatherWarning ?? this.isWeatherWarning,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlannedOutfit && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PlannedOutfit(id: $id, date: $date, outfitName: $outfitName, status: $status)';
  }

  /// Business logic extensions
  bool get isCompleted => status == OutfitStatus.completed;
  bool get isPending => status == OutfitStatus.planned;
  bool get isCancelled => status == OutfitStatus.cancelled;
  bool get isPostponed => status == OutfitStatus.postponed;
  bool get isToday => isSameDay(date, DateTime.now());
  bool get isPast => date.isBefore(DateTime.now()) && !isToday;
  bool get isFuture => date.isAfter(DateTime.now());

  /// Check if outfit is suitable for weather
  bool get isWeatherSuitable {
    if (expectedWeather == null) return true;
    
    switch (expectedWeather!.condition) {
      case WeatherCondition.rainy:
      case WeatherCondition.stormy:
        return tags.contains('waterproof') || tags.contains('rain');
      case WeatherCondition.snowy:
        return tags.contains('winter') || tags.contains('warm');
      case WeatherCondition.sunny:
        return tags.contains('summer') || tags.contains('light');
      case WeatherCondition.windy:
        return !tags.contains('light') && !tags.contains('flowing');
      default:
        return true;
    }
  }

  /// Get weather recommendation message
  String? get weatherRecommendation {
    if (expectedWeather == null || isWeatherSuitable) return null;
    
    switch (expectedWeather!.condition) {
      case WeatherCondition.rainy:
        return 'Consider adding a raincoat or waterproof jacket';
      case WeatherCondition.snowy:
        return 'This outfit might be too light for snowy weather';
      case WeatherCondition.sunny:
        return 'Consider lighter fabrics and sun protection';
      case WeatherCondition.windy:
        return 'Avoid loose or flowing items in windy weather';
      default:
        return null;
    }
  }
}

/// Helper function to check if two dates are the same day
bool isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
         date1.month == date2.month &&
         date1.day == date2.day;
}

/// PlannedOutfitExtensions for additional functionality
extension PlannedOutfitExtensions on List<PlannedOutfit> {
  /// Filter by date range
  List<PlannedOutfit> filterByDateRange(DateTime start, DateTime end) {
    return where((outfit) =>
        outfit.date.isAfter(start.subtract(const Duration(days: 1))) &&
        outfit.date.isBefore(end.add(const Duration(days: 1)))).toList();
  }

  /// Filter by status
  List<PlannedOutfit> filterByStatus(OutfitStatus status) {
    return where((outfit) => outfit.status == status).toList();
  }

  /// Filter by weather warnings
  List<PlannedOutfit> get withWeatherWarnings =>
      where((outfit) => outfit.isWeatherWarning).toList();

  /// Group by date
  Map<DateTime, List<PlannedOutfit>> groupByDate() {
    final Map<DateTime, List<PlannedOutfit>> grouped = {};
    for (final outfit in this) {
      final dateKey = DateTime(outfit.date.year, outfit.date.month, outfit.date.day);
      grouped.putIfAbsent(dateKey, () => []).add(outfit);
    }
    return grouped;
  }

  /// Get completion stats
  Map<String, int> get completionStats {
    return {
      'total': length,
      'completed': where((o) => o.isCompleted).length,
      'pending': where((o) => o.isPending).length,
      'cancelled': where((o) => o.isCancelled).length,
      'postponed': where((o) => o.isPostponed).length,
    };
  }
}
