import 'package:flutter/material.dart';

/// Enum for different analytics time periods
enum AnalyticsPeriod {
  week,
  month,
  quarter,
  season,
  year,
  allTime,
}

/// Extension for AnalyticsPeriod display and functionality
extension AnalyticsPeriodExtension on AnalyticsPeriod {
  String get displayName {
    switch (this) {
      case AnalyticsPeriod.week:
        return 'This Week';
      case AnalyticsPeriod.month:
        return 'This Month';
      case AnalyticsPeriod.quarter:
        return 'This Quarter';
      case AnalyticsPeriod.season:
        return 'This Season';
      case AnalyticsPeriod.year:
        return 'This Year';
      case AnalyticsPeriod.allTime:
        return 'All Time';
    }
  }

  String get shortName {
    switch (this) {
      case AnalyticsPeriod.week:
        return 'Week';
      case AnalyticsPeriod.month:
        return 'Month';
      case AnalyticsPeriod.quarter:
        return 'Quarter';
      case AnalyticsPeriod.season:
        return 'Season';
      case AnalyticsPeriod.year:
        return 'Year';
      case AnalyticsPeriod.allTime:
        return 'All Time';
    }
  }

  int get daysCount {
    switch (this) {
      case AnalyticsPeriod.week:
        return 7;
      case AnalyticsPeriod.month:
        return 30;
      case AnalyticsPeriod.quarter:
        return 90;
      case AnalyticsPeriod.season:
        return 90;
      case AnalyticsPeriod.year:
        return 365;
      case AnalyticsPeriod.allTime:
        return 3650; // 10 years
    }
  }

  IconData get icon {
    switch (this) {
      case AnalyticsPeriod.week:
        return Icons.view_week;
      case AnalyticsPeriod.month:
        return Icons.calendar_view_month;
      case AnalyticsPeriod.quarter:
        return Icons.calendar_today;
      case AnalyticsPeriod.season:
        return Icons.nature;
      case AnalyticsPeriod.year:
        return Icons.date_range;
      case AnalyticsPeriod.allTime:
        return Icons.history;
    }
  }
}

/// Data model for wardrobe usage analytics
class WardrobeAnalytics {
  final String id;
  final String userId;
  final AnalyticsPeriod period;
  final DateTime startDate;
  final DateTime endDate;
  final WardrobeUsageStats usageStats;
  final List<CategoryStats> categoryStats;
  final List<ColorAnalysis> colorAnalysis;
  final List<OutfitFrequency> mostWornOutfits;
  final List<ItemFrequency> mostWornItems;
  final List<ItemFrequency> leastWornItems;
  final SustainabilityMetrics sustainabilityMetrics;
  final StyleTrends styleTrends;
  final List<WardrobeRecommendation> recommendations;
  final DateTime generatedAt;

  const WardrobeAnalytics({
    required this.id,
    required this.userId,
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.usageStats,
    required this.categoryStats,
    required this.colorAnalysis,
    required this.mostWornOutfits,
    required this.mostWornItems,
    required this.leastWornItems,
    required this.sustainabilityMetrics,
    required this.styleTrends,
    required this.recommendations,
    required this.generatedAt,
  });

  WardrobeAnalytics copyWith({
    String? id,
    String? userId,
    AnalyticsPeriod? period,
    DateTime? startDate,
    DateTime? endDate,
    WardrobeUsageStats? usageStats,
    List<CategoryStats>? categoryStats,
    List<ColorAnalysis>? colorAnalysis,
    List<OutfitFrequency>? mostWornOutfits,
    List<ItemFrequency>? mostWornItems,
    List<ItemFrequency>? leastWornItems,
    SustainabilityMetrics? sustainabilityMetrics,
    StyleTrends? styleTrends,
    List<WardrobeRecommendation>? recommendations,
    DateTime? generatedAt,
  }) {
    return WardrobeAnalytics(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      usageStats: usageStats ?? this.usageStats,
      categoryStats: categoryStats ?? this.categoryStats,
      colorAnalysis: colorAnalysis ?? this.colorAnalysis,
      mostWornOutfits: mostWornOutfits ?? this.mostWornOutfits,
      mostWornItems: mostWornItems ?? this.mostWornItems,
      leastWornItems: leastWornItems ?? this.leastWornItems,
      sustainabilityMetrics: sustainabilityMetrics ?? this.sustainabilityMetrics,
      styleTrends: styleTrends ?? this.styleTrends,
      recommendations: recommendations ?? this.recommendations,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }
}

/// Overall wardrobe usage statistics
class WardrobeUsageStats {
  final int totalItems;
  final int wornItems;
  final int unwornItems;
  final double usagePercentage;
  final int totalOutfits;
  final int uniqueOutfitsWorn;
  final int averageWearPerItem;
  final double costPerWear;
  final int newItemsAdded;
  final int itemsRemoved;

  const WardrobeUsageStats({
    required this.totalItems,
    required this.wornItems,
    required this.unwornItems,
    required this.usagePercentage,
    required this.totalOutfits,
    required this.uniqueOutfitsWorn,
    required this.averageWearPerItem,
    required this.costPerWear,
    required this.newItemsAdded,
    required this.itemsRemoved,
  });

  WardrobeUsageStats copyWith({
    int? totalItems,
    int? wornItems,
    int? unwornItems,
    double? usagePercentage,
    int? totalOutfits,
    int? uniqueOutfitsWorn,
    int? averageWearPerItem,
    double? costPerWear,
    int? newItemsAdded,
    int? itemsRemoved,
  }) {
    return WardrobeUsageStats(
      totalItems: totalItems ?? this.totalItems,
      wornItems: wornItems ?? this.wornItems,
      unwornItems: unwornItems ?? this.unwornItems,
      usagePercentage: usagePercentage ?? this.usagePercentage,
      totalOutfits: totalOutfits ?? this.totalOutfits,
      uniqueOutfitsWorn: uniqueOutfitsWorn ?? this.uniqueOutfitsWorn,
      averageWearPerItem: averageWearPerItem ?? this.averageWearPerItem,
      costPerWear: costPerWear ?? this.costPerWear,
      newItemsAdded: newItemsAdded ?? this.newItemsAdded,
      itemsRemoved: itemsRemoved ?? this.itemsRemoved,
    );
  }
}

/// Statistics for clothing categories
class CategoryStats {
  final String category;
  final int totalItems;
  final int wornItems;
  final double usageRate;
  final double totalSpent;
  final double costPerWear;
  final int timesWorn;
  final Color displayColor;

  const CategoryStats({
    required this.category,
    required this.totalItems,
    required this.wornItems,
    required this.usageRate,
    required this.totalSpent,
    required this.costPerWear,
    required this.timesWorn,
    required this.displayColor,
  });

  CategoryStats copyWith({
    String? category,
    int? totalItems,
    int? wornItems,
    double? usageRate,
    double? totalSpent,
    double? costPerWear,
    int? timesWorn,
    Color? displayColor,
  }) {
    return CategoryStats(
      category: category ?? this.category,
      totalItems: totalItems ?? this.totalItems,
      wornItems: wornItems ?? this.wornItems,
      usageRate: usageRate ?? this.usageRate,
      totalSpent: totalSpent ?? this.totalSpent,
      costPerWear: costPerWear ?? this.costPerWear,
      timesWorn: timesWorn ?? this.timesWorn,
      displayColor: displayColor ?? this.displayColor,
    );
  }
}

/// Color usage analysis
class ColorAnalysis {
  final String colorName;
  final Color color;
  final int itemCount;
  final int timesWorn;
  final double percentage;
  final bool isTrending;
  final List<String> categories;

  const ColorAnalysis({
    required this.colorName,
    required this.color,
    required this.itemCount,
    required this.timesWorn,
    required this.percentage,
    required this.isTrending,
    required this.categories,
  });

  ColorAnalysis copyWith({
    String? colorName,
    Color? color,
    int? itemCount,
    int? timesWorn,
    double? percentage,
    bool? isTrending,
    List<String>? categories,
  }) {
    return ColorAnalysis(
      colorName: colorName ?? this.colorName,
      color: color ?? this.color,
      itemCount: itemCount ?? this.itemCount,
      timesWorn: timesWorn ?? this.timesWorn,
      percentage: percentage ?? this.percentage,
      isTrending: isTrending ?? this.isTrending,
      categories: categories ?? this.categories,
    );
  }
}

/// Outfit frequency tracking
class OutfitFrequency {
  final String outfitId;
  final String outfitName;
  final List<String> itemIds;
  final int timesWorn;
  final DateTime lastWorn;
  final String? imageUrl;
  final List<String> occasions;
  final double rating;

  const OutfitFrequency({
    required this.outfitId,
    required this.outfitName,
    required this.itemIds,
    required this.timesWorn,
    required this.lastWorn,
    this.imageUrl,
    required this.occasions,
    required this.rating,
  });

  OutfitFrequency copyWith({
    String? outfitId,
    String? outfitName,
    List<String>? itemIds,
    int? timesWorn,
    DateTime? lastWorn,
    String? imageUrl,
    List<String>? occasions,
    double? rating,
  }) {
    return OutfitFrequency(
      outfitId: outfitId ?? this.outfitId,
      outfitName: outfitName ?? this.outfitName,
      itemIds: itemIds ?? this.itemIds,
      timesWorn: timesWorn ?? this.timesWorn,
      lastWorn: lastWorn ?? this.lastWorn,
      imageUrl: imageUrl ?? this.imageUrl,
      occasions: occasions ?? this.occasions,
      rating: rating ?? this.rating,
    );
  }
}

/// Individual item frequency tracking
class ItemFrequency {
  final String itemId;
  final String itemName;
  final String category;
  final int timesWorn;
  final DateTime lastWorn;
  final String? imageUrl;
  final double costPerWear;
  final double versatilityScore;

  const ItemFrequency({
    required this.itemId,
    required this.itemName,
    required this.category,
    required this.timesWorn,
    required this.lastWorn,
    this.imageUrl,
    required this.costPerWear,
    required this.versatilityScore,
  });

  ItemFrequency copyWith({
    String? itemId,
    String? itemName,
    String? category,
    int? timesWorn,
    DateTime? lastWorn,
    String? imageUrl,
    double? costPerWear,
    double? versatilityScore,
  }) {
    return ItemFrequency(
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      category: category ?? this.category,
      timesWorn: timesWorn ?? this.timesWorn,
      lastWorn: lastWorn ?? this.lastWorn,
      imageUrl: imageUrl ?? this.imageUrl,
      costPerWear: costPerWear ?? this.costPerWear,
      versatilityScore: versatilityScore ?? this.versatilityScore,
    );
  }
}

/// Sustainability metrics for conscious fashion
class SustainabilityMetrics {
  final double totalWardroeValue;
  final double averageCostPerWear;
  final int sustainableItems;
  final double sustainabilityScore;
  final int itemsNeedingAttention;
  final double co2Saved;
  final int secondHandItems;
  final int donatedItems;

  const SustainabilityMetrics({
    required this.totalWardroeValue,
    required this.averageCostPerWear,
    required this.sustainableItems,
    required this.sustainabilityScore,
    required this.itemsNeedingAttention,
    required this.co2Saved,
    required this.secondHandItems,
    required this.donatedItems,
  });

  SustainabilityMetrics copyWith({
    double? totalWardroeValue,
    double? averageCostPerWear,
    int? sustainableItems,
    double? sustainabilityScore,
    int? itemsNeedingAttention,
    double? co2Saved,
    int? secondHandItems,
    int? donatedItems,
  }) {
    return SustainabilityMetrics(
      totalWardroeValue: totalWardroeValue ?? this.totalWardroeValue,
      averageCostPerWear: averageCostPerWear ?? this.averageCostPerWear,
      sustainableItems: sustainableItems ?? this.sustainableItems,
      sustainabilityScore: sustainabilityScore ?? this.sustainabilityScore,
      itemsNeedingAttention: itemsNeedingAttention ?? this.itemsNeedingAttention,
      co2Saved: co2Saved ?? this.co2Saved,
      secondHandItems: secondHandItems ?? this.secondHandItems,
      donatedItems: donatedItems ?? this.donatedItems,
    );
  }
}

/// Style trends analysis
class StyleTrends {
  final List<String> emergingStyles;
  final List<String> decliningStyles;
  final Map<String, double> stylePreferences;
  final List<String> seasonalTrends;
  final String dominantStyle;
  final double styleConsistency;

  const StyleTrends({
    required this.emergingStyles,
    required this.decliningStyles,
    required this.stylePreferences,
    required this.seasonalTrends,
    required this.dominantStyle,
    required this.styleConsistency,
  });

  StyleTrends copyWith({
    List<String>? emergingStyles,
    List<String>? decliningStyles,
    Map<String, double>? stylePreferences,
    List<String>? seasonalTrends,
    String? dominantStyle,
    double? styleConsistency,
  }) {
    return StyleTrends(
      emergingStyles: emergingStyles ?? this.emergingStyles,
      decliningStyles: decliningStyles ?? this.decliningStyles,
      stylePreferences: stylePreferences ?? this.stylePreferences,
      seasonalTrends: seasonalTrends ?? this.seasonalTrends,
      dominantStyle: dominantStyle ?? this.dominantStyle,
      styleConsistency: styleConsistency ?? this.styleConsistency,
    );
  }
}

/// Wardrobe recommendations based on analytics
class WardrobeRecommendation {
  final String id;
  final RecommendationType type;
  final String title;
  final String description;
  final String actionText;
  final IconData icon;
  final Color color;
  final int priority;
  final List<String> relatedItemIds;
  final Map<String, dynamic>? metadata;

  const WardrobeRecommendation({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.actionText,
    required this.icon,
    required this.color,
    required this.priority,
    required this.relatedItemIds,
    this.metadata,
  });

  WardrobeRecommendation copyWith({
    String? id,
    RecommendationType? type,
    String? title,
    String? description,
    String? actionText,
    IconData? icon,
    Color? color,
    int? priority,
    List<String>? relatedItemIds,
    Map<String, dynamic>? metadata,
  }) {
    return WardrobeRecommendation(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      actionText: actionText ?? this.actionText,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      priority: priority ?? this.priority,
      relatedItemIds: relatedItemIds ?? this.relatedItemIds,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Types of wardrobe recommendations
enum RecommendationType {
  addItem,
  removeItem,
  tryOutfit,
  createOutfit,
  sustainability,
  budget,
  organization,
  style,
}

/// Extension for RecommendationType functionality
extension RecommendationTypeExtension on RecommendationType {
  String get displayName {
    switch (this) {
      case RecommendationType.addItem:
        return 'Add Item';
      case RecommendationType.removeItem:
        return 'Remove Item';
      case RecommendationType.tryOutfit:
        return 'Try Outfit';
      case RecommendationType.createOutfit:
        return 'Create Outfit';
      case RecommendationType.sustainability:
        return 'Sustainability';
      case RecommendationType.budget:
        return 'Budget';
      case RecommendationType.organization:
        return 'Organization';
      case RecommendationType.style:
        return 'Style';
    }
  }

  IconData get defaultIcon {
    switch (this) {
      case RecommendationType.addItem:
        return Icons.add_shopping_cart;
      case RecommendationType.removeItem:
        return Icons.remove_circle_outline;
      case RecommendationType.tryOutfit:
        return Icons.style;
      case RecommendationType.createOutfit:
        return Icons.palette;
      case RecommendationType.sustainability:
        return Icons.eco;
      case RecommendationType.budget:
        return Icons.savings;
      case RecommendationType.organization:
        return Icons.folder_open;
      case RecommendationType.style:
        return Icons.auto_awesome;
    }
  }

  Color get defaultColor {
    switch (this) {
      case RecommendationType.addItem:
        return Colors.green;
      case RecommendationType.removeItem:
        return Colors.red;
      case RecommendationType.tryOutfit:
        return Colors.purple;
      case RecommendationType.createOutfit:
        return Colors.blue;
      case RecommendationType.sustainability:
        return Colors.teal;
      case RecommendationType.budget:
        return Colors.orange;
      case RecommendationType.organization:
        return Colors.indigo;
      case RecommendationType.style:
        return Colors.pink;
    }
  }
}

/// Extensions for WardrobeAnalytics
extension WardrobeAnalyticsExtensions on WardrobeAnalytics {
  /// Get the most worn category
  CategoryStats? get mostWornCategory {
    if (categoryStats.isEmpty) return null;
    return categoryStats.reduce((a, b) => a.timesWorn > b.timesWorn ? a : b);
  }

  /// Get the least worn category
  CategoryStats? get leastWornCategory {
    if (categoryStats.isEmpty) return null;
    return categoryStats.reduce((a, b) => a.timesWorn < b.timesWorn ? a : b);
  }

  /// Get dominant color
  ColorAnalysis? get dominantColor {
    if (colorAnalysis.isEmpty) return null;
    return colorAnalysis.reduce((a, b) => a.percentage > b.percentage ? a : b);
  }

  /// Get high priority recommendations
  List<WardrobeRecommendation> get highPriorityRecommendations {
    return recommendations.where((r) => r.priority >= 8).toList()
      ..sort((a, b) => b.priority.compareTo(a.priority));
  }

  /// Check if wardrobe is well-utilized
  bool get isWellUtilized => usageStats.usagePercentage >= 70;

  /// Check if wardrobe is sustainable
  bool get isSustainable => sustainabilityMetrics.sustainabilityScore >= 75;

  /// Get usage trend (improving/declining)
  String get usageTrend {
    if (usageStats.usagePercentage >= 75) return 'Excellent';
    if (usageStats.usagePercentage >= 60) return 'Good';
    if (usageStats.usagePercentage >= 40) return 'Fair';
    return 'Needs Improvement';
  }

  /// Format the analytics period display
  String get periodDisplay {
    return '${period.displayName} (${startDate.day}/${startDate.month} - ${endDate.day}/${endDate.month})';
  }
}
