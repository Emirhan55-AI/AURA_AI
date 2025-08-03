/// Data models for Social Post Detail UI
/// These are temporary models for UI structure - will be replaced with proper domain models

class SocialPostDetail {
  final String id;
  final String authorId;
  final String authorDisplayName;
  final String? authorAvatarUrl;
  final String combinationId;
  final String imageUrl;
  final String caption;
  final DateTime timestamp;
  final int likeCount;
  final int commentCount;
  final bool isLikedByCurrentUser;
  final bool isSavedByCurrentUser;
  final bool isNSFW;
  final List<Comment> comments;

  const SocialPostDetail({
    required this.id,
    required this.authorId,
    required this.authorDisplayName,
    this.authorAvatarUrl,
    required this.combinationId,
    required this.imageUrl,
    required this.caption,
    required this.timestamp,
    required this.likeCount,
    required this.commentCount,
    required this.isLikedByCurrentUser,
    required this.isSavedByCurrentUser,
    required this.isNSFW,
    required this.comments,
  });

  SocialPostDetail copyWith({
    String? id,
    String? authorId,
    String? authorDisplayName,
    String? authorAvatarUrl,
    String? combinationId,
    String? imageUrl,
    String? caption,
    DateTime? timestamp,
    int? likeCount,
    int? commentCount,
    bool? isLikedByCurrentUser,
    bool? isSavedByCurrentUser,
    bool? isNSFW,
    List<Comment>? comments,
  }) {
    return SocialPostDetail(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorDisplayName: authorDisplayName ?? this.authorDisplayName,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      combinationId: combinationId ?? this.combinationId,
      imageUrl: imageUrl ?? this.imageUrl,
      caption: caption ?? this.caption,
      timestamp: timestamp ?? this.timestamp,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
      isSavedByCurrentUser: isSavedByCurrentUser ?? this.isSavedByCurrentUser,
      isNSFW: isNSFW ?? this.isNSFW,
      comments: comments ?? this.comments,
    );
  }

  /// Sample post detail for UI development
  static SocialPostDetail getSample() {
    return SocialPostDetail(
      id: '1',
      authorId: 'user_1',
      authorDisplayName: 'Sarah Chen',
      authorAvatarUrl: 'https://picsum.photos/40/40?random=1',
      combinationId: 'combo_1',
      imageUrl: 'https://picsum.photos/400/600?random=1',
      caption: 'Perfect autumn vibes with this cozy sweater and boots combo! 🍂✨ I love how the warm tones complement each other and create such a comfortable yet stylish look. This outfit is perfect for those crisp fall days when you want to look put-together but still feel cozy.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      likeCount: 124,
      commentCount: 18,
      isLikedByCurrentUser: false,
      isSavedByCurrentUser: true,
      isNSFW: false,
      comments: Comment.getSampleComments(),
    );
  }
}

class Comment {
  final String id;
  final String authorId;
  final String authorDisplayName;
  final String? authorAvatarUrl;
  final String text;
  final DateTime timestamp;
  final int likeCount;
  final bool isLikedByCurrentUser;

  const Comment({
    required this.id,
    required this.authorId,
    required this.authorDisplayName,
    this.authorAvatarUrl,
    required this.text,
    required this.timestamp,
    required this.likeCount,
    required this.isLikedByCurrentUser,
  });

  Comment copyWith({
    String? id,
    String? authorId,
    String? authorDisplayName,
    String? authorAvatarUrl,
    String? text,
    DateTime? timestamp,
    int? likeCount,
    bool? isLikedByCurrentUser,
  }) {
    return Comment(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorDisplayName: authorDisplayName ?? this.authorDisplayName,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      likeCount: likeCount ?? this.likeCount,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
    );
  }

  /// Sample comments for UI development
  static List<Comment> getSampleComments() {
    return [
      Comment(
        id: '1',
        authorId: 'user_2',
        authorDisplayName: 'Emma Wilson',
        authorAvatarUrl: 'https://picsum.photos/32/32?random=2',
        text: 'Love this look! Where did you get that sweater? 😍',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        likeCount: 12,
        isLikedByCurrentUser: true,
      ),
      Comment(
        id: '2',
        authorId: 'user_3',
        authorDisplayName: 'Maya Rodriguez',
        authorAvatarUrl: 'https://picsum.photos/32/32?random=3',
        text: 'Such perfect autumn vibes! The color coordination is amazing.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
        likeCount: 8,
        isLikedByCurrentUser: false,
      ),
      Comment(
        id: '3',
        authorId: 'user_4',
        authorDisplayName: 'Alex Kim',
        authorAvatarUrl: 'https://picsum.photos/32/32?random=4',
        text: 'This is exactly what I need for my fall wardrobe! Thanks for the inspiration 🍂',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        likeCount: 5,
        isLikedByCurrentUser: false,
      ),
      Comment(
        id: '4',
        authorId: 'user_5',
        authorDisplayName: 'Jordan Thompson',
        authorAvatarUrl: 'https://picsum.photos/32/32?random=5',
        text: 'The boots are perfect! 👢✨',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        likeCount: 3,
        isLikedByCurrentUser: false,
      ),
    ];
  }
}
