import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/chat_message.dart';

/// Chat screen app bar with conversation info and actions
class ChatAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String conversationId;
  final ChatConversation? conversation;

  const ChatAppBar({
    super.key,
    required this.conversationId,
    this.conversation,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversation = this.conversation;
    
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      title: conversation != null
          ? _buildConversationInfo(context, conversation)
          : const Text('Chat'),
      actions: [
        IconButton(
          icon: const Icon(Icons.videocam_outlined),
          onPressed: () => _startVideoCall(context),
        ),
        IconButton(
          icon: const Icon(Icons.call_outlined),
          onPressed: () => _startVoiceCall(context),
        ),
        PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(context, value),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view_profile',
              child: ListTile(
                leading: Icon(Icons.person_outline),
                title: Text('View Profile'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'media',
              child: ListTile(
                leading: Icon(Icons.photo_library_outlined),
                title: Text('Media & Files'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'search',
              child: ListTile(
                leading: Icon(Icons.search),
                title: Text('Search in Chat'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'mute',
              child: ListTile(
                leading: Icon(Icons.notifications_off_outlined),
                title: Text('Mute Notifications'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'block',
              child: ListTile(
                leading: Icon(Icons.block, color: Colors.red),
                title: Text('Block User', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      elevation: 1,
    );
  }

  Widget _buildConversationInfo(BuildContext context, ChatConversation conversation) {
    return Row(
      children: [
        // Avatar
        CircleAvatar(
          radius: 18,
          backgroundImage: conversation.avatarUrl != null
              ? NetworkImage(conversation.avatarUrl!)
              : null,
          backgroundColor: Colors.grey.shade300,
          child: conversation.avatarUrl == null
              ? Text(
                  conversation.name.isNotEmpty
                      ? conversation.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
              : null,
        ),
        
        const SizedBox(width: 8),
        
        // Name and status
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                conversation.getDisplayName('current_user'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              Text(
                _getStatusText(conversation),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: _getStatusColor(conversation),
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getStatusText(ChatConversation conversation) {
    final otherParticipant = conversation.participants
        .where((p) => p.userId != 'current_user')
        .firstOrNull;
    
    if (otherParticipant == null) return 'Unknown';
    
    switch (otherParticipant.status) {
      case ParticipantStatus.online:
        return 'Online';
      case ParticipantStatus.away:
        return 'Away';
      case ParticipantStatus.busy:
        return 'Busy';
      case ParticipantStatus.offline:
        final lastSeen = otherParticipant.lastSeenAt;
        if (lastSeen == null) return 'Offline';
        
        final now = DateTime.now();
        final difference = now.difference(lastSeen);
        
        if (difference.inMinutes < 1) {
          return 'Just now';
        } else if (difference.inHours < 1) {
          return '${difference.inMinutes}m ago';
        } else if (difference.inDays < 1) {
          return '${difference.inHours}h ago';
        } else if (difference.inDays < 7) {
          return '${difference.inDays}d ago';
        } else {
          return 'Last seen ${lastSeen.day}/${lastSeen.month}';
        }
    }
  }

  Color _getStatusColor(ChatConversation conversation) {
    final otherParticipant = conversation.participants
        .where((p) => p.userId != 'current_user')
        .firstOrNull;
    
    if (otherParticipant == null) return Colors.grey;
    
    switch (otherParticipant.status) {
      case ParticipantStatus.online:
        return Colors.green;
      case ParticipantStatus.away:
        return Colors.orange;
      case ParticipantStatus.busy:
        return Colors.red;
      case ParticipantStatus.offline:
        return Colors.grey;
    }
  }

  void _startVideoCall(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Video call feature coming soon!'),
      ),
    );
  }

  void _startVoiceCall(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voice call feature coming soon!'),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'view_profile':
        // TODO: Navigate to user profile
        break;
      case 'media':
        // TODO: Show media gallery
        break;
      case 'search':
        // TODO: Open chat search
        break;
      case 'mute':
        // TODO: Mute/unmute conversation
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notifications muted')),
        );
        break;
      case 'block':
        _showBlockConfirmation(context);
        break;
    }
  }

  void _showBlockConfirmation(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block User'),
        content: const Text(
          'Are you sure you want to block this user? You won\'t receive messages from them anymore.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Block user
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User blocked')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }
}
