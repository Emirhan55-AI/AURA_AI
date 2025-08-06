import '../../domain/entities/search_result.dart';
import '../../domain/repositories/search_repository.dart';
import '../../presentation/controllers/search_controller.dart';

/// Implementation of SearchRepository
/// 
/// In a real app, this would connect to backend APIs
/// Currently provides mock data for development
class SearchRepositoryImpl implements SearchRepository {
  @override
  Future<SearchResults> search({
    required String query,
    SearchFilters? filters,
  }) async {
    // Simulate API delay
    await Future<void>.delayed(const Duration(milliseconds: 800));

    // Mock search results based on query
    final items = await searchItems(query: query, filters: filters);
    final outfits = await searchOutfits(query: query, filters: filters);
    final posts = await searchPosts(query: query, filters: filters);
    final users = await searchUsers(query: query, filters: filters);
    final swaps = await searchSwaps(query: query, filters: filters);
    final challenges = await searchChallenges(query: query, filters: filters);

    return SearchResults(
      items: items,
      outfits: outfits,
      posts: posts,
      users: users,
      swaps: swaps,
      challenges: challenges,
    );
  }

  @override
  Future<List<String>> getSuggestions(String partial) async {
    // Simulate API delay
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final suggestions = [
      'summer dress',
      'casual outfit',
      'formal wear',
      'street style',
      'vintage style',
      'minimalist fashion',
      'boho chic',
      'sustainable fashion',
      'color blocking',
      'layering techniques',
    ];

    return suggestions
        .where((suggestion) =>
            suggestion.toLowerCase().contains(partial.toLowerCase()))
        .take(5)
        .toList();
  }

  @override
  Future<List<String>> getTrendingSearches() async {
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

  @override
  Future<List<SearchResultItem>> searchItems({
    required String query,
    SearchFilters? filters,
  }) async {
    // Mock clothing items data
    final mockItems = [
      SearchResultItem(
        id: '1',
        title: 'Summer Maxi Dress',
        description: 'Flowy summer dress perfect for warm weather',
        imageUrl: 'https://via.placeholder.com/300x400',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        category: 'Dresses',
        brand: 'Zara',
        color: 'Blue',
        size: 'M',
        price: 89.99,
        tags: ['summer', 'casual', 'maxi'],
      ),
      SearchResultItem(
        id: '2',
        title: 'Leather Jacket',
        description: 'Classic black leather jacket',
        imageUrl: 'https://via.placeholder.com/300x400',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        category: 'Jackets',
        brand: 'H&M',
        color: 'Black',
        size: 'L',
        price: 149.99,
        tags: ['leather', 'classic', 'outerwear'],
      ),
    ];

    return mockItems
        .where((item) =>
            item.title.toLowerCase().contains(query.toLowerCase()) ||
            item.category.toLowerCase().contains(query.toLowerCase()) ||
            item.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase())))
        .toList();
  }

  @override
  Future<List<SearchResultOutfit>> searchOutfits({
    required String query,
    SearchFilters? filters,
  }) async {
    final mockOutfits = [
      SearchResultOutfit(
        id: '1',
        title: 'Casual Summer Look',
        description: 'Perfect for weekend brunch',
        imageUrl: 'https://via.placeholder.com/300x400',
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        userId: 'user1',
        userName: 'StyleQueen',
        itemCount: 3,
        itemIds: ['1', '2', '3'],
        style: 'Casual',
        occasion: 'Weekend',
      ),
      SearchResultOutfit(
        id: '2',
        title: 'Office Professional',
        description: 'Business casual ensemble',
        imageUrl: 'https://via.placeholder.com/300x400',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        userId: 'user2',
        userName: 'BusinessBabe',
        itemCount: 4,
        itemIds: ['4', '5', '6', '7'],
        style: 'Professional',
        occasion: 'Work',
      ),
    ];

    return mockOutfits
        .where((outfit) =>
            outfit.title.toLowerCase().contains(query.toLowerCase()) ||
            outfit.style.toLowerCase().contains(query.toLowerCase()) ||
            outfit.occasion.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Future<List<SearchResultPost>> searchPosts({
    required String query,
    SearchFilters? filters,
  }) async {
    final mockPosts = [
      SearchResultPost(
        id: '1',
        title: 'Today\'s OOTD ✨',
        description: 'Feeling confident in this vintage-inspired look!',
        imageUrl: 'https://via.placeholder.com/300x400',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        userId: 'user1',
        userName: 'StyleQueen',
        userAvatar: 'https://via.placeholder.com/100x100',
        likesCount: 127,
        commentsCount: 23,
        isLiked: false,
        hashtags: ['ootd', 'vintage', 'style', 'confidence'],
      ),
      SearchResultPost(
        id: '2',
        title: 'Sustainable Fashion Tips',
        description: 'How to build a capsule wardrobe on a budget',
        imageUrl: 'https://via.placeholder.com/300x400',
        createdAt: DateTime.now().subtract(const Duration(hours: 18)),
        userId: 'user3',
        userName: 'EcoFashionista',
        userAvatar: 'https://via.placeholder.com/100x100',
        likesCount: 89,
        commentsCount: 15,
        isLiked: true,
        hashtags: ['sustainable', 'capsule', 'budget', 'tips'],
      ),
    ];

    return mockPosts
        .where((post) =>
            post.title.toLowerCase().contains(query.toLowerCase()) ||
            post.description?.toLowerCase().contains(query.toLowerCase()) == true ||
            post.hashtags.any((tag) => tag.toLowerCase().contains(query.toLowerCase())))
        .toList();
  }

  @override
  Future<List<SearchResultUser>> searchUsers({
    required String query,
    SearchFilters? filters,
  }) async {
    final mockUsers = [
      SearchResultUser(
        id: 'user1',
        title: 'Emma Style', // Display name
        username: 'emmastyle',
        bio: 'Fashion blogger & sustainable style advocate',
        avatarUrl: 'https://via.placeholder.com/100x100',
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        followersCount: 12500,
        followingCount: 892,
        isFollowing: false,
        isVerified: true,
      ),
      SearchResultUser(
        id: 'user2',
        title: 'Fashion Forward',
        username: 'fashionforward',
        bio: 'Trend spotter & style influencer',
        avatarUrl: 'https://via.placeholder.com/100x100',
        createdAt: DateTime.now().subtract(const Duration(days: 200)),
        followersCount: 8900,
        followingCount: 456,
        isFollowing: true,
        isVerified: false,
      ),
    ];

    return mockUsers
        .where((user) =>
            user.title.toLowerCase().contains(query.toLowerCase()) ||
            user.username.toLowerCase().contains(query.toLowerCase()) ||
            user.bio?.toLowerCase().contains(query.toLowerCase()) == true)
        .toList();
  }

  @override
  Future<List<SearchResultSwap>> searchSwaps({
    required String query,
    SearchFilters? filters,
  }) async {
    final mockSwaps = [
      SearchResultSwap(
        id: '1',
        title: 'Designer Dress Swap',
        description: 'Looking to trade my Zara dress for something vintage',
        imageUrl: 'https://via.placeholder.com/300x400',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        userId: 'user1',
        userName: 'StyleQueen',
        userAvatar: 'https://via.placeholder.com/100x100',
        offeredItemIds: ['1'],
        wantedItemIds: ['vintage-dress'],
        status: 'active',
        location: 'New York, NY',
      ),
      SearchResultSwap(
        id: '2',
        title: 'Shoe Exchange',
        description: 'Size 8 heels for size 8 sneakers',
        imageUrl: 'https://via.placeholder.com/300x400',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        userId: 'user2',
        userName: 'BusinessBabe',
        userAvatar: 'https://via.placeholder.com/100x100',
        offeredItemIds: ['2'],
        wantedItemIds: ['sneakers'],
        status: 'pending',
        location: 'Los Angeles, CA',
      ),
    ];

    return mockSwaps
        .where((swap) =>
            swap.title.toLowerCase().contains(query.toLowerCase()) ||
            swap.description?.toLowerCase().contains(query.toLowerCase()) == true)
        .toList();
  }

  @override
  Future<List<SearchResultChallenge>> searchChallenges({
    required String query,
    SearchFilters? filters,
  }) async {
    final mockChallenges = [
      SearchResultChallenge(
        id: '1',
        title: '30-Day Sustainable Style',
        description: 'Style challenge using only sustainable brands',
        imageUrl: 'https://via.placeholder.com/300x400',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        theme: 'Sustainability',
        startDate: DateTime.now().subtract(const Duration(days: 3)),
        endDate: DateTime.now().add(const Duration(days: 27)),
        participantsCount: 1250,
        isParticipating: true,
        prizes: ['Gift Card', 'Featured Post'],
        difficulty: 'Medium',
      ),
      SearchResultChallenge(
        id: '2',
        title: 'Vintage Vibes Week',
        description: 'Show off your best vintage-inspired looks',
        imageUrl: 'https://via.placeholder.com/300x400',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        theme: 'Vintage',
        startDate: DateTime.now().add(const Duration(days: 2)),
        endDate: DateTime.now().add(const Duration(days: 9)),
        participantsCount: 890,
        isParticipating: false,
        prizes: ['Vintage Accessory', 'Style Guide'],
        difficulty: 'Easy',
      ),
    ];

    return mockChallenges
        .where((challenge) =>
            challenge.title.toLowerCase().contains(query.toLowerCase()) ||
            challenge.theme.toLowerCase().contains(query.toLowerCase()) ||
            challenge.description?.toLowerCase().contains(query.toLowerCase()) == true)
        .toList();
  }
}
