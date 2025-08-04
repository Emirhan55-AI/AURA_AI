import 'package:flutter/material.dart';
import 'favorite_item_models.dart';

/// FavoritesListView - Scrollable list view for displaying favorited items
/// 
/// This widget displays favorited items in a vertical list layout
/// with support for different item types and interactions.
class FavoritesListView extends StatelessWidget {
  final List<FavoritableItem> items;
  final void Function(FavoritableItem)? onItemTap;
  final void Function(FavoritableItem)? onItemLongPress;
  final bool isSelectionMode;
  final Set<String> selectedItems;

  const FavoritesListView({
    super.key,
    required this.items,
    this.onItemTap,
    this.onItemLongPress,
    this.isSelectionMode = false,
    this.selectedItems = const {},
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (items.isEmpty) {
      return _buildEmptyState(context, theme, colorScheme);
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = selectedItems.contains(item.id);
        
        return _buildListItem(context, item, isSelected, theme, colorScheme);
      },
    );
  }

  Widget _buildListItem(
    BuildContext context,
    FavoritableItem item,
    bool isSelected,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return GestureDetector(
      onTap: () => onItemTap?.call(item),
      onLongPress: () => onItemLongPress?.call(item),
      child: Card(
        elevation: isSelected ? 4 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isSelected 
              ? BorderSide(color: colorScheme.primary, width: 2)
              : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Selection indicator
              if (isSelectionMode) ...[
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? colorScheme.primary : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? colorScheme.primary : colorScheme.outline,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          size: 16,
                          color: colorScheme.onPrimary,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
              ],
              
              // Image
              Container(
                width: 60,
                height: 80,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.antiAlias,
                child: item.imageUrl != null
                    ? Image.network(
                        item.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildImagePlaceholder(colorScheme, Icons.image_not_supported),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return _buildImagePlaceholder(colorScheme, Icons.image);
                        },
                      )
                    : _buildImagePlaceholder(colorScheme, Icons.image),
              ),
              
              const SizedBox(width: 12),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      item.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Subtitle based on item type
                    Text(
                      _getItemSubtitle(item),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Additional info based on item type
                    _buildAdditionalInfo(context, item, theme, colorScheme),
                  ],
                ),
              ),
              
              // Favorite date and menu
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatDate(item.favoriteDate),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Icon(
                    Icons.more_vert,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(ColorScheme colorScheme, IconData icon) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: colorScheme.surfaceVariant,
      child: Icon(
        icon,
        size: 24,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildAdditionalInfo(
    BuildContext context,
    FavoritableItem item,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    if (item is FavoriteClothingItem) {
      return Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              item.color,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontSize: 11,
              ),
            ),
          ),
          if (item.price != null) ...[
            const SizedBox(width: 8),
            Text(
              '\$${item.price!.toStringAsFixed(2)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      );
    } else if (item is FavoriteOutfit) {
      return Wrap(
        spacing: 6,
        runSpacing: 4,
        children: item.tags.take(2).map((tag) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '#$tag',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
        )).toList(),
      );
    } else if (item is FavoriteSocialPost) {
      return Row(
        children: [
          Icon(
            Icons.favorite,
            size: 16,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            '${item.likesCount}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            Icons.chat_bubble_outline,
            size: 16,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            '${item.commentsCount}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ],
      );
    } else if (item is FavoriteSwapListing) {
      return Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: item.isAvailable 
                  ? colorScheme.primaryContainer 
                  : colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              item.isAvailable ? 'Available' : 'Unavailable',
              style: theme.textTheme.bodySmall?.copyWith(
                color: item.isAvailable 
                    ? colorScheme.onPrimaryContainer 
                    : colorScheme.onErrorContainer,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_border,
                size: 48,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No favorites yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Items you favorite will appear here for quick access.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getItemSubtitle(FavoritableItem item) {
    if (item is FavoriteClothingItem) {
      return '${item.brand} • ${item.category}';
    } else if (item is FavoriteOutfit) {
      return '${item.itemCount} items • ${item.occasion}';
    } else if (item is FavoriteSocialPost) {
      return 'by ${item.authorName}';
    } else if (item is FavoriteSwapListing) {
      return 'by ${item.ownerName} • ${item.condition}';
    }
    return '';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${difference.inDays ~/ 7}w';
    }
  }
}
