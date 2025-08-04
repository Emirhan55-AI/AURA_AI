import '../../domain/entities/social_post.dart';

/// Data model for social posts
/// Handles serialization/deserialization to/from JSON
class SocialPostModel {
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

  /// Creates a new SocialPostModel instance
  const SocialPostModel({
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

  /// Creates a SocialPostModel from a JSON map
  factory SocialPostModel.fromJson(Map<String, dynamic> json) {
    // Extract user profile data
    final userProfile = json['user_profile'] as Map<String, dynamic>;

    return SocialPostModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      imageUrl: json['image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      username: userProfile['username'] as String,
      avatarUrl: userProfile['avatar_url'] as String?,
      likeCount: (json['like_count'] as int?) ?? 0,
      commentCount: (json['comment_count'] as int?) ?? 0,
      isLikedByCurrentUser: (json['is_liked_by_user'] as bool?) ?? false,
    );
  }

  /// Converts this model to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'content': content,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
      'user_profile': {
        'username': username,
        'avatar_url': avatarUrl,
      },
      'like_count': likeCount,
      'comment_count': commentCount,
      'is_liked_by_user': isLikedByCurrentUser,
    };
  }

  /// Converts this model to a domain entity
  SocialPost toEntity() {
    return SocialPost(
      id: id,
      userId: userId,
      content: content,
      imageUrl: imageUrl,
      createdAt: createdAt,
      username: username,
      avatarUrl: avatarUrl,
      likeCount: likeCount,
      commentCount: commentCount,
      isLikedByCurrentUser: isLikedByCurrentUser,
    );
  }

  /// Creates a model from a domain entity
  factory SocialPostModel.fromEntity(SocialPost entity) {
    return SocialPostModel(
      id: entity.id,
      userId: entity.userId,
      content: entity.content,
      imageUrl: entity.imageUrl,
      createdAt: entity.createdAt,
      username: entity.username,
      avatarUrl: entity.avatarUrl,
      likeCount: entity.likeCount,
      commentCount: entity.commentCount,
      isLikedByCurrentUser: entity.isLikedByCurrentUser,
    );
  }
}
