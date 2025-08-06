import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/failure_types.dart';
import '../../../../core/services/supabase_service.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';

/// Supabase implementation of NotificationRepository
/// 
/// Handles all notification-related data operations using Supabase as backend.
/// Includes real-time subscriptions and push notification integration.
class SupabaseNotificationRepository implements NotificationRepository {
  final SupabaseClient _supabase;
  
  SupabaseNotificationRepository({
    SupabaseClient? supabaseClient,
  }) : _supabase = supabaseClient ?? Supabase.instance.client;

  String? get _currentUserId => _supabase.auth.currentUser?.id;

  @override
  Future<Either<Failure, List<AppNotification>>> getNotifications({
    int page = 1,
    int limit = 20,
    List<NotificationType>? filters,
    String sortBy = 'newest',
    bool unreadOnly = false,
  }) async {
    try {
      if (_currentUserId == null) {
        return Left(AuthFailure(message: 'User not authenticated'));
      }

      var query = _supabase
          .from('notifications')
          .select()
          .eq('user_id', _currentUserId!)
          .range((page - 1) * limit, page * limit - 1);

      // Apply filters
      if (filters != null && filters.isNotEmpty) {
        final filterValues = filters.map((f) => f.name).toList();
        query = query.in_('type', filterValues);
      }

      if (unreadOnly) {
        query = query.is_('read_at', null);
      }

      // Apply sorting
      switch (sortBy) {
        case 'oldest':
          query = query.order('created_at', ascending: true);
          break;
        case 'unread_first':
          query = query.order('read_at', ascending: true, nullsFirst: true)
                      .order('created_at', ascending: false);
          break;
        default: // newest
          query = query.order('created_at', ascending: false);
      }

      final response = await query;
      
      final notifications = (response as List<dynamic>)
          .map((json) => _mapToNotification(json as Map<String, dynamic>))
          .toList();

      return Right(notifications);
    } on PostgrestException catch (e) {
      return Left(DataFailure(message: 'Database error: ${e.message}'));
    } catch (e) {
      return Left(DataFailure(message: 'Failed to fetch notifications: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    try {
      if (_currentUserId == null) {
        return Left(AuthFailure(message: 'User not authenticated'));
      }

      final response = await _supabase
          .from('notifications')
          .select('id', const FetchOptions(count: CountOption.exact))
          .eq('user_id', _currentUserId!)
          .is_('read_at', null);

      return Right(response.count ?? 0);
    } catch (e) {
      return Left(DataFailure(message: 'Failed to get unread count: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    try {
      if (_currentUserId == null) {
        return Left(AuthFailure(message: 'User not authenticated'));
      }

      await _supabase
          .from('notifications')
          .update({'read_at': DateTime.now().toIso8601String()})
          .eq('id', notificationId)
          .eq('user_id', _currentUserId!);

      return const Right(null);
    } catch (e) {
      return Left(DataFailure(message: 'Failed to mark as read: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markMultipleAsRead(List<String> notificationIds) async {
    try {
      if (_currentUserId == null) {
        return Left(AuthFailure(message: 'User not authenticated'));
      }

      await _supabase
          .from('notifications')
          .update({'read_at': DateTime.now().toIso8601String()})
          .in_('id', notificationIds)
          .eq('user_id', _currentUserId!);

      return const Right(null);
    } catch (e) {
      return Left(DataFailure(message: 'Failed to mark multiple as read: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    try {
      if (_currentUserId == null) {
        return Left(AuthFailure(message: 'User not authenticated'));
      }

      await _supabase
          .from('notifications')
          .update({'read_at': DateTime.now().toIso8601String()})
          .eq('user_id', _currentUserId!)
          .is_('read_at', null);

      return const Right(null);
    } catch (e) {
      return Left(DataFailure(message: 'Failed to mark all as read: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotification(String notificationId) async {
    try {
      if (_currentUserId == null) {
        return Left(AuthFailure(message: 'User not authenticated'));
      }

      await _supabase
          .from('notifications')
          .delete()
          .eq('id', notificationId)
          .eq('user_id', _currentUserId!);

      return const Right(null);
    } catch (e) {
      return Left(DataFailure(message: 'Failed to delete notification: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMultipleNotifications(List<String> notificationIds) async {
    try {
      if (_currentUserId == null) {
        return Left(AuthFailure(message: 'User not authenticated'));
      }

      await _supabase
          .from('notifications')
          .delete()
          .in_('id', notificationIds)
          .eq('user_id', _currentUserId!);

      return const Right(null);
    } catch (e) {
      return Left(DataFailure(message: 'Failed to delete notifications: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearAllNotifications() async {
    try {
      if (_currentUserId == null) {
        return Left(AuthFailure(message: 'User not authenticated'));
      }

      await _supabase
          .from('notifications')
          .delete()
          .eq('user_id', _currentUserId!);

      return const Right(null);
    } catch (e) {
      return Left(DataFailure(message: 'Failed to clear all notifications: $e'));
    }
  }

  @override
  Future<Either<Failure, NotificationSettings>> getNotificationSettings() async {
    try {
      if (_currentUserId == null) {
        return Left(AuthFailure(message: 'User not authenticated'));
      }

      final response = await _supabase
          .from('notification_settings')
          .select()
          .eq('user_id', _currentUserId!)
          .maybeSingle();

      if (response == null) {
        // Return default settings if none exist
        return Right(NotificationSettings(userId: _currentUserId!));
      }

      return Right(NotificationSettings.fromJson(response));
    } catch (e) {
      return Left(DataFailure(message: 'Failed to get settings: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateNotificationSettings(NotificationSettings settings) async {
    try {
      if (_currentUserId == null) {
        return Left(AuthFailure(message: 'User not authenticated'));
      }

      final data = settings.toJson()..['updated_at'] = DateTime.now().toIso8601String();

      await _supabase
          .from('notification_settings')
          .upsert(data)
          .eq('user_id', _currentUserId!);

      return const Right(null);
    } catch (e) {
      return Left(DataFailure(message: 'Failed to update settings: $e'));
    }
  }

  @override
  Stream<AppNotification> subscribeToNotifications() {
    if (_currentUserId == null) {
      return Stream.error(AuthFailure(message: 'User not authenticated'));
    }

    return _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', _currentUserId!)
        .map((data) {
          if (data.isNotEmpty) {
            return _mapToNotification(data.first);
          }
          throw Exception('No notification data received');
        });
  }

  @override
  Future<Either<Failure, AppNotification?>> getNotificationById(String id) async {
    try {
      if (_currentUserId == null) {
        return Left(AuthFailure(message: 'User not authenticated'));
      }

      final response = await _supabase
          .from('notifications')
          .select()
          .eq('id', id)
          .eq('user_id', _currentUserId!)
          .maybeSingle();

      if (response == null) {
        return const Right(null);
      }

      return Right(_mapToNotification(response));
    } catch (e) {
      return Left(DataFailure(message: 'Failed to get notification: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> hasNotificationPermission() async {
    try {
      // TODO: Implement platform-specific permission checking
      // For now, return true for mock implementation
      return const Right(true);
    } catch (e) {
      return Left(DataFailure(message: 'Failed to check permission: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> requestNotificationPermission() async {
    try {
      // TODO: Implement platform-specific permission request
      // For now, return true for mock implementation
      return const Right(true);
    } catch (e) {
      return Left(DataFailure(message: 'Failed to request permission: $e'));
    }
  }

  /// Map database JSON to AppNotification entity
  AppNotification _mapToNotification(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.system,
      ),
      actionType: NotificationActionType.values.firstWhere(
        (e) => e.name == json['action_type'],
        orElse: () => NotificationActionType.systemUpdate,
      ),
      title: json['title'] as String,
      message: json['message'] as String,
      imageUrl: json['image_url'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      deepLinkPath: json['deep_link_path'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at'] as String) : null,
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at'] as String) : null,
      priority: NotificationPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => NotificationPriority.medium,
      ),
      actorUserId: json['actor_user_id'] as String?,
      actorName: json['actor_name'] as String?,
      actorAvatarUrl: json['actor_avatar_url'] as String?,
      groupKey: json['group_key'] as String?,
      groupCount: json['group_count'] as int? ?? 1,
      isPushEnabled: json['is_push_enabled'] as bool? ?? true,
      isInAppEnabled: json['is_in_app_enabled'] as bool? ?? true,
    );
  }
}
