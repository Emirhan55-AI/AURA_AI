import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/clothing_item.dart';
import '../../domain/repositories/i_user_wardrobe_repository.dart';
import '../../data/providers/wardrobe_providers.dart';
import '../../../wardrobe/providers/repository_providers.dart';

part 'wardrobe_controller.g.dart';

@riverpod
class WardrobeController extends _$WardrobeController {
  // Current filter state - managed separately from the main AsyncValue state
  String _searchTerm = '';
  List<String> _selectedCategoryIds = [];
  List<String> _selectedSeasons = [];
  bool _showOnlyFavorites = false;
  String _sortBy = 'created_at';
  int _currentPage = 1;
  static const int _itemsPerPage = 20;

  // Multi-select state
  bool _isMultiSelectMode = false;
  Set<String> _selectedItemsInMultiSelect = <String>{};

  @override
  Future<List<ClothingItem>> build() async {
    // Use mock data for demo
    final items = _getMockClothingItems();
    ref.invalidate(wardrobeStatsProvider); // Refresh stats
    return items;
  }

  /// Mock data for testing wardrobe functionality
  List<ClothingItem> _getMockClothingItems() {
    return [
      ClothingItem(
        id: '1',
        userId: 'test-user',
        name: 'Blue Denim Jacket',
        category: 'Outerwear',
        color: 'Blue',
        brand: 'Levi\'s',
        size: 'M',
        isFavorite: true,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        imageUrl: 'https://i.imgur.com/pZ9jX8v.jpeg',
      ),
      ClothingItem(
        id: '2',
        userId: 'test-user',
        name: 'Black Skinny Jeans',
        category: 'Bottoms',
        color: 'Black',
        brand: 'Zara',
        size: '32',
        isFavorite: false,
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
        imageUrl: 'https://i.imgur.com/X0qGHm9.jpeg',
      ),
      ClothingItem(
        id: '3',
        userId: 'test-user',
        name: 'White Cotton T-Shirt',
        category: 'Tops',
        color: 'White',
        brand: 'H&M',
        size: 'L',
        isFavorite: true,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(days: 12)),
        imageUrl: 'https://picsum.photos/300/400?random=3',
      ),
      ClothingItem(
        id: '4',
        userId: 'test-user',
        name: 'Red Summer Dress',
        category: 'Dresses',
        color: 'Red',
        brand: 'Mango',
        size: 'S',
        isFavorite: false,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        imageUrl: 'https://picsum.photos/300/400?random=4',
      ),
      ClothingItem(
        id: '5',
        userId: 'test-user',
        name: 'Brown Leather Boots',
        category: 'Shoes',
        color: 'Brown',
        brand: 'Dr. Martens',
        size: '9',
        isFavorite: true,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(days: 18)),
        imageUrl: 'https://picsum.photos/300/400?random=5',
      ),
      ClothingItem(
        id: '6',
        userId: 'test-user',
        name: 'Gold Chain Necklace',
        category: 'Accessories',
        color: 'Gold',
        brand: 'Pandora',
        isFavorite: false,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 25)),
        imageUrl: 'https://picsum.photos/300/400?random=6',
      ),
    ];
  }

  /// Gets the current repository instance
  IUserWardrobeRepository get _repository => ref.read(userWardrobeRepositoryProvider);

  /// Loads clothing items with current filters and pagination
  /// If [isRefresh] is true, resets to first page and loads fresh data
  Future<void> loadItems({
    bool isRefresh = false,
    String? searchTerm,
    List<String>? categoryIds,
    List<String>? seasons,
    bool? showOnlyFavorites,
    String? sortBy,
  }) async {
    try {
      // Update filter state if provided
      if (searchTerm != null) _searchTerm = searchTerm;
      if (categoryIds != null) _selectedCategoryIds = categoryIds;
      if (seasons != null) _selectedSeasons = seasons;
      if (showOnlyFavorites != null) _showOnlyFavorites = showOnlyFavorites;
      if (sortBy != null) _sortBy = sortBy;

      // Reset to first page if refreshing
      if (isRefresh) {
        _currentPage = 1;
      }

      // Set loading state
      state = const AsyncValue.loading();

      // Fetch items from repository
      final result = await _repository.fetchItems(
        page: _currentPage,
        limit: _itemsPerPage,
        searchTerm: _searchTerm.isNotEmpty ? _searchTerm : null,
        categoryIds: _selectedCategoryIds.isNotEmpty ? _selectedCategoryIds : null,
        seasons: _selectedSeasons.isNotEmpty ? _selectedSeasons : null,
        showOnlyFavorites: _showOnlyFavorites,
        sortBy: _sortBy,
      );

      // Handle result
      result.fold(
        (failure) {
          state = AsyncValue.error(failure, StackTrace.current);
        },
        (items) {
          state = AsyncValue.data(items);
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Adds a new clothing item to the wardrobe
  Future<void> addItem(ClothingItem newItem) async {
    try {
      final result = await _repository.addItem(newItem);

      result.fold(
        (failure) {
          // Handle add failure - you might want to show an error message
          // For now, we'll just ignore and keep current state
        },
        (addedItem) {
          // On success, refresh the list to ensure consistency
          // Alternative: prepend the item to current list for immediate feedback
          loadItems(isRefresh: true);
        },
      );
    } catch (e) {
      // Handle unexpected errors
    }
  }

  /// Updates an existing clothing item
  Future<void> updateItem(ClothingItem updatedItem) async {
    try {
      final result = await _repository.updateItem(updatedItem);

      result.fold(
        (failure) {
          // Handle update failure
        },
        (item) {
          // Update the item in the current list
          final currentItems = state.value ?? [];
          final updatedItems = currentItems.map((existingItem) {
            return existingItem.id == item.id ? item : existingItem;
          }).toList();
          
          state = AsyncValue.data(updatedItems);
        },
      );
    } catch (e) {
      // Handle unexpected errors
    }
  }

  /// Deletes multiple clothing items
  Future<void> deleteItems(List<String> itemIds) async {
    if (itemIds.isEmpty) return;

    try {
      final currentItems = state.value ?? [];
      
      // Optimistically remove items from UI
      final remainingItems = currentItems
          .where((item) => !itemIds.contains(item.id))
          .toList();
      state = AsyncValue.data(remainingItems);

      // Delete items from repository
      for (final itemId in itemIds) {
        final result = await _repository.deleteItem(itemId);
        
        // If any deletion fails, you might want to handle it differently
        // For now, we'll continue with the optimistic update
        result.fold(
          (failure) {
            // Log failure or handle as needed
          },
          (_) {
            // Success - item deleted
          },
        );
      }
    } catch (e) {
      // Handle unexpected errors - might want to reload data
      loadItems(isRefresh: true);
    }
  }

  /// Toggles the favorite status of a clothing item
  Future<void> toggleFavorite(String itemId) async {
    try {
      // Find the current item
      final currentItems = state.value ?? [];
      final itemIndex = currentItems.indexWhere((item) => item.id == itemId);
      
      if (itemIndex == -1) return; // Item not found
      
      final currentItem = currentItems[itemIndex];
      final newFavoriteStatus = !currentItem.isFavorite;

      // Optimistically update UI
      final updatedItems = [...currentItems];
      updatedItems[itemIndex] = currentItem.copyWith(isFavorite: newFavoriteStatus);
      state = AsyncValue.data(updatedItems);

      // Persist to repository
      final result = await _repository.toggleFavorite(itemId, newFavoriteStatus);

      result.fold(
        (failure) {
          // Revert the optimistic update on failure
          state = AsyncValue.data(currentItems);
        },
        (updatedItem) {
          // Update with the server response to ensure consistency
          final finalItems = [...updatedItems];
          finalItems[itemIndex] = updatedItem;
          state = AsyncValue.data(finalItems);
        },
      );
    } catch (e) {
      // Handle unexpected errors - might want to revert optimistic update
    }
  }

  /// Updates search term and triggers new search
  Future<void> searchItems(String searchTerm) async {
    _searchTerm = searchTerm;
    _currentPage = 1; // Reset pagination
    await loadItems(isRefresh: true);
  }

  /// Applies filters and reloads items
  Future<void> applyFilters({
    List<String>? categoryIds,
    List<String>? seasons,
    bool? showOnlyFavorites,
    String? sortBy,
  }) async {
    await loadItems(
      isRefresh: true,
      categoryIds: categoryIds,
      seasons: seasons,
      showOnlyFavorites: showOnlyFavorites,
      sortBy: sortBy,
    );
  }

  /// Clears all filters and reloads items
  Future<void> clearFilters() async {
    _searchTerm = '';
    _selectedCategoryIds = [];
    _selectedSeasons = [];
    _showOnlyFavorites = false;
    _sortBy = 'created_at';
    await loadItems(isRefresh: true);
  }

  /// Gets current search term
  String get searchTerm => _searchTerm;

  /// Gets current selected category IDs
  List<String> get selectedCategoryIds => _selectedCategoryIds;

  /// Gets current selected seasons
  List<String> get selectedSeasons => _selectedSeasons;

  /// Gets current favorite filter status
  bool get showOnlyFavorites => _showOnlyFavorites;

  /// Gets current sort criteria
  String get sortBy => _sortBy;

  /// Gets current page number
  int get currentPage => _currentPage;

  /// Checks if there might be more items to load
  bool get canLoadMore {
    final currentItems = state.value ?? [];
    return currentItems.length >= (_currentPage * _itemsPerPage);
  }

  // Legacy methods for backward compatibility - can be removed later
  Future<List<ClothingItem>> searchItemsLegacy(String query) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return [];

    if (query.isEmpty) return currentState;

    return currentState.where((item) =>
      item.name.toLowerCase().contains(query.toLowerCase()) ||
      (item.brand?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
      (item.category?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
      (item.color?.toLowerCase().contains(query.toLowerCase()) ?? false)
    ).toList();
  }

  Future<List<ClothingItem>> filterByCategory(String? category) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return [];

    if (category == null || category == 'All') return currentState;

    return currentState.where((item) =>
      item.category?.toLowerCase() == category.toLowerCase()
    ).toList();
  }

  Future<List<ClothingItem>> getFavoriteItems() async {
    final currentState = state.valueOrNull;
    if (currentState == null) return [];

    return currentState.where((item) => item.isFavorite).toList();
  }

  Future<List<ClothingItem>> getRecentItems({int days = 30}) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return [];

    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return currentState.where((item) =>
      item.createdAt.isAfter(cutoffDate)
    ).toList();
  }

  // Get statistics for the wardrobe
  WardrobeStats getStats() {
    final currentState = state.valueOrNull;
    if (currentState == null) {
      return const WardrobeStats(
        totalItems: 0,
        favoriteItems: 0,
        recentItems: 0,
        categories: <String, int>{},
      );
    }

    final totalItems = currentState.length;
    final favoriteItems = currentState.where((item) => item.isFavorite).length;
    final recentItems = currentState.where((item) =>
      item.createdAt.isAfter(DateTime.now().subtract(const Duration(days: 30)))
    ).length;

    // Group by category
    final categories = <String, int>{};
    for (final item in currentState) {
      final category = item.category ?? 'Uncategorized';
      categories[category] = (categories[category] ?? 0) + 1;
    }

    return WardrobeStats(
      totalItems: totalItems,
      favoriteItems: favoriteItems,
      recentItems: recentItems,
      categories: categories,
    );
  }

  // Multi-select functionality
  bool get isMultiSelectMode => _isMultiSelectMode;
  Set<String> get selectedItemsInMultiSelect => _selectedItemsInMultiSelect;

  /// Enters multi-select mode
  void enterMultiSelectMode() {
    _isMultiSelectMode = true;
    _selectedItemsInMultiSelect.clear();
    ref.invalidateSelf(); // Trigger UI update
  }

  /// Exits multi-select mode
  void exitMultiSelectMode() {
    _isMultiSelectMode = false;
    _selectedItemsInMultiSelect.clear();
    ref.invalidateSelf(); // Trigger UI update
  }

  /// Toggles item selection in multi-select mode
  void toggleItemSelectionInMultiSelect(String itemId) {
    if (_selectedItemsInMultiSelect.contains(itemId)) {
      _selectedItemsInMultiSelect.remove(itemId);
    } else {
      _selectedItemsInMultiSelect.add(itemId);
    }
    ref.invalidateSelf(); // Trigger UI update
  }

  /// Deletes all selected items in multi-select mode
  Future<void> deleteSelectedItems() async {
    if (_selectedItemsInMultiSelect.isEmpty) return;

    try {
      // For now, just remove from local state (mock implementation)
      final currentItems = state.valueOrNull ?? [];
      final updatedItems = currentItems.where(
        (item) => !_selectedItemsInMultiSelect.contains(item.id)
      ).toList();

      // Exit multi-select mode
      exitMultiSelectMode();

      // Update state with filtered items
      state = AsyncValue.data(updatedItems);

      // TODO: In real implementation, call repository to delete items
      // final repository = ref.read(userWardrobeRepositoryProvider);
      // await repository.deleteItems(_selectedItemsInMultiSelect.toList());
      
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void updateSearchTerm(String searchTerm) {
    _searchTerm = searchTerm;
    ref.invalidateSelf();
  }

  void updateFilters({
    List<String>? categoryIds,
    List<String>? seasons,
    bool? showOnlyFavorites,
    String? sortBy,
  }) {
    if (categoryIds != null) _selectedCategoryIds = categoryIds;
    if (seasons != null) _selectedSeasons = seasons;
    if (showOnlyFavorites != null) _showOnlyFavorites = showOnlyFavorites;
    if (sortBy != null) _sortBy = sortBy;
    ref.invalidateSelf();
  }

  void loadNextPage() {
    _currentPage++;
    ref.invalidateSelf();
  }

  void resetFilters() {
    _searchTerm = '';
    _selectedCategoryIds = [];
    _selectedSeasons = [];
    _showOnlyFavorites = false;
    _sortBy = 'created_at';
    _currentPage = 1;
    ref.invalidateSelf();
  }
}

// Data class for wardrobe statistics
class WardrobeStats {
  final int totalItems;
  final int favoriteItems;
  final int recentItems;
  final Map<String, int> categories;

  const WardrobeStats({
    required this.totalItems,
    required this.favoriteItems,
    required this.recentItems,
    required this.categories,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WardrobeStats &&
          runtimeType == other.runtimeType &&
          totalItems == other.totalItems &&
          favoriteItems == other.favoriteItems &&
          recentItems == other.recentItems;

  @override
  int get hashCode => Object.hash(
        totalItems,
        favoriteItems,
        recentItems,
        categories,
      );

  @override
  String toString() {
    return 'WardrobeStats{totalItems: $totalItems, favoriteItems: $favoriteItems, recentItems: $recentItems, categories: $categories}';
  }
}

// Provider for getting wardrobe statistics
@riverpod
WardrobeStats wardrobeStats(WardrobeStatsRef ref) {
  final controller = ref.watch(wardrobeControllerProvider.notifier);
  return controller.getStats();
}
