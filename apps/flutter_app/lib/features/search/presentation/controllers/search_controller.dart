import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/utils/debouncer.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/repositories/search_repository.dart';
import '../../data/providers/search_providers.dart';

part 'search_controller.g.dart';

/// Search Controller - Manages global search functionality
/// 
/// Handles:
/// - Multi-category search (items, outfits, posts, users, swap listings)
/// - Search query debouncing
/// - Search filters and sorting
/// - Search history management
/// - Trending searches
@riverpod
class SearchController extends _$SearchController {
  late final Debouncer _debouncer;

  @override
  SearchState build() {
    _debouncer = Debouncer(milliseconds: 500);
    return const SearchState();
  }

  /// Update search query with debouncing
  void updateQuery(String query) {
    state = state.copyWith(query: query);
    
    if (query.trim().isEmpty) {
      clearSearch();
      return;
    }

    _debouncer.run(() {
      if (query.trim().isNotEmpty) {
        search(query.trim());
      }
    });
  }

  /// Perform search across all categories
  Future<void> search(String query) async {
    if (query.trim().isEmpty) return;

    state = state.copyWith(
      query: query,
      isLoading: true,
      hasError: false,
      error: '',
    );

    try {
      final repository = ref.read(searchRepositoryProvider);
      final results = await repository.search(
        query: query,
        filters: state.filters,
      );

      state = state.copyWith(
        isLoading: false,
        itemResults: results.items,
        outfitResults: results.outfits,
        postResults: results.posts,
        userResults: results.users,
        swapResults: results.swaps,
        challengeResults: results.challenges,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        error: error.toString(),
      );
    }
  }

  /// Update search filters
  void updateFilters(SearchFilters filters) {
    state = state.copyWith(filters: filters);
  }

  /// Clear search results and query
  void clearSearch() {
    state = const SearchState();
  }

  /// Get search suggestions based on partial query
  Future<List<String>> getSuggestions(String partial) async {
    if (partial.length < 2) return [];

    try {
      final repository = ref.read(searchRepositoryProvider);
      return await repository.getSuggestions(partial);
    } catch (error) {
      return [];
    }
  }
}

/// Recent Searches Provider
@riverpod
class RecentSearches extends _$RecentSearches {
  @override
  List<String> build() {
    // In real implementation, load from local storage
    return [
      'summer dresses',
      'casual outfits',
      'formal wear',
      'trending styles',
    ];
  }

  /// Add a new search to recent searches
  void addSearch(String query) {
    final searches = List<String>.from(state);
    searches.removeWhere((search) => search.toLowerCase() == query.toLowerCase());
    searches.insert(0, query);
    
    // Keep only last 10 searches
    if (searches.length > 10) {
      searches.removeRange(10, searches.length);
    }
    
    state = searches;
    // TODO: Save to local storage
  }

  /// Clear all recent searches
  void clearAll() {
    state = [];
    // TODO: Clear from local storage
  }

  /// Remove specific search
  void removeSearch(String query) {
    state = state.where((search) => search != query).toList();
    // TODO: Update local storage
  }
}

/// Trending Searches Provider
@riverpod
Future<List<String>> trendingSearches(TrendingSearchesRef ref) async {
  // In real implementation, fetch from API
  await Future<void>.delayed(const Duration(milliseconds: 500));
  
  return [
    'vintage style',
    'minimalist fashion',
    'boho chic',
    'streetwear',
    'sustainable fashion',
    'color blocking',
    'layering techniques',
    'accessory trends',
  ];
}

/// Search State Model
class SearchState {
  final String query;
  final bool isLoading;
  final bool hasError;
  final String error;
  final SearchFilters filters;
  final List<SearchResultItem> itemResults;
  final List<SearchResultOutfit> outfitResults;
  final List<SearchResultPost> postResults;
  final List<SearchResultUser> userResults;
  final List<SearchResultSwap> swapResults;
  final List<SearchResultChallenge> challengeResults;

  const SearchState({
    this.query = '',
    this.isLoading = false,
    this.hasError = false,
    this.error = '',
    this.filters = const SearchFilters(),
    this.itemResults = const [],
    this.outfitResults = const [],
    this.postResults = const [],
    this.userResults = const [],
    this.swapResults = const [],
    this.challengeResults = const [],
  });

  int get totalResults =>
      itemResults.length +
      outfitResults.length +
      postResults.length +
      userResults.length +
      swapResults.length +
      challengeResults.length;

  SearchState copyWith({
    String? query,
    bool? isLoading,
    bool? hasError,
    String? error,
    SearchFilters? filters,
    List<SearchResultItem>? itemResults,
    List<SearchResultOutfit>? outfitResults,
    List<SearchResultPost>? postResults,
    List<SearchResultUser>? userResults,
    List<SearchResultSwap>? swapResults,
    List<SearchResultChallenge>? challengeResults,
  }) {
    return SearchState(
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      error: error ?? this.error,
      filters: filters ?? this.filters,
      itemResults: itemResults ?? this.itemResults,
      outfitResults: outfitResults ?? this.outfitResults,
      postResults: postResults ?? this.postResults,
      userResults: userResults ?? this.userResults,
      swapResults: swapResults ?? this.swapResults,
      challengeResults: challengeResults ?? this.challengeResults,
    );
  }
}

/// Search Filters Model
class SearchFilters {
  final List<String> categories;
  final List<String> colors;
  final List<String> brands;
  final List<String> sizes;
  final DateTimeRange? dateRange;
  final PriceRange? priceRange;
  final String sortBy;
  final String sortOrder;

  const SearchFilters({
    this.categories = const [],
    this.colors = const [],
    this.brands = const [],
    this.sizes = const [],
    this.dateRange,
    this.priceRange,
    this.sortBy = 'relevance',
    this.sortOrder = 'desc',
  });

  SearchFilters copyWith({
    List<String>? categories,
    List<String>? colors,
    List<String>? brands,
    List<String>? sizes,
    DateTimeRange? dateRange,
    PriceRange? priceRange,
    String? sortBy,
    String? sortOrder,
  }) {
    return SearchFilters(
      categories: categories ?? this.categories,
      colors: colors ?? this.colors,
      brands: brands ?? this.brands,
      sizes: sizes ?? this.sizes,
      dateRange: dateRange ?? this.dateRange,
      priceRange: priceRange ?? this.priceRange,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  bool get hasActiveFilters =>
      categories.isNotEmpty ||
      colors.isNotEmpty ||
      brands.isNotEmpty ||
      sizes.isNotEmpty ||
      dateRange != null ||
      priceRange != null;
}

class PriceRange {
  final double min;
  final double max;

  const PriceRange({
    required this.min,
    required this.max,
  });
}
