import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/global_search_controller.dart';
import '../widgets/global_search_bar.dart';
import '../widgets/recent_searches_view.dart';
import '../widgets/search_results_tab_view.dart';

class GlobalSearchScreen extends ConsumerStatefulWidget {
  final String? initialQuery;

  const GlobalSearchScreen({
    super.key,
    this.initialQuery,
  });

  @override
  ConsumerState<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends ConsumerState<GlobalSearchScreen> {
  @override
  void initState() {
    super.initState();
    
    // If there's an initial query, perform the search
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(globalSearchControllerProvider.notifier).search(widget.initialQuery!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final searchState = ref.watch(globalSearchControllerProvider);
    final searchController = ref.watch(globalSearchControllerProvider.notifier);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
        ),
        title: Text(
          'Search',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        actions: [
          if (searchState.searchTerm.isNotEmpty)
            IconButton(
              onPressed: () {
                searchController.clearSearch();
              },
              icon: const Icon(Icons.clear_all),
              tooltip: 'Clear search',
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: GlobalSearchBar(
              hintText: 'Search clothing, outfits, users...',
              autofocus: widget.initialQuery == null,
              onClear: () {
                // Additional clear action if needed
              },
            ),
          ),

          // Error display
          if (searchState.error != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: theme.colorScheme.onErrorContainer,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      searchState.error!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (searchState.searchTerm.isNotEmpty) {
                        searchController.search(searchState.searchTerm);
                      }
                    },
                    child: Text(
                      'Retry',
                      style: TextStyle(
                        color: theme.colorScheme.onErrorContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Main content
          Expanded(
            child: _buildMainContent(context, searchState),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, GlobalSearchState searchState) {
    // Show loading state
    if (searchState.isLoading && searchState.results == null) {
      return _buildLoadingState(context);
    }

    // Show search results if available
    if (searchState.results != null) {
      return const SearchResultsTabView();
    }

    // Show recent searches and trending topics
    return RecentSearchesView(
      onSearchSelected: () {
        // Optional callback when a search is selected
      },
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Searching...',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// Helper widget for search suggestions
class SearchSuggestion extends StatelessWidget {
  final String suggestion;
  final VoidCallback onTap;

  const SearchSuggestion({
    super.key,
    required this.suggestion,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ListTile(
      leading: Icon(
        Icons.search,
        color: theme.colorScheme.onSurfaceVariant,
        size: 20,
      ),
      title: Text(
        suggestion,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
      ),
      trailing: Icon(
        Icons.north_west,
        color: theme.colorScheme.onSurfaceVariant,
        size: 16,
      ),
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
