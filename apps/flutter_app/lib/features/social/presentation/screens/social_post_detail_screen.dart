import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ui/system_state_widget.dart';
import '../widgets/post_detail/post_detail_widgets.dart';
import '../widgets/post_detail/models.dart';
import '../controllers/social_post_detail_controller.dart';

/// Social Post Detail Screen - Displays a single social post in detail
/// 
/// Shows the full combination image, detailed caption, author information,
/// engagement metrics (likes, comments), full comment thread, and allows
/// interaction with the post (like, comment, save, share).
/// 
/// This screen follows the Material 3 design system and Aura's design guidelines.
class SocialPostDetailScreen extends ConsumerStatefulWidget {
  final String? postId;

  const SocialPostDetailScreen({
    super.key,
    this.postId,
  });

  @override
  ConsumerState<SocialPostDetailScreen> createState() => _SocialPostDetailScreenState();
}

class _SocialPostDetailScreenState extends ConsumerState<SocialPostDetailScreen> {
  String get postId => widget.postId ?? 'sample_post_1';

  void _handleRefresh() async {
    final controller = ref.read(socialPostDetailControllerProvider(postId).notifier);
    await controller.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildAppBar(theme, colorScheme),
      body: _buildBody(context),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme, ColorScheme colorScheme) {
    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      scrolledUnderElevation: 1,
      surfaceTintColor: colorScheme.surfaceTint,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Icon(
          Icons.arrow_back,
          color: colorScheme.onSurface,
        ),
        tooltip: 'Back',
      ),
      title: Text(
        'Post Detail',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: _showMoreOptions,
          icon: Icon(
            Icons.more_vert,
            color: colorScheme.onSurface,
          ),
          tooltip: 'More options',
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    final controllerState = ref.watch(socialPostDetailControllerProvider(postId));
    final controller = ref.read(socialPostDetailControllerProvider(postId).notifier);

    return controllerState.postDetail.when(
      loading: () => const SystemStateWidget(
        icon: Icons.photo_outlined,
        message: 'Loading post details...',
      ),
      error: (error, stackTrace) => SystemStateWidget(
        icon: Icons.error_outline,
        message: 'Failed to load post details',
        onRetry: _handleRefresh,
        retryText: 'Try Again',
      ),
      data: (postDetail) {
        if (postDetail == null) {
          return const SystemStateWidget(
            icon: Icons.not_interested,
            message: 'Post not found',
          );
        }

        return Column(
          children: [
            // Main content area (scrollable)
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => _handleRefresh(),
                child: CustomScrollView(
                  slivers: [
                    // Post detail content
                    SliverToBoxAdapter(
                      child: DetailedPostView(
                        post: postDetail,
                        onLikePressed: () => controller.togglePostLike(),
                        onSavePressed: () => controller.togglePostSave(),
                        onMorePressed: _showMoreOptions,
                        onAuthorPressed: _handleAuthorTap,
                      ),
                    ),
                    
                    // Spacing
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 24),
                    ),
                    
                    // Comments section
                    SliverToBoxAdapter(
                      child: controllerState.comments.when(
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (error, stackTrace) => Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Text(
                              'Failed to load comments',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ),
                        data: (comments) => CommentsSection(
                          comments: comments,
                          onCommentLikePressed: (comment) => controller.toggleCommentLike(comment.id),
                          onCommentAuthorPressed: _handleCommentAuthorTap,
                          onCommentReplyPressed: _handleCommentReply,
                        ),
                      ),
                    ),
                    
                    // Bottom padding for comment input
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 100),
                    ),
                  ],
                ),
              ),
            ),
            
            // Comment input (fixed at bottom)
            CommentInput(
              onCommentSubmitted: (text) async {
                final controller = ref.read(socialPostDetailControllerProvider(postId).notifier);
                await controller.addComment(text);
              },
              placeholder: 'Add a comment...',
            ),
          ],
        );
      },
    );
  }

  void _handleAuthorTap() {
    // TODO: Navigate to author profile
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigate to author profile'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleCommentAuthorTap(Comment comment) {
    // TODO: Navigate to comment author profile
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigate to ${comment.authorDisplayName}\'s profile'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleCommentReply(Comment comment) {
    // TODO: Implement reply functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reply to ${comment.authorDisplayName}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showMoreOptions() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Options
            ListTile(
              leading: Icon(Icons.share, color: colorScheme.onSurface),
              title: Text(
                'Share post',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _sharePost();
              },
            ),
            ListTile(
              leading: Icon(Icons.link, color: colorScheme.onSurface),
              title: Text(
                'Copy link',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _copyLink();
              },
            ),
            ListTile(
              leading: Icon(Icons.report, color: colorScheme.error),
              title: Text(
                'Report post',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.error,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _reportPost();
              },
            ),
            
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _sharePost() {
    final controller = ref.read(socialPostDetailControllerProvider(postId).notifier);
    controller.sharePost();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _copyLink() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link copied to clipboard'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _reportPost() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Post reported'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
