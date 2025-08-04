import 'package:flutter/material.dart';
import '../../../domain/entities/clothing_item.dart';

/// Widget containing action buttons for the clothing item
/// Provides quick access to common actions like edit, favorite, share, delete
class ItemActions extends StatelessWidget {
  final ClothingItem item;
  final VoidCallback? onEdit;
  final VoidCallback? onToggleFavorite;
  final VoidCallback? onShare;
  final VoidCallback? onDelete;
  final bool isOwner;

  const ItemActions({
    super.key,
    required this.item,
    this.onEdit,
    this.onToggleFavorite,
    this.onShare,
    this.onDelete,
    this.isOwner = true, // Default to true for now, will be determined by auth state later
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
            Text(
              'Actions',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            
            // Action buttons row
            Row(
              children: [
                // Edit button (only for owner)
                if (isOwner) ...[
                  Expanded(
                    child: _buildActionButton(
                      context,
                      theme,
                      colorScheme,
                      icon: Icons.edit_outlined,
                      label: 'Edit',
                      onPressed: onEdit,
                      isPrimary: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                
                // Favorite button
                Expanded(
                  child: _buildActionButton(
                    context,
                    theme,
                    colorScheme,
                    icon: item.isFavorite 
                        ? Icons.favorite 
                        : Icons.favorite_border,
                    label: item.isFavorite ? 'Favorited' : 'Favorite',
                    onPressed: onToggleFavorite,
                    color: item.isFavorite 
                        ? Colors.red 
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Share button
                Expanded(
                  child: _buildActionButton(
                    context,
                    theme,
                    colorScheme,
                    icon: Icons.share_outlined,
                    label: 'Share',
                    onPressed: onShare,
                  ),
                ),
                
                // Delete button (only for owner)
                if (isOwner) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildActionButton(
                      context,
                      theme,
                      colorScheme,
                      icon: Icons.delete_outline,
                      label: 'Delete',
                      onPressed: onDelete,
                      color: colorScheme.error,
                      isDestructive: true,
                    ),
                  ),
                ],
              ],
            ),
            
            // Additional info row
            const SizedBox(height: 12),
            _buildInfoRow(context, theme, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme, {
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    bool isPrimary = false,
    bool isDestructive = false,
    Color? color,
  }) {
    final buttonColor = color ?? 
        (isPrimary 
            ? colorScheme.primary 
            : colorScheme.onSurfaceVariant);
    
    final backgroundColor = isPrimary 
        ? colorScheme.primaryContainer 
        : isDestructive 
            ? colorScheme.errorContainer.withOpacity(0.5)
            : colorScheme.surfaceContainerHighest;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed ?? () => _showComingSoonSnackBar(context, label),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: buttonColor,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: buttonColor,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          // Favorite status
          Icon(
            item.isFavorite ? Icons.favorite : Icons.favorite_border,
            size: 14,
            color: item.isFavorite 
                ? Colors.red 
                : colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            item.isFavorite ? 'In favorites' : 'Not in favorites',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
          
          const Spacer(),
          
          // Usage indicator
          Icon(
            Icons.schedule,
            size: 14,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            item.lastWornDate != null 
                ? 'Recently worn' 
                : 'Never worn',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoonSnackBar(BuildContext context, String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$action functionality coming soon!'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
