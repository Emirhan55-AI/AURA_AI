import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../domain/repositories/wardrobe_planner_repository.dart';
import '../../domain/models/planned_outfit.dart';
import '../../domain/entities/clothing_item.dart';

/// Mock implementation of WardrobePlannerRepository
/// Provides realistic data simulation for development and testing
class WardrobePlannerRepositoryImpl implements WardrobePlannerRepository {
  // Simulated database storage
  final List<PlannedOutfit> _plannedOutfits = [];
  final Map<DateTime, WeatherData> _weatherCache = {};

  WardrobePlannerRepositoryImpl() {
    _initializeMockData();
  }

  void _initializeMockData() {
    final now = DateTime.now();
    
    // Create mock planned outfits
    _plannedOutfits.addAll([
      PlannedOutfit(
        id: 'planned_1',
        date: DateTime(now.year, now.month, now.day + 1),
        outfitId: 'outfit_casual_1',
        outfitName: 'Casual Friday',
        outfitImageUrl: 'https://images.unsplash.com/photo-1434389677669-e08b4cac3105?w=400',
        clothingItemIds: ['shirt_1', 'jeans_1', 'sneakers_1'],
        notes: 'Comfortable outfit for Friday work',
        tags: ['casual', 'work', 'comfortable'],
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      PlannedOutfit(
        id: 'planned_2',
        date: DateTime(now.year, now.month, now.day + 2),
        outfitId: 'outfit_formal_1',
        outfitName: 'Weekend Brunch',
        outfitImageUrl: 'https://images.unsplash.com/photo-1489370603040-dc6c28a1d37a?w=400',
        clothingItemIds: ['dress_1', 'heels_1', 'jacket_1'],
        notes: 'Perfect for weekend brunch with friends',
        tags: ['weekend', 'brunch', 'elegant'],
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      PlannedOutfit(
        id: 'planned_3',
        date: DateTime(now.year, now.month, now.day + 3),
        outfitId: 'outfit_sport_1',
        outfitName: 'Gym Session',
        outfitImageUrl: 'https://images.unsplash.com/photo-1506629905607-21e2b3b6b1a9?w=400',
        clothingItemIds: ['sports_top_1', 'leggings_1', 'sneakers_sport_1'],
        notes: 'Workout outfit for Monday gym session',
        tags: ['sport', 'gym', 'active'],
        createdAt: now.subtract(const Duration(hours: 12)),
        isCompleted: false,
      ),
      PlannedOutfit(
        id: 'planned_4',
        date: DateTime(now.year, now.month, now.day),
        outfitId: 'outfit_today_1',
        outfitName: 'Work Meeting',
        outfitImageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
        clothingItemIds: ['blazer_1', 'trousers_1', 'shirt_formal_1'],
        notes: 'Important client meeting today',
        tags: ['work', 'formal', 'meeting'],
        createdAt: now.subtract(const Duration(days: 1)),
        isCompleted: true,
        completedAt: now.subtract(const Duration(hours: 2)),
      ),
    ]);

    // Create mock weather data
    for (int i = 0; i < 14; i++) {
      final date = DateTime(now.year, now.month, now.day + i);
      _weatherCache[date] = _generateMockWeatherData(date, i);
    }
  }

  WeatherData _generateMockWeatherData(DateTime date, int dayOffset) {
    // Generate realistic weather variations
    final baseTemp = 20 + (dayOffset % 15) - 5; // Varies between 10-30°C
    final conditions = WeatherCondition.values;
    final condition = conditions[dayOffset % conditions.length];
    
    return WeatherData(
      date: date,
      temperature: baseTemp.toDouble(),
      feelsLike: baseTemp + (dayOffset % 5) - 2.0,
      condition: condition,
      humidity: 45 + (dayOffset % 40),
      windSpeed: 5 + (dayOffset % 15).toDouble(),
      description: _getWeatherDescription(condition),
      iconCode: condition.name,
    );
  }

  String _getWeatherDescription(WeatherCondition condition) {
    switch (condition) {
      case WeatherCondition.sunny:
        return 'Sunny with clear skies';
      case WeatherCondition.cloudy:
        return 'Partly cloudy';
      case WeatherCondition.rainy:
        return 'Light rain expected';
      case WeatherCondition.snowy:
        return 'Snow possible';
      case WeatherCondition.windy:
        return 'Windy conditions';
      case WeatherCondition.stormy:
        return 'Thunderstorms likely';
    }
  }

  @override
  Future<Either<Failure, List<PlannedOutfit>>> getPlannedOutfits({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));
      
      final filteredOutfits = _plannedOutfits.where((outfit) {
        return outfit.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
               outfit.date.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();
      
      // Sort by date
      filteredOutfits.sort((a, b) => a.date.compareTo(b.date));
      
      return Right(filteredOutfits);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load planned outfits: $e'));
    }
  }

  @override
  Future<Either<Failure, PlannedOutfit?>> getPlannedOutfitForDate(DateTime date) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      
      final outfit = _plannedOutfits.where((outfit) {
        return outfit.date.day == date.day &&
               outfit.date.month == date.month &&
               outfit.date.year == date.year;
      }).firstOrNull;
      
      return Right(outfit);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get planned outfit: $e'));
    }
  }

  @override
  Future<Either<Failure, PlannedOutfit>> createPlannedOutfit(PlannedOutfit outfit) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Check if outfit already exists for this date
      final existingOutfit = await getPlannedOutfitForDate(outfit.date);
      if (existingOutfit.isRight()) {
        final result = existingOutfit.getOrElse(() => null);
        if (result != null) {
          return Left(ConflictFailure(message: 'Outfit already planned for this date'));
        }
      }
      
      final newOutfit = outfit.copyWith(
        id: 'planned_${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
      );
      
      _plannedOutfits.add(newOutfit);
      return Right(newOutfit);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to create planned outfit: $e'));
    }
  }

  @override
  Future<Either<Failure, PlannedOutfit>> updatePlannedOutfit(PlannedOutfit outfit) async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      
      final index = _plannedOutfits.indexWhere((item) => item.id == outfit.id);
      if (index == -1) {
        return Left(NotFoundFailure(message: 'Planned outfit not found'));
      }
      
      _plannedOutfits[index] = outfit;
      return Right(outfit);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to update planned outfit: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deletePlannedOutfit(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      
      final index = _plannedOutfits.indexWhere((item) => item.id == id);
      if (index == -1) {
        return Left(NotFoundFailure(message: 'Planned outfit not found'));
      }
      
      _plannedOutfits.removeAt(index);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to delete planned outfit: $e'));
    }
  }

  @override
  Future<Either<Failure, PlannedOutfit>> markOutfitCompleted(String id) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      
      final index = _plannedOutfits.indexWhere((item) => item.id == id);
      if (index == -1) {
        return Left(NotFoundFailure(message: 'Planned outfit not found'));
      }
      
      final updatedOutfit = _plannedOutfits[index].copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
      );
      
      _plannedOutfits[index] = updatedOutfit;
      return Right(updatedOutfit);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to mark outfit completed: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<DateTime, WeatherData>>> getWeatherData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      
      final weatherMap = <DateTime, WeatherData>{};
      
      for (final entry in _weatherCache.entries) {
        if (entry.key.isAfter(startDate.subtract(const Duration(days: 1))) &&
            entry.key.isBefore(endDate.add(const Duration(days: 1)))) {
          weatherMap[entry.key] = entry.value;
        }
      }
      
      return Right(weatherMap);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load weather data: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getWeatherBasedSuggestions({
    required DateTime date,
    required List<ClothingItem> availableItems,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      
      final weatherData = _weatherCache[date];
      if (weatherData == null) {
        return const Right(['No weather data available']);
      }
      
      final suggestions = <String>[];
      
      if (weatherData.isWarmWeather) {
        suggestions.addAll([
          'Light cotton or linen fabrics',
          'Short sleeves or sleeveless tops',
          'Breathable footwear',
          'Sun hat for outdoor activities',
        ]);
      } else if (weatherData.requiresLayers) {
        suggestions.addAll([
          'Layer with a cardigan or jacket',
          'Long sleeves for warmth',
          'Closed-toe shoes',
          'Consider a warm scarf',
        ]);
      }
      
      if (weatherData.needsRainProtection) {
        suggestions.addAll([
          'Waterproof or water-resistant jacket',
          'Waterproof footwear',
          'Avoid delicate fabrics',
          'Bring an umbrella',
        ]);
      }
      
      return Right(suggestions.isNotEmpty ? suggestions : ['Perfect weather for any outfit!']);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get weather suggestions: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getPlanningStats() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      final totalPlanned = _plannedOutfits.length;
      final completed = _plannedOutfits.where((outfit) => outfit.isCompleted).length;
      final completionRate = totalPlanned > 0 ? (completed / totalPlanned * 100).round() : 0;
      
      final stats = {
        'totalPlanned': totalPlanned,
        'completed': completed,
        'completionRate': completionRate,
        'thisWeekPlanned': _plannedOutfits.where((outfit) {
          final now = DateTime.now();
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          final endOfWeek = startOfWeek.add(const Duration(days: 6));
          return outfit.date.isAfter(startOfWeek) && outfit.date.isBefore(endOfWeek);
        }).length,
        'favoriteTags': _getMostUsedTags(),
      };
      
      return Right(stats);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get planning stats: $e'));
    }
  }

  List<String> _getMostUsedTags() {
    final tagCount = <String, int>{};
    
    for (final outfit in _plannedOutfits) {
      for (final tag in outfit.tags) {
        tagCount[tag] = (tagCount[tag] ?? 0) + 1;
      }
    }
    
    final sortedTags = tagCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedTags.take(5).map((e) => e.key).toList();
  }

  @override
  Future<Either<Failure, List<PlannedOutfit>>> searchPlannedOutfits(String query) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      
      final lowerQuery = query.toLowerCase();
      final filtered = _plannedOutfits.where((outfit) {
        return (outfit.outfitName?.toLowerCase().contains(lowerQuery) ?? false) ||
               (outfit.notes?.toLowerCase().contains(lowerQuery) ?? false) ||
               outfit.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
      }).toList();
      
      return Right(filtered);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to search planned outfits: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getOutfitRecommendations({
    required DateTime date,
    required List<ClothingItem> availableItems,
    WeatherData? weatherData,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      
      final recommendations = <String>[
        'Business casual with navy blazer',
        'Comfortable weekend look',
        'Elegant dinner outfit',
        'Sporty active wear',
        'Cozy casual combination',
      ];
      
      return Right(recommendations);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get recommendations: $e'));
    }
  }

  @override
  Future<Either<Failure, List<PlannedOutfit>>> batchCreatePlannedOutfits(List<PlannedOutfit> outfits) async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      
      final createdOutfits = <PlannedOutfit>[];
      
      for (final outfit in outfits) {
        final result = await createPlannedOutfit(outfit);
        if (result.isRight()) {
          createdOutfits.add(result.getOrElse(() => outfit));
        }
      }
      
      return Right(createdOutfits);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to batch create outfits: $e'));
    }
  }

  @override
  Future<Either<Failure, List<PlannedOutfit>>> getRecentlyCompletedOutfits({int limit = 10}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      
      final completed = _plannedOutfits
          .where((outfit) => outfit.isCompleted)
          .toList()
        ..sort((a, b) => (b.completedAt ?? b.createdAt).compareTo(a.completedAt ?? a.createdAt));
      
      return Right(completed.take(limit).toList());
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get completed outfits: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> hasPlannedOutfitForDate(DateTime date) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      
      final hasOutfit = _plannedOutfits.any((outfit) =>
          outfit.date.day == date.day &&
          outfit.date.month == date.month &&
          outfit.date.year == date.year);
      
      return Right(hasOutfit);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to check planned outfit: $e'));
    }
  }
}

// Additional failure types for specific planner scenarios
class ConflictFailure extends Failure {
  ConflictFailure({required String message}) : super(message: message);
}

class NotFoundFailure extends Failure {
  NotFoundFailure({required String message}) : super(message: message);
}

class ServerFailure extends Failure {
  ServerFailure({required String message}) : super(message: message);
}
