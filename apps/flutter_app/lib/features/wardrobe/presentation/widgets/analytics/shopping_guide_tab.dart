import 'package:flutter/material.dart';
import '../../../../../core/ui/system_state_widget.dart';
import 'models.dart';
import 'shopping_guide_item_card.dart';

/// Tab widget for displaying shopping recommendations and guides
class ShoppingGuideTab extends StatelessWidget {
  final List<ShoppingGuideItem>? items;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRefresh;
  final ValueChanged<ShoppingGuideItem>? onItemTap;
  final VoidCallback? onLoadMore;
  final bool hasMore;

  const ShoppingGuideTab({
    super.key,
    this.items,
    this.isLoading = false,
    this.errorMessage,
    this.onRefresh,
    this.onItemTap,
    this.onLoadMore,
    this.hasMore = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (isLoading && (items == null || items!.isEmpty)) {
      return const SystemStateWidget(
        message: 'Generating personalized shopping suggestions...',
        icon: Icons.shopping_bag_outlined,
      );
    }

    if (errorMessage != null && (items == null || items!.isEmpty)) {
      return SystemStateWidget(
        title: 'Unable to load shopping guide',
        message: errorMessage!,
        icon: Icons.error_outline,
        iconColor: colorScheme.error,
        onRetry: onRefresh,
        retryText: 'Try Again',
      );
    }

    if (items == null || items!.isEmpty) {
      return SystemStateWidget(
        title: 'No shopping suggestions',
        message: 'Complete your wardrobe profile to get personalized shopping recommendations.',
        icon: Icons.shopping_cart_outlined,
        onCTA: () {
          // TODO: Navigate to wardrobe setup
        },
        ctaText: 'Set Up Profile',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        onRefresh?.call();
      },
      child: CustomScrollView(
        slivers: [
          // Header with categories and stats
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildHeader(context, theme, colorScheme),
            ),
          ),
          
          // Shopping guide items
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = items![index];
                return ShoppingGuideItemCard(
                  item: item,
                  onTap: () => onItemTap?.call(item),
                );
              },
              childCount: items!.length,
            ),
          ),
          
          // Load more button
          if (hasMore)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildLoadMoreButton(context, theme, colorScheme),
              ),
            ),
          
          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    final totalItems = items?.length ?? 0;
    final essentialItems = items?.where((item) => item.priority == 'essential').length ?? 0;
    final categories = items?.map((item) => item.category).toSet().length ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Shopping guide summary
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Shopping Guide',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Personalized recommendations based on your wardrobe analysis.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryItem(
                        context,
                        theme,
                        colorScheme,
                        'Total Items',
                        totalItems.toString(),
                        Icons.shopping_cart_outlined,
                        colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryItem(
                        context,
                        theme,
                        colorScheme,
                        'Essential',
                        essentialItems.toString(),
                        Icons.star_outline,
                        colorScheme.error,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryItem(
                        context,
                        theme,
                        colorScheme,
                        'Categories',
                        categories.toString(),
                        Icons.category_outlined,
                        colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Priority filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip(
                context,
                theme,
                colorScheme,
                'All Items',
                true,
                () {},
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                context,
                theme,
                colorScheme,
                'Essential',
                false,
                () {},
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                context,
                theme,
                colorScheme,
                'Recommended',
                false,
                () {},
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                context,
                theme,
                colorScheme,
                'Optional',
                false,
                () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: color,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => onTap(),
      selectedColor: colorScheme.primaryContainer,
      checkmarkColor: colorScheme.onPrimaryContainer,
      labelStyle: theme.textTheme.labelMedium?.copyWith(
        color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _buildLoadMoreButton(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: isLoading ? null : onLoadMore,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading) ...[
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Loading more...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ] else ...[
                Icon(
                  Icons.add_shopping_cart_outlined,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Load More Recommendations',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
