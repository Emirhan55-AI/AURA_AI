import 'package:flutter/material.dart';
import 'chat_bubble.dart';

/// Chat List View - Displays the chat conversation between user and AI
/// 
/// This widget manages the scrollable list of chat messages and handles
/// the display of loading states for AI responses.
class ChatListView extends StatefulWidget {
  final List<Map<String, dynamic>> messages;
  final bool isLoading;

  const ChatListView({
    super.key,
    required this.messages,
    this.isLoading = false,
  });

  @override
  State<ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ChatListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Auto-scroll to bottom when new messages are added
    if (widget.messages.length > oldWidget.messages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      color: colorScheme.background,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: widget.messages.length + (widget.isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          // Show loading indicator at the end if AI is responding
          if (widget.isLoading && index == widget.messages.length) {
            return _buildLoadingIndicator(context, theme, colorScheme);
          }

          final message = widget.messages[index];
          return ChatBubble(
            message: message,
          );
        },
      ),
    );
  }

  Widget _buildLoadingIndicator(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            margin: const EdgeInsets.only(right: 32),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Aura is thinking...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
