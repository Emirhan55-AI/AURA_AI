import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/social_post.dart';

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

  const SocialFeedState({
    required this.posts,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.currentFilter = 'all',
  });

  SocialFeedState copyWith({
    AsyncValue<List<SocialPost>>? posts,
    bool? isLoadingMore,
    bool? hasReachedMax,
    String? currentFilter,
  }) {
    return SocialFeedState(
      posts: posts ?? this.posts,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentFilter: currentFilter ?? this.currentFilter,
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
      // Simulate API call delay
      await Future<void>.delayed(const Duration(milliseconds: 1500));
      
      // Load sample posts (in real app, this would call repository)
      final posts = SocialPost.getSamplePosts();
      
      state = state.copyWith(
        posts: AsyncValue.data(posts),
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
      // Simulate API call delay
      await Future<void>.delayed(const Duration(milliseconds: 800));
      
      // Reload sample posts (in real app, this would call repository)
      final posts = SocialPost.getSamplePosts();
      
      state = state.copyWith(
        posts: AsyncValue.data(posts),
        isLoadingMore: false,
        hasReachedMax: false,
      );
    } catch (error, stackTrace) {
      // If refresh fails, keep existing posts and show error via snackbar
      // The UI should handle this gracefully
      state = state.copyWith(
        posts: AsyncValue<List<SocialPost>>.error(error, stackTrace),
      );
    }
  }

  /// Load more posts for infinite scroll
  Future<void> loadMorePosts() async {
    // Don't load more if already loading or reached max
    if (state.isLoadingMore || state.hasReachedMax) return;
    
    // Don't load more if there's no data yet
    final currentPosts = state.posts.valueOrNull;
    if (currentPosts == null) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      // Simulate API call delay
      await Future<void>.delayed(const Duration(milliseconds: 1000));
      
      // Generate more sample posts (simulating pagination)
      final morePosts = SocialPost.getSamplePosts()
          .map((post) => post.copyWith(
                id: '${post.id}_more_${DateTime.now().millisecondsSinceEpoch}',
                createdAt: DateTime.now().subtract(Duration(days: currentPosts.length + 1)),
              ))
          .toList();
      
      // Combine with existing posts
      final allPosts = [...currentPosts, ...morePosts];
      
      state = state.copyWith(
        posts: AsyncValue.data(allPosts),
        isLoadingMore: false,
        // Simulate reaching max after loading more posts a few times
        hasReachedMax: allPosts.length > 15,
      );
    } catch (error, stackTrace) {
      state = state.copyWith(
        isLoadingMore: false,
        posts: AsyncValue<List<SocialPost>>.error(error, stackTrace),
      );
    }
  }

  /// Toggle like status for a post
  Future<void> toggleLike(String postId) async {
    final currentPosts = state.posts.valueOrNull;
    if (currentPosts == null) return;

    try {
      // Find and update the post optimistically
      final updatedPosts = currentPosts.map((post) {
        if (post.id == postId) {
          return post.copyWith(
            isLiked: !post.isLiked,
            likesCount: post.isLiked ? post.likesCount - 1 : post.likesCount + 1,
          );
        }
        return post;
      }).toList();

      // Update state immediately for responsive UI
      state = state.copyWith(
        posts: AsyncValue.data(updatedPosts),
      );

      // Simulate API call
      await Future<void>.delayed(const Duration(milliseconds: 300));
      
      // TODO: In real app, call repository to update like status on server
      // If API call fails, we should revert the optimistic update
      
    } catch (error) {
      // TODO: Revert optimistic update and show error message
      // For now, just ignore the error as the optimistic update is sufficient
    }
  }

  /// Toggle save status for a post
  Future<void> toggleSave(String postId) async {
    final currentPosts = state.posts.valueOrNull;
    if (currentPosts == null) return;

    try {
      // Find and update the post optimistically
      final updatedPosts = currentPosts.map((post) {
        if (post.id == postId) {
          return post.copyWith(isSaved: !post.isSaved);
        }
        return post;
      }).toList();

      // Update state immediately for responsive UI
      state = state.copyWith(
        posts: AsyncValue.data(updatedPosts),
      );

      // Simulate API call
      await Future<void>.delayed(const Duration(milliseconds: 300));
      
      // TODO: In real app, call repository to update save status on server
      
    } catch (error) {
      // TODO: Revert optimistic update and show error message
      // For now, just ignore the error as the optimistic update is sufficient
    }
  }

  /// Apply a new filter to the posts
  void applyFilter(String filterTag) {
    // Update current filter
    state = state.copyWith(currentFilter: filterTag);
    
    // TODO: In real app, this would trigger a new API call with the filter
    // For now, we'll just update the filter state and reload posts
    loadInitialPosts();
  }

  /// Show options for a specific post (report, share, etc.)
  Future<void> showPostOptions(String postId) async {
    // TODO: Implement logic to show post options
    // This might involve showing a bottom sheet or dialog
    // For now, this is a placeholder
  }

  /// Retry a failed operation (usually initial load)
  Future<void> retry() async {
    if (state.posts.hasError) {
      await loadInitialPosts();
    }
  }
}

/// Provider for accessing the current filter separately if needed
@riverpod
String socialFeedCurrentFilter(Ref ref) {
  return ref.watch(socialFeedNotifierProvider).currentFilter;
}

/// Provider for accessing loading more state separately if needed
@riverpod
bool socialFeedIsLoadingMore(Ref ref) {
  return ref.watch(socialFeedNotifierProvider).isLoadingMore;
}

/// Provider for accessing has reached max state separately if needed
@riverpod
bool socialFeedHasReachedMax(Ref ref) {
  return ref.watch(socialFeedNotifierProvider).hasReachedMax;
}
