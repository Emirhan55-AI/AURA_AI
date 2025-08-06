import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/search_result.dart';
import '../controllers/global_search_controller.dart';
import 'search_result_tiles.dart';

class SearchResultsTabView extends ConsumerWidget {
  const SearchResultsTabView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final searchState = ref.watch(globalSearchControllerProvider);
    final searchController = ref.watch(globalSearchControllerProvider.notifier);

    if (searchState.results == null) {
      return const SizedBox.shrink();
    }

    final results = searchState.results!;
    final tabs = _buildTabs(context, results);
    
    if (tabs.isEmpty) {
      return _buildNoResultsState(context);
    }

    return DefaultTabController(
      length: tabs.length,
      initialIndex: _getInitialTabIndex(searchState.selectedTab, tabs),
      child: Column(
        children: [
          // Tab bar
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
              indicatorColor: theme.colorScheme.primary,
              labelStyle: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              onTap: (index) {
                final tabType = tabs[index].type;
                searchController.selectTab(tabType);
              },
              tabs: tabs.map((tab) => Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(tab.icon, size: 16),
                    const SizedBox(width: 8),
                    Text('${tab.label} (${tab.count})'),
                  ],
                ),
              )).toList(),
            ),
          ),

          // Tab views
          Expanded(
            child: TabBarView(
              children: tabs.map((tab) => _buildTabContent(
                context,
                tab.type,
                _getResultsForType(results, tab.type),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  List<_TabInfo> _buildTabs(BuildContext context, SearchResults results) {
    final tabs = <_TabInfo>[];

    if (results.clothingResults.isNotEmpty) {
      tabs.add(_TabInfo(
        type: SearchResultType.clothing,
        label: 'Clothing',
        icon: Icons.checkroom,
        count: results.clothingResults.length,
      ));
    }

    if (results.combinationResults.isNotEmpty) {
      tabs.add(_TabInfo(
        type: SearchResultType.combination,
        label: 'Outfits',
        icon: Icons.style,
        count: results.combinationResults.length,
      ));
    }

    if (results.socialPostResults.isNotEmpty) {
      tabs.add(_TabInfo(
        type: SearchResultType.socialPost,
        label: 'Posts',
        icon: Icons.article,
        count: results.socialPostResults.length,
      ));
    }

    if (results.userResults.isNotEmpty) {
      tabs.add(_TabInfo(
        type: SearchResultType.user,
        label: 'People',
        icon: Icons.people,
        count: results.userResults.length,
      ));
    }

    if (results.swapListingResults.isNotEmpty) {
      tabs.add(_TabInfo(
        type: SearchResultType.swapListing,
        label: 'Swaps',
        icon: Icons.swap_horiz,
        count: results.swapListingResults.length,
      ));
    }

    return tabs;
  }

  int _getInitialTabIndex(SearchResultType selectedTab, List<_TabInfo> tabs) {
    final index = tabs.indexWhere((tab) => tab.type == selectedTab);
    return index >= 0 ? index : 0;
  }

  List<SearchResult> _getResultsForType(SearchResults results, SearchResultType type) {
    switch (type) {
      case SearchResultType.clothing:
        return results.clothingResults;
      case SearchResultType.combination:
        return results.combinationResults;
      case SearchResultType.socialPost:
        return results.socialPostResults;
      case SearchResultType.user:
        return results.userResults;
      case SearchResultType.swapListing:
        return results.swapListingResults;
    }
  }

  Widget _buildTabContent(BuildContext context, SearchResultType type, List<SearchResult> results) {
    if (results.isEmpty) {
      return _buildEmptyTabState(context, type);
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final result = results[index];
        return _buildResultTile(context, result);
      },
    );
  }

  Widget _buildResultTile(BuildContext context, SearchResult result) {
    switch (result.type) {
      case SearchResultType.clothing:
        return ClothingSearchResultTile(result: result);
      case SearchResultType.combination:
        return CombinationSearchResultTile(result: result);
      case SearchResultType.socialPost:
        return SocialPostSearchResultTile(result: result);
      case SearchResultType.user:
        return UserSearchResultTile(result: result);
      case SearchResultType.swapListing:
        return SwapListingSearchResultTile(result: result);
    }
  }

  Widget _buildEmptyTabState(BuildContext context, SearchResultType type) {
    final theme = Theme.of(context);
    final typeInfo = _getTypeInfo(type);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              typeInfo.icon,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'No ${typeInfo.label} Found',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search terms or browse other categories.',
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

  Widget _buildNoResultsState(BuildContext context) {
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
              'No Results Found',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try different keywords or check your spelling.',
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

  _TabInfo _getTypeInfo(SearchResultType type) {
    switch (type) {
      case SearchResultType.clothing:
        return _TabInfo(type: type, label: 'Clothing', icon: Icons.checkroom, count: 0);
      case SearchResultType.combination:
        return _TabInfo(type: type, label: 'Outfits', icon: Icons.style, count: 0);
      case SearchResultType.socialPost:
        return _TabInfo(type: type, label: 'Posts', icon: Icons.article, count: 0);
      case SearchResultType.user:
        return _TabInfo(type: type, label: 'People', icon: Icons.people, count: 0);
      case SearchResultType.swapListing:
        return _TabInfo(type: type, label: 'Swaps', icon: Icons.swap_horiz, count: 0);
    }
  }
}

class _TabInfo {
  final SearchResultType type;
  final String label;
  final IconData icon;
  final int count;

  const _TabInfo({
    required this.type,
    required this.label,
    required this.icon,
    required this.count,
  });
}
