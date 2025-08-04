import 'package:flutter/material.dart';
import '../../../../outfits/domain/entities/outfit.dart';

/// A draggable widget representing an outfit that can be dragged onto the calendar
/// Displays the outfit's image and name with drag functionality
class DraggableCombinationCard extends StatelessWidget {
  final Outfit outfit;
  final VoidCallback? onDragStarted;
  final VoidCallback? onDragEnd;

  const DraggableCombinationCard({
    super.key,
    required this.outfit,
    this.onDragStarted,
    this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Draggable<Outfit>(
      data: outfit,
      onDragStarted: onDragStarted,
      onDragEnd: (_) => onDragEnd?.call(),
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 120,
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: colorScheme.surface,
            border: Border.all(
              color: colorScheme.primary,
              width: 2,
            ),
          ),
          child: _buildContent(context, isDragging: true),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _buildCard(context),
      ),
      child: _buildCard(context),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 120,
        height: 140,
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context, {bool isDragging = false}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Outfit image
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: colorScheme.surfaceVariant,
                image: outfit.imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(outfit.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: outfit.imageUrl == null
                  ? Icon(
                      Icons.checkroom,
                      color: colorScheme.onSurfaceVariant,
                      size: 32,
                    )
                  : null,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Outfit name
          Text(
            outfit.name,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: isDragging ? colorScheme.primary : null,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          
          // Drag indicator
          const SizedBox(height: 4),
          Container(
            width: 20,
            height: 3,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
