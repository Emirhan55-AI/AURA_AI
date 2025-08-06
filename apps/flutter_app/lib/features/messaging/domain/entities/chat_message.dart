import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

/// Message types enum
enum MessageType {
  text,
  image,
  voice,
  audio, // Audio messages
  video,
  file,
  sticker,
  location,
  outfit, // Aura-specific: Outfit sharing
  swapRequest, // Aura-specific: Swap request
  system, // System messages
}

/// Message status enum
enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

/// Chat Message Entity
/// 
/// Represents a single message in a conversation following Clean Architecture
/// Domain layer entity with all business logic rules
@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required String conversationId,
    required String senderId,
    required String senderName,
    String? senderAvatarUrl,
    required MessageType type,
    required String content,
    
    // Media content
    String? mediaUrl,
    @Default([]) List<String> mediaUrls, // Multiple media files
    String? thumbnailUrl,
    Map<String, dynamic>? mediaMetadata, // Duration, size, dimensions
    
    // Message metadata
    required DateTime createdAt,
    DateTime? updatedAt,
    DateTime? readAt,
    @Default(MessageStatus.sending) MessageStatus status,
    
    // Reply functionality
    String? replyToMessageId,
    ChatMessage? replyToMessage,
    
    // Reactions
    @Default({}) Map<String, List<String>> reactions, // emoji -> user_ids
    
    // Aura-specific content
    String? outfitId, // For outfit sharing
    String? swapRequestId, // For swap requests
    Map<String, dynamic>? metadata, // Additional custom data
    
    // Message thread support
    String? threadId,
    @Default(0) int threadRepliesCount,
    
    // Editing support
    @Default(false) bool isEdited,
    List<String>? editHistory,
    
    // Temporary message support (optimistic updates)
    @Default(false) bool isTemporary,
    String? tempId,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}

/// Chat Conversation Entity
@freezed
class ChatConversation with _$ChatConversation {
  const factory ChatConversation({
    required String id,
    required String name,
    String? avatarUrl,
    required ConversationType type,
    required List<String> participantIds,
    required List<ConversationParticipant> participants,
    
    // Last message info
    ChatMessage? lastMessage,
    required DateTime lastActivityAt,
    
    // Conversation metadata
    required DateTime createdAt,
    DateTime? updatedAt,
    String? description,
    
    // Unread counts
    @Default(0) int unreadCount,
    @Default(0) int totalMessagesCount,
    
    // Settings
    @Default(true) bool isNotificationsEnabled,
    @Default(false) bool isPinned,
    @Default(false) bool isArchived,
    @Default(false) bool isMuted,
    
    // Group chat specific
    String? createdById,
    Map<String, dynamic>? groupSettings,
    
    // Aura-specific
    String? swapRequestId, // If conversation is for a swap
    String? relatedItemId, // Related clothing item
    ConversationContext? context, // Social, swap, support, etc.
  }) = _ChatConversation;

  factory ChatConversation.fromJson(Map<String, dynamic> json) =>
      _$ChatConversationFromJson(json);
}

/// Conversation types
enum ConversationType {
  direct, // 1-on-1 chat
  group,  // Group chat
  channel, // Public channel
  support, // Customer support
}

/// Conversation context (Aura-specific)
enum ConversationContext {
  social,     // General social chat
  swap,       // Swap negotiation
  style,      // Style advice
  support,    // Customer support
  group,      // Group discussions
}

/// Conversation Participant Entity
@freezed
class ConversationParticipant with _$ConversationParticipant {
  const factory ConversationParticipant({
    required String userId,
    required String name,
    String? avatarUrl,
    required ParticipantRole role,
    required DateTime joinedAt,
    DateTime? lastSeenAt,
    DateTime? lastReadMessageAt,
    @Default(true) bool isActive,
    @Default(true) bool canSendMessages,
    @Default(ParticipantStatus.offline) ParticipantStatus status,
    Map<String, dynamic>? permissions,
  }) = _ConversationParticipant;

  factory ConversationParticipant.fromJson(Map<String, dynamic> json) =>
      _$ConversationParticipantFromJson(json);
}

/// Participant status
enum ParticipantStatus {
  online,
  away,
  busy,
  offline,
}

/// Participant roles
enum ParticipantRole {
  owner,
  admin,
  moderator,
  member,
  guest,
}

/// Message reactions
@freezed
class MessageReaction with _$MessageReaction {
  const factory MessageReaction({
    required String messageId,
    required String userId,
    required String emoji,
    required DateTime createdAt,
  }) = _MessageReaction;

  factory MessageReaction.fromJson(Map<String, dynamic> json) =>
      _$MessageReactionFromJson(json);
}

/// Typing indicator
@freezed
class TypingIndicator with _$TypingIndicator {
  const factory TypingIndicator({
    required String conversationId,
    required String userId,
    required String userName,
    required DateTime startedAt,
  }) = _TypingIndicator;

  factory TypingIndicator.fromJson(Map<String, dynamic> json) =>
      _$TypingIndicatorFromJson(json);
}

/// Business Logic Extensions
extension ChatMessageX on ChatMessage {
  /// Check if message is from current user
  bool isFromCurrentUser(String currentUserId) => senderId == currentUserId;
  
  /// Check if message is read
  bool get isRead => readAt != null;
  
  /// Check if message is media type
  bool get isMediaMessage => [
    MessageType.image,
    MessageType.voice, 
    MessageType.video,
    MessageType.file,
  ].contains(type);
  
  /// Check if message is Aura-specific type
  bool get isAuraSpecific => [
    MessageType.outfit,
    MessageType.swapRequest,
  ].contains(type);
  
  /// Get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inMinutes < 1) {
      return 'Now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${(difference.inDays / 7).floor()}w';
    }
  }
  
  /// Get message preview text for conversation list
  String get previewText {
    switch (type) {
      case MessageType.text:
        return content;
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
        return '👗 Outfit';
      case MessageType.swapRequest:
        return '🔄 Swap request';
      case MessageType.system:
        return content;
    }
  }
}

extension ChatConversationX on ChatConversation {
  /// Get display name for conversation
  String getDisplayName(String currentUserId) {
    if (type == ConversationType.direct) {
      // For direct messages, show other participant's name
      final otherParticipant = participants.firstWhere(
        (p) => p.userId != currentUserId,
        orElse: () => participants.first,
      );
      return otherParticipant.name;
    }
    return name;
  }
  
  /// Get avatar URL for conversation
  String? getAvatarUrl(String currentUserId) {
    if (type == ConversationType.direct && avatarUrl == null) {
      // For direct messages without avatar, use other participant's avatar
      final otherParticipant = participants.firstWhere(
        (p) => p.userId != currentUserId,
        orElse: () => participants.first,
      );
      return otherParticipant.avatarUrl;
    }
    return avatarUrl;
  }
  
  /// Check if conversation is active (recent activity)
  bool get isActive {
    final now = DateTime.now();
    return now.difference(lastActivityAt).inDays < 30;
  }
  
  /// Get unread status
  bool get hasUnreadMessages => unreadCount > 0;
  
  /// Get formatted unread count
  String get unreadCountText {
    if (unreadCount == 0) return '';
    if (unreadCount > 99) return '99+';
    return unreadCount.toString();
  }
}

/// Sample data for testing
extension SampleChatData on ChatMessage {
  static List<ChatMessage> getSampleMessages() {
    final now = DateTime.now();
    
    return [
      ChatMessage(
        id: '1',
        conversationId: 'conv_1',
        senderId: 'user_1',
        senderName: 'Sarah Johnson',
        senderAvatarUrl: 'https://i.pravatar.cc/150?img=1',
        type: MessageType.text,
        content: 'Hey! I love that vintage jacket you posted. Is it available for swap?',
        createdAt: now.subtract(const Duration(minutes: 5)),
        status: MessageStatus.read,
      ),
      
      ChatMessage(
        id: '2',
        conversationId: 'conv_1',
        senderId: 'user_2',
        senderName: 'Emma Wilson',
        senderAvatarUrl: 'https://i.pravatar.cc/150?img=2',
        type: MessageType.text,
        content: 'Hi Sarah! Yes, it\'s available. What would you like to swap it for?',
        createdAt: now.subtract(const Duration(minutes: 3)),
        status: MessageStatus.read,
      ),
      
      ChatMessage(
        id: '3',
        conversationId: 'conv_1',
        senderId: 'user_1',
        senderName: 'Sarah Johnson',
        type: MessageType.outfit,
        content: 'What about this denim shirt?',
        mediaUrl: 'https://images.unsplash.com/photo-1551232864-3f0890e580d9?w=300',
        outfitId: 'outfit_123',
        createdAt: now.subtract(const Duration(minutes: 1)),
        status: MessageStatus.delivered,
      ),
    ];
  }
}

extension SampleConversationData on ChatConversation {
  static List<ChatConversation> getSampleConversations() {
    final now = DateTime.now();
    
    return [
      ChatConversation(
        id: 'conv_1',
        name: 'Sarah Johnson',
        avatarUrl: 'https://i.pravatar.cc/150?img=1',
        type: ConversationType.direct,
        participantIds: ['user_1', 'user_2'],
        participants: [
          ConversationParticipant(
            userId: 'user_1',
            name: 'Sarah Johnson',
            avatarUrl: 'https://i.pravatar.cc/150?img=1',
            role: ParticipantRole.member,
            joinedAt: now.subtract(const Duration(days: 5)),
            lastSeenAt: now.subtract(const Duration(minutes: 1)),
          ),
          ConversationParticipant(
            userId: 'user_2',
            name: 'Emma Wilson',
            avatarUrl: 'https://i.pravatar.cc/150?img=2',
            role: ParticipantRole.member,
            joinedAt: now.subtract(const Duration(days: 5)),
            lastSeenAt: now.subtract(const Duration(minutes: 10)),
          ),
        ],
        lastMessage: ChatMessage(
          id: '3',
          conversationId: 'conv_1',
          senderId: 'user_1',
          senderName: 'Sarah Johnson',
          type: MessageType.outfit,
          content: 'What about this denim shirt?',
          createdAt: now.subtract(const Duration(minutes: 1)),
          status: MessageStatus.delivered,
        ),
        lastActivityAt: now.subtract(const Duration(minutes: 1)),
        createdAt: now.subtract(const Duration(days: 5)),
        unreadCount: 2,
        context: ConversationContext.swap,
        swapRequestId: 'swap_123',
      ),
      
      ChatConversation(
        id: 'conv_2',
        name: 'Style Enthusiasts',
        avatarUrl: 'https://images.unsplash.com/photo-1445205170230-053b83016050?w=150',
        type: ConversationType.group,
        participantIds: ['user_2', 'user_3', 'user_4', 'user_5'],
        participants: [
          ConversationParticipant(
            userId: 'user_2',
            name: 'Emma Wilson',
            role: ParticipantRole.owner,
            joinedAt: now.subtract(const Duration(days: 30)),
          ),
          ConversationParticipant(
            userId: 'user_3',
            name: 'Alex Rodriguez',
            role: ParticipantRole.member,
            joinedAt: now.subtract(const Duration(days: 25)),
          ),
        ],
        lastMessage: ChatMessage(
          id: '10',
          conversationId: 'conv_2',
          senderId: 'user_3',
          senderName: 'Alex Rodriguez',
          type: MessageType.text,
          content: 'Anyone know where to find sustainable fashion brands?',
          createdAt: now.subtract(const Duration(hours: 2)),
          status: MessageStatus.sent,
        ),
        lastActivityAt: now.subtract(const Duration(hours: 2)),
        createdAt: now.subtract(const Duration(days: 30)),
        unreadCount: 5,
        context: ConversationContext.social,
      ),
    ];
  }

}

/// Extensions for ChatMessage
extension ChatMessageExtensions on ChatMessage {
  /// Get sample messages for testing and development
  static List<ChatMessage> getSampleMessages() {
    final now = DateTime.now();
    return [
      ChatMessage(
        id: '1',
        conversationId: 'conv_1',
        senderId: 'user_1',
        senderName: 'Emma Johnson',
        type: MessageType.text,
        content: 'Hey! Love that outfit you posted yesterday 😍',
        createdAt: now.subtract(const Duration(hours: 1)),
        status: MessageStatus.read,
        readAt: now.subtract(const Duration(minutes: 30)),
      ),
      
      ChatMessage(
        id: '2',
        conversationId: 'conv_1',
        senderId: 'current_user',
        senderName: 'You',
        type: MessageType.text,
        content: 'Thank you! It\'s from that thrift store we went to last week',
        createdAt: now.subtract(const Duration(minutes: 45)),
        status: MessageStatus.read,
        readAt: now.subtract(const Duration(minutes: 25)),
      ),
      
      ChatMessage(
        id: '3',
        conversationId: 'conv_1',
        senderId: 'user_1',
        senderName: 'Emma Johnson',
        type: MessageType.image,
        content: 'Check out this similar style I found!',
        mediaUrl: 'https://images.unsplash.com/photo-1515372039744-b8f02a3ae446?w=500',
        createdAt: now.subtract(const Duration(minutes: 30)),
        status: MessageStatus.read,
        readAt: now.subtract(const Duration(minutes: 15)),
        reactions: {
          '😍': ['current_user']
        },
      ),
      
      ChatMessage(
        id: '4',
        conversationId: 'conv_1',
        senderId: 'current_user',
        senderName: 'You',
        type: MessageType.text,
        content: 'That\'s gorgeous! Where did you find it?',
        createdAt: now.subtract(const Duration(minutes: 20)),
        status: MessageStatus.read,
        readAt: now.subtract(const Duration(minutes: 10)),
      ),
      
      ChatMessage(
        id: '5',
        conversationId: 'conv_1',
        senderId: 'user_1',
        senderName: 'Emma Johnson',
        type: MessageType.text,
        content: 'It\'s from Zara! Want me to send you the link?',
        createdAt: now.subtract(const Duration(minutes: 15)),
        status: MessageStatus.read,
        readAt: now.subtract(const Duration(minutes: 5)),
      ),
      
      ChatMessage(
        id: '6',
        conversationId: 'conv_1',
        senderId: 'current_user',
        senderName: 'You',
        type: MessageType.text,
        content: 'Yes please! 🙏',
        createdAt: now.subtract(const Duration(minutes: 10)),
        status: MessageStatus.delivered,
      ),
      
      ChatMessage(
        id: '7',
        conversationId: 'conv_2',
        senderId: 'user_2',
        senderName: 'Emma Wilson',
        type: MessageType.text,
        content: 'Welcome to our style community! 👗✨',
        createdAt: now.subtract(const Duration(days: 30)),
        status: MessageStatus.read,
        readAt: now.subtract(const Duration(days: 29)),
      ),
      
      ChatMessage(
        id: '8',
        conversationId: 'conv_2',
        senderId: 'user_4',
        senderName: 'Sophie Chen',
        type: MessageType.outfit,
        content: 'Check out my spring collection! What do you think?',
        outfitId: 'outfit_123',
        createdAt: now.subtract(const Duration(hours: 6)),
        status: MessageStatus.read,
        readAt: now.subtract(const Duration(hours: 4)),
        reactions: {
          '🔥': ['user_3'],
          '👏': ['user_5']
        },
      ),
      
      ChatMessage(
        id: '9',
        conversationId: 'conv_2',
        senderId: 'user_5',
        senderName: 'Maria Garcia',
        type: MessageType.swapRequest,
        content: 'Would anyone be interested in swapping this vintage jacket?',
        swapRequestId: 'swap_456',
        createdAt: now.subtract(const Duration(hours: 4)),
        status: MessageStatus.read,
        readAt: now.subtract(const Duration(hours: 3)),
      ),
      
      ChatMessage(
        id: '10',
        conversationId: 'conv_2',
        senderId: 'user_3',
        senderName: 'Alex Rodriguez',
        type: MessageType.text,
        content: 'Anyone know where to find sustainable fashion brands?',
        createdAt: now.subtract(const Duration(hours: 2)),
        status: MessageStatus.sent,
      ),
    ];
  }
}
