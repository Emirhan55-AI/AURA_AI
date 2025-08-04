/// Temporary UI models for Favorites Screen structure
/// These are placeholder models for building the UI and will be replaced with domain models later

/// Generic favoritable item for UI structure
class FavoritableItem {
  final String id;
  final String name;
  final String? imageUrl;
  final bool isFavorite;
  final DateTime favoriteDate;

  const FavoritableItem({
    required this.id,
    required this.name,
    this.imageUrl,
    this.isFavorite = true,
    required this.favoriteDate,
  });
}

/// Favorite clothing item placeholder
class FavoriteClothingItem extends FavoritableItem {
  final String brand;
  final String category;
  final String color;
  final double? price;

  const FavoriteClothingItem({
    required super.id,
    required super.name,
    super.imageUrl,
    super.isFavorite = true,
    required super.favoriteDate,
    required this.brand,
    required this.category,
    required this.color,
    this.price,
  });
}

/// Favorite outfit/combination placeholder
class FavoriteOutfit extends FavoritableItem {
  final int itemCount;
  final List<String> tags;
  final String occasion;

  const FavoriteOutfit({
    required super.id,
    required super.name,
    super.imageUrl,
    super.isFavorite = true,
    required super.favoriteDate,
    required this.itemCount,
    this.tags = const [],
    required this.occasion,
  });
}

/// Favorite social post placeholder
class FavoriteSocialPost extends FavoritableItem {
  final String authorName;
  final String? authorAvatar;
  final int likesCount;
  final int commentsCount;

  const FavoriteSocialPost({
    required super.id,
    required super.name,
    super.imageUrl,
    super.isFavorite = true,
    required super.favoriteDate,
    required this.authorName,
    this.authorAvatar,
    required this.likesCount,
    required this.commentsCount,
  });
}

/// Favorite swap listing placeholder
class FavoriteSwapListing extends FavoritableItem {
  final String ownerName;
  final String? ownerAvatar;
  final String condition;
  final String size;
  final bool isAvailable;

  const FavoriteSwapListing({
    required super.id,
    required super.name,
    super.imageUrl,
    super.isFavorite = true,
    required super.favoriteDate,
    required this.ownerName,
    this.ownerAvatar,
    required this.condition,
    required this.size,
    this.isAvailable = true,
  });
}

/// Favorite tab types
enum FavoriteTabType {
  products('Products'),
  combinations('Combinations'), 
  posts('Posts'),
  swapListings('Swap Listings');

  const FavoriteTabType(this.displayName);
  final String displayName;
}
