import 'package:flutter/material.dart';
import 'models.dart';

/// A widget that displays the main social post content in detail
/// Shows the full combination image, author info, caption, and interaction options
class DetailedPostView extends StatelessWidget {
  final SocialPostDetail post;
  final VoidCallback? onLikePressed;
  final VoidCallback? onSavePressed;
  final VoidCallback? onMorePressed;
  final VoidCallback? onAuthorPressed;

  const DetailedPostView({
    super.key,
    required this.post,
    this.onLikePressed,
    this.onSavePressed,
    this.onMorePressed,
    this.onAuthorPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main image with NSFW handling
        _buildMainImage(context),
        
        const SizedBox(height: 16),
        
        // Author info and actions row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildAuthorAndActionsRow(context, theme, colorScheme),
        ),
        
        const SizedBox(height: 12),
        
        // Caption
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildCaption(context, theme),
        ),
        
        const SizedBox(height: 12),
        
        // Engagement stats and timestamp
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildEngagementStats(context, theme, colorScheme),
        ),
      ],
    );
  }

  Widget _buildMainImage(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3 / 4, // Standard social media aspect ratio
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(0), // Full width, no border radius
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(0),
          child: post.isNSFW 
            ? _buildNSFWOverlay(context)
            : _buildImage(context),
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    return Image.network(
      post.imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / 
                  loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.broken_image_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
              Text(
                'Failed to load image',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNSFWOverlay(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.visibility_off_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'Sensitive Content',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This post may contain sensitive content',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: () {
                // TODO: Show content after warning
              },
              child: const Text('View Anyway'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorAndActionsRow(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        // Author avatar and info
        InkWell(
          onTap: onAuthorPressed,
          borderRadius: BorderRadius.circular(24),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: colorScheme.primaryContainer,
                backgroundImage: post.authorAvatarUrl != null 
                  ? NetworkImage(post.authorAvatarUrl!)
                  : null,
                child: post.authorAvatarUrl == null
                  ? Icon(
                      Icons.person,
                      size: 20,
                      color: colorScheme.onPrimaryContainer,
                    )
                  : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.authorDisplayName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    _formatTimestamp(post.timestamp),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const Spacer(),
        
        // Action buttons
        Row(
          children: [
            // Like button
            IconButton(
              onPressed: onLikePressed,
              icon: Icon(
                post.isLikedByCurrentUser 
                  ? Icons.favorite 
                  : Icons.favorite_outline,
                color: post.isLikedByCurrentUser 
                  ? Colors.red 
                  : colorScheme.onSurfaceVariant,
              ),
              tooltip: post.isLikedByCurrentUser ? 'Unlike' : 'Like',
            ),
            
            // Save button
            IconButton(
              onPressed: onSavePressed,
              icon: Icon(
                post.isSavedByCurrentUser 
                  ? Icons.bookmark 
                  : Icons.bookmark_outline,
                color: post.isSavedByCurrentUser 
                  ? colorScheme.primary 
                  : colorScheme.onSurfaceVariant,
              ),
              tooltip: post.isSavedByCurrentUser ? 'Unsave' : 'Save',
            ),
            
            // More options button
            IconButton(
              onPressed: onMorePressed,
              icon: Icon(
                Icons.more_vert,
                color: colorScheme.onSurfaceVariant,
              ),
              tooltip: 'More options',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCaption(BuildContext context, ThemeData theme) {
    return Text(
      post.caption,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface,
        height: 1.4,
      ),
    );
  }

  Widget _buildEngagementStats(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        // Like count
        Row(
          children: [
            Icon(
              Icons.favorite,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              _formatCount(post.likeCount),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        
        const SizedBox(width: 16),
        
        // Comment count
        Row(
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              _formatCount(post.commentCount),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        
        const Spacer(),
        
        // Timestamp
        Text(
          _formatTimestamp(post.timestamp),
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
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
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  String _formatCount(int count) {
    if (count < 1000) {
      return count.toString();
    } else if (count < 1000000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
  }
}
