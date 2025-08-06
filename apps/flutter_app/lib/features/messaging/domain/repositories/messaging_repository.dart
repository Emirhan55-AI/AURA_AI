import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/chat_message.dart';

/// Messaging Repository Interface
/// 
/// Defines contracts for messaging operations following Clean Architecture principles
/// All messaging-related data operations should implement this interface
abstract class MessagingRepository {
  // Conversation operations
  Future<Either<Failure, List<ChatConversation>>> getConversations({
    int limit = 20,
    int offset = 0,
  });
  
  Future<Either<Failure, ChatConversation>> getConversation(String conversationId);
  
  Future<Either<Failure, ChatConversation>> createConversation({
    required List<String> participantIds,
    String? name,
    ConversationType type = ConversationType.direct,
    ConversationContext? context,
  });
  
  Future<Either<Failure, void>> updateConversation(
    String conversationId,
    Map<String, dynamic> updates,
  );
  
  Future<Either<Failure, void>> deleteConversation(String conversationId);
  
  Future<Either<Failure, void>> archiveConversation(String conversationId);
  
  Future<Either<Failure, void>> pinConversation(String conversationId);
  
  // Message operations
  Future<Either<Failure, List<ChatMessage>>> getMessages({
    required String conversationId,
    int limit = 50,
    String? before, // Message ID for pagination
    String? after,  // Message ID for pagination
  });
  
  Future<Either<Failure, ChatMessage>> sendMessage({
    required String conversationId,
    required String content,
    required MessageType type,
    String? mediaUrl,
    String? replyToMessageId,
    String? outfitId,
    String? swapRequestId,
    Map<String, dynamic>? metadata,
  });
  
  Future<Either<Failure, ChatMessage>> sendMediaMessage({
    required String conversationId,
    required String filePath,
    required MessageType type,
    String? caption,
    String? replyToMessageId,
  });
  
  Future<Either<Failure, void>> updateMessage(
    String messageId,
    Map<String, dynamic> updates,
  );
  
  Future<Either<Failure, void>> deleteMessage(String messageId);
  
  Future<Either<Failure, void>> markMessageAsRead(String messageId);
  
  Future<Either<Failure, void>> markConversationAsRead(String conversationId);
  
  // Reactions
  Future<Either<Failure, void>> addReaction({
    required String messageId,
    required String emoji,
  });
  
  Future<Either<Failure, void>> removeReaction({
    required String messageId,
    required String emoji,
  });
  
  // Typing indicators
  Future<Either<Failure, void>> sendTypingIndicator(String conversationId);
  
  Future<Either<Failure, void>> stopTypingIndicator(String conversationId);
  
  // Real-time subscriptions
  Stream<ChatMessage> subscribeToMessages(String conversationId);
  
  Stream<List<ChatConversation>> subscribeToConversations();
  
  Stream<TypingIndicator> subscribeToTypingIndicators(String conversationId);
  
  // Search
  Future<Either<Failure, List<ChatMessage>>> searchMessages({
    required String query,
    String? conversationId,
    int limit = 20,
  });
  
  Future<Either<Failure, List<ChatConversation>>> searchConversations({
    required String query,
    int limit = 20,
  });
  
  // Participants
  Future<Either<Failure, void>> addParticipant({
    required String conversationId,
    required String userId,
  });
  
  Future<Either<Failure, void>> removeParticipant({
    required String conversationId,
    required String userId,
  });
  
  Future<Either<Failure, void>> updateParticipantRole({
    required String conversationId,
    required String userId,
    required ParticipantRole role,
  });
  
  // Media upload
  Future<Either<Failure, String>> uploadMedia({
    required String filePath,
    required String mediaType,
  });
  
  // Push notifications
  Future<Either<Failure, void>> updatePushTokenForMessaging(String token);
  
  // Message status updates
  Future<Either<Failure, void>> updateMessageStatus({
    required String messageId,
    required MessageStatus status,
  });
  
  // Bulk operations
  Future<Either<Failure, void>> markMultipleMessagesAsRead(List<String> messageIds);
  
  Future<Either<Failure, void>> deleteMultipleMessages(List<String> messageIds);
  
  // Analytics
  Future<Either<Failure, Map<String, dynamic>>> getMessagingAnalytics();
  
  // Connection status
  Stream<bool> get connectionStatus;
  
  // Disconnect/reconnect
  Future<void> disconnect();
  Future<void> reconnect();
}
