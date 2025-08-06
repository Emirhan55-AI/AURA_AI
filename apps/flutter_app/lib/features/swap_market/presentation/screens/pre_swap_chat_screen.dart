import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/loading/shimmer_loading_widget.dart';
import '../../../../shared/widgets/dialogs/confirmation_dialog.dart';
import '../../../messaging/presentation/widgets/message_bubble.dart';
import '../../../messaging/presentation/widgets/message_input_field.dart';
import '../../../messaging/presentation/widgets/typing_indicator_widget.dart';
import '../../../messaging/domain/entities/chat_message.dart';
import '../controllers/pre_swap_chat_controller.dart';

/// Pre-Swap Chat Screen
/// 
/// Screen for direct messaging between users regarding swap listings
/// Includes deal agreement functionality and swap-specific features
class PreSwapChatScreen extends ConsumerStatefulWidget {
  final String otherUserId;
  final String? swapListingId;
  final String? otherUserName;
  final String? otherUserAvatar;

  const PreSwapChatScreen({
    Key? key,
    required this.otherUserId,
    this.swapListingId,
    this.otherUserName,
    this.otherUserAvatar,
  }) : super(key: key);

  @override
  ConsumerState<PreSwapChatScreen> createState() => _PreSwapChatScreenState();
}

class _PreSwapChatScreenState extends ConsumerState<PreSwapChatScreen>
    with TickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final TextEditingController _messageController;
  late final FocusNode _messageFocusNode;
  late final AnimationController _dealButtonAnimationController;
  bool _showScrollToBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _messageController = TextEditingController();
    _messageFocusNode = FocusNode();
    _dealButtonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scrollController.addListener(_handleScroll);

    // Initialize chat when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(preSwapChatControllerProvider.notifier)
          .initChat(widget.otherUserId, widget.swapListingId);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    _messageFocusNode.dispose();
    _dealButtonAnimationController.dispose();
    
    // Clean up chat controller
    ref.read(preSwapChatControllerProvider.notifier).leaveChat();
    super.dispose();
  }

  void _handleScroll() {
    final showButton = _scrollController.offset > 100;
    if (showButton != _showScrollToBottom) {
      setState(() {
        _showScrollToBottom = showButton;
      });
    }

    // Load more messages when near top
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(preSwapChatControllerProvider.notifier).loadMessages(loadMore: true);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();
    await ref
        .read(preSwapChatControllerProvider.notifier)
        .sendMessage(message);
    _scrollToBottom();
  }

  Future<void> _showDealAgreementDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Confirm Deal Agreement',
        message: 'Are you sure you want to agree to this swap deal? '
            'This will notify the other party that you\'re ready to proceed. '
            'Please ensure you\'re committed to following through with the swap.',
        confirmText: 'Agree to Deal',
        cancelText: 'Not Yet',
        isDestructive: false,
        icon: Icons.handshake,
      ),
    );

    if (confirmed == true) {
      HapticFeedback.mediumImpact();
      await ref
          .read(preSwapChatControllerProvider.notifier)
          .agreeToDeal();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🤝 Deal agreement sent!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(preSwapChatControllerProvider);
    final otherUserAsync = ref.watch(otherUserInfoProvider(widget.otherUserId));

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: _buildAppBar(context, otherUserAsync),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Deal status banner
            if (chatState.thread?.isDealAgreed == true)
              _buildDealAgreedBanner(),
            
            // Messages list
            Expanded(
              child: _buildMessagesList(context, chatState),
            ),
            
            // Message input
            _buildMessageInput(context, chatState),
          ],
        ),
      ),
      floatingActionButton: _showScrollToBottom
          ? FloatingActionButton.small(
              onPressed: _scrollToBottom,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.keyboard_arrow_down),
            )
          : null,
    );
  }

  Widget _buildAppBar(BuildContext context, AsyncValue<Map<String, dynamic>?> otherUserAsync) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 1,
      shadowColor: Colors.black26,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => context.pop(),
      ),
      title: otherUserAsync.when(
        data: (userData) => _buildAppBarTitle(userData),
        loading: () => _buildAppBarLoadingTitle(),
        error: (error, stack) => _buildAppBarErrorTitle(),
      ),
      actions: [
        // Deal agreement button
        Consumer(
          builder: (context, ref, child) {
            final chatState = ref.watch(preSwapChatControllerProvider);
            if (chatState.thread?.isDealAgreed == true) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Deal Agreed',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }
            
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                onPressed: chatState.isAgreingToDeal ? null : _showDealAgreementDialog,
                icon: chatState.isAgreingToDeal
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.handshake, size: 18),
                label: const Text('Deal', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
            );
          },
        ),
        
        // More options
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'report':
                _showReportDialog();
                break;
              case 'block':
                _showBlockDialog();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'report',
              child: Row(
                children: [
                  Icon(Icons.report_outlined, size: 18),
                  SizedBox(width: 8),
                  Text('Report'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'block',
              child: Row(
                children: [
                  Icon(Icons.block_outlined, size: 18),
                  SizedBox(width: 8),
                  Text('Block User'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAppBarTitle(Map<String, dynamic>? userData) {
    if (userData == null) return const Text('Chat');

    return Row(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: userData['avatar'] != null
                  ? NetworkImage(userData['avatar'] as String)
                  : null,
              child: userData['avatar'] == null
                  ? Text(
                      (userData['name'] as String).substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            if (userData['isOnline'] == true)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.surface,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (userData['name'] as String?) ?? 'Unknown User',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                userData['isOnline'] == true
                    ? 'Online'
                    : 'Last seen ${_formatLastSeen(userData['lastSeen'] as DateTime?)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppBarLoadingTitle() {
    return Row(
      children: [
        ShimmerLoadingWidget(
          child: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey[300],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerLoadingWidget(
              child: Container(
                width: 100,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 4),
            ShimmerLoadingWidget(
              child: Container(
                width: 60,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAppBarErrorTitle() {
    return const Row(
      children: [
        Icon(Icons.error_outline, color: Colors.red),
        SizedBox(width: 8),
        Text('Error loading user'),
      ],
    );
  }

  Widget _buildDealAgreedBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withOpacity(0.1),
            Colors.green.withOpacity(0.05),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: Colors.green.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Deal Agreement Reached! 🤝',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Both parties have agreed to proceed with the swap',
                  style: TextStyle(
                    color: Colors.green.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              // Navigate to swap completion flow
              // This would be implemented based on your app flow
            },
            child: const Text('Next Steps'),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(BuildContext context, PreSwapChatState chatState) {
    if (chatState.isLoading && chatState.messages.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (chatState.error != null && chatState.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load messages',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              chatState.error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              text: 'Retry',
              onPressed: () {
                ref
                    .read(preSwapChatControllerProvider.notifier)
                    .initChat(widget.otherUserId, widget.swapListingId);
              },
            ),
          ],
        ),
      );
    }

    if (chatState.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Start the conversation',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Send your first message about the swap',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(preSwapChatControllerProvider.notifier)
            .loadMessages();
      },
      child: ListView.builder(
        controller: _scrollController,
        reverse: true, // Most recent at bottom
        padding: const EdgeInsets.all(16),
        itemCount: chatState.messages.length + 
            (chatState.isLoadingMoreMessages ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == chatState.messages.length) {
            // Loading more indicator
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          final message = chatState.messages[index];

          // Convert DirectMessage to ChatMessage for the MessageBubble widget
          final chatMessage = ChatMessage(
            id: message.id,
            conversationId: message.threadId,
            senderId: message.senderId,
            senderName: message.senderName,
            senderAvatarUrl: message.senderAvatarUrl,
            type: _mapMessageType(message.messageType),
            content: message.content,
            createdAt: message.sentAt,
            status: _mapMessageStatus(message.status),
          );

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: MessageBubble(
              message: chatMessage,
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context, PreSwapChatState chatState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          // Typing indicator
          if (chatState.typingUserId != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TypingIndicatorWidget(
                typingIndicators: [], // Empty list for now - could be populated from controller
              ),
            ),
          
          // Message input field
          MessageInputField(
            controller: _messageController,
            focusNode: _messageFocusNode,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }

  String _formatLastSeen(DateTime? lastSeen) {
    if (lastSeen == null) return 'Unknown';
    
    final now = DateTime.now();
    final difference = now.difference(lastSeen);
    
    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  // Helper methods to map between domain and UI enums
  MessageType _mapMessageType(String messageType) {
    switch (messageType) {
      case 'text':
        return MessageType.text;
      case 'system':
        return MessageType.system;
      case 'image':
        return MessageType.image;
      default:
        return MessageType.text;
    }
  }

  MessageStatus _mapMessageStatus(String status) {
    switch (status) {
      case 'sending':
        return MessageStatus.sending;
      case 'sent':
        return MessageStatus.sent;
      case 'delivered':
        return MessageStatus.delivered;
      case 'read':
        return MessageStatus.read;
      case 'failed':
        return MessageStatus.failed;
      default:
        return MessageStatus.sent;
    }
  }

  void _showReportDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report User'),
        content: const Text(
          'Are you sure you want to report this user? '
          'This action will be reviewed by our team.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Handle report logic here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User reported successfully')),
              );
            },
            child: const Text('Report', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showBlockDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block User'),
        content: const Text(
          'Are you sure you want to block this user? '
          'You won\'t be able to receive messages from them.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Handle block logic here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User blocked successfully')),
              );
            },
            child: const Text('Block', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
