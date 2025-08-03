import 'package:flutter/material.dart';
import 'models.dart';
import 'comment_item.dart';

/// A widget that displays the list of comments for a social post
/// Handles empty state and provides a scrollable list of comments
class CommentsSection extends StatelessWidget {
  final List<Comment> comments;
  final void Function(Comment)? onCommentLikePressed;
  final void Function(Comment)? onCommentAuthorPressed;
  final void Function(Comment)? onCommentReplyPressed;

  const CommentsSection({
    super.key,
    required this.comments,
    this.onCommentLikePressed,
    this.onCommentAuthorPressed,
    this.onCommentReplyPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Comments header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                'Comments',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  comments.length.toString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Divider
        Divider(
          height: 1,
          thickness: 1,
          color: colorScheme.outline.withOpacity(0.2),
        ),
        
        const SizedBox(height: 8),
        
        // Comments list or empty state
        if (comments.isEmpty) 
          _buildEmptyState(context, theme, colorScheme)
        else 
          _buildCommentsList(context),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: colorScheme.onSurfaceVariant.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'No comments yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to share your thoughts!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsList(BuildContext context) {
    return Column(
      children: comments.map((comment) {
        return CommentItem(
          comment: comment,
          onLikePressed: () => onCommentLikePressed?.call(comment),
          onAuthorPressed: () => onCommentAuthorPressed?.call(comment),
          onReplyPressed: () => onCommentReplyPressed?.call(comment),
        );
      }).toList(),
    );
  }
}
