import 'comment.dart';

/// Domain entity representing a social post
class SocialPost {
  final String id;
  final String userId;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;
  final String username;
  final String? avatarUrl;
  final int likeCount;
  final int commentCount;
  final bool isLikedByCurrentUser;

  /// Creates a new SocialPost instance
  const SocialPost({
    required this.id,
    required this.userId,
    required this.content,
    this.imageUrl,
    required this.createdAt,
    required this.username,
    this.avatarUrl,
    required this.likeCount,
    required this.commentCount,
    required this.isLikedByCurrentUser,
  });

  /// Creates a copy of this SocialPost with the specified fields updated
  SocialPost copyWith({
    String? id,
    String? userId,
    String? content,
    String? imageUrl,
    DateTime? createdAt,
    String? username,
    String? avatarUrl,
    int? likeCount,
    int? commentCount,
    bool? isLikedByCurrentUser,
  }) {
    return SocialPost(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SocialPost &&
        other.id == id &&
        other.userId == userId &&
        other.content == content &&
        other.imageUrl == imageUrl &&
        other.createdAt == createdAt &&
        other.username == username &&
        other.avatarUrl == avatarUrl &&
        other.likeCount == likeCount &&
        other.commentCount == commentCount &&
        other.isLikedByCurrentUser == isLikedByCurrentUser;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      content.hashCode ^
      imageUrl.hashCode ^
      createdAt.hashCode ^
      username.hashCode ^
      avatarUrl.hashCode ^
      likeCount.hashCode ^
      commentCount.hashCode ^
      isLikedByCurrentUser.hashCode;
}
