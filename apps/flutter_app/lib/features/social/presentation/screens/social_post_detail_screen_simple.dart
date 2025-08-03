import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/post_detail/models.dart';

/// Simple Social Post Detail Screen for testing UI implementation
/// Shows mockup data without Riverpod controller dependency
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
  // Use sample data from models
  late final SocialPostDetail mockPostDetail;
  late final List<Comment> mockComments;

  @override
  void initState() {
    super.initState();
    mockPostDetail = SocialPostDetail.getSample();
    mockComments = Comment.getSampleComments();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
        ),
        title: Text(
          'Post Detail',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Share feature working!'),
                  backgroundColor: colorScheme.primary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: Icon(Icons.share_outlined, color: colorScheme.onSurfaceVariant),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('More options feature working!'),
                  backgroundColor: colorScheme.primary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: Icon(Icons.more_vert, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
      body: Column(
        children: [
          // Post Detail Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author Info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: colorScheme.primary,
                        child: Text(
                          mockPostDetail.authorDisplayName[0].toUpperCase(),
                          style: TextStyle(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mockPostDetail.authorDisplayName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              '@${mockPostDetail.authorId}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Follow feature working!'),
                              backgroundColor: colorScheme.primary,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: const Text('Follow'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Post Image Placeholder
                  Container(
                    width: double.infinity,
                    height: 400,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_camera_outlined,
                          size: 64,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Outfit Combination Image',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Engagement Row
                  Row(
                    children: [
                      _buildEngagementButton(
                        icon: mockPostDetail.isLikedByCurrentUser ? Icons.favorite : Icons.favorite_outline,
                        label: '${mockPostDetail.likeCount}',
                        color: mockPostDetail.isLikedByCurrentUser ? Colors.red : colorScheme.onSurfaceVariant,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Like feature working!'),
                              backgroundColor: colorScheme.primary,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 24),
                      _buildEngagementButton(
                        icon: Icons.chat_bubble_outline,
                        label: '${mockPostDetail.commentCount}',
                        color: colorScheme.onSurfaceVariant,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Comment section focus!'),
                              backgroundColor: colorScheme.primary,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 24),
                      _buildEngagementButton(
                        icon: Icons.share_outlined,
                        label: '89', // mock share count
                        color: colorScheme.onSurfaceVariant,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Share feature working!'),
                              backgroundColor: colorScheme.primary,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(mockPostDetail.isSavedByCurrentUser ? 'Removed from saved' : 'Added to saved'),
                              backgroundColor: colorScheme.primary,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: Icon(
                          mockPostDetail.isSavedByCurrentUser ? Icons.bookmark : Icons.bookmark_outline,
                          color: mockPostDetail.isSavedByCurrentUser ? colorScheme.primary : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Caption
                  Text(
                    mockPostDetail.caption,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Comments Section
                  Text(
                    'Comments (${mockComments.length})',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Comments List
                  ...mockComments.map((comment) => _buildComment(context, comment)).toList(),
                ],
              ),
            ),
          ),
          
          // Comment Input
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(
                    'U',
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: colorScheme.outline),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: colorScheme.primary),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Comment posted!'),
                        backgroundColor: colorScheme.primary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.send,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComment(BuildContext context, Comment comment) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: colorScheme.primaryContainer,
            child: Text(
              comment.authorDisplayName[0].toUpperCase(),
              style: TextStyle(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.authorDisplayName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  comment.text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Comment like feature working!'),
                            backgroundColor: colorScheme.primary,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            comment.isLikedByCurrentUser ? Icons.favorite : Icons.favorite_outline,
                            size: 16,
                            color: comment.isLikedByCurrentUser ? Colors.red : colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${comment.likeCount}',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      _formatTimeAgo(comment.timestamp),
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
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

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
