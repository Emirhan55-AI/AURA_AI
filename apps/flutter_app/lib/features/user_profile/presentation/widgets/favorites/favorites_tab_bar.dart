import 'package:flutter/material.dart';
import 'favorite_item_models.dart';

/// FavoritesTabBar - Horizontal scrollable bar for switching between favorite content types
/// 
/// This widget provides a tab bar for navigating between different types of favorited content
/// such as products, combinations, social posts, and swap listings.
class FavoritesTabBar extends StatelessWidget {
  final TabController tabController;
  final List<FavoriteTabType> tabs;
  final void Function(int)? onTabChanged;

  const FavoritesTabBar({
    super.key,
    required this.tabController,
    this.tabs = const [
      FavoriteTabType.products,
      FavoriteTabType.combinations,
      FavoriteTabType.posts,
      FavoriteTabType.swapListings,
    ],
    this.onTabChanged,
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
        tabs: tabs
            .map((tabType) => Tab(
                  text: tabType.displayName,
                ))
            .toList(),
        onTap: onTabChanged,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        labelStyle: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
          insets: const EdgeInsets.symmetric(horizontal: 16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        labelPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
