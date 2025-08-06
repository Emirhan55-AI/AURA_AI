import 'dart:async';
import 'dart:math';

import '../../domain/models/search_result.dart';
import '../../domain/repositories/search_repository.dart';

class MockSearchRepository implements SearchRepository {
  final List<RecentSearch> _recentSearches = [];
  final Random _random = Random();

  // Mock data for different categories
  static const List<Map<String, dynamic>> _mockClothingItems = [
    {
      'id': 'c1',
      'title': 'Classic Blue Denim Jacket',
      'description': 'Vintage style denim jacket perfect for casual wear',
      'imageUrl': 'https://example.com/jacket1.jpg',
      'metadata': {'category': 'Jackets', 'color': 'Blue', 'brand': 'Vintage'}
    },
    {
      'id': 'c2', 
      'title': 'White Cotton T-Shirt',
      'description': 'Basic white cotton t-shirt for everyday comfort',
      'imageUrl': 'https://example.com/tshirt1.jpg',
      'metadata': {'category': 'Tops', 'color': 'White', 'brand': 'Basic'}
    },
    {
      'id': 'c3',
      'title': 'Black Leather Boots',
      'description': 'Stylish leather boots for any occasion',
      'imageUrl': 'https://example.com/boots1.jpg',
      'metadata': {'category': 'Shoes', 'color': 'Black', 'brand': 'Fashion'}
    },
    {
      'id': 'c4',
      'title': 'Red Summer Dress',
      'description': 'Flowy red dress perfect for summer occasions',
      'imageUrl': 'https://example.com/dress1.jpg',
      'metadata': {'category': 'Dresses', 'color': 'Red', 'brand': 'Summer'}
    },
    {
      'id': 'c5',
      'title': 'Dark Blue Jeans',
      'description': 'Comfortable dark blue denim jeans',
      'imageUrl': 'https://example.com/jeans1.jpg',
      'metadata': {'category': 'Bottoms', 'color': 'Blue', 'brand': 'Denim'}
    },
  ];

  static const List<Map<String, dynamic>> _mockCombinations = [
    {
      'id': 'o1',
      'title': 'Casual Friday Look',
      'description': 'Perfect combination for casual work days',
      'imageUrl': 'https://example.com/outfit1.jpg',
      'metadata': {'style': 'Casual', 'occasion': 'Work', 'season': 'All'}
    },
    {
      'id': 'o2',
      'title': 'Weekend Brunch Outfit',
      'description': 'Relaxed yet stylish look for weekend outings',
      'imageUrl': 'https://example.com/outfit2.jpg',
      'metadata': {'style': 'Relaxed', 'occasion': 'Casual', 'season': 'Spring'}
    },
    {
      'id': 'o3',
      'title': 'Date Night Ensemble',
      'description': 'Elegant and romantic outfit for special evenings',
      'imageUrl': 'https://example.com/outfit3.jpg',
      'metadata': {'style': 'Elegant', 'occasion': 'Date', 'season': 'All'}
    },
  ];

  static const List<Map<String, dynamic>> _mockSocialPosts = [
    {
      'id': 'p1',
      'title': 'Spring Style Inspiration',
      'description': 'Check out my latest spring look with florals!',
      'imageUrl': 'https://example.com/post1.jpg',
      'metadata': {'author': 'StyleGuru123', 'likes': 142, 'comments': 23}
    },
    {
      'id': 'p2',
      'title': 'Sustainable Fashion Tips',
      'description': 'How to build a sustainable wardrobe on a budget',
      'imageUrl': 'https://example.com/post2.jpg',
      'metadata': {'author': 'EcoFashionista', 'likes': 89, 'comments': 15}
    },
    {
      'id': 'p3',
      'title': 'Color Coordination Masterclass',
      'description': 'Learn the art of perfect color matching',
      'imageUrl': 'https://example.com/post3.jpg',
      'metadata': {'author': 'ColorExpert', 'likes': 203, 'comments': 45}
    },
  ];

  static const List<Map<String, dynamic>> _mockUsers = [
    {
      'id': 'u1',
      'title': 'Sarah Johnson',
      'description': 'Fashion enthusiast | Style blogger | Vintage lover',
      'imageUrl': 'https://example.com/user1.jpg',
      'metadata': {'followers': 1250, 'following': 340, 'posts': 89}
    },
    {
      'id': 'u2',
      'title': 'Mike Chen',
      'description': 'Minimalist fashion | Sustainable living advocate',
      'imageUrl': 'https://example.com/user2.jpg',
      'metadata': {'followers': 892, 'following': 156, 'posts': 67}
    },
    {
      'id': 'u3',
      'title': 'Emma Wilson',
      'description': 'Vintage collector | Thrift store finder | Style inspiration',
      'imageUrl': 'https://example.com/user3.jpg',
      'metadata': {'followers': 2180, 'following': 423, 'posts': 156}
    },
  ];

  static const List<Map<String, dynamic>> _mockSwapListings = [
    {
      'id': 's1',
      'title': 'Designer Handbag for Shoes',
      'description': 'Trading luxury handbag for designer heels',
      'imageUrl': 'https://example.com/swap1.jpg',
      'metadata': {'type': 'Trade', 'value': '\$200', 'condition': 'Excellent'}
    },
    {
      'id': 's2',
      'title': 'Winter Coat Collection',
      'description': 'Multiple winter coats available for trade',
      'imageUrl': 'https://example.com/swap2.jpg',
      'metadata': {'type': 'Trade', 'value': '\$150', 'condition': 'Good'}
    },
    {
      'id': 's3',
      'title': 'Vintage Denim Jacket',
      'description': 'Authentic vintage denim, looking for accessories',
      'imageUrl': 'https://example.com/swap3.jpg',
      'metadata': {'type': 'Trade', 'value': '\$80', 'condition': 'Very Good'}
    },
  ];

  static const List<String> _trendingSearches = [
    'summer dress',
    'vintage jacket',
    'sustainable fashion',
    'color coordination',
    'casual outfit',
    'formal wear',
    'denim trends',
    'minimalist style',
    'boho chic',
    'street style',
  ];

  @override
  Future<SearchResults> searchAll({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(500)));

    if (query.isEmpty) {
      return SearchResults.empty();
    }

    // Save search to history
    await saveSearch(query, 0);

    final lowercaseQuery = query.toLowerCase();

    // Filter results from each category
    final clothingResults = _filterMockData(_mockClothingItems, lowercaseQuery, SearchResultType.clothing);
    final combinationResults = _filterMockData(_mockCombinations, lowercaseQuery, SearchResultType.combination);
    final socialPostResults = _filterMockData(_mockSocialPosts, lowercaseQuery, SearchResultType.socialPost);
    final userResults = _filterMockData(_mockUsers, lowercaseQuery, SearchResultType.user);
    final swapListingResults = _filterMockData(_mockSwapListings, lowercaseQuery, SearchResultType.swapListing);

    final totalResults = clothingResults.length + 
                        combinationResults.length + 
                        socialPostResults.length + 
                        userResults.length + 
                        swapListingResults.length;

    // Update search history with result count
    if (_recentSearches.isNotEmpty && _recentSearches.first.query == query) {
      _recentSearches[0] = _recentSearches[0].copyWith(resultCount: totalResults);
    }

    return SearchResults(
      query: query,
      clothingResults: clothingResults,
      combinationResults: combinationResults,
      socialPostResults: socialPostResults,
      userResults: userResults,
      swapListingResults: swapListingResults,
      hasMore: false, // Mock data doesn't have pagination
      totalCount: totalResults,
    );
  }

  @override
  Future<List<SearchResult>> searchByCategory({
    required String query,
    required SearchResultType category,
    int page = 1,
    int limit = 20,
  }) async {
    await Future.delayed(Duration(milliseconds: 300 + _random.nextInt(300)));

    if (query.isEmpty) return [];

    final lowercaseQuery = query.toLowerCase();

    switch (category) {
      case SearchResultType.clothing:
        return _filterMockData(_mockClothingItems, lowercaseQuery, category);
      case SearchResultType.combination:
        return _filterMockData(_mockCombinations, lowercaseQuery, category);
      case SearchResultType.socialPost:
        return _filterMockData(_mockSocialPosts, lowercaseQuery, category);
      case SearchResultType.user:
        return _filterMockData(_mockUsers, lowercaseQuery, category);
      case SearchResultType.swapListing:
        return _filterMockData(_mockSwapListings, lowercaseQuery, category);
    }
  }

  @override
  Future<List<RecentSearch>> getRecentSearches({int limit = 10}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _recentSearches.take(limit).toList();
  }

  @override
  Future<void> saveSearch(String query, int resultCount) async {
    if (query.trim().isEmpty) return;

    // Remove if already exists
    _recentSearches.removeWhere((search) => search.query == query);
    
    // Add to beginning
    _recentSearches.insert(0, RecentSearch(
      query: query,
      timestamp: DateTime.now(),
      resultCount: resultCount,
    ));

    // Keep only last 20 searches
    if (_recentSearches.length > 20) {
      _recentSearches.removeRange(20, _recentSearches.length);
    }
  }

  @override
  Future<void> clearSearchHistory() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _recentSearches.clear();
  }

  @override
  Future<List<String>> getTrendingSearches({int limit = 10}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _trendingSearches.take(limit).toList();
  }

  List<SearchResult> _filterMockData(
    List<Map<String, dynamic>> data,
    String query,
    SearchResultType type,
  ) {
    return data
        .where((item) =>
            item['title'].toString().toLowerCase().contains(query) ||
            item['description'].toString().toLowerCase().contains(query))
        .map((item) => SearchResult(
              id: item['id'],
              title: item['title'],
              description: item['description'],
              type: type,
              imageUrl: item['imageUrl'],
              metadata: Map<String, dynamic>.from(item['metadata']),
            ))
        .toList();
  }
}
