import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/messaging_repository.dart';
import '../../data/repositories/mock_messaging_repository.dart';

/// Provider for MessagingRepository
/// TODO: Replace with real Supabase implementation
final messagingRepositoryProvider = Provider<MessagingRepository>((ref) {
  return MockMessagingRepository();
});

/// State classes for messaging functionality

/// Messaging state for conversations list
@immutable
class MessagingState {
  final List<ChatConversation> conversations;
  final bool isLoading;
  final String? error;
  final bool hasReachedMax;
  final int unreadTotalCount;

  const MessagingState({
    this.conversations = const [],
    this.isLoading = false,
    this.error,
    this.hasReachedMax = false,
    this.unreadTotalCount = 0,
  });

  MessagingState copyWith({
    List<ChatConversation>? conversations,
    bool? isLoading,
    String? error,
    bool? hasReachedMax,
    int? unreadTotalCount,
  }) {
    return MessagingState(
      conversations: conversations ?? this.conversations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      unreadTotalCount: unreadTotalCount ?? this.unreadTotalCount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessagingState &&
        listEquals(other.conversations, conversations) &&
        other.isLoading == isLoading &&
        other.error == error &&
        other.hasReachedMax == hasReachedMax &&
        other.unreadTotalCount == unreadTotalCount;
  }

  @override
  int get hashCode {
    return conversations.hashCode ^
        isLoading.hashCode ^
        error.hashCode ^
        hasReachedMax.hashCode ^
        unreadTotalCount.hashCode;
  }
}

/// Chat state for individual conversation
@immutable
class ChatState {
  final String conversationId;
  final ChatConversation? conversation;
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final bool hasReachedMax;
  final List<TypingIndicator> typingIndicators;
  final bool isConnected;
  final String? replyingToMessageId;
  final ChatMessage? replyingToMessage;

  const ChatState({
    required this.conversationId,
    this.conversation,
    this.messages = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.hasReachedMax = false,
    this.typingIndicators = const [],
    this.isConnected = true,
    this.replyingToMessageId,
    this.replyingToMessage,
  });

  ChatState copyWith({
    String? conversationId,
    ChatConversation? conversation,
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool? hasReachedMax,
    List<TypingIndicator>? typingIndicators,
    bool? isConnected,
    String? replyingToMessageId,
    ChatMessage? replyingToMessage,
  }) {
    return ChatState(
      conversationId: conversationId ?? this.conversationId,
      conversation: conversation ?? this.conversation,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      typingIndicators: typingIndicators ?? this.typingIndicators,
      isConnected: isConnected ?? this.isConnected,
      replyingToMessageId: replyingToMessageId,
      replyingToMessage: replyingToMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatState &&
        other.conversationId == conversationId &&
        other.conversation == conversation &&
        listEquals(other.messages, messages) &&
        other.isLoading == isLoading &&
        other.isLoadingMore == isLoadingMore &&
        other.error == error &&
        other.hasReachedMax == hasReachedMax &&
        listEquals(other.typingIndicators, typingIndicators) &&
        other.isConnected == isConnected &&
        other.replyingToMessageId == replyingToMessageId &&
        other.replyingToMessage == replyingToMessage;
  }

  @override
  int get hashCode {
    return conversationId.hashCode ^
        conversation.hashCode ^
        messages.hashCode ^
        isLoading.hashCode ^
        isLoadingMore.hashCode ^
        error.hashCode ^
        hasReachedMax.hashCode ^
        typingIndicators.hashCode ^
        isConnected.hashCode ^
        replyingToMessageId.hashCode ^
        replyingToMessage.hashCode;
  }
}

/// Main messaging controller for conversations list
class MessagingController extends StateNotifier<MessagingState> {
  final MessagingRepository _repository;
  StreamSubscription<List<ChatConversation>>? _conversationsSubscription;
  StreamSubscription<bool>? _connectionSubscription;

  MessagingController(this._repository) : super(const MessagingState()) {
    _init();
  }

  void _init() {
    loadConversations();
    _subscribeToConversations();
    _subscribeToConnectionStatus();
  }

  /// Load conversations with pagination
  Future<void> loadConversations({bool refresh = false}) async {
    if (state.isLoading && !refresh) return;

    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    final result = await _repository.getConversations(
      limit: 20,
      offset: refresh ? 0 : state.conversations.length,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (conversations) {
        final updatedConversations = refresh 
            ? conversations
            : [...state.conversations, ...conversations];

        final totalUnread = updatedConversations.fold<int>(
          0, (sum, conv) => sum + conv.unreadCount,
        );

        state = state.copyWith(
          conversations: updatedConversations,
          isLoading: false,
          error: null,
          hasReachedMax: conversations.isEmpty,
          unreadTotalCount: totalUnread,
        );
      },
    );
  }

  /// Search conversations
  Future<void> searchConversations(String query) async {
    if (query.isEmpty) {
      loadConversations(refresh: true);
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.searchConversations(
      query: query,
      limit: 20,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (conversations) {
        state = state.copyWith(
          conversations: conversations,
          isLoading: false,
          error: null,
          hasReachedMax: true, // No pagination for search
        );
      },
    );
  }

  /// Create new conversation
  Future<Either<Failure, ChatConversation>> createConversation({
    required List<String> participantIds,
    String? name,
    ConversationType type = ConversationType.direct,
    ConversationContext? context,
  }) async {
    final result = await _repository.createConversation(
      participantIds: participantIds,
      name: name,
      type: type,
      context: context,
    );

    result.fold(
      (failure) => null,
      (conversation) {
        // Add to current conversations list
        final updatedConversations = [conversation, ...state.conversations];
        state = state.copyWith(conversations: updatedConversations);
      },
    );

    return result;
  }

  /// Delete conversation
  Future<void> deleteConversation(String conversationId) async {
    final result = await _repository.deleteConversation(conversationId);
    
    result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
      },
      (_) {
        final updatedConversations = state.conversations
            .where((c) => c.id != conversationId)
            .toList();
        
        final totalUnread = updatedConversations.fold<int>(
          0, (sum, conv) => sum + conv.unreadCount,
        );
        
        state = state.copyWith(
          conversations: updatedConversations,
          unreadTotalCount: totalUnread,
        );
      },
    );
  }

  /// Archive conversation
  Future<void> archiveConversation(String conversationId) async {
    final result = await _repository.archiveConversation(conversationId);
    
    result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
      },
      (_) {
        final updatedConversations = state.conversations
            .where((c) => c.id != conversationId)
            .toList();
        
        state = state.copyWith(conversations: updatedConversations);
      },
    );
  }

  /// Pin/unpin conversation
  Future<void> togglePinConversation(String conversationId) async {
    final result = await _repository.pinConversation(conversationId);
    
    result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
      },
      (_) {
        // In a real app, you'd update the conversation's isPinned status
        loadConversations(refresh: true);
      },
    );
  }

  /// Mark conversation as read
  Future<void> markConversationAsRead(String conversationId) async {
    final result = await _repository.markConversationAsRead(conversationId);
    
    result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
      },
      (_) {
        final updatedConversations = state.conversations.map((c) {
          if (c.id == conversationId) {
            return c.copyWith(unreadCount: 0);
          }
          return c;
        }).toList();
        
        final totalUnread = updatedConversations.fold<int>(
          0, (sum, conv) => sum + conv.unreadCount,
        );
        
        state = state.copyWith(
          conversations: updatedConversations,
          unreadTotalCount: totalUnread,
        );
      },
    );
  }

  /// Subscribe to real-time conversation updates
  void _subscribeToConversations() {
    _conversationsSubscription = _repository.subscribeToConversations().listen(
      (conversations) {
        final totalUnread = conversations.fold<int>(
          0, (sum, conv) => sum + conv.unreadCount,
        );
        
        state = state.copyWith(
          conversations: conversations,
          unreadTotalCount: totalUnread,
        );
      },
      onError: (Object error) {
        state = state.copyWith(error: error.toString());
      },
    );
  }

  /// Subscribe to connection status
  void _subscribeToConnectionStatus() {
    _connectionSubscription = _repository.connectionStatus.listen(
      (isConnected) {
        // Handle connection status changes if needed
      },
    );
  }

  @override
  void dispose() {
    _conversationsSubscription?.cancel();
    _connectionSubscription?.cancel();
    super.dispose();
  }
}

/// Chat controller for individual conversation
class ChatController extends StateNotifier<ChatState> {
  final MessagingRepository _repository;
  StreamSubscription<ChatMessage>? _messagesSubscription;
  StreamSubscription<TypingIndicator>? _typingSubscription;
  StreamSubscription<bool>? _connectionSubscription;
  Timer? _typingTimer;

  ChatController(this._repository, String conversationId) 
      : super(ChatState(conversationId: conversationId)) {
    _init();
  }

  void _init() {
    loadConversation();
    loadMessages();
    _subscribeToMessages();
    _subscribeToTypingIndicators();
    _subscribeToConnectionStatus();
  }

  /// Load conversation details
  Future<void> loadConversation() async {
    final result = await _repository.getConversation(state.conversationId);
    
    result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
      },
      (conversation) {
        state = state.copyWith(conversation: conversation);
      },
    );
  }

  /// Load messages with pagination
  Future<void> loadMessages({bool loadMore = false}) async {
    if (state.isLoading || (state.isLoadingMore && loadMore)) return;

    state = state.copyWith(
      isLoading: !loadMore,
      isLoadingMore: loadMore,
      error: null,
    );

    final String? beforeMessageId = loadMore && state.messages.isNotEmpty 
        ? state.messages.last.id 
        : null;

    final result = await _repository.getMessages(
      conversationId: state.conversationId,
      limit: 50,
      before: beforeMessageId,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          error: failure.message,
        );
      },
      (messages) {
        final updatedMessages = loadMore 
            ? [...state.messages, ...messages]
            : messages;

        state = state.copyWith(
          messages: updatedMessages,
          isLoading: false,
          isLoadingMore: false,
          error: null,
          hasReachedMax: messages.isEmpty,
        );

        // Mark messages as read if they're from other users
        _markMessagesAsRead(messages);
      },
    );
  }

  /// Send text message
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    // Stop typing indicator
    stopTyping();

    final result = await _repository.sendMessage(
      conversationId: state.conversationId,
      content: content.trim(),
      type: MessageType.text,
      replyToMessageId: state.replyingToMessageId,
    );

    result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
      },
      (message) {
        // Clear reply state after sending
        clearReply();
      },
    );
  }

  /// Send media message
  Future<void> sendMediaMessage({
    required String filePath,
    required MessageType type,
    String? caption,
  }) async {
    final result = await _repository.sendMediaMessage(
      conversationId: state.conversationId,
      filePath: filePath,
      type: type,
      caption: caption,
      replyToMessageId: state.replyingToMessageId,
    );

    result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
      },
      (message) {
        clearReply();
      },
    );
  }

  /// Send outfit message
  Future<void> sendOutfitMessage({
    required String outfitId,
    String? caption,
  }) async {
    final result = await _repository.sendMessage(
      conversationId: state.conversationId,
      content: caption ?? '',
      type: MessageType.outfit,
      outfitId: outfitId,
      replyToMessageId: state.replyingToMessageId,
    );

    result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
      },
      (message) {
        clearReply();
      },
    );
  }

  /// Add reaction to message
  Future<void> addReaction(String messageId, String emoji) async {
    final result = await _repository.addReaction(
      messageId: messageId,
      emoji: emoji,
    );

    result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
      },
      (_) {
        // Reaction will be updated via real-time stream
      },
    );
  }

  /// Remove reaction from message
  Future<void> removeReaction(String messageId, String emoji) async {
    final result = await _repository.removeReaction(
      messageId: messageId,
      emoji: emoji,
    );

    result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
      },
      (_) {
        // Reaction will be updated via real-time stream
      },
    );
  }

  /// Set message to reply to
  void setReplyToMessage(ChatMessage message) {
    state = state.copyWith(
      replyingToMessageId: message.id,
      replyingToMessage: message,
    );
  }

  /// Clear reply state
  void clearReply() {
    state = state.copyWith(
      replyingToMessageId: null,
      replyingToMessage: null,
    );
  }

  /// Start typing indicator
  void startTyping() {
    _repository.sendTypingIndicator(state.conversationId);
    
    // Cancel existing timer
    _typingTimer?.cancel();
    
    // Auto-stop typing after 3 seconds
    _typingTimer = Timer(const Duration(seconds: 3), () {
      stopTyping();
    });
  }

  /// Stop typing indicator
  void stopTyping() {
    _repository.stopTypingIndicator(state.conversationId);
    _typingTimer?.cancel();
  }

  /// Delete message
  Future<void> deleteMessage(String messageId) async {
    final result = await _repository.deleteMessage(messageId);
    
    result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
      },
      (_) {
        // Message will be removed via real-time stream
      },
    );
  }

  /// Mark messages as read
  void _markMessagesAsRead(List<ChatMessage> messages) {
    for (final message in messages) {
      if (message.senderId != 'current_user' && !message.isRead) {
        _repository.markMessageAsRead(message.id);
      }
    }
  }

  /// Subscribe to real-time message updates
  void _subscribeToMessages() {
    _messagesSubscription = _repository.subscribeToMessages(state.conversationId).listen(
      (message) {
        // Add new message to the list
        final updatedMessages = [message, ...state.messages];
        state = state.copyWith(messages: updatedMessages);

        // Mark as read if from another user
        if (message.senderId != 'current_user') {
          _repository.markMessageAsRead(message.id);
        }
      },
      onError: (Object error) {
        state = state.copyWith(error: error.toString());
      },
    );
  }

  /// Subscribe to typing indicators
  void _subscribeToTypingIndicators() {
    _typingSubscription = _repository.subscribeToTypingIndicators(state.conversationId).listen(
      (indicator) {
        // Update typing indicators (exclude current user)
        if (indicator.userId != 'current_user') {
          final existingIndex = state.typingIndicators
              .indexWhere((t) => t.userId == indicator.userId);
          
          final updatedIndicators = [...state.typingIndicators];
          
          if (existingIndex != -1) {
            updatedIndicators[existingIndex] = indicator;
          } else {
            updatedIndicators.add(indicator);
          }
          
          state = state.copyWith(typingIndicators: updatedIndicators);

          // Remove typing indicator after timeout
          Timer(const Duration(seconds: 5), () {
            final filtered = state.typingIndicators
                .where((t) => t.userId != indicator.userId)
                .toList();
            state = state.copyWith(typingIndicators: filtered);
          });
        }
      },
      onError: (Object error) {
        state = state.copyWith(error: error.toString());
      },
    );
  }

  /// Subscribe to connection status
  void _subscribeToConnectionStatus() {
    _connectionSubscription = _repository.connectionStatus.listen(
      (isConnected) {
        state = state.copyWith(isConnected: isConnected);
      },
    );
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    _typingSubscription?.cancel();
    _connectionSubscription?.cancel();
    _typingTimer?.cancel();
    super.dispose();
  }
}

/// Providers for messaging controllers

/// Messaging controller provider (conversations list)
final messagingControllerProvider = StateNotifierProvider<MessagingController, MessagingState>((ref) {
  final repository = ref.read(messagingRepositoryProvider);
  return MessagingController(repository);
});

/// Chat controller provider factory (individual conversation)
final chatControllerProvider = StateNotifierProvider.family<ChatController, ChatState, String>((ref, conversationId) {
  final repository = ref.read(messagingRepositoryProvider);
  return ChatController(repository, conversationId);
});

/// Convenience providers for specific data

/// Current user's conversations
final conversationsProvider = Provider<List<ChatConversation>>((ref) {
  return ref.watch(messagingControllerProvider).conversations;
});

/// Total unread count
final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(messagingControllerProvider).unreadTotalCount;
});

/// Messages for a specific conversation
final messagesProvider = Provider.family<List<ChatMessage>, String>((ref, conversationId) {
  return ref.watch(chatControllerProvider(conversationId)).messages;
});

/// Connection status
final connectionStatusProvider = Provider<bool>((ref) {
  // This would need to be implemented with a StreamProvider in real app
  return true; // Default connected status
});
