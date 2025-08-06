import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../messaging/domain/repositories/messaging_repository.dart';
import '../../../messaging/domain/entities/chat_message.dart';
import '../../../messaging/presentation/controllers/messaging_controller.dart';
import '../../domain/entities/direct_message_thread.dart';
import '../providers/swap_market_providers.dart';

/// State class for Pre-Swap Chat
class PreSwapChatState {
  final DirectMessageThread? thread;
  final List<DirectMessage> messages;
  final bool isLoading;
  final bool isSendingMessage;
  final bool isCreatingThread;
  final bool isAgreingToDeal;
  final String? error;
  final bool hasMoreMessages;
  final bool isLoadingMoreMessages;
  final String? typingUserId;

  const PreSwapChatState({
    this.thread,
    this.messages = const [],
    this.isLoading = false,
    this.isSendingMessage = false,
    this.isCreatingThread = false,
    this.isAgreingToDeal = false,
    this.error,
    this.hasMoreMessages = true,
    this.isLoadingMoreMessages = false,
    this.typingUserId,
  });

  PreSwapChatState copyWith({
    DirectMessageThread? thread,
    List<DirectMessage>? messages,
    bool? isLoading,
    bool? isSendingMessage,
    bool? isCreatingThread,
    bool? isAgreingToDeal,
    String? error,
    bool? hasMoreMessages,
    bool? isLoadingMoreMessages,
    String? typingUserId,
  }) {
    return PreSwapChatState(
      thread: thread ?? this.thread,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSendingMessage: isSendingMessage ?? this.isSendingMessage,
      isCreatingThread: isCreatingThread ?? this.isCreatingThread,
      isAgreingToDeal: isAgreingToDeal ?? this.isAgreingToDeal,
      error: error ?? this.error,
      hasMoreMessages: hasMoreMessages ?? this.hasMoreMessages,
      isLoadingMoreMessages: isLoadingMoreMessages ?? this.isLoadingMoreMessages,
      typingUserId: typingUserId ?? this.typingUserId,
    );
  }
}

/// Pre-Swap Chat Controller
/// 
/// Manages the state and business logic for pre-swap chat conversations
/// Handles message sending, deal agreements, and real-time updates
class PreSwapChatController extends StateNotifier<PreSwapChatState> {
  final MessagingRepository _messagingRepository;

  PreSwapChatController(this._messagingRepository) : super(const PreSwapChatState());

  /// Initialize chat with another user for a specific swap listing
  Future<void> initChat(String otherUserId, String? relatedListingId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // First try to find existing thread
      final existingThread = await _findExistingThread(otherUserId, relatedListingId);
      
      if (existingThread != null) {
        state = state.copyWith(thread: existingThread);
        await loadMessages();
      } else {
        // Create new thread
        await _createNewThread(otherUserId, relatedListingId);
      }
      
      // Subscribe to real-time updates
      if (state.thread != null) {
        _subscribeToRealTimeUpdates(state.thread!.id);
      }
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to initialize chat: ${e.toString()}',
      );
    }
  }

  /// Find existing thread between users for the specific listing
  Future<DirectMessageThread?> _findExistingThread(
    String otherUserId,
    String? relatedListingId,
  ) async {
    // This would typically query the backend for existing threads
    // For now, we'll simulate with mock data
    await Future<void>.delayed(const Duration(milliseconds: 500));
    
    // Mock implementation - in real app, this would be a database query
    if (relatedListingId != null) {
      return DirectMessageThread(
        id: 'thread_${DateTime.now().millisecondsSinceEpoch}',
        participantIds: [_getCurrentUserId(), otherUserId],
        relatedListingId: relatedListingId,
        context: ConversationContext.swap,
        title: 'Swap Chat',
        createdAt: DateTime.now(),
        lastActivityAt: DateTime.now(),
      );
    }
    
    return null;
  }

  /// Create new thread for the conversation
  Future<void> _createNewThread(String otherUserId, String? relatedListingId) async {
    state = state.copyWith(isCreatingThread: true);
    
    try {
      final thread = DirectMessageThread(
        id: 'thread_${DateTime.now().millisecondsSinceEpoch}',
        participantIds: [_getCurrentUserId(), otherUserId],
        relatedListingId: relatedListingId,
        context: ConversationContext.swap,
        title: 'Swap Chat',
        createdAt: DateTime.now(),
        lastActivityAt: DateTime.now(),
      );
      
      // In real implementation, this would save to backend
      await Future<void>.delayed(const Duration(milliseconds: 300));
      
      state = state.copyWith(
        thread: thread,
        isCreatingThread: false,
      );
    } catch (e) {
      state = state.copyWith(
        isCreatingThread: false,
        error: 'Failed to create chat thread: ${e.toString()}',
      );
    }
  }

  /// Load messages for the current thread
  Future<void> loadMessages({bool loadMore = false}) async {
    if (state.thread == null) return;
    
    if (loadMore) {
      if (!state.hasMoreMessages || state.isLoadingMoreMessages) return;
      state = state.copyWith(isLoadingMoreMessages: true);
    }
    
    try {
      // Simulate loading messages from backend
      await Future<void>.delayed(const Duration(milliseconds: 500));
      
      final newMessages = _generateMockMessages(state.thread!.id, loadMore);
      
      List<DirectMessage> allMessages;
      if (loadMore) {
        allMessages = [...state.messages, ...newMessages];
      } else {
        allMessages = newMessages;
      }
      
      state = state.copyWith(
        messages: allMessages,
        hasMoreMessages: newMessages.length >= 20, // Simulate pagination
        isLoadingMoreMessages: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMoreMessages: false,
        error: 'Failed to load messages: ${e.toString()}',
      );
    }
  }

  /// Send a text message
  Future<void> sendMessage(String content) async {
    if (state.thread == null || content.trim().isEmpty) return;
    
    state = state.copyWith(isSendingMessage: true, error: null);
    
    try {
      final message = DirectMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        threadId: state.thread!.id,
        senderId: _getCurrentUserId(),
        senderName: 'Current User', // This would come from user service
        content: content.trim(),
        sentAt: DateTime.now(),
        status: 'sending',
      );
      
      // Optimistically add message to UI
      state = state.copyWith(
        messages: [message, ...state.messages],
      );
      
      // Simulate sending to backend
      await Future<void>.delayed(const Duration(milliseconds: 800));
      
      // Update message status to sent
      final updatedMessages = state.messages.map((msg) {
        if (msg.id == message.id) {
          return msg.copyWith(status: 'sent');
        }
        return msg;
      }).toList();
      
      state = state.copyWith(
        messages: updatedMessages,
        isSendingMessage: false,
      );
    } catch (e) {
      // Remove failed message and show error
      final filteredMessages = state.messages
          .where((msg) => msg.status != 'sending')
          .toList();
      
      state = state.copyWith(
        messages: filteredMessages,
        isSendingMessage: false,
        error: 'Failed to send message: ${e.toString()}',
      );
    }
  }

  /// Agree to deal - mark the thread as deal agreed
  Future<void> agreeToDeal() async {
    if (state.thread == null || state.thread!.isDealAgreed) return;
    
    state = state.copyWith(isAgreingToDeal: true, error: null);
    
    try {
      // Update thread with deal agreement
      final updatedThread = state.thread!.copyWith(
        isDealAgreed: true,
        dealAgreedAt: DateTime.now(),
        dealAgreedByUserId: _getCurrentUserId(),
        lastActivityAt: DateTime.now(),
      );
      
      // Add system message about deal agreement
      final systemMessage = DirectMessage(
        id: 'msg_deal_${DateTime.now().millisecondsSinceEpoch}',
        threadId: state.thread!.id,
        senderId: 'system',
        senderName: 'System',
        content: '🤝 Deal agreement reached! Both parties have agreed to proceed with the swap.',
        sentAt: DateTime.now(),
        messageType: 'system',
        isSystemMessage: true,
        isDealAgreementMessage: true,
        status: 'sent',
      );
      
      // Simulate backend update
      await Future<void>.delayed(const Duration(milliseconds: 1000));
      
      state = state.copyWith(
        thread: updatedThread,
        messages: [systemMessage, ...state.messages],
        isAgreingToDeal: false,
      );
    } catch (e) {
      state = state.copyWith(
        isAgreingToDeal: false,
        error: 'Failed to agree to deal: ${e.toString()}',
      );
    }
  }

  /// Subscribe to real-time updates for the thread
  void _subscribeToRealTimeUpdates(String threadId) {
    // In real implementation, this would subscribe to WebSocket or similar
    // For now, we'll simulate with periodic updates
    
    // This would be replaced with actual real-time subscription
    // Example: _messagingRepository.subscribeToMessages(threadId).listen(...)
  }

  /// Generate mock messages for testing
  List<DirectMessage> _generateMockMessages(String threadId, bool isLoadMore) {
    final messages = <DirectMessage>[];
    final baseTime = DateTime.now().subtract(const Duration(hours: 2));
    
    final mockMessages = [
      "Hi! I'm interested in your swap listing. Is it still available?",
      "Yes, it's still available! What item are you looking to swap?",
      "I have a similar jacket in blue. Would you be interested?",
      "That sounds great! Can you send me some photos?",
      "Sure, I'll take some photos and send them over.",
      "Perfect! I'll wait for the photos then.",
      "Here are the photos of my jacket. What do you think?",
      "Wow, it looks amazing! I think this could be a perfect swap.",
      "Great! Should we arrange to meet up?",
      "Yes, let's do it! When would be good for you?",
    ];
    
    for (int i = 0; i < (isLoadMore ? 5 : 10); i++) {
      if (i < mockMessages.length) {
        final isCurrentUser = i % 2 == 0;
        messages.add(
          DirectMessage(
            id: 'msg_${threadId}_${i + (isLoadMore ? 10 : 0)}',
            threadId: threadId,
            senderId: isCurrentUser ? _getCurrentUserId() : 'other_user',
            senderName: isCurrentUser ? 'You' : 'Sarah Johnson',
            senderAvatarUrl: isCurrentUser 
                ? null 
                : 'https://images.unsplash.com/photo-1494790108755-2616b612b1e6?w=150&h=150&fit=crop&crop=face',
            content: mockMessages[i],
            sentAt: baseTime.add(Duration(minutes: i * 5)),
            status: 'read',
          ),
        );
      }
    }
    
    return messages.reversed.toList(); // Most recent first
  }

  /// Get current user ID (mock implementation)
  String _getCurrentUserId() {
    return 'current_user_123'; // This would come from auth service
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Mark thread as read
  Future<void> markAsRead() async {
    if (state.thread == null) return;
    
    try {
      // In real implementation, this would update read status on backend
      await Future<void>.delayed(const Duration(milliseconds: 200));
      
      // Update unread count for current user
      final updatedThread = state.thread!.copyWith(
        unreadCounts: {
          ...state.thread!.unreadCounts,
          _getCurrentUserId(): 0,
        },
      );
      
      state = state.copyWith(thread: updatedThread);
    } catch (e) {
      // Silently fail for read status updates
      print('Failed to mark as read: $e');
    }
  }

  /// Leave the chat (for cleanup)
  void leaveChat() {
    // Clean up any subscriptions or resources
    state = const PreSwapChatState();
  }
}

/// Provider for getting other user info in the chat
final otherUserInfoProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, userId) async {
  // Mock user data - in real app this would fetch from user service
  await Future<void>.delayed(const Duration(milliseconds: 300));
  
  return {
    'id': userId,
    'name': 'Sarah Johnson',
    'avatar': 'https://images.unsplash.com/photo-1494790108755-2616b612b1e6?w=150&h=150&fit=crop&crop=face',
    'isOnline': true,
    'lastSeen': DateTime.now().subtract(const Duration(minutes: 5)),
  };
});

/// Provider for PreSwapChatController
final preSwapChatControllerProvider = 
    StateNotifierProvider<PreSwapChatController, PreSwapChatState>((ref) {
  final messagingRepository = ref.read(messagingRepositoryProvider);
  return PreSwapChatController(messagingRepository);
});
