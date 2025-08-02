import 'package:flutter/material.dart';
import 'system_state_widget.dart';

/// A comprehensive empty state view component for displaying "no content" scenarios
/// Designed with Aura's empathetic approach to guide users toward meaningful actions
/// Supports various empty state types with contextual messaging and call-to-actions
class EmptyView extends StatelessWidget {
  /// The primary message explaining the empty state
  final String message;
  
  /// Optional title displayed above the message
  final String? title;
  
  /// Optional subtitle for additional context
  final String? subtitle;
  
  /// Icon to display for the empty state
  final IconData? icon;
  
  /// Icon color override (uses theme primary color by default)
  final Color? iconColor;
  
  /// Icon size (default: 60)
  final double iconSize;
  
  /// Optional illustration asset path
  final String? illustrationPath;
  
  /// Callback for primary action
  final VoidCallback? onPrimaryAction;
  
  /// Text for primary action button
  final String? primaryActionText;
  
  /// Callback for secondary action
  final VoidCallback? onSecondaryAction;
  
  /// Text for secondary action button
  final String? secondaryActionText;
  
  /// Whether this is displayed in a compact space
  final bool isCompact;

  const EmptyView({
    super.key,
    required this.message,
    this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.iconSize = 60,
    this.illustrationPath,
    this.onPrimaryAction,
    this.primaryActionText,
    this.onSecondaryAction,
    this.secondaryActionText,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return _buildCompactView(context);
    }

    return SystemStateWidget(
      title: title,
      message: message,
      icon: icon ?? Icons.inbox_outlined,
      iconColor: iconColor,
      iconSize: iconSize,
      illustrationPath: illustrationPath,
      onRetry: onPrimaryAction,
      retryText: primaryActionText,
      onCTA: onSecondaryAction,
      ctaText: secondaryActionText,
    );
  }

  Widget _buildCompactView(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon ?? Icons.inbox_outlined,
            size: iconSize * 0.7,
            color: iconColor ?? colorScheme.outline,
          ),
          const SizedBox(height: 16),
          if (title != null) ...[
            Text(
              title!,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (onPrimaryAction != null) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: onPrimaryAction,
              child: Text(primaryActionText ?? 'Take Action'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Predefined empty views for common scenarios with contextual messaging
class CommonEmptyViews {
  static EmptyView noData({
    String? title,
    String? message,
    VoidCallback? onRefresh,
  }) =>
      EmptyView(
        title: title ?? 'No data yet',
        message: message ?? 'We\'ll show your content here once it\'s available.',
        icon: Icons.data_usage_outlined,
        onPrimaryAction: onRefresh,
        primaryActionText: 'Refresh',
      );

  static EmptyView noResults({
    String? query,
    VoidCallback? onClearFilters,
    VoidCallback? onSearchAgain,
  }) =>
      EmptyView(
        title: 'No results found',
        message: query != null
            ? 'We couldn\'t find anything matching "$query". Try adjusting your search.'
            : 'No items match your current filters. Try adjusting your criteria.',
        icon: Icons.search_off_outlined,
        onPrimaryAction: onSearchAgain,
        primaryActionText: 'Search Again',
        onSecondaryAction: onClearFilters,
        secondaryActionText: 'Clear Filters',
      );

  static EmptyView noNotifications({
    VoidCallback? onEnableNotifications,
  }) =>
      EmptyView(
        title: 'All caught up!',
        message: 'You\'re all up to date. New notifications will appear here.',
        icon: Icons.notifications_none_outlined,
        onPrimaryAction: onEnableNotifications,
        primaryActionText: 'Enable Notifications',
      );

  static EmptyView noFavorites({
    VoidCallback? onExplore,
  }) =>
      EmptyView(
        title: 'No favorites yet',
        message: 'Items you favorite will appear here for quick access.',
        icon: Icons.favorite_border_outlined,
        onPrimaryAction: onExplore,
        primaryActionText: 'Explore',
      );

  static EmptyView noHistory({
    VoidCallback? onGetStarted,
  }) =>
      EmptyView(
        title: 'No history yet',
        message: 'Your activity history will appear here as you use the app.',
        icon: Icons.history_outlined,
        onPrimaryAction: onGetStarted,
        primaryActionText: 'Get Started',
      );

  static EmptyView noContent({
    String? contentType,
    VoidCallback? onCreate,
    VoidCallback? onImport,
  }) =>
      EmptyView(
        title: 'No ${contentType ?? 'content'} yet',
        message: 'Get started by creating your first ${contentType ?? 'item'}.',
        icon: Icons.add_circle_outline,
        onPrimaryAction: onCreate,
        primaryActionText: 'Create',
        onSecondaryAction: onImport,
        secondaryActionText: 'Import',
      );

  static EmptyView noMessages({
    VoidCallback? onStartConversation,
  }) =>
      EmptyView(
        title: 'No messages yet',
        message: 'Start a conversation to see your messages here.',
        icon: Icons.chat_bubble_outline,
        onPrimaryAction: onStartConversation,
        primaryActionText: 'Start Chat',
      );

  static EmptyView noDownloads({
    VoidCallback? onBrowse,
  }) =>
      EmptyView(
        title: 'No downloads',
        message: 'Downloaded files will appear here for offline access.',
        icon: Icons.download_outlined,
        onPrimaryAction: onBrowse,
        primaryActionText: 'Browse Content',
      );

  static EmptyView noBookmarks({
    VoidCallback? onExplore,
  }) =>
      EmptyView(
        title: 'No bookmarks saved',
        message: 'Save interesting content here for later reading.',
        icon: Icons.bookmark_border_outlined,
        onPrimaryAction: onExplore,
        primaryActionText: 'Explore',
      );

  static EmptyView noConnections({
    VoidCallback? onConnect,
    VoidCallback? onInvite,
  }) =>
      EmptyView(
        title: 'No connections yet',
        message: 'Connect with others to see them here.',
        icon: Icons.people_outline,
        onPrimaryAction: onConnect,
        primaryActionText: 'Find People',
        onSecondaryAction: onInvite,
        secondaryActionText: 'Invite Friends',
      );

  static EmptyView offlineContent({
    VoidCallback? onGoOnline,
  }) =>
      EmptyView(
        title: 'No offline content',
        message: 'Download content while online to access it here later.',
        icon: Icons.cloud_download_outlined,
        onPrimaryAction: onGoOnline,
        primaryActionText: 'Go Online',
      );

  static EmptyView maintenanceMode({
    String? estimatedTime,
  }) =>
      EmptyView(
        title: 'Under maintenance',
        message: estimatedTime != null
            ? 'We\'re improving things for you. Expected completion: $estimatedTime'
            : 'We\'re making improvements and will be back shortly.',
        icon: Icons.construction_outlined,
      );

  static EmptyView comingSoon({
    String? feature,
    VoidCallback? onNotifyMe,
  }) =>
      EmptyView(
        title: '${feature ?? 'Feature'} coming soon!',
        message: 'We\'re working hard to bring you this feature. Stay tuned!',
        icon: Icons.upcoming_outlined,
        onPrimaryAction: onNotifyMe,
        primaryActionText: 'Notify Me',
      );
}

/// List view wrapper that shows empty state when list is empty
class EmptyAwareListView extends StatelessWidget {
  final List<dynamic> items;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final EmptyView emptyView;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const EmptyAwareListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.emptyView,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return emptyView;
    }

    return ListView.builder(
      controller: controller,
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: items.length,
      itemBuilder: itemBuilder,
    );
  }
}

/// Grid view wrapper that shows empty state when grid is empty
class EmptyAwareGridView extends StatelessWidget {
  final List<dynamic> items;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final EmptyView emptyView;
  final SliverGridDelegate gridDelegate;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const EmptyAwareGridView({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.emptyView,
    required this.gridDelegate,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return emptyView;
    }

    return GridView.builder(
      controller: controller,
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      gridDelegate: gridDelegate,
      itemCount: items.length,
      itemBuilder: itemBuilder,
    );
  }
}
