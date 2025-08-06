import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ui/system_state_widget.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/secondary_button.dart';
import '../controllers/notifications_controller.dart';
import '../widgets/notification_item.dart';
import '../widgets/notification_filter_sheet.dart';
import '../widgets/notification_settings_sheet.dart';
import '../../domain/entities/app_notification.dart';

/// Notifications Screen - V3.0 Release Critical Feature
/// 
/// Production-ready notification management screen following docs requirements:
/// - Real-time notification updates
/// - Comprehensive filtering and sorting
/// - Bulk operations (mark as read, delete)
/// - Settings management
/// - Material 3 design compliance
/// - Error handling and retry functionality
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    
    // Setup infinite scroll
    _scrollController.addListener(_onScroll);
    
    // Load notifications on screen open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationsControllerProvider.notifier).loadNotifications(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      // Load more when near bottom
      ref.read(notificationsControllerProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = ref.watch(notificationsControllerProvider);
    final controller = ref.read(notificationsControllerProvider.notifier);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildAppBar(context, theme, colorScheme, state, controller),
      body: _buildBody(context, theme, colorScheme, state, controller),
      floatingActionButton: state.isSelectionMode ? null : _buildFloatingActionButton(context, colorScheme),
    );
  }

  /// Build app bar with actions
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    NotificationsState state,
    NotificationsController controller,
  ) {
    if (state.isSelectionMode) {
      return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => controller.deselectAllNotifications(),
        ),
        title: Text('${state.selectedNotificationIds.length} selected'),
        backgroundColor: colorScheme.surfaceContainerHighest,
        actions: [
          if (state.selectedNotificationIds.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.mark_email_read),
              onPressed: () => _markSelectedAsRead(controller, state),
              tooltip: 'Mark as read',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _deleteSelected(context, controller, state),
              tooltip: 'Delete',
            ),
          ],
          IconButton(
            icon: const Icon(Icons.select_all),
            onPressed: () => controller.selectAllNotifications(),
            tooltip: 'Select all',
          ),
        ],
      );
    }

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Notifications'),
          if (state.unreadCount > 0)
            Text(
              '${state.unreadCount} unread',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      actions: [
        // Filter button
        IconButton(
          icon: Badge(
            isLabelVisible: state.activeFilters.isNotEmpty,
            backgroundColor: colorScheme.primary,
            child: const Icon(Icons.filter_list),
          ),
          onPressed: () => _showFilterSheet(context),
          tooltip: 'Filter notifications',
        ),
        
        // More options menu
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) => _handleMenuAction(context, value, controller, state),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'mark_all_read',
              enabled: state.unreadCount > 0,
              child: const Row(
                children: [
                  Icon(Icons.done_all),
                  SizedBox(width: 12),
                  Text('Mark all as read'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'select_mode',
              child: const Row(
                children: [
                  Icon(Icons.checklist),
                  SizedBox(width: 12),
                  Text('Select notifications'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings),
                  SizedBox(width: 12),
                  Text('Notification settings'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'clear_all',
              enabled: state.notifications.isNotEmpty,
              child: Row(
                children: [
                  Icon(Icons.clear_all, color: colorScheme.error),
                  const SizedBox(width: 12),
                  Text('Clear all', style: TextStyle(color: colorScheme.error)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build main body content
  Widget _buildBody(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    NotificationsState state,
    NotificationsController controller,
  ) {
    // Error state
    if (state.error != null && state.notifications.isEmpty) {
      return SystemStateWidget(
        title: 'Unable to load notifications',
        message: state.error!,
        icon: Icons.error_outline,
        iconColor: colorScheme.error,
        onRetry: () => controller.retry(),
        retryText: 'Try Again',
      );
    }

    // Loading state (initial load)
    if (state.isLoading && state.notifications.isEmpty) {
      return _buildLoadingState(colorScheme);
    }

    // Empty state
    if (state.notifications.isEmpty && !state.isLoading) {
      return _buildEmptyState(context, theme, colorScheme);
    }

    // Notifications list
    return RefreshIndicator(
      onRefresh: () => controller.loadNotifications(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: state.notifications.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Loading more indicator
          if (index >= state.notifications.length) {
            return _buildLoadMoreIndicator(colorScheme);
          }

          final notification = state.notifications[index];
          return NotificationItem(
            notification: notification,
            isSelected: state.selectedNotificationIds.contains(notification.id),
            isSelectionMode: state.isSelectionMode,
            onTap: () => _handleNotificationTap(context, notification, controller, state),
            onLongPress: () => _handleNotificationLongPress(notification, controller),
            onMarkAsRead: () => controller.markAsRead(notification.id),
            onDelete: () => _deleteNotification(context, notification, controller),
          );
        },
      ),
    );
  }

  /// Build loading state
  Widget _buildLoadingState(ColorScheme colorScheme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      itemBuilder: (context, index) => _buildShimmerItem(colorScheme),
    );
  }

  /// Build shimmer loading item
  Widget _buildShimmerItem(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 14,
                      width: 100,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_outlined,
                size: 64,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No notifications yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'When you receive notifications, they\'ll appear here. Stay tuned for updates!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              text: 'Explore Aura',
              onPressed: () => context.go('/home'),
              icon: Icons.explore,
            ),
          ],
        ),
      ),
    );
  }

  /// Build load more indicator
  Widget _buildLoadMoreIndicator(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Loading more...',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Build floating action button
  Widget? _buildFloatingActionButton(BuildContext context, ColorScheme colorScheme) {
    return FloatingActionButton.extended(
      onPressed: () => _showNotificationSettings(context),
      icon: const Icon(Icons.tune),
      label: const Text('Settings'),
      backgroundColor: colorScheme.primaryContainer,
      foregroundColor: colorScheme.onPrimaryContainer,
    );
  }

  /// Handle notification tap
  void _handleNotificationTap(
    BuildContext context,
    AppNotification notification,
    NotificationsController controller,
    NotificationsState state,
  ) {
    if (state.isSelectionMode) {
      controller.toggleNotificationSelection(notification.id);
      return;
    }

    // Mark as read if unread
    if (!notification.isRead) {
      controller.markAsRead(notification.id);
    }

    // Navigate to deep link if available
    if (notification.deepLinkPath != null) {
      context.push(notification.deepLinkPath!);
    }
  }

  /// Handle notification long press
  void _handleNotificationLongPress(AppNotification notification, NotificationsController controller) {
    controller.toggleNotificationSelection(notification.id);
  }

  /// Handle menu actions
  void _handleMenuAction(
    BuildContext context,
    String action,
    NotificationsController controller,
    NotificationsState state,
  ) {
    switch (action) {
      case 'mark_all_read':
        controller.markAllAsRead();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All notifications marked as read')),
        );
        break;
      case 'select_mode':
        controller.toggleSelectionMode();
        break;
      case 'settings':
        _showNotificationSettings(context);
        break;
      case 'clear_all':
        _showClearAllDialog(context, controller, state);
        break;
    }
  }

  /// Mark selected notifications as read
  void _markSelectedAsRead(NotificationsController controller, NotificationsState state) {
    final selectedIds = state.selectedNotificationIds.toList();
    controller.markMultipleAsRead(selectedIds);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${selectedIds.length} notifications marked as read')),
    );
  }

  /// Delete selected notifications
  void _deleteSelected(BuildContext context, NotificationsController controller, NotificationsState state) {
    final selectedIds = state.selectedNotificationIds.toList();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notifications'),
        content: Text('Are you sure you want to delete ${selectedIds.length} notifications? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              controller.deleteMultipleNotifications(selectedIds);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${selectedIds.length} notifications deleted')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Delete single notification
  void _deleteNotification(BuildContext context, AppNotification notification, NotificationsController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notification'),
        content: const Text('Are you sure you want to delete this notification? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              controller.deleteNotification(notification.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notification deleted')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Show filter bottom sheet
  void _showFilterSheet(BuildContext context) {
    final controller = ref.read(notificationsControllerProvider.notifier);
    final currentFilters = ref.read(notificationsControllerProvider).activeFilters;
    
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => NotificationFilterSheet(
        selectedTypes: Set.from(currentFilters),
        onFiltersChanged: (filters) {
          controller.applyFilters(filters.toList());
        },
      ),
    );
  }

  /// Show notification settings
  void _showNotificationSettings(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const NotificationSettingsSheet(),
    );
  }

  /// Show clear all dialog
  void _showClearAllDialog(BuildContext context, NotificationsController controller, NotificationsState state) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications'),
        content: Text('Are you sure you want to clear all ${state.notifications.length} notifications? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              controller.clearAllNotifications();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All notifications cleared')),
              );
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
