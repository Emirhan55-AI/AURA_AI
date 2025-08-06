import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/search_result.dart';
import '../../domain/repositories/search_repository.dart';
import '../../data/repositories/mock_search_repository.dart';

// Provider for the search repository
final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return MockSearchRepository();
});

// State class for search
class GlobalSearchState {
  final String searchTerm;
  final bool isLoading;
  final String? error;
  final SearchResults? results;
  final List<RecentSearch> recentSearches;
  final List<String> trendingSearches;
  final SearchResultType selectedTab;

  const GlobalSearchState({
    this.searchTerm = '',
    this.isLoading = false,
    this.error,
    this.results,
    this.recentSearches = const [],
    this.trendingSearches = const [],
    this.selectedTab = SearchResultType.clothing,
  });

  GlobalSearchState copyWith({
    String? searchTerm,
    bool? isLoading,
    String? error,
    SearchResults? results,
    List<RecentSearch>? recentSearches,
    List<String>? trendingSearches,
    SearchResultType? selectedTab,
  }) {
    return GlobalSearchState(
      searchTerm: searchTerm ?? this.searchTerm,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      results: results ?? this.results,
      recentSearches: recentSearches ?? this.recentSearches,
      trendingSearches: trendingSearches ?? this.trendingSearches,
      selectedTab: selectedTab ?? this.selectedTab,
    );
  }
}

// Main search controller
class GlobalSearchController extends StateNotifier<GlobalSearchState> {
  final SearchRepository _repository;
  Timer? _debounceTimer;
  static const _debounceDelay = Duration(milliseconds: 500);

  GlobalSearchController(this._repository) : super(const GlobalSearchState()) {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final recentSearches = await _repository.getRecentSearches();
      final trendingSearches = await _repository.getTrendingSearches();

      state = state.copyWith(
        recentSearches: recentSearches,
        trendingSearches: trendingSearches,
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to load initial data: $e');
    }
  }

  void updateSearchTerm(String term) {
    state = state.copyWith(searchTerm: term, error: null);
    
    // Cancel previous timer
    _debounceTimer?.cancel();
    
    if (term.trim().isEmpty) {
      state = state.copyWith(results: null);
      return;
    }

    // Start new debounce timer
    _debounceTimer = Timer(_debounceDelay, () {
      search(term);
    });
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final results = await _repository.searchAll(query: query.trim());
      
      state = state.copyWith(
        isLoading: false,
        results: results,
        searchTerm: query.trim(),
      );

      // Refresh recent searches
      await _refreshRecentSearches();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Search failed: $e',
      );
    }
  }

  Future<void> searchInCategory(SearchResultType category, String query) async {
    if (query.trim().isEmpty) return;

    state = state.copyWith(isLoading: true, error: null, selectedTab: category);

    try {
      final categoryResults = await _repository.searchByCategory(
        query: query.trim(),
        category: category,
      );
      
      // Update only the specific category in results
      if (state.results != null) {
        SearchResults updatedResults;
        switch (category) {
          case SearchResultType.clothing:
            updatedResults = state.results!.copyWith(clothingResults: categoryResults);
            break;
          case SearchResultType.combination:
            updatedResults = state.results!.copyWith(combinationResults: categoryResults);
            break;
          case SearchResultType.socialPost:
            updatedResults = state.results!.copyWith(socialPostResults: categoryResults);
            break;
          case SearchResultType.user:
            updatedResults = state.results!.copyWith(userResults: categoryResults);
            break;
          case SearchResultType.swapListing:
            updatedResults = state.results!.copyWith(swapListingResults: categoryResults);
            break;
        }
        
        state = state.copyWith(
          isLoading: false,
          results: updatedResults,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Category search failed: $e',
      );
    }
  }

  void selectTab(SearchResultType tab) {
    state = state.copyWith(selectedTab: tab);
  }

  Future<void> selectRecentSearch(String query) async {
    state = state.copyWith(searchTerm: query);
    await search(query);
  }

  void clearSearch() {
    _debounceTimer?.cancel();
    state = state.copyWith(
      searchTerm: '',
      results: null,
      error: null,
      isLoading: false,
    );
  }

  Future<void> clearSearchHistory() async {
    try {
      await _repository.clearSearchHistory();
      state = state.copyWith(recentSearches: []);
    } catch (e) {
      state = state.copyWith(error: 'Failed to clear search history: $e');
    }
  }

  Future<void> _refreshRecentSearches() async {
    try {
      final recentSearches = await _repository.getRecentSearches();
      state = state.copyWith(recentSearches: recentSearches);
    } catch (e) {
      // Silently fail for recent searches refresh
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

// Provider for the search controller
final globalSearchControllerProvider = StateNotifierProvider<GlobalSearchController, GlobalSearchState>((ref) {
  final repository = ref.watch(searchRepositoryProvider);
  return GlobalSearchController(repository);
});

// Helper providers for specific data
final searchResultsCountProvider = Provider.family<int, SearchResultType>((ref, type) {
  final results = ref.watch(globalSearchControllerProvider).results;
  if (results == null) return 0;

  switch (type) {
    case SearchResultType.clothing:
      return results.clothingResults.length;
    case SearchResultType.combination:
      return results.combinationResults.length;
    case SearchResultType.socialPost:
      return results.socialPostResults.length;
    case SearchResultType.user:
      return results.userResults.length;
    case SearchResultType.swapListing:
      return results.swapListingResults.length;
  }
});

final searchResultsByTypeProvider = Provider.family<List<SearchResult>, SearchResultType>((ref, type) {
  final results = ref.watch(globalSearchControllerProvider).results;
  if (results == null) return [];

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
});
