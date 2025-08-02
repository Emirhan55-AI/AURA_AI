class Outfit {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final List<String> clothingItemIds;
  final String? occasion;
  final String? season;
  final String? weather;
  final String? style;
  final List<String>? tags;
  final String? imageUrl;
  final Map<String, dynamic>? metadata;
  final bool isFavorite;
  final bool isPublic;
  final int wearCount;
  final DateTime? lastWorn;
  final double? rating;
  final List<String>? colors;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const Outfit({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.clothingItemIds,
    this.occasion,
    this.season,
    this.weather,
    this.style,
    this.tags,
    this.imageUrl,
    this.metadata,
    this.isFavorite = false,
    this.isPublic = false,
    this.wearCount = 0,
    this.lastWorn,
    this.rating,
    this.colors,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  @override
  String toString() {
    return 'Outfit(id: $id, userId: $userId, name: $name, occasion: $occasion, wearCount: $wearCount)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Outfit &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  Outfit copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    List<String>? clothingItemIds,
    String? occasion,
    String? season,
    String? weather,
    String? style,
    List<String>? tags,
    String? imageUrl,
    Map<String, dynamic>? metadata,
    bool? isFavorite,
    bool? isPublic,
    int? wearCount,
    DateTime? lastWorn,
    double? rating,
    List<String>? colors,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Outfit(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      clothingItemIds: clothingItemIds ?? this.clothingItemIds,
      occasion: occasion ?? this.occasion,
      season: season ?? this.season,
      weather: weather ?? this.weather,
      style: style ?? this.style,
      tags: tags ?? this.tags,
      imageUrl: imageUrl ?? this.imageUrl,
      metadata: metadata ?? this.metadata,
      isFavorite: isFavorite ?? this.isFavorite,
      isPublic: isPublic ?? this.isPublic,
      wearCount: wearCount ?? this.wearCount,
      lastWorn: lastWorn ?? this.lastWorn,
      rating: rating ?? this.rating,
      colors: colors ?? this.colors,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  /// Check if outfit is deleted (soft delete)
  bool get isDeleted => deletedAt != null;

  /// Get the number of clothing items in this outfit
  int get itemCount => clothingItemIds.length;

  /// Check if outfit was worn recently (within last 30 days)
  bool get isRecentlyWorn {
    if (lastWorn == null) return false;
    return DateTime.now().difference(lastWorn!).inDays <= 30;
  }

  /// Get outfit freshness score based on wear count and last worn date
  double get freshnessScore {
    if (wearCount == 0) return 1.0;
    
    final daysSinceLastWorn = lastWorn != null 
        ? DateTime.now().difference(lastWorn!).inDays 
        : 365;
    
    // Higher score for less worn and longer time since last wear
    final wearFrequencyScore = 1.0 / (wearCount + 1);
    final timeScore = (daysSinceLastWorn / 365.0).clamp(0.0, 1.0);
    
    return (wearFrequencyScore + timeScore) / 2.0;
  }
}
