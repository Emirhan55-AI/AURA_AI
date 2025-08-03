import 'package:flutter/material.dart';

/// Outfit Card - Displays AI-suggested outfits in chat messages
/// 
/// This widget shows outfit suggestions with thumbnail, name, and
/// action buttons for favoriting and viewing details.
class OutfitCard extends StatelessWidget {
  final Map<String, dynamic> outfit;
  final double? width;
  final double? height;

  const OutfitCard({
    super.key,
    required this.outfit,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: width ?? 140,
      height: height ?? 160,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () => _viewOutfitDetails(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Outfit image/thumbnail
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                  ),
                  child: outfit['coverImageUrl'] != null
                      ? Image.network(
                          outfit['coverImageUrl'].toString(),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholder(context, theme, colorScheme),
                        )
                      : _buildPlaceholder(context, theme, colorScheme),
                ),
              ),
              
              // Outfit info
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Outfit name
                      Text(
                        (outfit['name'] ?? 'Outfit').toString(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Items count
                      Text(
                        '${(outfit['clothingItemIds'] as List?)?.length ?? 0} items',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Action buttons
                      Row(
                        children: [
                          // Favorite button
                          InkWell(
                            onTap: () => _toggleFavorite(context),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                outfit['isFavorite'] == true
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 16,
                                color: outfit['isFavorite'] == true
                                    ? colorScheme.error
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          
                          const Spacer(),
                          
                          // View button
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer,
            colorScheme.secondaryContainer,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.style,
          color: colorScheme.onPrimaryContainer,
          size: 32,
        ),
      ),
    );
  }

  void _viewOutfitDetails(BuildContext context) {
    // TODO: Navigate to outfit details screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('View outfit: ${outfit['name'] ?? 'Outfit'}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _toggleFavorite(BuildContext context) {
    // TODO: Implement favorite toggle functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          outfit['isFavorite'] == true
              ? 'Removed from favorites'
              : 'Added to favorites',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
