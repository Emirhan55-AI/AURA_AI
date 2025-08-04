import 'package:flutter/material.dart';
import 'favorite_item_models.dart';
import 'favorites_grid_view.dart';
import 'favorites_list_view.dart';

/// FavoritesTabBarView - Displays content corresponding to the selected tab
/// 
/// This widget manages the content view for each tab in the favorites screen,
/// showing different types of favorited content based on the selected tab.
class FavoritesTabBarView extends StatelessWidget {
  final TabController tabController;
  final List<FavoriteTabType> tabs;
  final bool isGridView;
  final void Function()? onToggleView;
  final void Function(FavoritableItem)? onItemTap;
  final void Function(FavoritableItem)? onItemLongPress;

  const FavoritesTabBarView({
    super.key,
    required this.tabController,
    this.tabs = const [
      FavoriteTabType.products,
      FavoriteTabType.combinations,
      FavoriteTabType.posts,
      FavoriteTabType.swapListings,
    ],
    this.isGridView = true,
    this.onToggleView,
    this.onItemTap,
    this.onItemLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: tabController,
      children: tabs.map((tabType) => _buildTabContent(context, tabType)).toList(),
    );
  }

  Widget _buildTabContent(BuildContext context, FavoriteTabType tabType) {
    final mockData = _getMockDataForTab(tabType);

    return Column(
      children: [
        // View toggle button
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: onToggleView,
                icon: Icon(
                  isGridView ? Icons.view_list : Icons.grid_view,
                  size: 24,
                ),
                tooltip: isGridView ? 'Switch to List View' : 'Switch to Grid View',
              ),
            ],
          ),
        ),
        
        // Content view
        Expanded(
          child: isGridView
              ? FavoritesGridView(
                  items: mockData,
                  onItemTap: onItemTap,
                  onItemLongPress: onItemLongPress,
                )
              : FavoritesListView(
                  items: mockData,
                  onItemTap: onItemTap,
                  onItemLongPress: onItemLongPress,
                ),
        ),
      ],
    );
  }

  List<FavoritableItem> _getMockDataForTab(FavoriteTabType tabType) {
    switch (tabType) {
      case FavoriteTabType.products:
        return _getMockClothingItems();
      case FavoriteTabType.combinations:
        return _getMockOutfits();
      case FavoriteTabType.posts:
        return _getMockSocialPosts();
      case FavoriteTabType.swapListings:
        return _getMockSwapListings();
    }
  }

  List<FavoriteClothingItem> _getMockClothingItems() {
    return [
      FavoriteClothingItem(
        id: '1',
        name: 'Classic White T-Shirt',
        imageUrl: 'https://picsum.photos/300/400?random=1',
        brand: 'Zara',
        category: 'T-Shirts',
        color: 'White',
        price: 29.99,
        favoriteDate: DateTime.now().subtract(const Duration(days: 1)),
      ),
      FavoriteClothingItem(
        id: '2',
        name: 'Denim Jacket',
        imageUrl: 'https://picsum.photos/300/400?random=2',
        brand: 'Levi\'s',
        category: 'Jackets',
        color: 'Blue',
        price: 89.99,
        favoriteDate: DateTime.now().subtract(const Duration(days: 3)),
      ),
      FavoriteClothingItem(
        id: '3',
        name: 'Black Leather Boots',
        imageUrl: 'https://picsum.photos/300/400?random=3',
        brand: 'Dr. Martens',
        category: 'Boots',
        color: 'Black',
        price: 159.99,
        favoriteDate: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }

  List<FavoriteOutfit> _getMockOutfits() {
    return [
      FavoriteOutfit(
        id: '1',
        name: 'Casual Weekend Look',
        imageUrl: 'https://picsum.photos/300/400?random=4',
        itemCount: 4,
        tags: ['casual', 'weekend', 'comfortable'],
        occasion: 'Weekend',
        favoriteDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
      FavoriteOutfit(
        id: '2',
        name: 'Business Meeting Outfit',
        imageUrl: 'https://picsum.photos/300/400?random=5',
        itemCount: 5,
        tags: ['business', 'formal', 'professional'],
        occasion: 'Work',
        favoriteDate: DateTime.now().subtract(const Duration(days: 4)),
      ),
    ];
  }

  List<FavoriteSocialPost> _getMockSocialPosts() {
    return [
      FavoriteSocialPost(
        id: '1',
        name: 'Summer Vibes Outfit',
        imageUrl: 'https://picsum.photos/300/400?random=6',
        authorName: 'Sarah Johnson',
        authorAvatar: 'https://picsum.photos/40/40?random=10',
        likesCount: 248,
        commentsCount: 32,
        favoriteDate: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      FavoriteSocialPost(
        id: '2',
        name: 'Elegant Evening Look',
        imageUrl: 'https://picsum.photos/300/400?random=7',
        authorName: 'Emma Wilson',
        authorAvatar: 'https://picsum.photos/40/40?random=11',
        likesCount: 156,
        commentsCount: 18,
        favoriteDate: DateTime.now().subtract(const Duration(hours: 12)),
      ),
    ];
  }

  List<FavoriteSwapListing> _getMockSwapListings() {
    return [
      FavoriteSwapListing(
        id: '1',
        name: 'Vintage Silk Scarf',
        imageUrl: 'https://picsum.photos/300/400?random=8',
        ownerName: 'Alex Chen',
        ownerAvatar: 'https://picsum.photos/40/40?random=12',
        condition: 'Like New',
        size: 'One Size',
        favoriteDate: DateTime.now().subtract(const Duration(hours: 8)),
      ),
      FavoriteSwapListing(
        id: '2',
        name: 'Designer Handbag',
        imageUrl: 'https://picsum.photos/300/400?random=9',
        ownerName: 'Maria Rodriguez',
        ownerAvatar: 'https://picsum.photos/40/40?random=13',
        condition: 'Good',
        size: 'Medium',
        favoriteDate: DateTime.now().subtract(const Duration(hours: 18)),
      ),
    ];
  }
}
