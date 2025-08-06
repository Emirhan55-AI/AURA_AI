import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/app_loading_indicator.dart';
import '../../../../shared/widgets/app_error_widget.dart';
import '../../domain/entities/chat_message.dart';
import '../controllers/messaging_controller.dart';
import '../widgets/conversation_tile.dart' as conversation_widgets;
import '../widgets/messaging_app_bar.dart';
import '../widgets/messaging_fab.dart';
import '../widgets/empty_conversations_widget.dart';

/// Main messaging screen showing conversation list
/// 
/// Features:
/// - Real-time conversation updates
/// - Search functionality
/// - Pull-to-refresh
/// - Infinite scroll pagination
/// - Create new conversation
/// - Context menu actions (delete, archive, pin)
class MessagingScreen extends ConsumerStatefulWidget {
  const MessagingScreen({super.key});

  @override
  ConsumerState<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends ConsumerState<MessagingScreen>
    with AutomaticKeepAliveClientMixin {
  
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _setupScrollListener();
    _setupSearchListener();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent * 0.8) {
        _loadMoreConversations();
      }
    });
  }

  void _setupSearchListener() {
    _searchController.addListener(() {
      final query = _searchController.text;
      if (query != _searchQuery) {
        setState(() {
          _searchQuery = query;
        });
        _performSearch(query);
      }
    });
  }

  void _loadMoreConversations() {
    final controller = ref.read(messagingControllerProvider.notifier);
    if (!ref.read(messagingControllerProvider).hasReachedMax) {
      controller.loadConversations();
    }
  }

  void _performSearch(String query) {
    final controller = ref.read(messagingControllerProvider.notifier);
    controller.searchConversations(query);
  }

  void _refreshConversations() {
    final controller = ref.read(messagingControllerProvider.notifier);
    controller.loadConversations(refresh: true);
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchQuery = '';
        _refreshConversations();
      }
    });
  }

  void _createNewConversation() {
    // TODO: Navigate to contact selection screen
    // For now, show a placeholder
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Conversation'),
        content: const Text('Contact selection feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _onConversationTap(ChatConversation conversation) {
    // Mark as read
    ref.read(messagingControllerProvider.notifier)
        .markConversationAsRead(conversation.id);
    
    // Navigate to chat screen
    context.push('/messaging/chat/${conversation.id}');
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    final messagingState = ref.watch(messagingControllerProvider);
    final unreadCount = ref.watch(unreadCountProvider);

    return Scaffold(
      appBar: MessagingAppBar(
        isSearching: _isSearching,
        searchController: _searchController,
        unreadCount: unreadCount,
        onSearchToggle: _toggleSearch,
        onClearSearch: () {
          _searchController.clear();
          _refreshConversations();
        },
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshConversations(),
        child: _buildBody(messagingState),
      ),
      floatingActionButton: MessagingFAB(
        onPressed: _createNewConversation,
      ),
    );
  }

  Widget _buildBody(MessagingState state) {
    if (state.isLoading && state.conversations.isEmpty) {
      return const Center(
        child: AppLoadingIndicator(message: 'Loading conversations...'),
      );
    }

    if (state.error != null && state.conversations.isEmpty) {
      return AppErrorWidget(
        message: state.error!,
        onRetry: _refreshConversations,
      );
    }

    if (state.conversations.isEmpty) {
      return EmptyConversationsWidget(
        isSearching: _isSearching,
        searchQuery: _searchQuery,
        onCreateConversation: _createNewConversation,
      );
    }

    return _buildConversationsList(state);
  }

  Widget _buildConversationsList(MessagingState state) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Error banner if there's an error with existing conversations
        if (state.error != null)
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.error!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      ref.read(messagingControllerProvider.notifier)
                          .loadConversations(refresh: true);
                    },
                    icon: const Icon(Icons.refresh),
                    color: Colors.red.shade700,
                  ),
                ],
              ),
            ),
          ),

        // Conversations list
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index >= state.conversations.length) {
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

              final conversation = state.conversations[index];
              
              // Get other participant info (for direct messages)
              final otherParticipant = conversation.participants
                  .firstWhere((p) => p.userId != 'current_user_id', // TODO: Get from auth
                      orElse: () => conversation.participants.first);
              
              return conversation_widgets.ConversationTile(
                conversationId: conversation.id,
                userName: otherParticipant.name,
                userAvatar: otherParticipant.avatarUrl,
                lastMessage: conversation.lastMessage,
                unreadCount: conversation.unreadCount,
                isOnline: otherParticipant.status == ParticipantStatus.online,
                isTyping: false, // TODO: Track typing status per conversation
                onTap: () => _onConversationTap(conversation),
              );
            },
            childCount: state.conversations.length + (state.hasReachedMax ? 0 : 1),
          ),
        ),

        // Bottom padding for FAB
        const SliverPadding(
          padding: EdgeInsets.only(bottom: 80),
        ),
      ],
    );
  }
}
