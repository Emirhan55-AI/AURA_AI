import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../wardrobe/presentation/controllers/wardrobe_controller.dart';
import '../../../wardrobe/domain/entities/clothing_item.dart';
import '../widgets/wardrobe_multi_select_toolbar.dart';
import '../widgets/wardrobe_filter_bottom_sheet.dart';
import '../widgets/clothing_item_card.dart';
import '../../../../core/ui/loading_view.dart';
import '../../../../core/ui/error_view.dart';

class WardrobeHomeScreen extends ConsumerStatefulWidget {
  const WardrobeHomeScreen({super.key});

  @override
  ConsumerState<WardrobeHomeScreen> createState() => _WardrobeHomeScreenState();
}

class _WardrobeHomeScreenState extends ConsumerState<WardrobeHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(wardrobeControllerProvider.notifier).loadItems(isRefresh: true);
    });
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wardrobeAsync = ref.watch(wardrobeControllerProvider);
    final controller = ref.watch(wardrobeControllerProvider.notifier);
    final theme = Theme.of(context);
    final isMultiSelectMode = controller.isMultiSelectMode;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: _buildAppBar(theme),
      body: Column(
        children: [
          if (isMultiSelectMode) const WardrobeMultiSelectToolbar(),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: wardrobeAsync.when(
                  loading: () => const LoadingView(message: 'Loading your wardrobe...'),
                  error: (error, stack) => ErrorView(
                    error: error,
                    onRetry: () => ref.read(wardrobeControllerProvider.notifier)
                        .loadItems(isRefresh: true),
                  ),
                  data: (items) => _buildWardrobeContent(items, theme),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: isMultiSelectMode ? null : _buildAddItemFAB(theme),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(120),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.checkroom_outlined,
                            color: theme.colorScheme.onPrimaryContainer,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'My Wardrobe',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => setState(() => _isGridView = !_isGridView),
                      icon: Icon(
                        _isGridView ? Icons.list : Icons.grid_view,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      tooltip: _isGridView ? 'List view' : 'Grid view',
                    ),
                    IconButton(
                      onPressed: () => _showFilterDialog(context),
                      icon: Icon(
                        Icons.tune,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      tooltip: 'Filters',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildSearchBar(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: TextField(
        onChanged: (value) {
          setState(() => _searchQuery = value);
          ref.read(wardrobeControllerProvider.notifier).searchItems(value);
        },
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: 'Search your wardrobe...',
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: theme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    setState(() => _searchQuery = '');
                    ref.read(wardrobeControllerProvider.notifier).searchItems('');
                  },
                  icon: Icon(
                    Icons.clear,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildWardrobeContent(List<ClothingItem> items, ThemeData theme) {
    if (items.isEmpty) return _buildEmptyState(theme);

    return Column(
      children: [
        _buildCategoryFilter(theme),
        _buildStatsSection(items, theme),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _isGridView 
                ? _buildItemGrid(items, theme)
                : _buildItemList(items, theme),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter(ThemeData theme) {
    final categories = ['All', 'Tops', 'Bottoms', 'Dresses', 'Outerwear', 'Shoes', 'Accessories'];

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedCategory = category);
                final categoryIds = category == 'All' ? <String>[] : [category];
                ref.read(wardrobeControllerProvider.notifier).applyFilters(
                  categoryIds: categoryIds,
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsSection(List<ClothingItem> items, ThemeData theme) {
    final totalItems = items.length;
    final favoriteItems = items.where((item) => item.isFavorite).length;
    final recentItems = items.where((item) => 
        item.createdAt.isAfter(DateTime.now().subtract(const Duration(days: 30)))
    ).length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', totalItems.toString(), Icons.checkroom, theme),
          _buildStatItem('Favorites', favoriteItems.toString(), Icons.favorite, theme),
          _buildStatItem('Recent', recentItems.toString(), Icons.new_releases, theme),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 24, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildItemGrid(List<ClothingItem> items, ThemeData theme) {
    return GridView.builder(
      key: const ValueKey('grid'),
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _calculateCrossAxisCount(),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ClothingItemCard(
          item: item,
          isGridView: true,
          onTap: () => _navigateToItemDetail(item),
        );
      },
    );
  }

  Widget _buildItemList(List<ClothingItem> items, ThemeData theme) {
    return ListView.builder(
      key: const ValueKey('list'),
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: ClothingItemCard(
            item: item,
            isGridView: false,
            onTap: () => _navigateToItemDetail(item),
          ),
        );
      },
    );
  }

  int _calculateCrossAxisCount() {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    return 2;
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primaryContainer.withOpacity(0.3),
                    theme.colorScheme.secondaryContainer.withOpacity(0.3),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.checkroom_outlined,
                size: 80,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Your wardrobe awaits!',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Start building your digital wardrobe by adding your first clothing item.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            FilledButton.icon(
              onPressed: () => _navigateToAddItem(),
              icon: const Icon(Icons.add),
              label: const Text('Add Your First Item'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddItemFAB(ThemeData theme) {
    return FloatingActionButton.extended(
      onPressed: () => _navigateToAddItem(),
      icon: const Icon(Icons.add),
      label: const Text('Add Item'),
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
    );
  }

  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const WardrobeFilterBottomSheet(),
    );
  }

  void _navigateToItemDetail(ClothingItem item) {
    context.push('/wardrobe/item/${item.id}');
  }

  void _navigateToAddItem() {
    context.push('/wardrobe/add');
  }
}
