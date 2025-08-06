import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/clothing_item.dart';
import '../controllers/wardrobe_controller.dart';

class ClothingItemCard extends ConsumerWidget {
  final ClothingItem item;
  final bool isGridView;
  final VoidCallback? onTap;

  const ClothingItemCard({
    super.key,
    required this.item,
    this.isGridView = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(wardrobeControllerProvider.notifier);
    final isMultiSelectMode = controller.isMultiSelectMode;
    final isSelected = controller.selectedItemsInMultiSelect.contains(item.id);

    return GestureDetector(
      onTap: () {
        if (isMultiSelectMode) {
          controller.toggleItemSelectionInMultiSelect(item.id);
        } else {
          onTap?.call();
        }
      },
      onLongPress: () {
        if (!isMultiSelectMode) {
          controller.enterMultiSelectMode();
          controller.toggleItemSelectionInMultiSelect(item.id);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                )
              : null,
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Card(
          elevation: isSelected ? 4 : 1,
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: isGridView ? _buildGridLayout(context, ref) : _buildListLayout(context, ref),
        ),
      ),
    );
  }

  Widget _buildGridLayout(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(wardrobeControllerProvider.notifier);
    final isMultiSelectMode = controller.isMultiSelectMode;
    final isSelected = controller.selectedItemsInMultiSelect.contains(item.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image section with overlay icons
        Expanded(
          child: Stack(
            children: [
              // Main image
              _buildImage(context),
              
              // Multi-select checkbox overlay
              if (isMultiSelectMode)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Checkbox(
                      value: isSelected,
                      onChanged: (value) {
                        controller.toggleItemSelectionInMultiSelect(item.id);
                      },
                      shape: const CircleBorder(),
                    ),
                  ),
                ),
              
              // Favorite heart icon
              if (!isMultiSelectMode)
                Positioned(
                  top: 8,
                  right: 8,
                  child: _buildFavoriteButton(context, ref),
                ),
              
              // Warning icon for old items (6+ months without wear)
              if (_shouldShowWarningIcon())
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        // Item info
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: Theme.of(context).textTheme.titleSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              if (item.brand != null)
                Text(
                  item.brand!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 4),
              Row(
                children: [
                  if (item.color != null) ...[
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getColorFromString(item.color!),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Expanded(
                    child: Text(
                      item.category ?? 'Uncategorized',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListLayout(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(wardrobeControllerProvider.notifier);
    final isMultiSelectMode = controller.isMultiSelectMode;
    final isSelected = controller.selectedItemsInMultiSelect.contains(item.id);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 80,
              height: 80,
              child: _buildImage(context),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (item.brand != null) ...[
                  Text(
                    item.brand!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Row(
                  children: [
                    if (item.color != null) ...[
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: _getColorFromString(item.color!),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      item.category ?? 'Uncategorized',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Actions
          Column(
            children: [
              if (isMultiSelectMode)
                Checkbox(
                  value: isSelected,
                  onChanged: (value) {
                    controller.toggleItemSelectionInMultiSelect(item.id);
                  },
                )
              else
                _buildFavoriteButton(context, ref),
              
              if (_shouldShowWarningIcon())
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Theme.of(context).colorScheme.error,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
      ),
      child: item.imageUrl != null
          ? Image.network(
              item.imageUrl!,
              fit: BoxFit.cover,
              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.primary,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                return _buildPlaceholderImage(context);
              },
            )
          : _buildPlaceholderImage(context),
    );
  }

  Widget _buildPlaceholderImage(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Center(
        child: Icon(
          Icons.checkroom,
          size: 48,
          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
        ),
      ),
    );
  }

  Widget _buildFavoriteButton(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: () {
          ref.read(wardrobeControllerProvider.notifier).toggleFavorite(item.id);
        },
        icon: Icon(
          item.isFavorite ? Icons.favorite : Icons.favorite_border,
          color: item.isFavorite
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.onSurface,
        ),
        iconSize: 20,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        padding: const EdgeInsets.all(4),
      ),
    );
  }

  bool _shouldShowWarningIcon() {
    if (item.lastWornDate == null) return false;
    final sixMonthsAgo = DateTime.now().subtract(const Duration(days: 180));
    return item.lastWornDate!.isBefore(sixMonthsAgo);
  }

  Color _getColorFromString(String colorName) {
    // Simple color mapping - in real app this could be more sophisticated
    switch (colorName.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'pink':
        return Colors.pink;
      case 'brown':
        return Colors.brown;
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'grey':
      case 'gray':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
