/// Social Post Model - Data structure for social feed posts
/// 
/// This model represents a social media post in the community feed.
/// It contains all the necessary information for displaying posts in the UI.
class SocialPost {
  final String id;
  final String authorName;
  final String? authorAvatar;
  final String imageUrl;
  final String caption;
  final List<String> tags;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final bool isSaved;
  final DateTime createdAt;
  final bool isNsfw;

  const SocialPost({
    required this.id,
    required this.authorName,
    this.authorAvatar,
    required this.imageUrl,
    required this.caption,
    required this.tags,
    required this.likesCount,
    required this.commentsCount,
    required this.isLiked,
    required this.isSaved,
    required this.createdAt,
    this.isNsfw = false,
  });

  /// Creates a copy of this post with the given fields replaced
  SocialPost copyWith({
    String? id,
    String? authorName,
    String? authorAvatar,
    String? imageUrl,
    String? caption,
    List<String>? tags,
    int? likesCount,
    int? commentsCount,
    bool? isLiked,
    bool? isSaved,
    DateTime? createdAt,
    bool? isNsfw,
  }) {
    return SocialPost(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      imageUrl: imageUrl ?? this.imageUrl,
      caption: caption ?? this.caption,
      tags: tags ?? this.tags,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      createdAt: createdAt ?? this.createdAt,
      isNsfw: isNsfw ?? this.isNsfw,
    );
  }

  /// Sample posts for demonstration purposes
  static List<SocialPost> getSamplePosts() {
    return [
      SocialPost(
        id: '1',
        authorName: 'Sarah Chen',
        authorAvatar: 'https://picsum.photos/40/40?random=1',
        imageUrl: 'https://picsum.photos/400/500?random=1',
        caption: 'Perfect autumn vibes with this cozy sweater and boots combo! 🍂✨',
        tags: ['autumn', 'cozy', 'sweater', 'boots'],
        likesCount: 124,
        commentsCount: 18,
        isLiked: false,
        isSaved: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      SocialPost(
        id: '2',
        authorName: 'Alex Rivera',
        authorAvatar: 'https://picsum.photos/40/40?random=2',
        imageUrl: 'https://picsum.photos/400/600?random=2',
        caption: 'Business meeting ready! This blazer was a game-changer for my confidence 💼',
        tags: ['business', 'blazer', 'professional', 'confidence'],
        likesCount: 89,
        commentsCount: 12,
        isLiked: true,
        isSaved: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      SocialPost(
        id: '3',
        authorName: 'Maya Patel',
        authorAvatar: 'https://picsum.photos/40/40?random=3',
        imageUrl: 'https://picsum.photos/400/450?random=3',
        caption: 'Weekend vibes! Sometimes simple is just perfect 🌸',
        tags: ['weekend', 'casual', 'simple', 'comfort'],
        likesCount: 156,
        commentsCount: 24,
        isLiked: false,
        isSaved: false,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      SocialPost(
        id: '4',
        authorName: 'Jordan Kim',
        authorAvatar: 'https://picsum.photos/40/40?random=4',
        imageUrl: 'https://picsum.photos/400/550?random=4',
        caption: 'Date night outfit! Feeling elegant and confident ✨💕',
        tags: ['date', 'elegant', 'night', 'dress'],
        likesCount: 203,
        commentsCount: 31,
        isLiked: true,
        isSaved: false,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      SocialPost(
        id: '5',
        authorName: 'Taylor Johnson',
        authorAvatar: 'https://picsum.photos/40/40?random=5',
        imageUrl: 'https://picsum.photos/400/480?random=5',
        caption: 'Gym to brunch transition! Athleisure is life 🏃‍♀️☕',
        tags: ['athleisure', 'gym', 'brunch', 'transition'],
        likesCount: 92,
        commentsCount: 8,
        isLiked: false,
        isSaved: true,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }
}
