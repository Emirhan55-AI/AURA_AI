import 'package:flutter/material.dart';

/// Data models for Wardrobe Analytics UI structure
/// These are temporary models used only for UI implementation
/// Final domain models will be implemented in the domain layer later

enum TimeRange {
  last7Days,
  last30Days,
  allTime,
}

extension TimeRangeExtension on TimeRange {
  String get displayName {
    switch (this) {
      case TimeRange.last7Days:
        return 'Last 7 Days';
      case TimeRange.last30Days:
        return 'Last 30 Days';
      case TimeRange.allTime:
        return 'All Time';
    }
  }
}

/// Wardrobe analytics data for UI display
class WardrobeAnalyticsData {
  final CategoryDistribution categoryDistribution;
  final List<ColorData> colorPalette;
  final List<WearFrequencyData> wearFrequency;
  final int totalItems;
  final double averageWearCount;

  const WardrobeAnalyticsData({
    required this.categoryDistribution,
    required this.colorPalette,
    required this.wearFrequency,
    required this.totalItems,
    required this.averageWearCount,
  });
}

/// Category distribution data for pie chart
class CategoryDistribution {
  final List<CategoryData> categories;

  const CategoryDistribution({required this.categories});
}

class CategoryData {
  final String name;
  final int count;
  final double percentage;
  final String color; // Hex color string

  const CategoryData({
    required this.name,
    required this.count,
    required this.percentage,
    required this.color,
  });
}

/// Color palette data
class ColorData {
  final String colorHex;
  final int itemCount;
  final double percentage;

  const ColorData({
    required this.colorHex,
    required this.itemCount,
    required this.percentage,
  });
}

/// Wear frequency data for bar chart
class WearFrequencyData {
  final String itemName;
  final int wearCount;
  final String category;

  const WearFrequencyData({
    required this.itemName,
    required this.wearCount,
    required this.category,
  });
}

/// Insight data for insights tab
class Insight {
  final String id;
  final String title;
  final String description;
  final InsightActionType actionType;
  final Map<String, dynamic>? actionPayload;
  final bool isFavorite;
  final IconData icon;
  final String priority; // 'high', 'medium', 'low'

  const Insight({
    required this.id,
    required this.title,
    required this.description,
    required this.actionType,
    this.actionPayload,
    required this.isFavorite,
    required this.icon,
    required this.priority,
  });

  Insight copyWith({
    String? id,
    String? title,
    String? description,
    InsightActionType? actionType,
    Map<String, dynamic>? actionPayload,
    bool? isFavorite,
    IconData? icon,
    String? priority,
  }) {
    return Insight(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      actionType: actionType ?? this.actionType,
      actionPayload: actionPayload ?? this.actionPayload,
      isFavorite: isFavorite ?? this.isFavorite,
      icon: icon ?? this.icon,
      priority: priority ?? this.priority,
    );
  }
}

enum InsightActionType {
  viewItems,
  addToWardrobe,
  createOutfit,
  shoppingList,
  none,
}

/// Shopping guide item data for shopping guide tab
class ShoppingGuideItem {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String aiQuery;
  final String category;
  final String priority; // 'essential', 'recommended', 'optional'
  final List<String> tags;

  const ShoppingGuideItem({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.aiQuery,
    required this.category,
    required this.priority,
    required this.tags,
  });
}
