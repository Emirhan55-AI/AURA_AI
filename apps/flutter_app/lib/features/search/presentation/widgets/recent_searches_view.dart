import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/search_result.dart';
import '../controllers/global_search_controller.dart';

class RecentSearchesView extends ConsumerWidget {
  final VoidCallback? onSearchSelected;

  const RecentSearchesView({
    super.key,
    this.onSearchSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final searchState = ref.watch(globalSearchControllerProvider);
    final searchController = ref.watch(globalSearchControllerProvider.notifier);

    if (searchState.recentSearches.isEmpty && searchState.trendingSearches.isEmpty) {
      return _buildEmptyState(context);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent searches section
          if (searchState.recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Searches',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    searchController.clearSearchHistory();
                  },
                  child: Text(
                    'Clear All',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...searchState.recentSearches.map(
              (search) => _buildRecentSearchTile(
                context,
                search,
                () {
                  searchController.selectRecentSearch(search.query);
                  onSearchSelected?.call();
                },
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Trending searches section
          if (searchState.trendingSearches.isNotEmpty) ...[
            Text(
              'Trending Searches',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: searchState.trendingSearches.map(
                (trendingSearch) => _buildTrendingChip(
                  context,
                  trendingSearch,
                  () {
                    searchController.selectRecentSearch(trendingSearch);
                    onSearchSelected?.call();
                  },
                ),
              ).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'No Search History',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start searching to see your recent searches and trending topics here.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearchTile(
    BuildContext context,
    RecentSearch search,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    
    return ListTile(
      leading: Icon(
        Icons.history,
        color: theme.colorScheme.onSurfaceVariant,
        size: 20,
      ),
      title: Text(
        search.query,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
      ),
      subtitle: search.resultCount > 0
          ? Text(
              '${search.resultCount} result${search.resultCount == 1 ? '' : 's'}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      trailing: Icon(
        Icons.north_west,
        color: theme.colorScheme.onSurfaceVariant,
        size: 16,
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }

  Widget _buildTrendingChip(
    BuildContext context,
    String trendingSearch,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    
    return ActionChip(
      label: Text(trendingSearch),
      onPressed: onTap,
      avatar: Icon(
        Icons.trending_up,
        size: 16,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      labelStyle: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurface,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
    );
  }
}
