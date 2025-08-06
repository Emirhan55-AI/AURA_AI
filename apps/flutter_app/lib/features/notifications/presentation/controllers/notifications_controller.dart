import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:dartz/dartz.dart';
import 'dart:math' as math;

import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../../../core/error/failure.dart';

part 'notifications_controller.g.dart';
part 'notifications_controller.freezed.dart';

/// Notifications State
@freezed
class NotificationsState with _$NotificationsState {
  const factory NotificationsState({
    @Default([]) List<AppNotification> notifications,
    @Default([]) List<AppNotification> unreadNotifications,
    @Default(0) int unreadCount,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMore,
    @Default(true) bool hasMore,
    @Default(1) int currentPage,
    String? error,
    @Default(false) bool isRefreshing,
    
    // Notification settings
    NotificationSettings? settings,
    @Default(false) bool isSettingsLoading,
    
    // Real-time updates
    @Default(false) bool isConnected,
    DateTime? lastUpdate,
    
    // Filters and sorting
    @Default([]) List<NotificationType> activeFilters,
    @Default('newest') String sortBy, // newest, oldest, unread_first
    
    // Selection state for bulk operations
    @Default({}) Set<String> selectedNotificationIds,
    @Default(false) bool isSelectionMode,
  }) = _NotificationsState;
}

/// Mock Notification Repository for development/testing
class MockNotificationRepository implements NotificationRepository {
  static List<AppNotification> _mockNotifications = [];
  static NotificationSettings _mockSettings = const NotificationSettings(userId: 'mock_user');
  
  // Initialize with sample data
  static void initialize() {
    if (_mockNotifications.isEmpty) {
      _mockNotifications = _getSampleNotifications();
    }
  }

  /// Generate sample notifications for testing
  static List<AppNotification> _getSampleNotifications() {
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

  @override
  Future<Either<Failure, List<AppNotification>>> getNotifications({
    int page = 1,
    int limit = 20,
    List<NotificationType>? filters,
    String sortBy = 'newest',
    bool unreadOnly = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    
    initialize();
    var notifications = List<AppNotification>.from(_mockNotifications);
    
    // Apply filters
    if (filters != null && filters.isNotEmpty) {
      notifications = notifications.where((n) => filters.contains(n.type)).toList();
    }
    
    if (unreadOnly) {
      notifications = notifications.where((n) => !n.isRead).toList();
    }
    
    // Apply sorting
    switch (sortBy) {
      case 'oldest':
        notifications.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'unread_first':
        notifications.sort((a, b) {
          if (a.isRead != b.isRead) {
            return a.isRead ? 1 : -1;
          }
          return b.createdAt.compareTo(a.createdAt);
        });
        break;
      default: // newest
        notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    
    // Apply pagination
    final startIndex = (page - 1) * limit;
    final endIndex = startIndex + limit;
    final paginatedResults = notifications.skip(startIndex).take(limit).toList();
    
    return Right(paginatedResults);
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    initialize();
    final unreadCount = _mockNotifications.where((n) => !n.isRead).length;
    return Right(unreadCount);
  }

  @override
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final index = _mockNotifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _mockNotifications[index] = _mockNotifications[index].copyWith(
        readAt: DateTime.now(),
      );
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> markMultipleAsRead(List<String> notificationIds) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    for (final id in notificationIds) {
      final index = _mockNotifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _mockNotifications[index] = _mockNotifications[index].copyWith(
          readAt: DateTime.now(),
        );
      }
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    for (int i = 0; i < _mockNotifications.length; i++) {
      if (!_mockNotifications[i].isRead) {
        _mockNotifications[i] = _mockNotifications[i].copyWith(
          readAt: DateTime.now(),
        );
      }
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteNotification(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    _mockNotifications.removeWhere((n) => n.id == notificationId);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteMultipleNotifications(List<String> notificationIds) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    _mockNotifications.removeWhere((n) => notificationIds.contains(n.id));
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> clearAllNotifications() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    _mockNotifications.clear();
    return const Right(null);
  }

  @override
  Future<Either<Failure, NotificationSettings>> getNotificationSettings() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return Right(_mockSettings);
  }

  @override
  Future<Either<Failure, void>> updateNotificationSettings(NotificationSettings settings) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockSettings = settings;
    return const Right(null);
  }

  @override
  Stream<AppNotification> subscribeToNotifications() {
    // Mock real-time stream
    return Stream.periodic(const Duration(seconds: 30), (index) {
      return AppNotification(
        id: 'realtime_${index}_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'mock_user',
        type: NotificationType.values[index % NotificationType.values.length],
        actionType: NotificationActionType.like,
        title: 'Real-time Notification',
        message: 'This is a real-time notification #${index + 1}',
        createdAt: DateTime.now(),
      );
    });
  }

  @override
  Future<Either<Failure, AppNotification?>> getNotificationById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    try {
      final notification = _mockNotifications.firstWhere((n) => n.id == id);
      return Right(notification);
    } catch (e) {
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, bool>> hasNotificationPermission() async {
    return const Right(true);
  }

  @override
  Future<Either<Failure, bool>> requestNotificationPermission() async {
    return const Right(true);
  }
}

/// Provider for notification repository
@riverpod
NotificationRepository notificationRepository(NotificationRepositoryRef ref) {
  return MockNotificationRepository();
}

/// Notifications Controller
/// 
/// Manages the state of notifications including fetching, marking as read,
/// real-time updates, and user preferences.
@riverpod
class NotificationsController extends _$NotificationsController {
  static const int _pageSize = 20;
  
  @override
  NotificationsState build() {
    // Initialize real-time connection
    _initializeRealTimeConnection();
    
    return const NotificationsState();
  }
  
  /// Initialize real-time notification connection
  void _initializeRealTimeConnection() {
    // Subscribe to real-time notifications
    final repository = ref.read(notificationRepositoryProvider);
    repository.subscribeToNotifications().listen(
      (notification) {
        // Add new notification to state
        state = state.copyWith(
          notifications: [notification, ...state.notifications],
          unreadCount: state.unreadCount + 1,
          lastUpdate: DateTime.now(),
        );
      },
      onError: (error) {
        debugPrint('Real-time notification error: $error');
      },
    );
    
    state = state.copyWith(isConnected: true);
  }
  
  /// Load notifications with pagination
  Future<void> loadNotifications({
    bool refresh = false,
    List<NotificationType>? filters,
    String? sortBy,
  }) async {
    if (refresh) {
      state = state.copyWith(
        isRefreshing: true,
        currentPage: 1,
        hasMore: true,
        error: null,
      );
    } else if (state.isLoading || state.isLoadingMore) {
      return; // Prevent multiple simultaneous loads
    }
    
    state = state.copyWith(
      isLoading: !refresh && state.notifications.isEmpty,
      isLoadingMore: !refresh && state.notifications.isNotEmpty,
      activeFilters: filters ?? state.activeFilters,
      sortBy: sortBy ?? state.sortBy,
    );
    
    try {
      final repository = ref.read(notificationRepositoryProvider);
      final result = await repository.getNotifications(
        page: refresh ? 1 : state.currentPage,
        limit: _pageSize,
        filters: state.activeFilters,
        sortBy: state.sortBy,
      );
      
      result.fold(
        (failure) => state = state.copyWith(
          error: failure.message,
          isLoading: false,
          isRefreshing: false,
          isLoadingMore: false,
        ),
        (newNotifications) {
          final hasMore = newNotifications.length == _pageSize;
          final allNotifications = refresh 
              ? newNotifications
              : [...state.notifications, ...newNotifications];
          
          state = state.copyWith(
            notifications: allNotifications,
            currentPage: refresh ? 2 : state.currentPage + 1,
            hasMore: hasMore,
            isLoading: false,
            isRefreshing: false,
            isLoadingMore: false,
            error: null,
            lastUpdate: DateTime.now(),
          );
          
          // Update unread count
          _updateUnreadCount();
        },
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Unexpected error: $e',
        isLoading: false,
        isRefreshing: false,
        isLoadingMore: false,
      );
    }
  }
  
  /// Update unread count
  Future<void> _updateUnreadCount() async {
    final repository = ref.read(notificationRepositoryProvider);
    final result = await repository.getUnreadCount();
    result.fold(
      (failure) => debugPrint('Failed to update unread count: ${failure.message}'),
      (count) => state = state.copyWith(unreadCount: count),
    );
  }
  
  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    final repository = ref.read(notificationRepositoryProvider);
    final result = await repository.markAsRead(notificationId);
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) {
        // Update local state
        final updatedNotifications = state.notifications.map((n) {
          if (n.id == notificationId && !n.isRead) {
            return n.copyWith(readAt: DateTime.now());
          }
          return n;
        }).toList();
        
        state = state.copyWith(
          notifications: updatedNotifications,
          unreadCount: math.max(0, state.unreadCount - 1),
        );
      },
    );
  }
  
  /// Mark multiple notifications as read
  Future<void> markMultipleAsRead(List<String> notificationIds) async {
    final repository = ref.read(notificationRepositoryProvider);
    final result = await repository.markMultipleAsRead(notificationIds);
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) {
        // Update local state
        int unreadReduced = 0;
        final updatedNotifications = state.notifications.map((n) {
          if (notificationIds.contains(n.id) && !n.isRead) {
            unreadReduced++;
            return n.copyWith(readAt: DateTime.now());
          }
          return n;
        }).toList();
        
        state = state.copyWith(
          notifications: updatedNotifications,
          unreadCount: math.max(0, state.unreadCount - unreadReduced),
          selectedNotificationIds: {},
          isSelectionMode: false,
        );
      },
    );
  }
  
  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    final repository = ref.read(notificationRepositoryProvider);
    final result = await repository.markAllAsRead();
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) {
        // Update local state
        final updatedNotifications = state.notifications.map((n) {
          if (!n.isRead) {
            return n.copyWith(readAt: DateTime.now());
          }
          return n;
        }).toList();
        
        state = state.copyWith(
          notifications: updatedNotifications,
          unreadCount: 0,
        );
      },
    );
  }
  
  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    final repository = ref.read(notificationRepositoryProvider);
    final result = await repository.deleteNotification(notificationId);
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) {
        // Update local state
        final wasUnread = state.notifications.any((n) => n.id == notificationId && !n.isRead);
        final updatedNotifications = state.notifications.where((n) => n.id != notificationId).toList();
        
        state = state.copyWith(
          notifications: updatedNotifications,
          unreadCount: wasUnread ? math.max(0, state.unreadCount - 1) : state.unreadCount,
        );
      },
    );
  }
  
  /// Delete multiple notifications
  Future<void> deleteMultipleNotifications(List<String> notificationIds) async {
    final repository = ref.read(notificationRepositoryProvider);
    final result = await repository.deleteMultipleNotifications(notificationIds);
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) {
        // Update local state
        int unreadReduced = 0;
        final updatedNotifications = state.notifications.where((n) {
          if (notificationIds.contains(n.id)) {
            if (!n.isRead) unreadReduced++;
            return false;
          }
          return true;
        }).toList();
        
        state = state.copyWith(
          notifications: updatedNotifications,
          unreadCount: math.max(0, state.unreadCount - unreadReduced),
          selectedNotificationIds: {},
          isSelectionMode: false,
        );
      },
    );
  }
  
  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    final repository = ref.read(notificationRepositoryProvider);
    final result = await repository.clearAllNotifications();
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) {
        state = state.copyWith(
          notifications: [],
          unreadCount: 0,
          selectedNotificationIds: {},
          isSelectionMode: false,
        );
      },
    );
  }
  
  /// Toggle selection mode
  void toggleSelectionMode() {
    state = state.copyWith(
      isSelectionMode: !state.isSelectionMode,
      selectedNotificationIds: {},
    );
  }
  
  /// Toggle notification selection
  void toggleNotificationSelection(String notificationId) {
    final selectedIds = Set<String>.from(state.selectedNotificationIds);
    
    if (selectedIds.contains(notificationId)) {
      selectedIds.remove(notificationId);
    } else {
      selectedIds.add(notificationId);
    }
    
    state = state.copyWith(
      selectedNotificationIds: selectedIds,
      isSelectionMode: selectedIds.isNotEmpty,
    );
  }
  
  /// Select all notifications
  void selectAllNotifications() {
    final allIds = state.notifications.map((n) => n.id).toSet();
    state = state.copyWith(selectedNotificationIds: allIds);
  }
  
  /// Deselect all notifications
  void deselectAllNotifications() {
    state = state.copyWith(
      selectedNotificationIds: {},
      isSelectionMode: false,
    );
  }
  
  /// Apply filters
  void applyFilters(List<NotificationType> filters) {
    state = state.copyWith(
      activeFilters: filters,
      currentPage: 1,
      hasMore: true,
    );
    loadNotifications(refresh: true);
  }
  
  /// Apply sorting
  void applySorting(String sortBy) {
    state = state.copyWith(
      sortBy: sortBy,
      currentPage: 1,
      hasMore: true,
    );
    loadNotifications(refresh: true);
  }
  
  /// Retry loading notifications
  void retry() {
    loadNotifications(refresh: true);
  }
  
  /// Load more notifications (infinite scroll)
  Future<void> loadMore() async {
    if (state.hasMore && !state.isLoadingMore && !state.isLoading) {
      await loadNotifications();
    }
  }
}
