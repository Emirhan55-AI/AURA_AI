import 'package:flutter/material.dart';
import 'models.dart';

/// Card widget for displaying individual insights in the insights tab
class InsightCard extends StatelessWidget {
  final Insight insight;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onActionPressed;

  const InsightCard({
    super.key,
    required this.insight,
    this.onFavoriteToggle,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with icon, priority, and favorite button
            Row(
              children: [
                // Priority indicator and icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(insight.priority, colorScheme).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    insight.icon,
                    size: 20,
                    color: _getPriorityColor(insight.priority, colorScheme),
                  ),
                ),
                const SizedBox(width: 12),
                // Priority badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(insight.priority, colorScheme).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    insight.priority.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: _getPriorityColor(insight.priority, colorScheme),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                // Favorite button
                IconButton(
                  onPressed: onFavoriteToggle,
                  icon: Icon(
                    insight.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: insight.isFavorite ? colorScheme.error : colorScheme.onSurfaceVariant,
                  ),
                  tooltip: insight.isFavorite ? 'Remove from favorites' : 'Add to favorites',
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Title
            Text(
              insight.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Description
            Text(
              insight.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            
            // Action button (if applicable)
            if (insight.actionType != InsightActionType.none) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onActionPressed,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    side: BorderSide(color: colorScheme.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(_getActionText(insight.actionType)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority, ColorScheme colorScheme) {
    switch (priority.toLowerCase()) {
      case 'high':
        return colorScheme.error;
      case 'medium':
        return Colors.orange;
      case 'low':
        return colorScheme.primary;
      default:
        return colorScheme.primary;
    }
  }

  String _getActionText(InsightActionType actionType) {
    switch (actionType) {
      case InsightActionType.viewItems:
        return 'View Items';
      case InsightActionType.addToWardrobe:
        return 'Add to Wardrobe';
      case InsightActionType.createOutfit:
        return 'Create Outfit';
      case InsightActionType.shoppingList:
        return 'Add to Shopping List';
      case InsightActionType.none:
        return '';
    }
  }
}
