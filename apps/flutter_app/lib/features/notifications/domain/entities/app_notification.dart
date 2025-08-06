import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_notification.freezed.dart';
part 'app_notification.g.dart';

/// Notification Types enum
enum NotificationType {
  social,    // Likes, comments, follows
  system,    // App updates, maintenance
  swap,      // Swap requests, matches
  wardrobe,  // Outfit suggestions, reminders
  challenge, // Style challenges, competitions
  message,   // Direct messages
}

/// Notification Priority levels
enum NotificationPriority {
  low,
  medium,
  high,
  urgent,
}

/// Notification Action Types
enum NotificationActionType {
  like,
  comment,
  follow,
  swapRequest,
  swapMatch,
  challengeInvite,
  systemUpdate,
  outfitSuggestion,
  message,
}

/// Main Notification Entity
/// 
/// Represents a single notification in the app following Clean Architecture
/// Domain layer entity with all business logic rules
@freezed
class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String id,
    required String userId,
    required NotificationType type,
    required NotificationActionType actionType,
    required String title,
    required String message,
    String? imageUrl,
    String? avatarUrl,
    
    // Navigation data
    String? deepLinkPath,
    Map<String, dynamic>? metadata,
    
    // Status and timing
    required DateTime createdAt,
    DateTime? readAt,
    DateTime? expiresAt,
    @Default(NotificationPriority.medium) NotificationPriority priority,
    
    // Actor information (who triggered this notification)
    String? actorUserId,
    String? actorName,
    String? actorAvatarUrl,
    
    // Grouped notification support
    String? groupKey,
    @Default(1) int groupCount,
    
    // Push notification settings
    @Default(true) bool isPushEnabled,
    @Default(true) bool isInAppEnabled,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);
}

/// Notification Settings Entity
@freezed
class NotificationSettings with _$NotificationSettings {
  const factory NotificationSettings({
    required String userId,
    
    // Global settings
    @Default(true) bool pushNotificationsEnabled,
    @Default(true) bool inAppNotificationsEnabled,
    @Default(true) bool emailNotificationsEnabled,
    
    // Category settings
    @Default(true) bool socialNotifications,
    @Default(true) bool systemNotifications,
    @Default(true) bool swapNotifications,
    @Default(true) bool wardrobeNotifications,
    @Default(true) bool challengeNotifications,
    @Default(true) bool messageNotifications,
    
    // Timing settings
    String? quietHoursStart, // "22:00"
    String? quietHoursEnd,   // "08:00"
    @Default([]) List<int> quietDays, // 0=Sunday, 6=Saturday
    
    // Advanced settings
    @Default(true) bool soundEnabled,
    @Default(true) bool vibrationEnabled,
    @Default(true) bool groupSimilarNotifications,
    
    DateTime? updatedAt,
  }) = _NotificationSettings;

  factory NotificationSettings.fromJson(Map<String, dynamic> json) =>
      _$NotificationSettingsFromJson(json);
}

/// Notification Group for displaying grouped notifications
@freezed
class NotificationGroup with _$NotificationGroup {
  const factory NotificationGroup({
    required String groupKey,
    required NotificationType type,
    required List<AppNotification> notifications,
    required DateTime latestAt,
    required int totalCount,
    required int unreadCount,
    String? title,
    String? summary,
  }) = _NotificationGroup;
}

/// Extension methods for business logic
extension AppNotificationX on AppNotification {
  /// Check if notification is read
  bool get isRead => readAt != null;
  
  /// Check if notification is expired
  bool get isExpired => 
      expiresAt != null && DateTime.now().isAfter(expiresAt!);
  
  /// Check if notification is recent (within 24 hours)
  bool get isRecent => 
      DateTime.now().difference(createdAt).inHours < 24;
  
  /// Get relative time string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }
  
  /// Get display color based on type
  String get typeColor {
    switch (type) {
      case NotificationType.social:
        return '#FF6F61'; // Primary coral
      case NotificationType.system:
        return '#6366F1'; // Indigo
      case NotificationType.swap:
        return '#10B981'; // Emerald
      case NotificationType.wardrobe:
        return '#F59E0B'; // Amber
      case NotificationType.challenge:
        return '#EF4444'; // Red
      case NotificationType.message:
        return '#8B5CF6'; // Purple
    }
  }
  
  /// Generate sample notifications for testing
  static List<AppNotification> getSampleNotifications() {
    final now = DateTime.now();
    
    return [
      AppNotification(
        id: '1',
        userId: 'user123',
        type: NotificationType.social,
        actionType: NotificationActionType.like,
        title: 'New Like',
        message: 'Sarah liked your outfit combination',
        actorUserId: 'sarah123',
        actorName: 'Sarah Johnson',
        actorAvatarUrl: 'https://i.pravatar.cc/150?img=1',
        createdAt: now.subtract(const Duration(minutes: 5)),
        deepLinkPath: '/social/post/abc123',
      ),
      
      AppNotification(
        id: '2',
        userId: 'user123',
        type: NotificationType.swap,
        actionType: NotificationActionType.swapRequest,
        title: 'Swap Request',
        message: 'Emma wants to swap her vintage jacket with your denim shirt',
        actorUserId: 'emma456',
        actorName: 'Emma Wilson',
        actorAvatarUrl: 'https://i.pravatar.cc/150?img=2',
        imageUrl: 'https://images.unsplash.com/photo-1551232864-3f0890e580d9?w=300',
        createdAt: now.subtract(const Duration(hours: 2)),
        deepLinkPath: '/swap/request/def456',
      ),
      
      AppNotification(
        id: '3',
        userId: 'user123',
        type: NotificationType.challenge,
        actionType: NotificationActionType.challengeInvite,
        title: 'Style Challenge',
        message: 'Join the "Minimalist Chic" challenge starting tomorrow!',
        createdAt: now.subtract(const Duration(hours: 4)),
        priority: NotificationPriority.high,
        deepLinkPath: '/challenges/minimalist-chic',
      ),
      
      AppNotification(
        id: '4',
        userId: 'user123',
        type: NotificationType.system,
        actionType: NotificationActionType.systemUpdate,
        title: 'App Update Available',
        message: 'Version 3.1 is ready with new AI styling features!',
        createdAt: now.subtract(const Duration(days: 1)),
        priority: NotificationPriority.medium,
      ),
      
      AppNotification(
        id: '5',
        userId: 'user123',
        type: NotificationType.message,
        actionType: NotificationActionType.message,
        title: 'New Message',
        message: 'Alex: "Love your latest style posts! 😍"',
        actorUserId: 'alex789',
        actorName: 'Alex Rodriguez',
        actorAvatarUrl: 'https://i.pravatar.cc/150?img=3',
        createdAt: now.subtract(const Duration(days: 2)),
        deepLinkPath: '/messages/alex789',
        readAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }
}
