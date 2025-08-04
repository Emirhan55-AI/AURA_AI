import 'package:flutter/material.dart';
import '../../domain/entities/social_post.dart';

/// SocialPostViewModel - Adapter class for UI display
///
/// This adapter converts the domain entity SocialPost to a format 
/// that is compatible with existing UI components.
class SocialPostViewModel {
  final String id;
  final String authorName;
  final String? authorAvatar;
  final String? imageUrl;
  final String caption;
  final List<String> tags;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final bool isSaved;
  final DateTime createdAt;

  const SocialPostViewModel({
    required this.id,
    required this.authorName,
    this.authorAvatar,
    this.imageUrl,
    required this.caption,
    required this.tags,
    required this.likesCount,
    required this.commentsCount,
    required this.isLiked,
    required this.isSaved,
    required this.createdAt,
  });

  /// Convert domain entity to view model
  factory SocialPostViewModel.fromEntity(SocialPost entity) {
    // Extract tags from content (simple implementation)
    final List<String> tags = entity.content
        .split(' ')
        .where((word) => word.startsWith('#'))
        .map((tag) => tag.substring(1))
        .toList();

    return SocialPostViewModel(
      id: entity.id,
      authorName: entity.username,
      authorAvatar: entity.avatarUrl,
      imageUrl: entity.imageUrl,
      caption: entity.content,
      tags: tags,
      likesCount: entity.likeCount,
      commentsCount: entity.commentCount,
      isLiked: entity.isLikedByCurrentUser,
      isSaved: false, // Not tracked in the domain model yet
      createdAt: entity.createdAt,
    );
  }

  /// Creates a copy of this post with the given fields replaced
  SocialPostViewModel copyWith({
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
  }) {
    return SocialPostViewModel(
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
    );
  }
}
