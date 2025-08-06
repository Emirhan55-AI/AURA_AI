/// Enhanced analytics data for wardrobe and style insights
class UserAnalytics {
  // Wardrobe Analytics
  final int totalItems;
  final int wornItems;
  final int unwornItems;
  final double wearRatio; // 0.0 to 1.0
  final Map<String, int> categoryDistribution;
  final Map<String, int> colorDistribution;
  final Map<String, int> brandDistribution;
  
  // Style Analytics
  final Map<String, int> stylePreferences;
  final List<String> topStyles;
  final Map<String, double> seasonalPreferences;
  final List<OutfitInsight> recentInsights;
  
  // Usage Analytics
  final int daysActive;
  final int outfitsCreated;
  final int outfitsWorn;
  final double averageOutfitsPerWeek;
  final Map<String, int> weeklyActivity;
  
  // Social Analytics
  final int totalLikes;
  final int totalShares;
  final int totalComments;
  final double socialEngagementRate;
  final List<String> topHashtags;
  
  // Sustainability Analytics
  final double sustainabilityScore; // 0.0 to 100.0
  final int itemsSwapped;
  final int itemsRecycled;
  final double costPerWear;
  final double totalWardrobeValue;
  
  // Achievement Analytics
  final int streakDays;
  final int badgesEarned;
  final List<Achievement> recentAchievements;
  
  // Time-based Analytics
  final DateTime lastUpdated;
  final Map<String, double> monthlyTrends;

  const UserAnalytics({
    required this.totalItems,
    required this.wornItems,
    required this.unwornItems,
    required this.wearRatio,
    required this.categoryDistribution,
    required this.colorDistribution,
    required this.brandDistribution,
    required this.stylePreferences,
    required this.topStyles,
    required this.seasonalPreferences,
    required this.recentInsights,
    required this.daysActive,
    required this.outfitsCreated,
    required this.outfitsWorn,
    required this.averageOutfitsPerWeek,
    required this.weeklyActivity,
    required this.totalLikes,
    required this.totalShares,
    required this.totalComments,
    required this.socialEngagementRate,
    required this.topHashtags,
    required this.sustainabilityScore,
    required this.itemsSwapped,
    required this.itemsRecycled,
    required this.costPerWear,
    required this.totalWardrobeValue,
    required this.streakDays,
    required this.badgesEarned,
    required this.recentAchievements,
    required this.lastUpdated,
    required this.monthlyTrends,
  });

  UserAnalytics copyWith({
    int? totalItems,
    int? wornItems,
    int? unwornItems,
    double? wearRatio,
    Map<String, int>? categoryDistribution,
    Map<String, int>? colorDistribution,  
    Map<String, int>? brandDistribution,
    Map<String, int>? stylePreferences,
    List<String>? topStyles,
    Map<String, double>? seasonalPreferences,
    List<OutfitInsight>? recentInsights,
    int? daysActive,
    int? outfitsCreated,
    int? outfitsWorn,
    double? averageOutfitsPerWeek,
    Map<String, int>? weeklyActivity,
    int? totalLikes,
    int? totalShares,
    int? totalComments,
    double? socialEngagementRate,
    List<String>? topHashtags,
    double? sustainabilityScore,
    int? itemsSwapped,
    int? itemsRecycled,
    double? costPerWear,
    double? totalWardrobeValue,
    int? streakDays,
    int? badgesEarned,
    List<Achievement>? recentAchievements,
    DateTime? lastUpdated,
    Map<String, double>? monthlyTrends,
  }) {
    return UserAnalytics(
      totalItems: totalItems ?? this.totalItems,
      wornItems: wornItems ?? this.wornItems,
      unwornItems: unwornItems ?? this.unwornItems,
      wearRatio: wearRatio ?? this.wearRatio,
      categoryDistribution: categoryDistribution ?? this.categoryDistribution,
      colorDistribution: colorDistribution ?? this.colorDistribution,
      brandDistribution: brandDistribution ?? this.brandDistribution,
      stylePreferences: stylePreferences ?? this.stylePreferences,
      topStyles: topStyles ?? this.topStyles,
      seasonalPreferences: seasonalPreferences ?? this.seasonalPreferences,
      recentInsights: recentInsights ?? this.recentInsights,
      daysActive: daysActive ?? this.daysActive,
      outfitsCreated: outfitsCreated ?? this.outfitsCreated,
      outfitsWorn: outfitsWorn ?? this.outfitsWorn,
      averageOutfitsPerWeek: averageOutfitsPerWeek ?? this.averageOutfitsPerWeek,
      weeklyActivity: weeklyActivity ?? this.weeklyActivity,
      totalLikes: totalLikes ?? this.totalLikes,
      totalShares: totalShares ?? this.totalShares,
      totalComments: totalComments ?? this.totalComments,
      socialEngagementRate: socialEngagementRate ?? this.socialEngagementRate,
      topHashtags: topHashtags ?? this.topHashtags,
      sustainabilityScore: sustainabilityScore ?? this.sustainabilityScore,
      itemsSwapped: itemsSwapped ?? this.itemsSwapped,
      itemsRecycled: itemsRecycled ?? this.itemsRecycled,
      costPerWear: costPerWear ?? this.costPerWear,
      totalWardrobeValue: totalWardrobeValue ?? this.totalWardrobeValue,
      streakDays: streakDays ?? this.streakDays,
      badgesEarned: badgesEarned ?? this.badgesEarned,
      recentAchievements: recentAchievements ?? this.recentAchievements,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      monthlyTrends: monthlyTrends ?? this.monthlyTrends,
    );
  }

  factory UserAnalytics.fromJson(Map<String, dynamic> json) {
    return UserAnalytics(
      totalItems: json['totalItems'] as int,
      wornItems: json['wornItems'] as int,
      unwornItems: json['unwornItems'] as int,
      wearRatio: (json['wearRatio'] as num).toDouble(),
      categoryDistribution: Map<String, int>.from(json['categoryDistribution'] as Map),
      colorDistribution: Map<String, int>.from(json['colorDistribution'] as Map),
      brandDistribution: Map<String, int>.from(json['brandDistribution'] as Map),
      stylePreferences: Map<String, int>.from(json['stylePreferences'] as Map),
      topStyles: List<String>.from(json['topStyles'] as List),
      seasonalPreferences: Map<String, double>.from(
        (json['seasonalPreferences'] as Map)
            .map((key, value) => MapEntry(key, (value as num).toDouble())),
      ),
      recentInsights: (json['recentInsights'] as List)
          .map((e) => OutfitInsight.fromJson(e as Map<String, dynamic>))
          .toList(),
      daysActive: json['daysActive'] as int,
      outfitsCreated: json['outfitsCreated'] as int,
      outfitsWorn: json['outfitsWorn'] as int,
      averageOutfitsPerWeek: (json['averageOutfitsPerWeek'] as num).toDouble(),
      weeklyActivity: Map<String, int>.from(json['weeklyActivity'] as Map),
      totalLikes: json['totalLikes'] as int,
      totalShares: json['totalShares'] as int,
      totalComments: json['totalComments'] as int,
      socialEngagementRate: (json['socialEngagementRate'] as num).toDouble(),
      topHashtags: List<String>.from(json['topHashtags'] as List),
      sustainabilityScore: (json['sustainabilityScore'] as num).toDouble(),
      itemsSwapped: json['itemsSwapped'] as int,
      itemsRecycled: json['itemsRecycled'] as int,
      costPerWear: (json['costPerWear'] as num).toDouble(),
      totalWardrobeValue: (json['totalWardrobeValue'] as num).toDouble(),
      streakDays: json['streakDays'] as int,
      badgesEarned: json['badgesEarned'] as int,
      recentAchievements: (json['recentAchievements'] as List)
          .map((e) => Achievement.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      monthlyTrends: Map<String, double>.from(
        (json['monthlyTrends'] as Map)
            .map((key, value) => MapEntry(key, (value as num).toDouble())),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalItems': totalItems,
      'wornItems': wornItems,
      'unwornItems': unwornItems,
      'wearRatio': wearRatio,
      'categoryDistribution': categoryDistribution,
      'colorDistribution': colorDistribution,
      'brandDistribution': brandDistribution,
      'stylePreferences': stylePreferences,
      'topStyles': topStyles,
      'seasonalPreferences': seasonalPreferences,
      'recentInsights': recentInsights.map((e) => e.toJson()).toList(),
      'daysActive': daysActive,
      'outfitsCreated': outfitsCreated,
      'outfitsWorn': outfitsWorn,
      'averageOutfitsPerWeek': averageOutfitsPerWeek,
      'weeklyActivity': weeklyActivity,
      'totalLikes': totalLikes,
      'totalShares': totalShares,
      'totalComments': totalComments,
      'socialEngagementRate': socialEngagementRate,
      'topHashtags': topHashtags,
      'sustainabilityScore': sustainabilityScore,
      'itemsSwapped': itemsSwapped,
      'itemsRecycled': itemsRecycled,
      'costPerWear': costPerWear,
      'totalWardrobeValue': totalWardrobeValue,
      'streakDays': streakDays,
      'badgesEarned': badgesEarned,
      'recentAchievements': recentAchievements.map((e) => e.toJson()).toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'monthlyTrends': monthlyTrends,
    };
  }
}

/// Individual outfit insight for style recommendations
class OutfitInsight {
  final String id;
  final String type; // 'recommendation', 'trend', 'seasonal'
  final String title;
  final String description;
  final String iconCode;
  final String colorHex;
  final DateTime createdAt;
  final String? actionText;
  final String? actionUrl;

  const OutfitInsight({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.iconCode,
    required this.colorHex,
    required this.createdAt,
    this.actionText,
    this.actionUrl,
  });

  OutfitInsight copyWith({
    String? id,
    String? type,
    String? title,
    String? description,
    String? iconCode,
    String? colorHex,
    DateTime? createdAt,
    String? actionText,
    String? actionUrl,
  }) {
    return OutfitInsight(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      iconCode: iconCode ?? this.iconCode,
      colorHex: colorHex ?? this.colorHex,
      createdAt: createdAt ?? this.createdAt,
      actionText: actionText ?? this.actionText,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }

  factory OutfitInsight.fromJson(Map<String, dynamic> json) {
    return OutfitInsight(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      iconCode: json['iconCode'] as String,
      colorHex: json['colorHex'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      actionText: json['actionText'] as String?,
      actionUrl: json['actionUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'description': description,
      'iconCode': iconCode,
      'colorHex': colorHex,
      'createdAt': createdAt.toIso8601String(),
      'actionText': actionText,
      'actionUrl': actionUrl,
    };
  }
}

/// Achievement data for gamification
class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconCode;
  final String category; // 'style', 'social', 'sustainability', etc.
  final int points;
  final DateTime unlockedAt;
  final bool isNew;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconCode,
    required this.category,
    required this.points,
    required this.unlockedAt,
    required this.isNew,
  });

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? iconCode,
    String? category,
    int? points,
    DateTime? unlockedAt,
    bool? isNew,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconCode: iconCode ?? this.iconCode,
      category: category ?? this.category,
      points: points ?? this.points,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      isNew: isNew ?? this.isNew,
    );
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      iconCode: json['iconCode'] as String,
      category: json['category'] as String,
      points: json['points'] as int,
      unlockedAt: DateTime.parse(json['unlockedAt'] as String),
      isNew: json['isNew'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconCode': iconCode,
      'category': category,
      'points': points,
      'unlockedAt': unlockedAt.toIso8601String(),
      'isNew': isNew,
    };
  }
}

/// Detailed statistics for each category
class CategoryStats {
  final String categoryName;
  final int totalItems;
  final int wornItems;
  final double wearRatio;
  final double averageWearCount;
  final String mostWornItem;
  final String leastWornItem;
  final List<String> topBrands;
  final List<String> topColors;
  final double categoryValue;
  final double costPerWear;

  const CategoryStats({
    required this.categoryName,
    required this.totalItems,
    required this.wornItems,
    required this.wearRatio,
    required this.averageWearCount,
    required this.mostWornItem,
    required this.leastWornItem,
    required this.topBrands,
    required this.topColors,
    required this.categoryValue,
    required this.costPerWear,
  });

  CategoryStats copyWith({
    String? categoryName,
    int? totalItems,
    int? wornItems,
    double? wearRatio,
    double? averageWearCount,
    String? mostWornItem,
    String? leastWornItem,
    List<String>? topBrands,
    List<String>? topColors,
    double? categoryValue,
    double? costPerWear,
  }) {
    return CategoryStats(
      categoryName: categoryName ?? this.categoryName,
      totalItems: totalItems ?? this.totalItems,
      wornItems: wornItems ?? this.wornItems,
      wearRatio: wearRatio ?? this.wearRatio,
      averageWearCount: averageWearCount ?? this.averageWearCount,
      mostWornItem: mostWornItem ?? this.mostWornItem,
      leastWornItem: leastWornItem ?? this.leastWornItem,
      topBrands: topBrands ?? this.topBrands,
      topColors: topColors ?? this.topColors,
      categoryValue: categoryValue ?? this.categoryValue,
      costPerWear: costPerWear ?? this.costPerWear,
    );
  }

  factory CategoryStats.fromJson(Map<String, dynamic> json) {
    return CategoryStats(
      categoryName: json['categoryName'] as String,
      totalItems: json['totalItems'] as int,
      wornItems: json['wornItems'] as int,
      wearRatio: (json['wearRatio'] as num).toDouble(),
      averageWearCount: (json['averageWearCount'] as num).toDouble(),
      mostWornItem: json['mostWornItem'] as String,
      leastWornItem: json['leastWornItem'] as String,
      topBrands: List<String>.from(json['topBrands'] as List),
      topColors: List<String>.from(json['topColors'] as List),
      categoryValue: (json['categoryValue'] as num).toDouble(),
      costPerWear: (json['costPerWear'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryName': categoryName,
      'totalItems': totalItems,
      'wornItems': wornItems,
      'wearRatio': wearRatio,
      'averageWearCount': averageWearCount,
      'mostWornItem': mostWornItem,
      'leastWornItem': leastWornItem,
      'topBrands': topBrands,
      'topColors': topColors,
      'categoryValue': categoryValue,
      'costPerWear': costPerWear,
    };
  }
}

/// Style preference data with insights
class StylePreference {
  final String styleName;
  final double preference; // 0.0 to 1.0
  final int outfitsCount;
  final double socialEngagement;
  final List<String> associatedColors;
  final List<String> associatedCategories;
  final Map<String, double> seasonalUsage;
  final String trend; // 'increasing', 'stable', 'decreasing'

  const StylePreference({
    required this.styleName,
    required this.preference,
    required this.outfitsCount,
    required this.socialEngagement,
    required this.associatedColors,
    required this.associatedCategories,
    required this.seasonalUsage,
    required this.trend,
  });

  StylePreference copyWith({
    String? styleName,
    double? preference,
    int? outfitsCount,
    double? socialEngagement,
    List<String>? associatedColors,
    List<String>? associatedCategories,
    Map<String, double>? seasonalUsage,
    String? trend,
  }) {
    return StylePreference(
      styleName: styleName ?? this.styleName,
      preference: preference ?? this.preference,
      outfitsCount: outfitsCount ?? this.outfitsCount,
      socialEngagement: socialEngagement ?? this.socialEngagement,
      associatedColors: associatedColors ?? this.associatedColors,
      associatedCategories: associatedCategories ?? this.associatedCategories,
      seasonalUsage: seasonalUsage ?? this.seasonalUsage,
      trend: trend ?? this.trend,
    );
  }

  factory StylePreference.fromJson(Map<String, dynamic> json) {
    return StylePreference(
      styleName: json['styleName'] as String,
      preference: (json['preference'] as num).toDouble(),
      outfitsCount: json['outfitsCount'] as int,
      socialEngagement: (json['socialEngagement'] as num).toDouble(),
      associatedColors: List<String>.from(json['associatedColors'] as List),
      associatedCategories: List<String>.from(json['associatedCategories'] as List),
      seasonalUsage: Map<String, double>.from(
        (json['seasonalUsage'] as Map)
            .map((key, value) => MapEntry(key, (value as num).toDouble())),
      ),
      trend: json['trend'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'styleName': styleName,
      'preference': preference,
      'outfitsCount': outfitsCount,
      'socialEngagement': socialEngagement,
      'associatedColors': associatedColors,
      'associatedCategories': associatedCategories,
      'seasonalUsage': seasonalUsage,
      'trend': trend,
    };
  }
}
