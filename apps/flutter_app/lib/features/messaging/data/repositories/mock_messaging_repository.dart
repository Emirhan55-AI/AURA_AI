import 'dart:async';
import 'dart:math';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/failure_types.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/messaging_repository.dart';

/// Mock implementation of MessagingRepository for development and testing
/// 
/// Provides realistic sample data and simulates network delays
/// Includes real-time streaming simulation for messages and typing indicators
class MockMessagingRepository implements MessagingRepository {
  final Random _random = Random();
  
  // In-memory storage
  List<ChatConversation> _conversations = [];
  List<ChatMessage> _messages = [];
  List<TypingIndicator> _typingIndicators = [];
  
  // Stream controllers for real-time updates
  final StreamController<ChatMessage> _messageStreamController = StreamController.broadcast();
  final StreamController<List<ChatConversation>> _conversationsStreamController = StreamController.broadcast();
  final StreamController<TypingIndicator> _typingStreamController = StreamController.broadcast();
  final StreamController<bool> _connectionStatusController = StreamController.broadcast();
  
  bool _isConnected = true;
  String _currentUserId = 'current_user';

  MockMessagingRepository() {
    _initializeSampleData();
    _simulateConnectionStatus();
  }

  void _initializeSampleData() {
    _conversations = SampleConversationData.getSampleConversations();
    _messages = ChatMessageExtensions.getSampleMessages();
  }

  void _simulateConnectionStatus() {
    Timer.periodic(const Duration(seconds: 30), (timer) {
      // Simulate occasional connection issues
      if (_random.nextDouble() < 0.05) { // 5% chance
        _isConnected = false;
        _connectionStatusController.add(false);
        
        // Reconnect after 2-5 seconds
        Timer(Duration(seconds: 2 + _random.nextInt(4)), () {
          _isConnected = true;
          _connectionStatusController.add(true);
        });
      }
    });
  }

  Future<void> _simulateNetworkDelay() async {
    await Future<void>.delayed(Duration(milliseconds: 200 + _random.nextInt(800)));
  }

  @override
  Future<Either<Failure, List<ChatConversation>>> getConversations({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      await _simulateNetworkDelay();
      
      final sortedConversations = List<ChatConversation>.from(_conversations)
        ..sort((a, b) => b.lastActivityAt.compareTo(a.lastActivityAt));
      
      final paginatedConversations = sortedConversations
          .skip(offset)
          .take(limit)
          .toList();
      
      return Right(paginatedConversations);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get conversations: $e'));
    }
  }

  @override
  Future<Either<Failure, ChatConversation>> getConversation(String conversationId) async {
    try {
      await _simulateNetworkDelay();
      
      final conversation = _conversations.firstWhere(
        (c) => c.id == conversationId,
        orElse: () => throw Exception('Conversation not found'),
      );
      
      return Right(conversation);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get conversation: $e'));
    }
  }

  @override
  Future<Either<Failure, ChatConversation>> createConversation({
    required List<String> participantIds,
    String? name,
    ConversationType type = ConversationType.direct,
    ConversationContext? context,
  }) async {
    try {
      await _simulateNetworkDelay();
      
      final now = DateTime.now();
      final conversationId = 'conv_${now.millisecondsSinceEpoch}';
      
      // Create participants
      final participants = participantIds.map((userId) => ConversationParticipant(
        userId: userId,
        name: 'User $userId', // In real app, fetch from user service
        role: userId == _currentUserId ? ParticipantRole.owner : ParticipantRole.member,
        joinedAt: now,
        lastSeenAt: now,
      )).toList();
      
      final conversation = ChatConversation(
        id: conversationId,
        name: name ?? _generateConversationName(participants, type),
        type: type,
        participantIds: participantIds,
        participants: participants,
        lastActivityAt: now,
        createdAt: now,
        context: context,
      );
      
      _conversations.add(conversation);
      _conversationsStreamController.add(_conversations);
      
      return Right(conversation);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to create conversation: $e'));
    }
  }

  String _generateConversationName(List<ConversationParticipant> participants, ConversationType type) {
    if (type == ConversationType.direct) {
      final otherParticipant = participants.firstWhere(
        (p) => p.userId != _currentUserId,
        orElse: () => participants.first,
      );
      return otherParticipant.name;
    }
    return 'Group Chat';
  }

  @override
  Future<Either<Failure, List<ChatMessage>>> getMessages({
    required String conversationId,
    int limit = 50,
    String? before,
    String? after,
  }) async {
    try {
      await _simulateNetworkDelay();
      
      var conversationMessages = _messages
          .where((m) => m.conversationId == conversationId)
          .toList();
      
      // Sort by creation time (newest first for UI)
      conversationMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      // Apply pagination
      if (before != null) {
        final beforeIndex = conversationMessages.indexWhere((m) => m.id == before);
        if (beforeIndex != -1) {
          conversationMessages = conversationMessages.skip(beforeIndex + 1).toList();
        }
      }
      
      if (after != null) {
        final afterIndex = conversationMessages.indexWhere((m) => m.id == after);
        if (afterIndex != -1) {
          conversationMessages = conversationMessages.take(afterIndex).toList();
        }
      }
      
      final paginatedMessages = conversationMessages.take(limit).toList();
      
      return Right(paginatedMessages);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get messages: $e'));
    }
  }

  @override
  Future<Either<Failure, ChatMessage>> sendMessage({
    required String conversationId,
    required String content,
    required MessageType type,
    String? mediaUrl,
    String? replyToMessageId,
    String? outfitId,
    String? swapRequestId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _simulateNetworkDelay();
      
      final now = DateTime.now();
      final messageId = 'msg_${now.millisecondsSinceEpoch}';
      
      final message = ChatMessage(
        id: messageId,
        conversationId: conversationId,
        senderId: _currentUserId,
        senderName: 'Current User', // In real app, get from auth service
        type: type,
        content: content,
        mediaUrl: mediaUrl,
        createdAt: now,
        status: MessageStatus.sent,
        replyToMessageId: replyToMessageId,
        outfitId: outfitId,
        swapRequestId: swapRequestId,
        metadata: metadata,
      );
      
      _messages.add(message);
      
      // Update conversation's last message and activity
      final conversationIndex = _conversations.indexWhere((c) => c.id == conversationId);
      if (conversationIndex != -1) {
        _conversations[conversationIndex] = _conversations[conversationIndex].copyWith(
          lastMessage: message,
          lastActivityAt: now,
          totalMessagesCount: _conversations[conversationIndex].totalMessagesCount + 1,
        );
      }
      
      // Emit real-time updates
      _messageStreamController.add(message);
      _conversationsStreamController.add(_conversations);
      
      // Simulate message delivery after a short delay
      Timer(const Duration(milliseconds: 500), () {
        _simulateMessageDelivery(messageId);
      });
      
      return Right(message);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to send message: $e'));
    }
  }

  void _simulateMessageDelivery(String messageId) {
    final messageIndex = _messages.indexWhere((m) => m.id == messageId);
    if (messageIndex != -1) {
      _messages[messageIndex] = _messages[messageIndex].copyWith(
        status: MessageStatus.delivered,
      );
      _messageStreamController.add(_messages[messageIndex]);
    }
  }

  @override
  Future<Either<Failure, ChatMessage>> sendMediaMessage({
    required String conversationId,
    required String filePath,
    required MessageType type,
    String? caption,
    String? replyToMessageId,
  }) async {
    try {
      // Simulate file upload
      await _simulateNetworkDelay();
      
      final mediaUrl = 'https://mock-storage.example.com/media/${DateTime.now().millisecondsSinceEpoch}';
      
      return sendMessage(
        conversationId: conversationId,
        content: caption ?? '',
        type: type,
        mediaUrl: mediaUrl,
        replyToMessageId: replyToMessageId,
      );
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to send media message: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markMessageAsRead(String messageId) async {
    try {
      await _simulateNetworkDelay();
      
      final messageIndex = _messages.indexWhere((m) => m.id == messageId);
      if (messageIndex != -1) {
        _messages[messageIndex] = _messages[messageIndex].copyWith(
          readAt: DateTime.now(),
          status: MessageStatus.read,
        );
        _messageStreamController.add(_messages[messageIndex]);
      }
      
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to mark message as read: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markConversationAsRead(String conversationId) async {
    try {
      await _simulateNetworkDelay();
      
      // Mark all unread messages in conversation as read
      final now = DateTime.now();
      for (int i = 0; i < _messages.length; i++) {
        if (_messages[i].conversationId == conversationId && 
            _messages[i].senderId != _currentUserId &&
            _messages[i].readAt == null) {
          _messages[i] = _messages[i].copyWith(
            readAt: now,
            status: MessageStatus.read,
          );
        }
      }
      
      // Update conversation unread count
      final conversationIndex = _conversations.indexWhere((c) => c.id == conversationId);
      if (conversationIndex != -1) {
        _conversations[conversationIndex] = _conversations[conversationIndex].copyWith(
          unreadCount: 0,
        );
      }
      
      _conversationsStreamController.add(_conversations);
      
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to mark conversation as read: $e'));
    }
  }

  @override
  Stream<ChatMessage> subscribeToMessages(String conversationId) {
    return _messageStreamController.stream
        .where((message) => message.conversationId == conversationId);
  }

  @override
  Stream<List<ChatConversation>> subscribeToConversations() {
    return _conversationsStreamController.stream;
  }

  @override
  Stream<TypingIndicator> subscribeToTypingIndicators(String conversationId) {
    return _typingStreamController.stream
        .where((indicator) => indicator.conversationId == conversationId);
  }

  @override
  Future<Either<Failure, void>> sendTypingIndicator(String conversationId) async {
    try {
      final indicator = TypingIndicator(
        conversationId: conversationId,
        userId: _currentUserId,
        userName: 'Current User',
        startedAt: DateTime.now(),
      );
      
      _typingIndicators.add(indicator);
      _typingStreamController.add(indicator);
      
      // Auto-remove typing indicator after 3 seconds
      Timer(const Duration(seconds: 3), () {
        stopTypingIndicator(conversationId);
      });
      
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to send typing indicator: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> stopTypingIndicator(String conversationId) async {
    try {
      _typingIndicators.removeWhere((indicator) => 
          indicator.conversationId == conversationId && 
          indicator.userId == _currentUserId);
      
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to stop typing indicator: $e'));
    }
  }

  @override
  Stream<bool> get connectionStatus {
    _connectionStatusController.add(_isConnected); // Add current status immediately
    return _connectionStatusController.stream;
  }

  @override
  Future<void> disconnect() async {
    _isConnected = false;
    _connectionStatusController.add(false);
  }

  @override
  Future<void> reconnect() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    _isConnected = true;
    _connectionStatusController.add(true);
  }

  // Simplified implementations for other methods
  @override
  Future<Either<Failure, void>> updateConversation(String conversationId, Map<String, dynamic> updates) async {
    await _simulateNetworkDelay();
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteConversation(String conversationId) async {
    await _simulateNetworkDelay();
    _conversations.removeWhere((c) => c.id == conversationId);
    _conversationsStreamController.add(_conversations);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> archiveConversation(String conversationId) async {
    await _simulateNetworkDelay();
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> pinConversation(String conversationId) async {
    await _simulateNetworkDelay();
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> updateMessage(String messageId, Map<String, dynamic> updates) async {
    await _simulateNetworkDelay();
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteMessage(String messageId) async {
    await _simulateNetworkDelay();
    _messages.removeWhere((m) => m.id == messageId);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> addReaction({required String messageId, required String emoji}) async {
    await _simulateNetworkDelay();
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> removeReaction({required String messageId, required String emoji}) async {
    await _simulateNetworkDelay();
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<ChatMessage>>> searchMessages({required String query, String? conversationId, int limit = 20}) async {
    await _simulateNetworkDelay();
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<ChatConversation>>> searchConversations({required String query, int limit = 20}) async {
    await _simulateNetworkDelay();
    return const Right([]);
  }

  @override
  Future<Either<Failure, void>> addParticipant({required String conversationId, required String userId}) async {
    await _simulateNetworkDelay();
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> removeParticipant({required String conversationId, required String userId}) async {
    await _simulateNetworkDelay();
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> updateParticipantRole({required String conversationId, required String userId, required ParticipantRole role}) async {
    await _simulateNetworkDelay();
    return const Right(null);
  }

  @override
  Future<Either<Failure, String>> uploadMedia({required String filePath, required String mediaType}) async {
    await _simulateNetworkDelay();
    return Right('https://mock-storage.example.com/media/${DateTime.now().millisecondsSinceEpoch}');
  }

  @override
  Future<Either<Failure, void>> updatePushTokenForMessaging(String token) async {
    await _simulateNetworkDelay();
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> updateMessageStatus({required String messageId, required MessageStatus status}) async {
    await _simulateNetworkDelay();
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> markMultipleMessagesAsRead(List<String> messageIds) async {
    await _simulateNetworkDelay();
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteMultipleMessages(List<String> messageIds) async {
    await _simulateNetworkDelay();
    return const Right(null);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getMessagingAnalytics() async {
    await _simulateNetworkDelay();
    return Right({
      'totalConversations': _conversations.length,
      'totalMessages': _messages.length,
      'unreadCount': _conversations.fold(0, (sum, c) => sum + c.unreadCount),
    });
  }

  void dispose() {
    _messageStreamController.close();
    _conversationsStreamController.close();
    _typingStreamController.close();
    _connectionStatusController.close();
  }
}
