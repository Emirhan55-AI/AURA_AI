/// Favorite entity representing a user's favorited item
/// 
/// This entity represents different types of content that users can favorite:
/// - Products (clothing items)
/// - Combinations (outfits)
/// - Posts (social media posts)
/// - Swap Listings (items available for swapping)
class Favorite {
  final String id;
  final String userId;
  final String itemId;
  final FavoriteType type;
  final DateTime createdAt;
  final Map<String, dynamic> metadata; // Additional data specific to the favorite type

  const Favorite({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.type,
    required this.createdAt,
    this.metadata = const {},
  });

  /// Creates a copy of this favorite with the given fields replaced
  Favorite copyWith({
    String? id,
    String? userId,
    String? itemId,
    FavoriteType? type,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return Favorite(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      itemId: itemId ?? this.itemId,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Favorite &&
        other.id == id &&
        other.userId == userId &&
        other.itemId == itemId &&
        other.type == type &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        itemId.hashCode ^
        type.hashCode ^
        createdAt.hashCode;
  }

  @override
  String toString() {
    return 'Favorite(id: $id, userId: $userId, itemId: $itemId, type: $type, createdAt: $createdAt)';
  }
}

/// Types of content that can be favorited
enum FavoriteType {
  product('product'),
  combination('combination'),
  post('post'),
  swapListing('swap_listing');

  const FavoriteType(this.value);
  final String value;

  /// Creates a FavoriteType from its string value
  static FavoriteType fromString(String value) {
    return FavoriteType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => throw ArgumentError('Invalid favorite type: $value'),
    );
  }
}

/// Extension for UI-related operations on FavoriteType
extension FavoriteTypeExtension on FavoriteType {
  /// Display name for the favorite type
  String get displayName {
    switch (this) {
      case FavoriteType.product:
        return 'Products';
      case FavoriteType.combination:
        return 'Combinations';
      case FavoriteType.post:
        return 'Posts';
      case FavoriteType.swapListing:
        return 'Swap Listings';
    }
  }

  /// Icon name for the favorite type
  String get iconName {
    switch (this) {
      case FavoriteType.product:
        return 'shopping_bag';
      case FavoriteType.combination:
        return 'style';
      case FavoriteType.post:
        return 'photo';
      case FavoriteType.swapListing:
        return 'swap_horiz';
    }
  }
}
