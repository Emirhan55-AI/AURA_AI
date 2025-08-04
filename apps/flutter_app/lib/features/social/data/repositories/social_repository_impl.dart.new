import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../../../core/services/supabase_service.dart';
import '../../domain/entities/comment.dart';
import '../../domain/entities/social_post.dart';
import '../../domain/repositories/social_repository.dart';
import '../models/comment_model.dart';
import '../models/social_post_model.dart';

/// Implementation of the [SocialRepository] interface
/// Uses Supabase as the data source
class SocialRepositoryImpl implements SocialRepository {
  final SupabaseService _supabaseService;
  final String _postsTable = 'social_posts';
  final String _commentsTable = 'social_comments';
  final String _likesTable = 'social_likes';
  final String _storageBucket = 'social_images';

  /// Creates a new SocialRepositoryImpl with the required dependencies
  const SocialRepositoryImpl({
    required SupabaseService supabaseService,
  }) : _supabaseService = supabaseService;

  @override
  Future<Either<Failure, List<SocialPost>>> getPosts({
    int page = 1,
    int limit = 20,
    String filter = 'all',
  }) async {
    try {
      final client = _supabaseService.client;
      final userId = client.auth.currentUser?.id;
      
      // Calculate range based on page and limit
      final start = (page - 1) * limit;
      final end = start + limit - 1;
      
      // Build the query based on filter
      var query = client.from(_postsTable)
          .select('''
            *,
            user_profile: profiles!user_id(username, avatar_url),
            like_count: social_likes!post_id(count),
            comment_count: social_comments!post_id(count)
          ''')
          .order('created_at', ascending: false)
          .range(start, end);
      
      // Apply additional filters
      if (filter == 'following') {
        // Get posts from users the current user follows
        final followedUsers = await client.from('follows')
            .select('followed_user_id')
            .eq('follower_user_id', userId);
        
        final followedIds = (followedUsers as List<dynamic>)
            .map((item) => item['followed_user_id'] as String)
            .toList();
        
        // Add current user to see their own posts too
        if (userId != null) {
          followedIds.add(userId);
        }
        
        query = query.in_('user_id', followedIds);
      } else if (filter == 'trending') {
        // Order by likes and comments instead
        query = client.from(_postsTable)
            .select('''
              *,
              user_profile: profiles!user_id(username, avatar_url),
              like_count: social_likes!post_id(count),
              comment_count: social_comments!post_id(count)
            ''')
            .order('like_count', ascending: false)
            .order('comment_count', ascending: false)
            .range(start, end);
      }
      
      final response = await query;
      
      // For each post, check if the current user has liked it
      final postsList = await Future.wait(
        (response as List<dynamic>).map((post) async {
          // Add likes information
          Map<String, dynamic> postWithLikes = Map<String, dynamic>.from(post);
          if (userId != null) {
            final likeResponse = await client
                .from(_likesTable)
                .select()
                .eq('post_id', post['id'])
                .eq('user_id', userId)
                .maybeSingle();
            
            postWithLikes['is_liked_by_user'] = likeResponse != null;
          } else {
            postWithLikes['is_liked_by_user'] = false;
          }
          
          return postWithLikes;
        }),
      );
      
      // Convert to models and then to entities
      final posts = postsList
          .map((json) => SocialPostModel.fromJson(json).toEntity())
          .toList();
          
      return Right(posts);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, SocialPost>> getPostById(String id) async {
    try {
      final client = _supabaseService.client;
      final userId = client.auth.currentUser?.id;
      
      // Query for the post with user profile
      final response = await client.from(_postsTable)
          .select('''
            *,
            user_profile: profiles!user_id(username, avatar_url),
            like_count: social_likes!post_id(count),
            comment_count: social_comments!post_id(count)
          ''')
          .eq('id', id)
          .single();
      
      // Add likes information
      Map<String, dynamic> postWithLikes = Map<String, dynamic>.from(response);
      if (userId != null) {
        final likeResponse = await client
            .from(_likesTable)
            .select()
            .eq('post_id', id)
            .eq('user_id', userId)
            .maybeSingle();
        
        postWithLikes['is_liked_by_user'] = likeResponse != null;
      } else {
        postWithLikes['is_liked_by_user'] = false;
      }
      
      // Convert to model and then to entity
      final post = SocialPostModel.fromJson(postWithLikes).toEntity();
          
      return Right(post);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<Comment>>> getComments(
    String postId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final client = _supabaseService.client;
      
      // Query for comments with user profiles
      final response = await client.from(_commentsTable)
          .select('''
            *,
            user_profile: profiles!user_id(username, avatar_url)
          ''')
          .eq('post_id', postId)
          .order('created_at', ascending: true)
          .range(offset, offset + limit - 1);
      
      // Convert to models and then to entities
      final comments = (response as List<dynamic>)
          .map((json) => CommentModel.fromJson(json).toEntity())
          .toList();
          
      return Right(comments);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, SocialPost>> createPost(
    String content, {
    File? image,
  }) async {
    try {
      final client = _supabaseService.client;
      final userId = _supabaseService.currentUserId;
      
      // Upload image if provided
      String? imageUrl;
      if (image != null) {
        final result = await _supabaseService.uploadFile(
          filePath: image.path,
          bucket: _storageBucket,
        );
        
        imageUrl = result;
      }

      // Create post data
      final postData = {
        'user_id': userId,
        'content': content,
        'image_url': imageUrl,
        'created_at': DateTime.now().toIso8601String(),
      };
      
      // Insert post
      final response = await client.from(_postsTable)
          .insert(postData)
          .select('''
            *,
            user_profile: profiles!user_id(username, avatar_url)
          ''')
          .single();
      
      // Create post entity
      final post = SocialPostModel.fromJson({
        ...response,
        'user_profile': response['user_profile'],
        'like_count': 0,
        'is_liked_by_user': false,
        'comment_count': 0,
      }).toEntity();
      
      return Right(post);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> likePost(String postId, bool like) async {
    try {
      final client = _supabaseService.client;
      final userId = _supabaseService.currentUserId;
      
      if (like) {
        // Like the post
        await client.from(_likesTable).insert({
          'user_id': userId,
          'post_id': postId,
          'created_at': DateTime.now().toIso8601String(),
        }).onConflict('post_id, user_id').ignore();
      } else {
        // Unlike the post
        await client.from(_likesTable)
            .delete()
            .eq('user_id', userId)
            .eq('post_id', postId);
      }
      
      return const Right(null);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Comment>> createComment(
    String postId,
    String content,
  ) async {
    try {
      final client = _supabaseService.client;
      final userId = _supabaseService.currentUserId;
      
      // Insert comment
      final commentData = {
        'post_id': postId,
        'user_id': userId,
        'content': content,
        'created_at': DateTime.now().toIso8601String(),
      };
      
      final response = await client.from(_commentsTable)
          .insert(commentData)
          .select('''
            *,
            user_profile: profiles!user_id(username, avatar_url)
          ''')
          .single();
      
      // Create comment entity
      final comment = CommentModel.fromJson({
        ...response,
        'user_profile': response['user_profile'],
      }).toEntity();
      
      return Right(comment);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> deletePost(String postId) async {
    try {
      final client = _supabaseService.client;
      final userId = _supabaseService.currentUserId;
      
      // Get post to check ownership and image URL
      final postResponse = await client
          .from(_postsTable)
          .select('user_id, image_url')
          .eq('id', postId)
          .maybeSingle();
      
      if (postResponse == null) {
        return Left(const ValidationFailure(message: 'Post not found'));
      }
      
      // Check if user owns the post
      if (postResponse['user_id'] != userId) {
        return Left(const AuthFailure.forbidden());
      }
      
      // Delete associated image if exists
      final imageUrl = postResponse['image_url'] as String?;
      if (imageUrl != null) {
        final imagePath = imageUrl.split('/').last;
        await client.storage.from(_storageBucket).remove([imagePath]);
      }
      
      // Delete post (cascade should delete comments and likes)
      await client.from(_postsTable).delete().eq('id', postId);
      
      return const Right(null);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteComment(String commentId) async {
    try {
      final client = _supabaseService.client;
      final userId = _supabaseService.currentUserId;
      
      // Get comment to check ownership
      final commentResponse = await client
          .from(_commentsTable)
          .select('user_id')
          .eq('id', commentId)
          .maybeSingle();
      
      if (commentResponse == null) {
        return Left(const ValidationFailure(message: 'Comment not found'));
      }
      
      // Check if user owns the comment
      if (commentResponse['user_id'] != userId) {
        return Left(const AuthFailure.forbidden());
      }
      
      // Delete comment
      await client.from(_commentsTable).delete().eq('id', commentId);
      
      return const Right(null);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }
}
