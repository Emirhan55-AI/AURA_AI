import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/search_controller.dart';
import '../widgets/search_widgets.dart';
import '../widgets/search_result_cards.dart';
import '../../domain/entities/search_result.dart';

/// Global Search Screen
/// 
/// Provides comprehensive search functionality across all app content:
/// - Clothing items, outfits, social posts, users, swap listings, challenges
/// - Real-time search with debouncing
/// - Search filters and sorting
/// - Recent searches and trending searches
class SearchScreen extends ConsumerStatefulWidget {
  final String? initialQuery;

  const SearchScreen({
    super.key,
    this.initialQuery,
  });

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(searchControllerProvider.notifier).search(widget.initialQuery!);
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchControllerProvider);
    final recentSearches = ref.watch(recentSearchesProvider);

    return Scaffold(
      appBar: AppBar(
        title: SearchInput(
          hint: 'Search items, outfits, people...',
          initialValue: _searchController.text,
          onChanged: (query) {
            ref.read(searchControllerProvider.notifier).updateQuery(query);
          },
          onClear: () {
            ref.read(searchControllerProvider.notifier).clearSearch();
          },
          autofocus: widget.initialQuery == null,
        ),
        bottom: searchState.query.isNotEmpty
            ? TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: [
                  Tab(text: 'All (${searchState.totalResults})'),
                  Tab(text: 'Items (${searchState.itemResults.length})'),
                  Tab(text: 'Outfits (${searchState.outfitResults.length})'),
                  Tab(text: 'Posts (${searchState.postResults.length})'),
                  Tab(text: 'People (${searchState.userResults.length})'),
                  Tab(text: 'Swap (${searchState.swapResults.length})'),
                ],
              )
            : null,
      ),
      body: searchState.query.isEmpty
          ? _buildEmptySearchState(context, recentSearches)
          : _buildSearchResults(context, searchState),
    );
  }

  Widget _buildEmptySearchState(BuildContext context, List<String> recentSearches) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent searches
          if (recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Searches',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ref.read(recentSearchesProvider.notifier).clearAll();
                  },
                  child: const Text('Clear All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...recentSearches.map((search) {
              return SearchSuggestionItem(
                text: search,
                icon: Icons.history,
                showRemoveButton: true,
                onTap: () {
                  _searchController.text = search;
                  ref.read(searchControllerProvider.notifier).updateQuery(search);
                },
                onRemove: () {
                  ref.read(recentSearchesProvider.notifier).removeSearch(search);
                },
              );
            }),
            const SizedBox(height: 24),
          ],

          // Trending searches
          Consumer(
            builder: (context, ref, child) {
              final trending = ref.watch(trendingSearchesProvider);
              
              return trending.when(
                data: (searches) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trending Searches',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...searches.map((search) {
                      return SearchSuggestionItem(
                        text: search,
                        icon: Icons.trending_up,
                        onTap: () {
                          _searchController.text = search;
                          ref.read(searchControllerProvider.notifier).updateQuery(search);
                        },
                      );
                    }),
                  ],
                ),
                loading: () => const SearchLoadingWidget(
                  message: 'Loading trending searches...',
                ),
                error: (error, stack) => const EmptySearchState(
                  title: 'Failed to load trends',
                  subtitle: 'Check your connection and try again',
                  icon: Icons.trending_down,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context, SearchState searchState) {
    if (searchState.isLoading) {
      return const SearchLoadingWidget(
        message: 'Searching...',
      );
    }

    if (searchState.hasError) {
      return EmptySearchState(
        title: 'Search Error',
        subtitle: searchState.error,
        icon: Icons.error_outline,
      );
    }

    if (searchState.totalResults == 0) {
      return const EmptySearchState(
        title: 'No results found',
        subtitle: 'Try different keywords or check spelling',
        icon: Icons.search_off,
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildAllResultsTab(searchState),
        _buildItemsTab(searchState.itemResults),
        _buildOutfitsTab(searchState.outfitResults),
        _buildPostsTab(searchState.postResults),
        _buildUsersTab(searchState.userResults),
        _buildSwapTab(searchState.swapResults),
      ],
    );
  }

  Widget _buildAllResultsTab(SearchState searchState) {
    final allResults = <Widget>[];

    // Add section headers and results
    if (searchState.itemResults.isNotEmpty) {
      allResults.add(_buildSectionHeader('Clothing Items', searchState.itemResults.length));
      allResults.addAll(
        searchState.itemResults.take(3).map((item) {
          return ItemResultCard(
            item: item,
            onTap: () => _navigateToItem(item.id),
          );
        }),
      );
      if (searchState.itemResults.length > 3) {
        allResults.add(_buildViewMoreButton('items'));
      }
    }

    if (searchState.outfitResults.isNotEmpty) {
      allResults.add(_buildSectionHeader('Outfits', searchState.outfitResults.length));
      allResults.addAll(
        searchState.outfitResults.take(3).map((outfit) {
          return OutfitResultCard(
            outfit: outfit,
            onTap: () => _navigateToOutfit(outfit.id),
          );
        }),
      );
      if (searchState.outfitResults.length > 3) {
        allResults.add(_buildViewMoreButton('outfits'));
      }
    }

    if (searchState.userResults.isNotEmpty) {
      allResults.add(_buildSectionHeader('People', searchState.userResults.length));
      allResults.addAll(
        searchState.userResults.take(3).map((user) {
          return UserResultCard(
            user: user,
            onTap: () => _navigateToProfile(user.id),
            onFollow: () => _toggleFollow(user.id),
          );
        }),
      );
      if (searchState.userResults.length > 3) {
        allResults.add(_buildViewMoreButton('people'));
      }
    }

    return ListView(
      children: allResults,
    );
  }

  Widget _buildItemsTab(List<SearchResultItem> items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return ItemResultCard(
          item: items[index],
          onTap: () => _navigateToItem(items[index].id),
        );
      },
    );
  }

  Widget _buildOutfitsTab(List<SearchResultOutfit> outfits) {
    return ListView.builder(
      itemCount: outfits.length,
      itemBuilder: (context, index) {
        return OutfitResultCard(
          outfit: outfits[index],
          onTap: () => _navigateToOutfit(outfits[index].id),
        );
      },
    );
  }

  Widget _buildPostsTab(List<SearchResultPost> posts) {
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return PostResultCard(
          post: posts[index],
          onTap: () => _navigateToPost(posts[index].id),
        );
      },
    );
  }

  Widget _buildUsersTab(List<SearchResultUser> users) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        return UserResultCard(
          user: users[index],
          onTap: () => _navigateToProfile(users[index].id),
          onFollow: () => _toggleFollow(users[index].id),
        );
      },
    );
  }

  Widget _buildSwapTab(List<SearchResultSwap> swaps) {
    return ListView.builder(
      itemCount: swaps.length,
      itemBuilder: (context, index) {
        final swap = swaps[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: swap.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        swap.imageUrl!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(Icons.swap_horiz),
            ),
            title: Text(swap.title),
            subtitle: Text('${swap.userName} • ${swap.location}'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: swap.status == 'active' ? Colors.green[100] : Colors.orange[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                swap.status.toUpperCase(),
                style: TextStyle(
                  color: swap.status == 'active' ? Colors.green[700] : Colors.orange[700],
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            onTap: () => _navigateToSwap(swap.id),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        '$title ($count)',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildViewMoreButton(String category) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextButton(
        onPressed: () {
          // Switch to specific tab
          switch (category) {
            case 'items':
              _tabController.animateTo(1);
              break;
            case 'outfits':
              _tabController.animateTo(2);
              break;
            case 'people':
              _tabController.animateTo(4);
              break;
          }
        },
        child: Text('View all $category'),
      ),
    );
  }

  // Navigation methods
  void _navigateToItem(String itemId) {
    // TODO: Navigate to item detail
    debugPrint('Navigate to item: $itemId');
  }

  void _navigateToOutfit(String outfitId) {
    // TODO: Navigate to outfit detail
    debugPrint('Navigate to outfit: $outfitId');
  }

  void _navigateToPost(String postId) {
    // TODO: Navigate to post detail
    debugPrint('Navigate to post: $postId');
  }

  void _navigateToProfile(String userId) {
    // TODO: Navigate to user profile
    debugPrint('Navigate to profile: $userId');
  }

  void _navigateToSwap(String swapId) {
    // TODO: Navigate to swap detail
    debugPrint('Navigate to swap: $swapId');
  }

  void _toggleFollow(String userId) {
    // TODO: Implement follow/unfollow
    debugPrint('Toggle follow for user: $userId');
  }
}
