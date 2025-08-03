import 'package:flutter/material.dart';

/// Profile Tab Bar Widget - Horizontal scrollable tab bar for profile sections
/// 
/// Provides navigation between different profile content sections:
/// - My Combinations
/// - My Favorites
/// - My Likes
/// - Social Shares
/// - Communities
/// - Swap History
class ProfileTabBar extends StatelessWidget {
  final TabController tabController;
  final List<String> tabs;

  const ProfileTabBar({
    super.key,
    required this.tabController,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: tabController,
        isScrollable: true,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        tabAlignment: TabAlignment.start,
        indicatorColor: colorScheme.primary,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        labelStyle: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        overlayColor: WidgetStateProperty.all(
          colorScheme.primary.withOpacity(0.1),
        ),
        splashFactory: InkRipple.splashFactory,
        tabs: tabs.map((tab) => _buildTab(tab, theme)).toList(),
      ),
    );
  }

  /// Builds individual tab with proper padding and styling
  Widget _buildTab(String label, ThemeData theme) {
    return Tab(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          label,
          style: theme.textTheme.labelLarge,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
