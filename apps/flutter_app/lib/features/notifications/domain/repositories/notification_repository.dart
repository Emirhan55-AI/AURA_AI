import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/app_notification.dart';

/// Notification Repository Interface
/// 
/// Defines the contract for notification data operations following Clean Architecture.
/// This interface will be implemented by data layer repositories.
abstract class NotificationRepository {
  /// Get paginated notifications for current user
  Future<Either<Failure, List<AppNotification>>> getNotifications({
    int page = 1,
    int limit = 20,
    List<NotificationType>? filters,
    String sortBy = 'newest',
    bool unreadOnly = false,
  });

  /// Get count of unread notifications
  Future<Either<Failure, int>> getUnreadCount();

  /// Mark notification as read
  Future<Either<Failure, void>> markAsRead(String notificationId);

  /// Mark multiple notifications as read
  Future<Either<Failure, void>> markMultipleAsRead(List<String> notificationIds);

  /// Mark all notifications as read
  Future<Either<Failure, void>> markAllAsRead();

  /// Delete notification
  Future<Either<Failure, void>> deleteNotification(String notificationId);

  /// Delete multiple notifications
  Future<Either<Failure, void>> deleteMultipleNotifications(List<String> notificationIds);

  /// Clear all notifications
  Future<Either<Failure, void>> clearAllNotifications();

  /// Get notification settings
  Future<Either<Failure, NotificationSettings>> getNotificationSettings();

  /// Update notification settings
  Future<Either<Failure, void>> updateNotificationSettings(NotificationSettings settings);

  /// Subscribe to real-time notifications
  Stream<AppNotification> subscribeToNotifications();

  /// Get notification by ID
  Future<Either<Failure, AppNotification?>> getNotificationById(String id);

  /// Check if user has specific notification permission
  Future<Either<Failure, bool>> hasNotificationPermission();

  /// Request notification permission
  Future<Either<Failure, bool>> requestNotificationPermission();
}
