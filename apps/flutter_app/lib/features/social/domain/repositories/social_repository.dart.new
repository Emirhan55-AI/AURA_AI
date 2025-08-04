import 'dart:io';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/social_post.dart';
import '../entities/comment.dart';

/// Repository interface for social feed functionality
abstract class SocialRepository {
  /// Get a paginated list of social posts
  /// 
  /// [page] The page number to fetch (1-based)
  /// [limit] The number of posts per page
  /// [filter] The filter type (all, following, trending)
  /// 
  /// Returns [Either] containing [List<SocialPost>] on success or [Failure] on error
  Future<Either<Failure, List<SocialPost>>> getPosts({
    int page = 1,
    int limit = 20,
    String filter = 'all',
  });
  
  /// Get a specific post by ID
  /// 
  /// [id] The ID of the post to fetch
  /// 
  /// Returns [Either] containing [SocialPost] on success or [Failure] on error
  Future<Either<Failure, SocialPost>> getPostById(String id);
  
  /// Get comments for a specific post
  /// 
  /// [postId] The ID of the post to fetch comments for
  /// [limit] The number of comments to fetch
  /// [offset] The number of comments to skip
  /// 
  /// Returns [Either] containing [List<Comment>] on success or [Failure] on error
  Future<Either<Failure, List<Comment>>> getComments(
    String postId, {
    int limit = 20,
    int offset = 0,
  });
  
  /// Create a new post
  /// 
  /// [content] The text content of the post
  /// [image] Optional image file to upload
  /// 
  /// Returns [Either] containing the created [SocialPost] on success or [Failure] on error
  Future<Either<Failure, SocialPost>> createPost(
    String content, {
    File? image,
  });
  
  /// Like or unlike a post
  /// 
  /// [postId] The ID of the post to like/unlike
  /// [like] Whether to like (true) or unlike (false) the post
  /// 
  /// Returns [Either] void on success or [Failure] on error
  Future<Either<Failure, void>> likePost(String postId, bool like);
  
  /// Add a comment to a post
  /// 
  /// [postId] The ID of the post to comment on
  /// [content] The text content of the comment
  /// 
  /// Returns [Either] containing the created [Comment] on success or [Failure] on error
  Future<Either<Failure, Comment>> createComment(String postId, String content);
  
  /// Delete a post
  /// 
  /// [postId] The ID of the post to delete
  /// 
  /// Returns [Either] void on success or [Failure] on error
  Future<Either<Failure, void>> deletePost(String postId);
  
  /// Delete a comment
  /// 
  /// [commentId] The ID of the comment to delete
  /// 
  /// Returns [Either] void on success or [Failure] on error
  Future<Either<Failure, void>> deleteComment(String commentId);
}
