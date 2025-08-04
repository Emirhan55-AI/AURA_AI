import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/social_post.dart';
import '../../domain/entities/comment.dart';
import '../../domain/repositories/social_repository.dart';
import '../../providers/social_providers.dart';

part 'social_feed_controller.g.dart';

/// Social Feed Controller State
/// 
/// Manages the complete state of the social feed including posts, 
/// loading states, filters, and user interactions.
class SocialFeedState {
  final AsyncValue<List<SocialPost>> posts;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final String currentFilter;
  final Set<String> savedPostIds; // Track saved posts locally

  const SocialFeedState({
    required this.posts,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.currentFilter = 'all',
    this.savedPostIds = const {},
  });

  SocialFeedState copyWith({
    AsyncValue<List<SocialPost>>? posts,
    bool? isLoadingMore,
    bool? hasReachedMax,
    String? currentFilter,
    Set<String>? savedPostIds,
  }) {
    return SocialFeedState(
      posts: posts ?? this.posts,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentFilter: currentFilter ?? this.currentFilter,
      savedPostIds: savedPostIds ?? this.savedPostIds,
    );
  }
}

/// Social Feed Controller
/// 
/// Manages the social feed data and user interactions using Riverpod.
/// Provides methods for loading posts, handling user actions like like/save,
/// filtering content, and managing pagination.
@riverpod
class SocialFeedNotifier extends _$SocialFeedNotifier {
  int _page = 1;
  static const int _pageSize = 10;
  
  /// Get the social repository instance
  SocialRepository get _repository => ref.read(socialRepositoryProvider);
  
  @override
  SocialFeedState build() {
    // Initialize with loading state and automatically load posts
    Future.microtask(() => loadInitialPosts());
    
    return const SocialFeedState(
      posts: AsyncValue<List<SocialPost>>.loading(),
    );
  }

  /// Load initial posts when the screen first loads
  Future<void> loadInitialPosts() async {
    state = state.copyWith(
      posts: const AsyncValue<List<SocialPost>>.loading(),
      isLoadingMore: false,
      hasReachedMax: false,
    );

    try {
      _page = 1;
      final result = await _repository.getPosts(page: _page, limit: _pageSize, filter: state.currentFilter);
      
      result.fold(
        (failure) {
          state = state.copyWith(
            posts: AsyncValue<List<SocialPost>>.error(failure, StackTrace.current),
          );
        },
        (posts) {
          state = state.copyWith(
            posts: AsyncValue.data(posts),
            hasReachedMax: posts.length < _pageSize,
          );
        }
      );
    } catch (error, stackTrace) {
      state = state.copyWith(
        posts: AsyncValue<List<SocialPost>>.error(error, stackTrace),
      );
    }
  }

  /// Refresh the entire post list (pull-to-refresh)
  Future<void> refreshPosts() async {
    try {
      _page = 1;
      final result = await _repository.getPosts(page: _page, limit: _pageSize, filter: state.currentFilter);
      
      result.fold(
        (failure) {
          state = state.copyWith(
            posts: AsyncValue<List<SocialPost>>.error(failure, StackTrace.current),
          );
        },
        (posts) {
          state = state.copyWith(
            posts: AsyncValue.data(posts),
            isLoadingMore: false,
            hasReachedMax: posts.length < _pageSize,
          );
        }
      );
    } catch (error, stackTrace) {
      state = state.copyWith(
        posts: AsyncValue<List<SocialPost>>.error(error, stackTrace),
      );
    }
  }

  /// Load more posts when user scrolls to the bottom
  Future<void> loadMorePosts() async {
    // If already loading or reached max, don't load more
    if (state.isLoadingMore || state.hasReachedMax) {
      return;
    }
    
    // Don't load more if there's no data yet
    final currentPosts = state.posts.valueOrNull;
    if (currentPosts == null) return;

    // Start loading state
    state = state.copyWith(
      isLoadingMore: true,
    );

    try {
      // Increment page and load more
      _page++;
      final result = await _repository.getPosts(
        page: _page, 
        limit: _pageSize, 
        filter: state.currentFilter
      );
      
      result.fold(
        (failure) {
          // If loading more fails, keep existing posts and just stop loading
          state = state.copyWith(
            isLoadingMore: false,
          );
          // Consider showing a "failed to load more" message
        },
        (newPosts) {
          // Append new posts
          state = state.copyWith(
            posts: AsyncValue.data([...currentPosts, ...newPosts]),
            isLoadingMore: false,
            hasReachedMax: newPosts.length < _pageSize,
          );
        }
      );
    } catch (error, stackTrace) {
      // If loading more fails, keep existing posts and just stop loading
      state = state.copyWith(
        isLoadingMore: false,
      );
      // Consider showing a "failed to load more" message
    }
  }

  /// Update the filter for the posts
  Future<void> applyFilter(String filter) async {
    if (filter == state.currentFilter) return;
    
    state = state.copyWith(
      currentFilter: filter,
      posts: const AsyncValue<List<SocialPost>>.loading(),
    );
    
    _page = 1;
    
    try {
      final result = await _repository.getPosts(page: 1, limit: _pageSize, filter: filter);
      
      result.fold(
        (failure) {
          state = state.copyWith(
            posts: AsyncValue<List<SocialPost>>.error(failure, StackTrace.current),
          );
        },
        (posts) {
          state = state.copyWith(
            posts: AsyncValue.data(posts),
            hasReachedMax: posts.length < _pageSize,
          );
        }
      );
    } catch (error, stackTrace) {
      state = state.copyWith(
        posts: AsyncValue<List<SocialPost>>.error(error, stackTrace),
      );
    }
  }

  /// Like or unlike a post
  Future<void> toggleLike(String postId) async {
    // Get current posts
    final currentPosts = state.posts.valueOrNull;
    if (currentPosts == null) return;
    
    // Find the post to update
    final index = currentPosts.indexWhere((post) => post.id == postId);
    if (index == -1) return;
    
    final post = currentPosts[index];
    final isCurrentlyLiked = post.isLikedByCurrentUser;
    
    // Optimistic update
    final updatedPosts = [...currentPosts];
    updatedPosts[index] = SocialPost(
      id: post.id,
      userId: post.userId,
      content: post.content,
      imageUrl: post.imageUrl,
      createdAt: post.createdAt,
      username: post.username,
      avatarUrl: post.avatarUrl,
      likeCount: isCurrentlyLiked ? post.likeCount - 1 : post.likeCount + 1,
      commentCount: post.commentCount,
      isLikedByCurrentUser: !isCurrentlyLiked,
    );
    
    state = state.copyWith(
      posts: AsyncValue.data(updatedPosts),
    );
    
    // Call repository
    final result = await _repository.likePost(postId, !isCurrentlyLiked);
    
    // Handle failure by reverting to previous state
    result.fold(
      (failure) {
        // Revert the change if the API call fails
        state = state.copyWith(
          posts: AsyncValue.data(currentPosts),
        );
      },
      (_) {
        // Success - already updated optimistically
      },
    );
  }

  /// Toggle save state for a post (client-side only for now)
  void toggleSave(String postId) {
    // Get current saved post IDs
    final savedPostIds = Set<String>.from(state.savedPostIds);

    // Toggle saved state
    if (savedPostIds.contains(postId)) {
      savedPostIds.remove(postId);
    } else {
      savedPostIds.add(postId);
    }

    // Update state
    state = state.copyWith(savedPostIds: savedPostIds);

    // TODO: In the future, integrate with an API endpoint to save posts
  }

  /// Create a new post
  Future<Either<Failure, SocialPost>> createPost(String content, {File? image}) async {
    final result = await _repository.createPost(content, image: image);
    
    result.fold(
      (failure) {
        // Handle failure - the UI should show an error
      },
      (newPost) {
        // Add the new post to the top of the list
        final currentPosts = state.posts.valueOrNull;
        if (currentPosts != null) {
          state = state.copyWith(
            posts: AsyncValue.data([newPost, ...currentPosts]),
          );
        }
      },
    );
    
    return result;
  }

  /// Delete a post
  Future<Either<Failure, void>> deletePost(String postId) async {
    // Get current posts
    final currentPosts = state.posts.valueOrNull;
    if (currentPosts == null) return Right<Failure, void>(null);
    
    // Find the post to delete
    final index = currentPosts.indexWhere((post) => post.id == postId);
    if (index == -1) return Right<Failure, void>(null);
    
    // Optimistic update - remove post from list
    final updatedPosts = [...currentPosts];
    updatedPosts.removeAt(index);
    
    state = state.copyWith(
      posts: AsyncValue.data(updatedPosts),
    );
    
    // Call repository
    final result = await _repository.deletePost(postId);
    
    // Handle failure by reverting to previous state
    if (result.isLeft()) {
      // Revert the change if the API call fails
      state = state.copyWith(
        posts: AsyncValue.data(currentPosts),
      );
    }
    
    return result;
  }

  /// Retry loading posts after an error
  void retry() {
    if (state.posts.hasError) {
      loadInitialPosts();
    }
  }
}
