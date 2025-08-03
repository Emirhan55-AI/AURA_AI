import 'package:flutter/material.dart';
import 'social_post.dart';

/// Social Post Card - Individual post display in social feed
/// 
/// This widget displays a single social post with image, author info,
/// caption, interaction buttons (like, save, comment), and tags.
class SocialPostCard extends StatelessWidget {
  final SocialPost post;
  final void Function(String postId)? onLike;
  final void Function(String postId)? onSave;
  final void Function(String postId)? onComment;
  final void Function(String postId)? onShare;
  final void Function(String tag)? onTagTap;

  const SocialPostCard({
    super.key,
    required this.post,
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

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post header with author info
          _buildPostHeader(context, theme, colorScheme),
          
          // Post image
          _buildPostImage(context, colorScheme),
          
          // Post interactions
          _buildInteractionBar(context, theme, colorScheme),
          
          // Post caption and tags
          _buildPostContent(context, theme, colorScheme),
          
          // Comments preview
          if (post.commentsCount > 0)
            _buildCommentsPreview(context, theme, colorScheme),
          
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildPostHeader(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Author avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: colorScheme.surfaceVariant,
            backgroundImage: post.authorAvatar != null
                ? NetworkImage(post.authorAvatar!)
                : null,
            child: post.authorAvatar == null
                ? Text(
                    post.authorName.isNotEmpty ? post.authorName[0].toUpperCase() : '?',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : null,
          ),
          
          const SizedBox(width: 12),
          
          // Author name and timestamp
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.authorName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  _formatTimestamp(post.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // More options button
          IconButton(
            onPressed: () => _showPostOptions(context),
            icon: Icon(
              Icons.more_vert,
              color: colorScheme.onSurfaceVariant,
            ),
            iconSize: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildPostImage(BuildContext context, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 200,
        maxHeight: 500,
      ),
      child: Stack(
        children: [
          // Main image
          Image.network(
            post.imageUrl,
            width: double.infinity,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: 300,
                color: colorScheme.surfaceVariant,
                child: Center(
                  child: CircularProgressIndicator(
                    color: colorScheme.primary,
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 300,
                color: colorScheme.surfaceVariant,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.broken_image_outlined,
                      size: 48,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Failed to load image',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          // NSFW overlay if applicable
          if (post.isNsfw)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.8),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.visibility_off,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sensitive Content',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap to view',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInteractionBar(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Like button
          _buildInteractionButton(
            icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
            color: post.isLiked ? const Color(0xFFE91E63) : colorScheme.onSurfaceVariant,
            onTap: () => onLike?.call(post.id),
          ),
          
          const SizedBox(width: 16),
          
          // Comment button
          _buildInteractionButton(
            icon: Icons.chat_bubble_outline,
            color: colorScheme.onSurfaceVariant,
            onTap: () => onComment?.call(post.id),
          ),
          
          const SizedBox(width: 16),
          
          // Share button
          _buildInteractionButton(
            icon: Icons.share_outlined,
            color: colorScheme.onSurfaceVariant,
            onTap: () => onShare?.call(post.id),
          ),
          
          const Spacer(),
          
          // Save button
          _buildInteractionButton(
            icon: post.isSaved ? Icons.bookmark : Icons.bookmark_border,
            color: post.isSaved ? colorScheme.primary : colorScheme.onSurfaceVariant,
            onTap: () => onSave?.call(post.id),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionButton({
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(
          icon,
          size: 24,
          color: color,
        ),
      ),
    );
  }

  Widget _buildPostContent(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Likes count
          if (post.likesCount > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                _formatLikesCount(post.likesCount),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          
          // Caption
          if (post.caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${post.authorName} ',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    TextSpan(
                      text: post.caption,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Tags
          if (post.tags.isNotEmpty)
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: post.tags.map((tag) => _buildTagChip(context, theme, colorScheme, tag)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildTagChip(BuildContext context, ThemeData theme, ColorScheme colorScheme, String tag) {
    return InkWell(
      onTap: () => onTagTap?.call(tag),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.primary.withOpacity(0.3),
            width: 0.5,
          ),
        ),
        child: Text(
          '#$tag',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.primary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildCommentsPreview(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        onTap: () => onComment?.call(post.id),
        child: Text(
          'View all ${post.commentsCount} comments',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${difference.inDays ~/ 7}w';
    }
  }

  String _formatLikesCount(int count) {
    if (count == 1) {
      return '1 like';
    } else if (count < 1000) {
      return '$count likes';
    } else if (count < 1000000) {
      final k = count / 1000;
      return '${k.toStringAsFixed(k.truncateToDouble() == k ? 0 : 1)}k likes';
    } else {
      final m = count / 1000000;
      return '${m.toStringAsFixed(m.truncateToDouble() == m ? 0 : 1)}m likes';
    }
  }

  void _showPostOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.report_outlined),
              title: const Text('Report'),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              leading: const Icon(Icons.block_outlined),
              title: const Text('Block User'),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              leading: const Icon(Icons.link_outlined),
              title: const Text('Copy Link'),
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
