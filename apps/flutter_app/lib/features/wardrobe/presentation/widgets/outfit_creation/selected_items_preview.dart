import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/clothing_item.dart';

/// SelectedItemsPreview shows a visual preview of the selected clothing items
/// as they would appear together in an outfit.
/// 
/// Features:
/// - Visual collage/layout of selected items
/// - Remove items from selection
/// - Empty state when no items selected
/// - Responsive layout based on number of items
class SelectedItemsPreview extends ConsumerWidget {
  final List<ClothingItem> wardrobeItems;
  final List<String> selectedItemIds;
  final void Function(String itemId) onItemRemoved;

  const SelectedItemsPreview({
    super.key,
    required this.wardrobeItems,
    required this.selectedItemIds,
    required this.onItemRemoved,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title with item count
        Row(
          children: [
            Text(
              'Outfit Preview',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 8),
            if (selectedItemIds.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${selectedItemIds.length}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Preview container
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.5),
              width: 1,
            ),
            color: colorScheme.surface,
          ),
          child: selectedItemIds.isEmpty
              ? _buildEmptyState(context)
              : _buildPreview(context),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.checkroom_outlined,
            size: 48,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            'No items selected',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Select items from your wardrobe to see the outfit preview',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(BuildContext context) {
    // For UI demonstration, we'll show placeholder items
    // In the real implementation, these would be actual ClothingItem objects
    final sampleItems = _generateSampleItemsFromIds(selectedItemIds);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: selectedItemIds.length == 1
          ? _buildSingleItemPreview(context, sampleItems.first)
          : selectedItemIds.length == 2
              ? _buildTwoItemsPreview(context, sampleItems)
              : _buildMultipleItemsPreview(context, sampleItems),
    );
  }

  List<ClothingItem> _generateSampleItemsFromIds(List<String> itemIds) {
    final now = DateTime.now();
    return itemIds.map((id) {
      // Generate sample data based on the ID
      final itemNames = [
        'Blue Denim Jacket',
        'White Cotton T-Shirt',
        'Black Skinny Jeans',
        'Red Summer Dress',
        'Brown Leather Shoes',
        'Striped Sweater',
      ];
      final colors = ['Blue', 'White', 'Black', 'Red', 'Brown', 'Navy'];
      final categories = ['Outerwear', 'Tops', 'Bottoms', 'Dresses', 'Shoes', 'Tops'];

      final index = int.tryParse(id) ?? 1;
      final adjustedIndex = (index - 1) % itemNames.length;

      return ClothingItem(
        id: id,
        userId: 'user1',
        name: itemNames[adjustedIndex],
        category: categories[adjustedIndex],
        color: colors[adjustedIndex],
        imageUrl: 'https://via.placeholder.com/150x200/${_getColorHex(colors[adjustedIndex])}/ffffff?text=${Uri.encodeComponent(itemNames[adjustedIndex].split(' ').first)}',
        createdAt: now,
        updatedAt: now,
      );
    }).toList();
  }

  String _getColorHex(String color) {
    switch (color.toLowerCase()) {
      case 'blue': return '4A90E2';
      case 'white': return 'ffffff';
      case 'black': return '2C3E50';
      case 'red': return 'E74C3C';
      case 'brown': return '8B4513';
      case 'navy': return '34495E';
      default: return '95A5A6';
    }
  }

  Widget _buildSingleItemPreview(BuildContext context, ClothingItem item) {
    return Center(
      child: _ItemPreviewCard(
        item: item,
        onRemove: () => onItemRemoved(item.id),
        size: 120,
      ),
    );
  }

  Widget _buildTwoItemsPreview(BuildContext context, List<ClothingItem> items) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: items.map((item) => 
        _ItemPreviewCard(
          item: item,
          onRemove: () => onItemRemoved(item.id),
          size: 100,
        ),
      ).toList(),
    );
  }

  Widget _buildMultipleItemsPreview(BuildContext context, List<ClothingItem> items) {
    // For multiple items, we'll create a collage-like layout
    return GridView.count(
      crossAxisCount: selectedItemIds.length <= 4 ? 2 : 3,
      childAspectRatio: 1,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children: items.map((item) => 
        _ItemPreviewCard(
          item: item,
          onRemove: () => onItemRemoved(item.id),
          size: null, // Let the grid determine the size
        ),
      ).toList(),
    );
  }
}

class _ItemPreviewCard extends StatelessWidget {
  final ClothingItem item;
  final VoidCallback onRemove;
  final double? size;

  const _ItemPreviewCard({
    required this.item,
    required this.onRemove,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget cardContent = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: colorScheme.surfaceVariant,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Item image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: item.imageUrl != null
                ? Image.network(
                    item.imageUrl!,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(context),
                  )
                : _buildImagePlaceholder(context),
          ),
          
          // Remove button
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colorScheme.error,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.2),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.close,
                  size: 12,
                  color: colorScheme.onError,
                ),
              ),
            ),
          ),

          // Item label (for smaller cards)
          if (size != null && size! < 100)
            Positioned(
              bottom: 4,
              left: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item.name,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );

    // Add tooltip for item details
    return Tooltip(
      message: '${item.name}\n${item.brand ?? ''}\n${item.color ?? ''}',
      child: cardContent,
    );
  }

  Widget _buildImagePlaceholder(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      width: size,
      height: size,
      color: colorScheme.surfaceVariant,
      child: Icon(
        Icons.checkroom,
        size: size != null ? size! * 0.4 : 24,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}
