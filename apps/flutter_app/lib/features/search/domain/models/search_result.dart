class SearchResult {
  final String id;
  final String title;
  final String description;
  final SearchResultType type;
  final String? imageUrl;
  final Map<String, dynamic> metadata;

  const SearchResult({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.imageUrl,
    this.metadata = const {},
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: SearchResultType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => SearchResultType.clothing,
      ),
      imageUrl: json['imageUrl'] as String?,
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'imageUrl': imageUrl,
      'metadata': metadata,
    };
  }
}

enum SearchResultType {
  clothing,
  combination,
  socialPost,
  user,
  swapListing,
}

class SearchResults {
  final String query;
  final List<SearchResult> clothingResults;
  final List<SearchResult> combinationResults;
  final List<SearchResult> socialPostResults;
  final List<SearchResult> userResults;
  final List<SearchResult> swapListingResults;
  final bool hasMore;
  final int totalCount;

  const SearchResults({
    required this.query,
    required this.clothingResults,
    required this.combinationResults,
    required this.socialPostResults,
    required this.userResults,
    required this.swapListingResults,
    this.hasMore = false,
    this.totalCount = 0,
  });

  factory SearchResults.empty() => const SearchResults(
        query: '',
        clothingResults: [],
        combinationResults: [],
        socialPostResults: [],
        userResults: [],
        swapListingResults: [],
      );

  SearchResults copyWith({
    String? query,
    List<SearchResult>? clothingResults,
    List<SearchResult>? combinationResults,
    List<SearchResult>? socialPostResults,
    List<SearchResult>? userResults,
    List<SearchResult>? swapListingResults,
    bool? hasMore,
    int? totalCount,
  }) {
    return SearchResults(
      query: query ?? this.query,
      clothingResults: clothingResults ?? this.clothingResults,
      combinationResults: combinationResults ?? this.combinationResults,
      socialPostResults: socialPostResults ?? this.socialPostResults,
      userResults: userResults ?? this.userResults,
      swapListingResults: swapListingResults ?? this.swapListingResults,
      hasMore: hasMore ?? this.hasMore,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}

class RecentSearch {
  final String query;
  final DateTime timestamp;
  final int resultCount;

  const RecentSearch({
    required this.query,
    required this.timestamp,
    this.resultCount = 0,
  });

  factory RecentSearch.fromJson(Map<String, dynamic> json) {
    return RecentSearch(
      query: json['query'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      resultCount: json['resultCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'timestamp': timestamp.toIso8601String(),
      'resultCount': resultCount,
    };
  }

  RecentSearch copyWith({
    String? query,
    DateTime? timestamp,
    int? resultCount,
  }) {
    return RecentSearch(
      query: query ?? this.query,
      timestamp: timestamp ?? this.timestamp,
      resultCount: resultCount ?? this.resultCount,
    );
  }
}
