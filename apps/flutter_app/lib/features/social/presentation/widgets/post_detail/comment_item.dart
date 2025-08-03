import 'package:flutter/material.dart';
import 'models.dart';

/// A widget representing a single comment in the comments list
/// Displays the commenter's info, comment text, timestamp, and interaction options
class CommentItem extends StatelessWidget {
  final Comment comment;
  final VoidCallback? onLikePressed;
  final VoidCallback? onAuthorPressed;
  final VoidCallback? onReplyPressed;

  const CommentItem({
    super.key,
    required this.comment,
    this.onLikePressed,
    this.onAuthorPressed,
    this.onReplyPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author avatar
          InkWell(
            onTap: onAuthorPressed,
            borderRadius: BorderRadius.circular(16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: colorScheme.primaryContainer,
              backgroundImage: comment.authorAvatarUrl != null 
                ? NetworkImage(comment.authorAvatarUrl!)
                : null,
              child: comment.authorAvatarUrl == null
                ? Icon(
                    Icons.person,
                    size: 16,
                    color: colorScheme.onPrimaryContainer,
                  )
                : null,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Comment content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author name and comment text
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Author name
                      InkWell(
                        onTap: onAuthorPressed,
                        child: Text(
                          comment.authorDisplayName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Comment text
                      Text(
                        comment.text,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Action row (timestamp, like, reply)
                Row(
                  children: [
                    // Timestamp
                    Text(
                      _formatTimestamp(comment.timestamp),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Like button
                    InkWell(
                      onTap: onLikePressed,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              comment.isLikedByCurrentUser 
                                ? Icons.favorite 
                                : Icons.favorite_outline,
                              size: 14,
                              color: comment.isLikedByCurrentUser 
                                ? Colors.red 
                                : colorScheme.onSurfaceVariant,
                            ),
                            if (comment.likeCount > 0) ...[
                              const SizedBox(width: 4),
                              Text(
                                _formatCount(comment.likeCount),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: comment.isLikedByCurrentUser 
                                    ? Colors.red 
                                    : colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Reply button
                    InkWell(
                      onTap: onReplyPressed,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text(
                          'Reply',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
