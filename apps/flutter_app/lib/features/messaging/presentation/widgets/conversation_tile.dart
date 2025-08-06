import 'package:flutter/material.dart';
import '../../domain/entities/chat_message.dart';

/// Widget for displaying conversation items in the messaging list
class ConversationTile extends StatelessWidget {
  final String conversationId;
  final String userName;
  final String? userAvatar;
  final ChatMessage? lastMessage;
  final int unreadCount;
  final bool isOnline;
  final bool isTyping;
  final VoidCallback? onTap;

  const ConversationTile({
    super.key,
    required this.conversationId,
    required this.userName,
    this.userAvatar,
    this.lastMessage,
    this.unreadCount = 0,
    this.isOnline = false,
    this.isTyping = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return ListTile(
      onTap: onTap,
      leading: _buildAvatar(context),
      title: Row(
        children: [
          Expanded(
            child: Text(
              userName,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (lastMessage != null)
            Text(
              _formatTimestamp(lastMessage!.createdAt),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: _buildSubtitle(context),
          ),
          if (unreadCount > 0) ...[
            const SizedBox(width: 8),
            _buildUnreadBadge(context),
          ],
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Stack(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: colorScheme.primaryContainer,
          backgroundImage: userAvatar != null ? NetworkImage(userAvatar!) : null,
          child: userAvatar == null
              ? Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                )
              : null,
        ),
        if (isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    if (isTyping) {
      return Row(
        children: [
          Icon(
            Icons.more_horiz,
            size: 16,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            'typing...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.primary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      );
    }
    
    if (lastMessage == null) {
      return Text(
        'No messages yet',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface.withOpacity(0.6),
          fontStyle: FontStyle.italic,
        ),
      );
    }
    
    return Row(
      children: [
        if (lastMessage!.senderId == 'current_user_id') // TODO: Get from auth
          Icon(
            _getStatusIcon(lastMessage!.status),
            size: 16,
            color: _getStatusColor(lastMessage!.status),
          ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            _getMessagePreview(lastMessage!),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: unreadCount > 0 
                ? colorScheme.onSurface
                : colorScheme.onSurface.withOpacity(0.7),
              fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildUnreadBadge(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      constraints: const BoxConstraints(minWidth: 20),
      child: Text(
        unreadCount > 99 ? '99+' : unreadCount.toString(),
        style: TextStyle(
          color: colorScheme.onPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${timestamp.day}/${timestamp.month}';
      }
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Now';
    }
  }

  IconData _getStatusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return Icons.schedule;
      case MessageStatus.sent:
        return Icons.check;
      case MessageStatus.delivered:
        return Icons.done_all;
      case MessageStatus.read:
        return Icons.done_all;
      case MessageStatus.failed:
        return Icons.error_outline;
    }
  }

  Color _getStatusColor(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return Colors.grey;
      case MessageStatus.sent:
        return Colors.grey;
      case MessageStatus.delivered:
        return Colors.grey;
      case MessageStatus.read:
        return Colors.blue;
      case MessageStatus.failed:
        return Colors.red;
    }
  }

  String _getMessagePreview(ChatMessage message) {
    switch (message.type) {
      case MessageType.text:
        return message.content;
      case MessageType.image:
        return '📷 Photo';
      case MessageType.voice:
        return '🎵 Voice message';
      case MessageType.audio:
        return '🎵 Audio message';
      case MessageType.video:
        return '🎥 Video';
      case MessageType.file:
        return '📎 File';
      case MessageType.sticker:
        return '😊 Sticker';
      case MessageType.location:
        return '📍 Location';
      case MessageType.outfit:
        return '👗 Outfit shared';
      case MessageType.swapRequest:
        return '🔄 Swap request';
      case MessageType.system:
        return message.content;
    }
  }
}
