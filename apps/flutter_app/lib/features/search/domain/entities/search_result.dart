/// Base class for all search results
abstract class SearchResult {
  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final DateTime createdAt;

  const SearchResult({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    required this.createdAt,
  });
}

/// Search result for clothing items
class SearchResultItem extends SearchResult {
  final String category;
  final String? brand;
  final String? color;
  final String? size;
  final double? price;
  final List<String> tags;

  const SearchResultItem({
    required super.id,
    required super.title,
    super.description,
    super.imageUrl,
    required super.createdAt,
    required this.category,
    this.brand,
    this.color,
    this.size,
    this.price,
    this.tags = const [],
  });
}

/// Search result for outfits
class SearchResultOutfit extends SearchResult {
  final String userId;
  final String? userName;
  final int itemCount;
  final List<String> itemIds;
  final String style;
  final String occasion;

  const SearchResultOutfit({
    required super.id,
    required super.title,
    super.description,
    super.imageUrl,
    required super.createdAt,
    required this.userId,
    this.userName,
    required this.itemCount,
    this.itemIds = const [],
    required this.style,
    required this.occasion,
  });
}

/// Search result for social posts
class SearchResultPost extends SearchResult {
  final String userId;
  final String userName;
  final String? userAvatar;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final List<String> hashtags;

  const SearchResultPost({
    required super.id,
    required super.title,
    super.description,
    super.imageUrl,
    required super.createdAt,
    required this.userId,
    required this.userName,
    this.userAvatar,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLiked = false,
    this.hashtags = const [],
  });
}

/// Search result for users
class SearchResultUser extends SearchResult {
  final String username;
  final String? bio;
  final String? avatarUrl;
  final int followersCount;
  final int followingCount;
  final bool isFollowing;
  final bool isVerified;

  const SearchResultUser({
    required super.id,
    required super.title, // Display name
    super.description,
    super.imageUrl,
    required super.createdAt,
    required this.username,
    this.bio,
    this.avatarUrl,
    this.followersCount = 0,
    this.followingCount = 0,
    this.isFollowing = false,
    this.isVerified = false,
  });
}

/// Search result for swap listings
class SearchResultSwap extends SearchResult {
  final String userId;
  final String userName;
  final String? userAvatar;
  final List<String> offeredItemIds;
  final List<String> wantedItemIds;
  final String status;
  final String location;

  const SearchResultSwap({
    required super.id,
    required super.title,
    super.description,
    super.imageUrl,
    required super.createdAt,
    required this.userId,
    required this.userName,
    this.userAvatar,
    this.offeredItemIds = const [],
    this.wantedItemIds = const [],
    required this.status,
    required this.location,
  });
}

/// Search result for style challenges
class SearchResultChallenge extends SearchResult {
  final String theme;
  final DateTime startDate;
  final DateTime endDate;
  final int participantsCount;
  final bool isParticipating;
  final List<String> prizes;
  final String difficulty;

  const SearchResultChallenge({
    required super.id,
    required super.title,
    super.description,
    super.imageUrl,
    required super.createdAt,
    required this.theme,
    required this.startDate,
    required this.endDate,
    this.participantsCount = 0,
    this.isParticipating = false,
    this.prizes = const [],
    required this.difficulty,
  });
}

/// Combined search results container
class SearchResults {
  final List<SearchResultItem> items;
  final List<SearchResultOutfit> outfits;
  final List<SearchResultPost> posts;
  final List<SearchResultUser> users;
  final List<SearchResultSwap> swaps;
  final List<SearchResultChallenge> challenges;

  const SearchResults({
    this.items = const [],
    this.outfits = const [],
    this.posts = const [],
    this.users = const [],
    this.swaps = const [],
    this.challenges = const [],
  });

  int get totalCount =>
      items.length +
      outfits.length +
      posts.length +
      users.length +
      swaps.length +
      challenges.length;

  bool get isEmpty => totalCount == 0;
  bool get isNotEmpty => totalCount > 0;
}
