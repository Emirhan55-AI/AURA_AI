import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ui/system_state_widget.dart';
import '../controllers/social_feed_controller.dart';
import '../widgets/feed_filter_bar.dart';
import '../widgets/social_posts_list_view_new.dart';

/// Social Feed Screen - Community social feed where users can view, like, and interact with posts
/// 
/// This screen displays a social feed with filtering options, allowing users to:
/// - View posts from the community
/// - Filter posts by categories (trending, recent, following, etc.)
/// - Like, save, comment on, and share posts
/// - Pull to refresh and infinite scroll
class SocialFeedScreen extends ConsumerWidget {
  const SocialFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Watch the social feed state
    final feedState = ref.watch(socialFeedNotifierProvider);
    final feedController = ref.read(socialFeedNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
        elevation: 0,
        title: Text(
          'Social Feed',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
            fontFamily: 'Urbanist', // Using Urbanist for headings as per style guide
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implement notifications functionality
            },
            icon: Icon(
              Icons.notifications_outlined,
              color: colorScheme.onSurface,
            ),
            tooltip: 'Notifications',
          ),
          IconButton(
            onPressed: () {
              // TODO: Implement search functionality
            },
            icon: Icon(
              Icons.search,
              color: colorScheme.onSurface,
            ),
            tooltip: 'Search',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Bar
          FeedFilterBar(
            filters: ['trending', 'recent', 'following', 'fashion', 'style'],
            selectedFilter: feedState.currentFilter == 'all' ? null : feedState.currentFilter,
            onFilterSelected: (filter) {
              feedController.applyFilter(filter ?? 'all');
            },
          ),
          
          // Divider
          Divider(
            height: 1,
            thickness: 0.5,
            color: colorScheme.outline.withOpacity(0.2),
          ),
          
          // Posts List - Handle AsyncValue states
          Expanded(
            child: feedState.posts.when(
              data: (posts) => SocialPostsListViewNew(
                posts: posts,
                isLoading: feedState.isLoadingMore,
                hasError: false,
                onRefresh: () => feedController.refreshPosts(),
                onLoadMore: () => feedController.loadMorePosts(),
                onLike: (postId) => feedController.toggleLike(postId),
                onSave: (postId) {
                  // TODO: Implement save functionality
                  _handleSave(context, postId);
                },
                onComment: (postId) {
                  // TODO: Navigate to post detail or comment modal
                  _showCommentModal(context, postId);
                },
                onShare: (postId) {
                  // TODO: Implement share functionality
                  _handleShare(context, postId);
                },
                onTagTap: (tag) {
                  // Apply tag filter
                  feedController.applyFilter(tag);
                },
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => SystemStateWidget(
                title: 'Failed to load posts',
                message: 'Please check your connection and try again.',
                icon: Icons.error_outline,
                onRetry: () => feedController.refreshPosts(),
                retryText: 'Try Again',
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to create post screen
          _navigateToCreatePost(context);
        },
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Handle save functionality
  void _handleSave(BuildContext context, String postId) {
    // TODO: Implement proper save functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Save functionality coming soon!'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  /// Show comment modal for a post
  void _showCommentModal(BuildContext context, String postId) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'Comments',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            // TODO: Implement comments list and input
            const Expanded(
              child: Center(
                child: Text('Comments feature coming soon!'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Handle share functionality
  void _handleShare(BuildContext context, String postId) {
    // TODO: Implement proper share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Share functionality coming soon!'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  /// Navigate to create post screen
  void _navigateToCreatePost(BuildContext context) {
    // TODO: Implement navigation to create post screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Create post functionality coming soon!'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
