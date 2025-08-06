import '../entities/search_result.dart';
import '../../presentation/controllers/search_controller.dart';

/// Abstract interface for search operations
abstract class SearchRepository {
  /// Search across all content types
  Future<SearchResults> search({
    required String query,
    SearchFilters? filters,
  });

  /// Get search suggestions based on partial input
  Future<List<String>> getSuggestions(String partial);

  /// Get trending search terms
  Future<List<String>> getTrendingSearches();

  /// Search specifically in clothing items
  Future<List<SearchResultItem>> searchItems({
    required String query,
    SearchFilters? filters,
  });

  /// Search specifically in outfits
  Future<List<SearchResultOutfit>> searchOutfits({
    required String query,
    SearchFilters? filters,
  });

  /// Search specifically in social posts
  Future<List<SearchResultPost>> searchPosts({
    required String query,
    SearchFilters? filters,
  });

  /// Search specifically in users
  Future<List<SearchResultUser>> searchUsers({
    required String query,
    SearchFilters? filters,
  });

  /// Search specifically in swap listings
  Future<List<SearchResultSwap>> searchSwaps({
    required String query,
    SearchFilters? filters,
  });

  /// Search specifically in style challenges
  Future<List<SearchResultChallenge>> searchChallenges({
    required String query,
    SearchFilters? filters,
  });
}
