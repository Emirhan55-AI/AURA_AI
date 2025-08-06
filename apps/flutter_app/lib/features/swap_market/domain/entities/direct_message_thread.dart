/// Conversation context for swap-related chats
enum ConversationContext {
  general,
  swap,
  socialPost,
  challenge,
}

/// Direct Message Thread Entity for Pre-Swap Conversations
/// 
/// Represents a conversation thread between two users regarding a swap listing
/// Used specifically for pre-swap negotiations and communication
class DirectMessageThread {
  final String id;
  final List<String> participantIds;
  
  // Swap-specific fields
  final String? relatedListingId;
  final bool isDealAgreed;
  final DateTime? dealAgreedAt;
  final String? dealAgreedByUserId;
  
  // Thread metadata
  final ConversationContext context;
  final String? title;
  final String? description;
  
  // Status and timestamps
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastActivityAt;
  
  // Last message info for preview
  final String? lastMessageId;
  final String? lastMessageContent;
  final String? lastMessageSenderId;
  final DateTime? lastMessageAt;
  
  // Unread counts for each participant
  final Map<String, int> unreadCounts;
  
  // Thread settings
  final bool isMuted;
  final bool isArchived;
  final bool isPinned;

  const DirectMessageThread({
    required this.id,
    required this.participantIds,
    this.relatedListingId,
    this.isDealAgreed = false,
    this.dealAgreedAt,
    this.dealAgreedByUserId,
    this.context = ConversationContext.general,
    this.title,
    this.description,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.lastActivityAt,
    this.lastMessageId,
    this.lastMessageContent,
    this.lastMessageSenderId,
    this.lastMessageAt,
    this.unreadCounts = const {},
    this.isMuted = false,
    this.isArchived = false,
    this.isPinned = false,
  });

  DirectMessageThread copyWith({
    String? id,
    List<String>? participantIds,
    String? relatedListingId,
    bool? isDealAgreed,
    DateTime? dealAgreedAt,
    String? dealAgreedByUserId,
    ConversationContext? context,
    String? title,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastActivityAt,
    String? lastMessageId,
    String? lastMessageContent,
    String? lastMessageSenderId,
    DateTime? lastMessageAt,
    Map<String, int>? unreadCounts,
    bool? isMuted,
    bool? isArchived,
    bool? isPinned,
  }) {
    return DirectMessageThread(
      id: id ?? this.id,
      participantIds: participantIds ?? this.participantIds,
      relatedListingId: relatedListingId ?? this.relatedListingId,
      isDealAgreed: isDealAgreed ?? this.isDealAgreed,
      dealAgreedAt: dealAgreedAt ?? this.dealAgreedAt,
      dealAgreedByUserId: dealAgreedByUserId ?? this.dealAgreedByUserId,
      context: context ?? this.context,
      title: title ?? this.title,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      lastMessageContent: lastMessageContent ?? this.lastMessageContent,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCounts: unreadCounts ?? this.unreadCounts,
      isMuted: isMuted ?? this.isMuted,
      isArchived: isArchived ?? this.isArchived,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}

/// Direct Message Entity for Pre-Swap Chat Messages
/// 
/// Represents individual messages within a DirectMessageThread
class DirectMessage {
  final String id;
  final String threadId;
  final String senderId;
  final String senderName;
  final String? senderAvatarUrl;
  
  // Message content
  final String content;
  final String messageType; // text, image, deal_agreement, system
  
  // Media and attachments
  final String? mediaUrl;
  final String? thumbnailUrl;
  final List<String> attachmentUrls;
  final Map<String, dynamic>? metadata;
  
  // Message relationships
  final String? replyToMessageId;
  final String? replyToContent;
  final String? replyToSenderId;
  
  // Deal-related fields
  final bool isDealAgreementMessage;
  final bool isSystemMessage;
  
  // Status and timestamps
  final String status; // sending, sent, delivered, read, failed
  final DateTime sentAt;
  final DateTime? deliveredAt;
  final DateTime? readAt;
  
  // Reactions
  final Map<String, List<String>> reactions; // emoji -> list of user IDs
  
  // Edit history
  final bool isEdited;
  final DateTime? editedAt;
  final String? originalContent;
  
  // Flags
  final bool isDeleted;
  final bool isPinned;
  final bool isImportant;

  const DirectMessage({
    required this.id,
    required this.threadId,
    required this.senderId,
    required this.senderName,
    this.senderAvatarUrl,
    required this.content,
    this.messageType = 'text',
    this.mediaUrl,
    this.thumbnailUrl,
    this.attachmentUrls = const [],
    this.metadata,
    this.replyToMessageId,
    this.replyToContent,
    this.replyToSenderId,
    this.isDealAgreementMessage = false,
    this.isSystemMessage = false,
    required this.status,
    required this.sentAt,
    this.deliveredAt,
    this.readAt,
    this.reactions = const {},
    this.isEdited = false,
    this.editedAt,
    this.originalContent,
    this.isDeleted = false,
    this.isPinned = false,
    this.isImportant = false,
  });

  DirectMessage copyWith({
    String? id,
    String? threadId,
    String? senderId,
    String? senderName,
    String? senderAvatarUrl,
    String? content,
    String? messageType,
    String? mediaUrl,
    String? thumbnailUrl,
    List<String>? attachmentUrls,
    Map<String, dynamic>? metadata,
    String? replyToMessageId,
    String? replyToContent,
    String? replyToSenderId,
    bool? isDealAgreementMessage,
    bool? isSystemMessage,
    String? status,
    DateTime? sentAt,
    DateTime? deliveredAt,
    DateTime? readAt,
    Map<String, List<String>>? reactions,
    bool? isEdited,
    DateTime? editedAt,
    String? originalContent,
    bool? isDeleted,
    bool? isPinned,
    bool? isImportant,
  }) {
    return DirectMessage(
      id: id ?? this.id,
      threadId: threadId ?? this.threadId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatarUrl: senderAvatarUrl ?? this.senderAvatarUrl,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      attachmentUrls: attachmentUrls ?? this.attachmentUrls,
      metadata: metadata ?? this.metadata,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      replyToContent: replyToContent ?? this.replyToContent,
      replyToSenderId: replyToSenderId ?? this.replyToSenderId,
      isDealAgreementMessage: isDealAgreementMessage ?? this.isDealAgreementMessage,
      isSystemMessage: isSystemMessage ?? this.isSystemMessage,
      status: status ?? this.status,
      sentAt: sentAt ?? this.sentAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      readAt: readAt ?? this.readAt,
      reactions: reactions ?? this.reactions,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      originalContent: originalContent ?? this.originalContent,
      isDeleted: isDeleted ?? this.isDeleted,
      isPinned: isPinned ?? this.isPinned,
      isImportant: isImportant ?? this.isImportant,
    );
  }
}
