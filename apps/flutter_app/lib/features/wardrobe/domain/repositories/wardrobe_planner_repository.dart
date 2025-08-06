import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../models/planned_outfit.dart';
import '../entities/clothing_item.dart';

/// Repository interface for wardrobe planner operations
/// Extends wardrobe functionality with planning and scheduling
abstract class WardrobePlannerRepository {
  /// Gets all planned outfits for a specific date range
  Future<Either<Failure, List<PlannedOutfit>>> getPlannedOutfits({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Gets planned outfit for a specific date
  Future<Either<Failure, PlannedOutfit?>> getPlannedOutfitForDate(DateTime date);

  /// Creates a new planned outfit
  Future<Either<Failure, PlannedOutfit>> createPlannedOutfit(PlannedOutfit outfit);

  /// Updates an existing planned outfit
  Future<Either<Failure, PlannedOutfit>> updatePlannedOutfit(PlannedOutfit outfit);

  /// Deletes a planned outfit
  Future<Either<Failure, void>> deletePlannedOutfit(String id);

  /// Marks a planned outfit as completed
  Future<Either<Failure, PlannedOutfit>> markOutfitCompleted(String id);

  /// Gets weather data for a specific date range
  Future<Either<Failure, Map<DateTime, WeatherData>>> getWeatherData({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Gets outfit suggestions based on weather and wardrobe
  Future<Either<Failure, List<String>>> getWeatherBasedSuggestions({
    required DateTime date,
    required List<ClothingItem> availableItems,
  });

  /// Gets planning statistics (completion rate, favorite items, etc.)
  Future<Either<Failure, Map<String, dynamic>>> getPlanningStats();

  /// Searches planned outfits by name, notes, or tags
  Future<Either<Failure, List<PlannedOutfit>>> searchPlannedOutfits(String query);

  /// Gets outfit recommendations for a specific date
  Future<Either<Failure, List<String>>> getOutfitRecommendations({
    required DateTime date,
    required List<ClothingItem> availableItems,
    WeatherData? weatherData,
  });

  /// Batch creates multiple planned outfits
  Future<Either<Failure, List<PlannedOutfit>>> batchCreatePlannedOutfits(List<PlannedOutfit> outfits);

  /// Gets recently completed outfits
  Future<Either<Failure, List<PlannedOutfit>>> getRecentlyCompletedOutfits({int limit = 10});

  /// Checks if a date has a planned outfit
  Future<Either<Failure, bool>> hasPlannedOutfitForDate(DateTime date);
}
