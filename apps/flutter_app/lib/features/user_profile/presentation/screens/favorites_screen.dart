import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ui/system_state_widget.dart';
import '../controllers/favorites_controller.dart';
import '../widgets/favorites/favorite_item_models.dart';
import '../widgets/favorites/favorites_tab_bar.dart';
import '../widgets/favorites/favorites_tab_bar_view.dart';
import '../widgets/favorites/favorites_multi_select_toolbar.dart';

/// FavoritesScreen - Screen where users view all their favorited content
/// 
/// This screen displays favorited items across different categories:
/// - Products (clothing items)
/// - Combinations (outfits)
/// - Posts (social media posts)
/// - Swap Listings (items available for swapping)
/// 
/// Features:
/// - Tab-based navigation between different favorite types
/// - Grid/List view toggle
/// - Multi-select mode for bulk operations
/// - Empty states and error handling
/// - Real backend integration with Supabase
class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isGridView = true;
  bool _isSelectionMode = false;
  final Set<String> _selectedItems = <String>{};

  final List<FavoriteTabType> _tabs = [
    FavoriteTabType.products,
    FavoriteTabType.combinations,
    FavoriteTabType.posts,
    FavoriteTabType.swapListings,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_isSelectionMode) {
      _exitSelectionMode();
    }
  }

  void _toggleView() {
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  void _onItemTap(FavoritableItem item) {
    if (_isSelectionMode) {
      _toggleItemSelection(item.id);
    } else {
      // Navigate to item detail or perform item-specific action
      _showItemDetail(item);
    }
  }

  void _onItemLongPress(FavoritableItem item) {
    if (!_isSelectionMode) {
      _enterSelectionMode();
      _toggleItemSelection(item.id);
    }
  }

  void _enterSelectionMode() {
    setState(() {
      _isSelectionMode = true;
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedItems.clear();
    });
  }

  void _toggleItemSelection(String itemId) {
    setState(() {
      if (_selectedItems.contains(itemId)) {
        _selectedItems.remove(itemId);
        if (_selectedItems.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedItems.add(itemId);
      }
    });
  }

  void _selectAll() {
    // In a real implementation, this would get all items from the current tab
    // For now, we'll use placeholder logic
    setState(() {
      // This is a placeholder - in real implementation, get all item IDs from current tab
      _selectedItems.addAll(['1', '2', '3']); // Mock IDs
    });
  }

  void _deselectAll() {
    setState(() {
      _selectedItems.clear();
    });
  }

  void _removeSelected() {
    _showRemoveConfirmationDialog();
  }

  void _shareSelected() {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing ${_selectedItems.length} items...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    _exitSelectionMode();
  }

  void _showItemDetail(FavoritableItem item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              item.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            const Expanded(
              child: Center(
                child: Text('Item detail view coming soon!'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRemoveConfirmationDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove from Favorites'),
        content: Text(
          'Are you sure you want to remove ${_selectedItems.length} item${_selectedItems.length == 1 ? '' : 's'} from your favorites?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              // Remove favorites using real backend
              final controller = ref.read(favoritesControllerProvider.notifier);
              final success = await controller.removeFavorites(_selectedItems.toList());
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success 
                        ? 'Removed ${_selectedItems.length} items from favorites'
                        : 'Failed to remove items. Please try again.',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                _exitSelectionMode();
              }
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          Column(
            children: [
              // AppBar
              AppBar(
                backgroundColor: colorScheme.surface,
                surfaceTintColor: colorScheme.surfaceTint,
                elevation: 0,
                title: Text(
                  'Favorites',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                    fontFamily: 'Urbanist',
                  ),
                ),
                centerTitle: false,
                actions: [
                  if (!_isSelectionMode) ...[
                    IconButton(
                      onPressed: () async {
                        // Search favorites functionality
                        final controller = ref.read(favoritesControllerProvider.notifier);
                        await controller.searchFavorites(''); // Implement search UI
                      },
                      icon: Icon(
                        Icons.search,
                        color: colorScheme.onSurface,
                      ),
                      tooltip: 'Search favorites',
                    ),
                    IconButton(
                      onPressed: () {
                        // Implement filter/sort functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Filter options coming soon!'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.tune,
                        color: colorScheme.onSurface,
                      ),
                      tooltip: 'Filter and sort',
                    ),
                  ],
                ],
              ),

              // Tab Bar
              FavoritesTabBar(
                tabController: _tabController,
                tabs: _tabs,
                onTabChanged: (index) {
                  // Tab changed logic handled by controller listener
                },
              ),

              // Content Area with State Handling
              Expanded(
                child: _buildContent(context, theme, colorScheme),
              ),
            ],
          ),

          // Multi-select toolbar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: FavoritesMultiSelectToolbar(
              isVisible: _isSelectionMode,
              selectedCount: _selectedItems.length,
              totalCount: 3, // Mock total count - in real implementation, get from data
              onSelectAll: _selectAll,
              onDeselectAll: _deselectAll,
              onRemoveSelected: _removeSelected,
              onShareSelected: _shareSelected,
              onCancel: _exitSelectionMode,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    final favoritesAsyncValue = ref.watch(favoritesControllerProvider);
    
    return favoritesAsyncValue.when(
      data: (favorites) {
        if (favorites.isEmpty) {
          return const SystemStateWidget(
            title: 'No Favorites Yet',
            message: 'Start favoriting items to see them here.',
            icon: Icons.favorite_border,
          );
        }
        
        return FavoritesTabBarView(
          tabController: _tabController,
          tabs: _tabs,
          isGridView: _isGridView,
          onToggleView: _toggleView,
          onItemTap: _onItemTap,
          onItemLongPress: _onItemLongPress,
        );
      },
      loading: () => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading Favorites...'),
          ],
        ),
      ),
      error: (error, stackTrace) => SystemStateWidget(
        title: 'Failed to Load Favorites',
        message: 'Please check your connection and try again.',
        icon: Icons.error_outline,
        onRetry: () {
          ref.read(favoritesControllerProvider.notifier).refresh();
        },
        retryText: 'Try Again',
      ),
    );
  }
}
