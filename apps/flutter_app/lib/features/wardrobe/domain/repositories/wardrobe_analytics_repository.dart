import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../models/wardrobe_analytics.dart';
import '../entities/clothing_item.dart';

/// Repository interface for wardrobe analytics operations
/// Provides methods for generating, retrieving, and managing wardrobe usage analytics
abstract class WardrobeAnalyticsRepository {
  /// Generate analytics for a specific period
  /// Returns comprehensive wardrobe usage statistics and insights
  Future<Either<Failure, WardrobeAnalytics>> generateAnalytics({
    required String userId,
    required AnalyticsPeriod period,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get cached analytics for a specific period
  /// Returns previously generated analytics if available
  Future<Either<Failure, WardrobeAnalytics?>> getCachedAnalytics({
    required String userId,
    required AnalyticsPeriod period,
    DateTime? date,
  });

  /// Get usage statistics for specific items
  /// Returns detailed usage metrics for selected clothing items
  Future<Either<Failure, List<ItemFrequency>>> getItemUsageStats({
    required List<String> itemIds,
    required AnalyticsPeriod period,
  });

  /// Get outfit frequency statistics
  /// Returns most and least worn outfit combinations
  Future<Either<Failure, List<OutfitFrequency>>> getOutfitFrequencyStats({
    required String userId,
    required AnalyticsPeriod period,
    int limit = 10,
  });

  /// Get category breakdown analytics
  /// Returns usage statistics grouped by clothing categories
  Future<Either<Failure, List<CategoryStats>>> getCategoryAnalytics({
    required String userId,
    required AnalyticsPeriod period,
  });

  /// Get color usage analysis
  /// Returns color preferences and trends in wardrobe usage
  Future<Either<Failure, List<ColorAnalysis>>> getColorAnalytics({
    required String userId,
    required AnalyticsPeriod period,
  });

  /// Get sustainability metrics
  /// Returns environmental impact and conscious fashion metrics
  Future<Either<Failure, SustainabilityMetrics>> getSustainabilityMetrics({
    required String userId,
    required AnalyticsPeriod period,
  });

  /// Get style trends analysis
  /// Returns evolving style preferences and trends
  Future<Either<Failure, StyleTrends>> getStyleTrends({
    required String userId,
    required AnalyticsPeriod period,
  });

  /// Get personalized wardrobe recommendations
  /// Returns AI-powered suggestions for wardrobe optimization
  Future<Either<Failure, List<WardrobeRecommendation>>> getRecommendations({
    required String userId,
    required AnalyticsPeriod period,
    int limit = 5,
  });

  /// Get comparative analytics
  /// Compares current period with previous period for trend analysis
  Future<Either<Failure, Map<String, dynamic>>> getComparativeAnalytics({
    required String userId,
    required AnalyticsPeriod currentPeriod,
    required AnalyticsPeriod comparePeriod,
  });

  /// Get wardrobe efficiency score
  /// Returns overall wardrobe utilization and efficiency metrics
  Future<Either<Failure, double>> getWardrobeEfficiencyScore({
    required String userId,
    required AnalyticsPeriod period,
  });

  /// Get cost analysis
  /// Returns cost per wear and budget optimization insights
  Future<Either<Failure, Map<String, dynamic>>> getCostAnalysis({
    required String userId,
    required AnalyticsPeriod period,
  });

  /// Get seasonal analytics
  /// Returns season-specific usage patterns and trends
  Future<Either<Failure, Map<String, dynamic>>> getSeasonalAnalytics({
    required String userId,
    required int year,
  });

  /// Track item usage event
  /// Records when an item is worn for analytics computation
  Future<Either<Failure, void>> trackItemUsage({
    required String userId,
    required String itemId,
    required DateTime wornDate,
    String? occasion,
    double? rating,
  });

  /// Track outfit usage event
  /// Records when an outfit combination is worn
  Future<Either<Failure, void>> trackOutfitUsage({
    required String userId,
    required List<String> itemIds,
    required DateTime wornDate,
    String? outfitName,
    String? occasion,
    double? rating,
  });

  /// Get usage timeline
  /// Returns chronological usage data for visualization
  Future<Either<Failure, List<Map<String, dynamic>>>> getUsageTimeline({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    String? itemId,
  });

  /// Get wardrobe growth analytics
  /// Returns data about wardrobe expansion and reduction over time
  Future<Either<Failure, Map<String, dynamic>>> getWardrobeGrowthAnalytics({
    required String userId,
    required AnalyticsPeriod period,
  });

  /// Get style consistency score
  /// Returns metrics on style coherence and consistency
  Future<Either<Failure, double>> getStyleConsistencyScore({
    required String userId,
    required AnalyticsPeriod period,
  });

  /// Get underutilized items
  /// Returns items that are rarely or never worn
  Future<Either<Failure, List<ClothingItem>>> getUnderutilizedItems({
    required String userId,
    required AnalyticsPeriod period,
    int minWearThreshold = 1,
  });

  /// Get versatility rankings
  /// Returns items ranked by how often they're used in different outfits
  Future<Either<Failure, List<ItemFrequency>>> getVersatilityRankings({
    required String userId,
    required AnalyticsPeriod period,
  });

  /// Get occasion-based analytics
  /// Returns usage patterns based on different occasions
  Future<Either<Failure, Map<String, dynamic>>> getOccasionAnalytics({
    required String userId,
    required AnalyticsPeriod period,
  });

  /// Export analytics data
  /// Returns analytics data in exportable format (CSV, JSON, etc.)
  Future<Either<Failure, Map<String, dynamic>>> exportAnalytics({
    required String userId,
    required AnalyticsPeriod period,
    required String format, // 'json', 'csv', 'pdf'
  });

  /// Get analytics insights summary
  /// Returns key insights and highlights in text format
  Future<Either<Failure, List<String>>> getAnalyticsInsights({
    required String userId,
    required AnalyticsPeriod period,
  });

  /// Cache analytics data
  /// Stores analytics results for faster subsequent access
  Future<Either<Failure, void>> cacheAnalytics({
    required WardrobeAnalytics analytics,
  });

  /// Clear analytics cache
  /// Removes cached analytics data for fresh computation
  Future<Either<Failure, void>> clearAnalyticsCache({
    required String userId,
    AnalyticsPeriod? period,
  });

  /// Get analytics computation status
  /// Returns the status of ongoing analytics computation
  Future<Either<Failure, Map<String, dynamic>>> getAnalyticsComputationStatus({
    required String userId,
  });

  /// Schedule analytics computation
  /// Schedules analytics generation for background processing
  Future<Either<Failure, void>> scheduleAnalyticsComputation({
    required String userId,
    required AnalyticsPeriod period,
    DateTime? scheduledTime,
  });
}
