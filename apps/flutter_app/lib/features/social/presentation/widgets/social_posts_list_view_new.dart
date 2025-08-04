import 'package:flutter/material.dart';
import '../../domain/entities/social_post.dart';
import '../viewmodels/social_post_view_model.dart';
import 'social_post_card_new.dart';

/// Social Posts List View - Scrollable list of social feed posts
/// 
/// This widget displays a list of social posts in a scrollable view
/// with pull-to-refresh functionality and loading states.
class SocialPostsListViewNew extends StatelessWidget {
  final List<SocialPost> posts;
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final VoidCallback? onRefresh;
  final VoidCallback? onLoadMore;
  final void Function(String postId)? onLike;
  final void Function(String postId)? onSave;
  final void Function(String postId)? onComment;
  final void Function(String postId)? onShare;
  final void Function(String tag)? onTagTap;

  const SocialPostsListViewNew({
    super.key,
    required this.posts,
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
    this.onRefresh,
    this.onLoadMore,
    this.onLike,
    this.onSave,
    this.onComment,
    this.onShare,
    this.onTagTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (hasError) {
      return _buildErrorState(context, theme, colorScheme);
    }

    if (isLoading && posts.isEmpty) {
      return _buildLoadingState(context, colorScheme);
    }

    if (posts.isEmpty) {
      return _buildEmptyState(context, theme, colorScheme);
    }

    // Convert domain entities to view models
    final postViewModels = posts.map((post) => SocialPostViewModel.fromEntity(post)).toList();

    return RefreshIndicator(
      onRefresh: () async {
        onRefresh?.call();
        // Add a small delay to show the refresh indicator
        await Future<void>.delayed(const Duration(milliseconds: 500));
      },
      color: colorScheme.primary,
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo is ScrollEndNotification) {
            // Check if user has scrolled to the bottom
            if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
              onLoadMore?.call();
              return true;
            }
          }
          return false;
        },
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: postViewModels.length + (isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            // Show loading indicator at the bottom while loading more
            if (index == postViewModels.length) {
              return _buildLoadMoreIndicator(colorScheme);
            }

            final post = postViewModels[index];
            return SocialPostCard(
              post: post,
              onLike: onLike,
              onSave: onSave,
              onComment: onComment,
              onShare: onShare,
              onTagTap: onTagTap,
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context, ColorScheme colorScheme) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3, // Show 3 loading cards
      itemBuilder: (context, index) => _buildLoadingCard(context, colorScheme),
    );
  }

  Widget _buildLoadingCard(BuildContext context, ColorScheme colorScheme) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header skeleton
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Avatar skeleton
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                // Name and time skeleton
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 14,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 80,
                        height: 12,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Image skeleton
          Container(
            width: double.infinity,
            height: 300,
            color: colorScheme.surfaceVariant,
          ),
          
          // Content skeleton
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Action buttons skeleton
                Row(
                  children: List.generate(
                    4,
                    (index) => Padding(
                      padding: EdgeInsets.only(right: index < 3 ? 16 : 0),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Caption skeleton
                Container(
                  width: double.infinity,
                  height: 14,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 200,
                  height: 14,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ?? 'Unable to load posts. Please check your connection and try again.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_outline,
                size: 48,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No posts yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to share your style! Follow other users to see their posts in your feed.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: CircularProgressIndicator(
        color: colorScheme.primary,
        strokeWidth: 2,
      ),
    );
  }
}
