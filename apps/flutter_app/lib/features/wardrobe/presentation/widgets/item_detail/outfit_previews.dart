import 'package:flutter/material.dart';
import '../../../domain/entities/clothing_item.dart';
import '../../../../outfits/domain/entities/outfit.dart';

/// Widget for displaying outfits that include this clothing item
/// Shows a horizontal scrollable list of outfit previews
class OutfitPreviews extends StatelessWidget {
  final ClothingItem item;
  final List<Outfit> outfits;
  final VoidCallback? onViewAllOutfits;
  final void Function(Outfit)? onOutfitTap;

  const OutfitPreviews({
    super.key,
    required this.item,
    required this.outfits,
    this.onViewAllOutfits,
    this.onOutfitTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Row(
              children: [
                Icon(
                  Icons.checkroom_outlined,
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Used in Outfits',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                if (outfits.isNotEmpty)
                  TextButton(
                    onPressed: onViewAllOutfits ?? () => _showComingSoon(context),
                    child: Text(
                      'View All (${outfits.length})',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Outfits list or empty state
            if (outfits.isEmpty)
              _buildEmptyState(context, theme, colorScheme)
            else
              _buildOutfitsList(context, theme, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            Icons.checkroom_outlined,
            size: 48,
            color: colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'Not used in any outfits yet',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Create an outfit to see it here',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => _showComingSoon(context),
            icon: const Icon(Icons.add),
            label: const Text('Create Outfit'),
            style: FilledButton.styleFrom(
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutfitsList(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: outfits.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final outfit = outfits[index];
          return _buildOutfitCard(context, theme, colorScheme, outfit);
        },
      ),
    );
  }

  Widget _buildOutfitCard(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    Outfit outfit,
  ) {
    return Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () {
          if (onOutfitTap != null) {
            onOutfitTap!(outfit);
          } else {
            _showComingSoon(context);
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 100,
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Outfit image
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: outfit.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            outfit.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildOutfitPlaceholder(colorScheme);
                            },
                          ),
                        )
                      : _buildOutfitPlaceholder(colorScheme),
                ),
              ),
              
              const SizedBox(height: 6),
              
              // Outfit name
              Text(
                outfit.name,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              // Outfit metadata
              Row(
                children: [
                  Icon(
                    Icons.favorite,
                    size: 10,
                    color: outfit.isFavorite 
                        ? Colors.red 
                        : colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Text(
                      '${outfit.clothingItemIds.length} items',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 10,
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
      ),
    );
  }

  Widget _buildOutfitPlaceholder(ColorScheme colorScheme) {
    return Center(
      child: Icon(
        Icons.checkroom_outlined,
        size: 24,
        color: colorScheme.onSurfaceVariant.withOpacity(0.3),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Outfit functionality coming soon!'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }
}

/// Sample outfit data for testing the UI
class OutfitPreviewsData {
  static List<Outfit> getSampleOutfits() {
    final now = DateTime.now();
    
    return [
      Outfit(
        id: '1',
        userId: 'user1',
        name: 'Casual Friday',
        description: 'Comfortable office look',
        clothingItemIds: ['item1', 'item2', 'item3'],
        occasion: 'work',
        season: 'spring',
        isFavorite: true,
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(days: 7)),
      ),
      Outfit(
        id: '2',
        userId: 'user1',
        name: 'Weekend Brunch',
        description: 'Relaxed weekend style',
        clothingItemIds: ['item1', 'item4', 'item5'],
        occasion: 'casual',
        season: 'spring',
        isFavorite: false,
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
      Outfit(
        id: '3',
        userId: 'user1',
        name: 'Date Night',
        description: 'Elegant evening look',
        clothingItemIds: ['item1', 'item6', 'item7'],
        occasion: 'evening',
        season: 'spring',
        isFavorite: true,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }
}
