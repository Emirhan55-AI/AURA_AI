import '../../domain/entities/comment.dart';

/// Data model for comments on social posts
/// Handles serialization/deserialization to/from JSON
class CommentModel {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final DateTime createdAt;
  final String username;
  final String? avatarUrl;

  /// Creates a new CommentModel instance
  const CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.createdAt,
    required this.username,
    this.avatarUrl,
  });

  /// Creates a CommentModel from a JSON map
  factory CommentModel.fromJson(Map<String, dynamic> json) {
    // Extract user profile data
    final userProfile = json['user_profile'] as Map<String, dynamic>;

    return CommentModel(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      username: userProfile['username'] as String,
      avatarUrl: userProfile['avatar_url'] as String?,
    );
  }

  /// Converts this model to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'user_profile': {
        'username': username,
        'avatar_url': avatarUrl,
      },
    };
  }

  /// Converts this model to a domain entity
  Comment toEntity() {
    return Comment(
      id: id,
      postId: postId,
      userId: userId,
      content: content,
      createdAt: createdAt,
      username: username,
      avatarUrl: avatarUrl,
    );
  }

  /// Creates a model from a domain entity
  factory CommentModel.fromEntity(Comment entity) {
    return CommentModel(
      id: entity.id,
      postId: entity.postId,
      userId: entity.userId,
      content: entity.content,
      createdAt: entity.createdAt,
      username: entity.username,
      avatarUrl: entity.avatarUrl,
    );
  }
}
