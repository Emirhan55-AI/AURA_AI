import 'package:flutter/material.dart';

/// Profile Tab Bar View Widget - Displays content for each profile tab
/// 
/// Shows different content based on selected tab:
/// - My Combinations: Grid of outfit combinations
/// - My Favorites: Grid of favorite items
/// - My Likes: List of liked posts
/// - Social Shares: Grid of shared content
/// - Communities: List of joined communities
/// - Swap History: List of clothing swaps
class ProfileTabBarView extends StatelessWidget {
  final TabController tabController;
  final List<String> tabs;

  const ProfileTabBarView({
    super.key,
    required this.tabController,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: tabController,
      children: tabs.map((tab) => _buildTabContent(context, tab)).toList(),
    );
  }

  /// Builds content for each tab
  Widget _buildTabContent(BuildContext context, String tabName) {
    switch (tabName) {
      case 'My Combinations':
        return _buildCombinationsTab(context);
      case 'My Favorites':
        return _buildFavoritesTab(context);
      case 'My Likes':
        return _buildLikesTab(context);
      case 'Social Shares':
        return _buildSocialSharesTab(context);
      case 'Communities':
        return _buildCommunitiesTab(context);
      case 'Swap History':
        return _buildSwapHistoryTab(context);
      default:
        return _buildPlaceholderTab(context, tabName);
    }
  }

  /// Builds combinations tab with grid layout
  Widget _buildCombinationsTab(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _buildGridContent(
      context,
      'Your Style Combinations',
      'Create and share your outfit combinations',
      Icons.checkroom_outlined,
      colorScheme.primary,
      _generateMockCombinations(),
    );
  }

  /// Builds favorites tab with grid layout
  Widget _buildFavoritesTab(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _buildGridContent(
      context,
      'Your Favorite Items',
      'Items you\'ve saved for later',
      Icons.favorite_outline,
      colorScheme.error,
      _generateMockFavorites(),
    );
  }

  /// Builds likes tab with list layout
  Widget _buildLikesTab(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _buildListContent(
      context,
      'Posts You\'ve Liked',
      'Style posts that caught your eye',
      Icons.thumb_up_outlined,
      colorScheme.secondary,
      _generateMockLikes(),
    );
  }

  /// Builds social shares tab with grid layout
  Widget _buildSocialSharesTab(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _buildGridContent(
      context,
      'Your Shared Content',
      'Style content you\'ve shared with the community',
      Icons.share_outlined,
      colorScheme.tertiary,
      _generateMockShares(),
    );
  }

  /// Builds communities tab with list layout
  Widget _buildCommunitiesTab(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _buildListContent(
      context,
      'Your Communities',
      'Style communities you\'re part of',
      Icons.groups_outlined,
      colorScheme.primary,
      _generateMockCommunities(),
    );
  }

  /// Builds swap history tab with list layout
  Widget _buildSwapHistoryTab(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _buildListContent(
      context,
      'Swap History',
      'Your clothing exchange history',
      Icons.swap_horiz_outlined,
      colorScheme.secondary,
      _generateMockSwaps(),
    );
  }

  /// Builds generic grid content layout
  Widget _buildGridContent(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    List<String> items,
  ) {
    if (items.isEmpty) {
      return _buildEmptyState(context, title, subtitle, icon, iconColor);
    }

    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: _buildSectionHeader(context, title, subtitle, icon, iconColor),
        ),

        // Grid content
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildGridItem(context, items[index]),
              childCount: items.length,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds generic list content layout
  Widget _buildListContent(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    List<String> items,
  ) {
    if (items.isEmpty) {
      return _buildEmptyState(context, title, subtitle, icon, iconColor);
    }

    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: _buildSectionHeader(context, title, subtitle, icon, iconColor),
        ),

        // List content
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildListItem(context, items[index]),
              childCount: items.length,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds section header
  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds grid item card
  Widget _buildGridItem(BuildContext context, String title) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Icon(
                  Icons.image_outlined,
                  size: 48,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),

            // Content
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds list item card
  Widget _buildListItem(BuildContext context, String title) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.image_outlined,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          'Description for $title',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  /// Builds empty state
  Widget _buildEmptyState(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                size: 40,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Nothing here yet',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start building your style profile!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds placeholder tab for unhandled tabs
  Widget _buildPlaceholderTab(BuildContext context, String tabName) {
    return _buildEmptyState(
      context,
      tabName,
      'Content coming soon',
      Icons.construction_outlined,
      Theme.of(context).colorScheme.primary,
    );
  }

  // Mock data generators
  List<String> _generateMockCombinations() {
    return ['Summer Casual', 'Office Chic', 'Date Night', 'Weekend Vibes'];
  }

  List<String> _generateMockFavorites() {
    return ['Denim Jacket', 'White Sneakers', 'Floral Dress', 'Black Jeans'];
  }

  List<String> _generateMockLikes() {
    return ['Style Inspiration #1', 'Outfit of the Day #2', 'Fashion Tip #3'];
  }

  List<String> _generateMockShares() {
    return ['My OOTD', 'Style Challenge', 'Weekend Look'];
  }

  List<String> _generateMockCommunities() {
    return ['Sustainable Fashion', 'Vintage Lovers', 'Minimalist Style'];
  }

  List<String> _generateMockSwaps() {
    return ['Swapped with @alice', 'Swapped with @bob', 'Swapped with @carol'];
  }
}
