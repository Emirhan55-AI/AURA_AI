import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/app_loading_indicator.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../domain/entities/chat_message.dart';
import '../controllers/messaging_controller.dart';
import '../widgets/chat_app_bar.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input_field.dart';
import '../widgets/typing_indicator_widget.dart';
import '../widgets/connection_status_banner.dart';

/// Individual chat conversation screen
/// 
/// Features:
/// - Real-time message updates
/// - Message bubbles with status indicators
/// - Typing indicators
/// - Message replies
/// - Media sharing
/// - Connection status
/// - Message reactions
class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  
  const ChatScreen({
    super.key,
    required this.conversationId,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with WidgetsBindingObserver {
  
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();
  
  bool _showScrollToBottom = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupScrollListener();
    _setupMessageListener();
    
    // Auto-focus message input after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _messageFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    _messageController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = ref.read(chatControllerProvider(widget.conversationId).notifier);
    
    switch (state) {
      case AppLifecycleState.resumed:
        // Reconnect if needed
        break;
      case AppLifecycleState.paused:
        // Stop typing indicator
        controller.stopTyping();
        break;
      default:
        break;
    }
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      // Show/hide scroll to bottom button
      final showButton = _scrollController.offset > 200;
      if (showButton != _showScrollToBottom) {
        setState(() {
          _showScrollToBottom = showButton;
        });
      }

      // Load more messages when scrolling to top
      if (_scrollController.position.pixels >= 
          _scrollController.position.maxScrollExtent * 0.8) {
        _loadMoreMessages();
      }
    });
  }

  void _setupMessageListener() {
    // Listen for new messages and auto-scroll
    ref.listen(
      chatControllerProvider(widget.conversationId).select((state) => state.messages),
      (previous, current) {
        if (previous != null && current.length > previous.length) {
          // New message received, scroll to bottom
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
        }
      },
    );
  }

  void _loadMoreMessages() {
    final controller = ref.read(chatControllerProvider(widget.conversationId).notifier);
    controller.loadMessages(loadMore: true);
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final controller = ref.read(chatControllerProvider(widget.conversationId).notifier);
    controller.sendMessage(text);
    
    _messageController.clear();
    _scrollToBottom();
  }

  void _onMessageChanged(String text) {
    final controller = ref.read(chatControllerProvider(widget.conversationId).notifier);
    
    if (text.isNotEmpty) {
      controller.startTyping();
    } else {
      controller.stopTyping();
    }
  }

  void _showMessageOptions(ChatMessage message) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => MessageOptionsBottomSheet(
        message: message,
        onReply: () {
          Navigator.pop(context);
          _replyToMessage(message);
        },
        onReact: (emoji) {
          Navigator.pop(context);
          _addReaction(message, emoji);
        },
        onDelete: () {
          Navigator.pop(context);
          _deleteMessage(message);
        },
      ),
    );
  }

  void _replyToMessage(ChatMessage message) {
    final controller = ref.read(chatControllerProvider(widget.conversationId).notifier);
    controller.setReplyToMessage(message);
    _messageFocusNode.requestFocus();
  }

  void _addReaction(ChatMessage message, String emoji) {
    final controller = ref.read(chatControllerProvider(widget.conversationId).notifier);
    controller.addReaction(message.id, emoji);
  }

  void _deleteMessage(ChatMessage message) {
    final controller = ref.read(chatControllerProvider(widget.conversationId).notifier);
    controller.deleteMessage(message.id);
  }

  void _clearReply() {
    final controller = ref.read(chatControllerProvider(widget.conversationId).notifier);
    controller.clearReply();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatControllerProvider(widget.conversationId));
    
    return Scaffold(
      appBar: ChatAppBar(
        conversationId: widget.conversationId,
        conversation: chatState.conversation,
      ),
      body: Column(
        children: [
          // Connection status banner
          ConnectionStatusBanner(
            isConnected: chatState.isConnected,
          ),
          
          // Messages list
          Expanded(
            child: _buildMessagesList(chatState),
          ),
          
          // Message input
          MessageInputField(
            controller: _messageController,
            focusNode: _messageFocusNode,
            replyingToMessage: chatState.replyingToMessage,
            onMessageChanged: _onMessageChanged,
            onSend: _sendMessage,
            onClearReply: _clearReply,
            onAttachMedia: _showMediaPicker,
            onSendOutfit: _showOutfitPicker,
          ),
        ],
      ),
      floatingActionButton: _showScrollToBottom
          ? FloatingActionButton.small(
              onPressed: _scrollToBottom,
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.keyboard_arrow_down),
            )
          : null,
    );
  }

  Widget _buildMessagesList(ChatState state) {
    if (state.isLoading && state.messages.isEmpty) {
      return const Center(
        child: AppLoadingIndicator(message: 'Loading messages...'),
      );
    }

    if (state.error != null && state.messages.isEmpty) {
      return AppErrorWidget(
        message: state.error!,
        onRetry: () {
          ref.read(chatControllerProvider(widget.conversationId).notifier)
              .loadMessages();
        },
      );
    }

    if (state.messages.isEmpty) {
      return _buildEmptyChat();
    }

    return Stack(
      children: [
        CustomScrollView(
          controller: _scrollController,
          reverse: true, // Start from bottom
          slivers: [
            // Typing indicators
            SliverToBoxAdapter(
              child: TypingIndicatorWidget(
                typingIndicators: state.typingIndicators,
              ),
            ),
            
            // Messages
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index >= state.messages.length) {
                    // Loading more indicator
                    return state.hasReachedMax
                        ? const SizedBox.shrink()
                        : const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: AppLoadingIndicator(),
                            ),
                          );
                  }

                  final message = state.messages[index];
                  final previousMessage = index < state.messages.length - 1
                      ? state.messages[index + 1]
                      : null;
                  
                  final showDateSeparator = _shouldShowDateSeparator(
                    message, 
                    previousMessage,
                  );

                  return Column(
                    children: [
                      if (showDateSeparator)
                        _buildDateSeparator(message.createdAt),
                      
                      MessageBubble(
                        message: message,
                        previousMessage: previousMessage,
                        onLongPress: () => _showMessageOptions(message),
                        onReactionTap: (String emoji) => _addReaction(message, emoji),
                      ),
                    ],
                  );
                },
                childCount: state.messages.length + (state.hasReachedMax ? 0 : 1),
              ),
            ),
            
            // Bottom padding
            const SliverPadding(
              padding: EdgeInsets.only(bottom: 16),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyChat() {
    final conversation = ref.watch(
      chatControllerProvider(widget.conversationId).select((s) => s.conversation),
    );
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: conversation?.avatarUrl != null
                  ? NetworkImage(conversation!.avatarUrl!)
                  : null,
              backgroundColor: Colors.grey.shade300,
              child: conversation?.avatarUrl == null
                  ? Text(
                      conversation?.name.isNotEmpty == true
                          ? conversation!.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              conversation?.getDisplayName('current_user') ?? 'Chat',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Start your conversation about fashion, style, and swaps!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSeparator(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);
    
    String dateText;
    if (messageDate == today) {
      dateText = 'Today';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      dateText = 'Yesterday';
    } else if (now.difference(messageDate).inDays < 7) {
      const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      dateText = weekdays[messageDate.weekday - 1];
    } else {
      dateText = '${date.day}/${date.month}/${date.year}';
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            dateText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  bool _shouldShowDateSeparator(ChatMessage current, ChatMessage? previous) {
    if (previous == null) return true;
    
    final currentDate = DateTime(
      current.createdAt.year,
      current.createdAt.month,
      current.createdAt.day,
    );
    
    final previousDate = DateTime(
      previous.createdAt.year,
      previous.createdAt.month,
      previous.createdAt.day,
    );
    
    return currentDate != previousDate;
  }

  void _showMediaPicker() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement camera
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Photo Library'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement photo picker
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Video'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement video picker
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showOutfitPicker() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Share an Outfit',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const ListTile(
              leading: Icon(Icons.checkroom),
              title: Text('From My Wardrobe'),
              subtitle: Text('Choose from your saved outfits'),
            ),
            const ListTile(
              leading: Icon(Icons.photo_camera),
              title: Text('Take New Photo'),
              subtitle: Text('Create and share a new outfit'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// Message options bottom sheet
class MessageOptionsBottomSheet extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback onReply;
  final ValueChanged<String> onReact;
  final VoidCallback onDelete;

  const MessageOptionsBottomSheet({
    super.key,
    required this.message,
    required this.onReply,
    required this.onReact,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isOwnMessage = message.senderId == 'current_user';
    
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Quick reactions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickReaction('👍', onReact),
                _buildQuickReaction('❤️', onReact),
                _buildQuickReaction('😂', onReact),
                _buildQuickReaction('😍', onReact),
                _buildQuickReaction('🔥', onReact),
              ],
            ),
          ),
          
          const Divider(),
          
          // Actions
          ListTile(
            leading: const Icon(Icons.reply),
            title: const Text('Reply'),
            onTap: onReply,
          ),
          
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('Copy'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Copy message content
            },
          ),
          
          if (isOwnMessage)
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: onDelete,
            ),
          
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildQuickReaction(String emoji, ValueChanged<String> onReact) {
    return GestureDetector(
      onTap: () => onReact(emoji),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade100,
        ),
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
