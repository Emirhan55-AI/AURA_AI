import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/app_notification.dart';

/// Individual notification item widget
/// 
/// Features:
/// - Visual indicators for read/unread status
/// - Type-specific icons and colors
/// - Long press for selection mode
/// - Swipe actions for quick operations
/// - Accessibility support
class NotificationItem extends StatelessWidget {
  final AppNotification notification;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onDelete;

  const NotificationItem({
    super.key,
    required this.notification,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onTap,
    required this.onLongPress,
    this.onMarkAsRead,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: _buildDismissBackground(colorScheme, isRead: !notification.isRead),
      confirmDismiss: (direction) async {
        if (!notification.isRead && onMarkAsRead != null) {
          onMarkAsRead!();
          return false; // Don't dismiss, just mark as read
        }
        return await _showDeleteConfirmation(context);
      },
      onDismissed: (direction) {
        onDelete?.call();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Material(
          color: _getBackgroundColor(colorScheme),
          borderRadius: BorderRadius.circular(12),
          elevation: notification.isRead ? 0 : 1,
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? Border.all(color: colorScheme.primary, width: 2)
                    : null,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selection checkbox or notification icon
                  if (isSelectionMode)
                    _buildSelectionCheckbox(colorScheme)
                  else
                    _buildNotificationIcon(colorScheme),
                  
                  const SizedBox(width: 12),
                  
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and timestamp row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w600,
                                  color: notification.isRead 
                                      ? colorScheme.onSurfaceVariant 
                                      : colorScheme.onSurface,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _formatTimestamp(notification.createdAt),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                if (!notification.isRead)
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 4),
                        
                        // Body text
                        if (notification.message.isNotEmpty)
                          Text(
                            notification.message,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: notification.isRead 
                                  ? colorScheme.onSurfaceVariant 
                                  : colorScheme.onSurface,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        
                        // Priority indicator
                        if (notification.priority == NotificationPriority.high ||
                            notification.priority == NotificationPriority.urgent)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: colorScheme.errorContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                notification.priority == NotificationPriority.urgent ? 'URGENT' : 'HIGH PRIORITY',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onErrorContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build selection checkbox
  Widget _buildSelectionCheckbox(ColorScheme colorScheme) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? colorScheme.primary : colorScheme.outline,
          width: 2,
        ),
        color: isSelected ? colorScheme.primary : Colors.transparent,
      ),
      child: isSelected
          ? Icon(
              Icons.check,
              color: colorScheme.onPrimary,
              size: 20,
            )
          : null,
    );
  }

  /// Build notification type icon
  Widget _buildNotificationIcon(ColorScheme colorScheme) {
    final typeColor = _getTypeColor();
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: typeColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _getNotificationIcon(),
        color: typeColor,
        size: 22,
      ),
    );
  }

  /// Get notification type color
  Color _getTypeColor() {
    switch (notification.type) {
      case NotificationType.social:
        return const Color(0xFFFF6F61); // Primary coral
      case NotificationType.system:
        return const Color(0xFF6366F1); // Indigo
      case NotificationType.swap:
        return const Color(0xFF10B981); // Emerald
      case NotificationType.wardrobe:
        return const Color(0xFFF59E0B); // Amber
      case NotificationType.challenge:
        return const Color(0xFFEF4444); // Red
      case NotificationType.message:
        return const Color(0xFF8B5CF6); // Purple
    }
  }

  /// Get notification icon based on type
  IconData _getNotificationIcon() {
    switch (notification.type) {
      case NotificationType.social:
        return Icons.people;
      case NotificationType.challenge:
        return Icons.star;
      case NotificationType.wardrobe:
        return Icons.checkroom;
      case NotificationType.swap:
        return Icons.swap_horiz;
      case NotificationType.system:
        return Icons.settings;
      case NotificationType.message:
        return Icons.message;
    }
  }

  /// Get background color based on read status
  Color _getBackgroundColor(ColorScheme colorScheme) {
    if (isSelected) {
      return colorScheme.primaryContainer.withOpacity(0.3);
    }
    if (!notification.isRead) {
      return colorScheme.surfaceContainerHighest;
    }
    return colorScheme.surface;
  }

  /// Build dismiss background
  Widget _buildDismissBackground(ColorScheme colorScheme, {required bool isRead}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isRead ? colorScheme.primaryContainer : colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isRead ? Icons.mark_email_read : Icons.delete,
            color: isRead ? colorScheme.onPrimaryContainer : colorScheme.onErrorContainer,
          ),
          const SizedBox(height: 4),
          Text(
            isRead ? 'Mark Read' : 'Delete',
            style: TextStyle(
              color: isRead ? colorScheme.onPrimaryContainer : colorScheme.onErrorContainer,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Format timestamp
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return DateFormat('MMM d').format(timestamp);
    }
  }

  /// Show delete confirmation
  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notification'),
        content: const Text('Are you sure you want to delete this notification?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
