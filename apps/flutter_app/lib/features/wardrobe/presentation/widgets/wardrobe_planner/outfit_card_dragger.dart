import 'package:flutter/material.dart';
import '../../../../outfits/domain/entities/outfit.dart';

class OutfitCardDragger extends StatelessWidget {
  final Outfit outfit;
  final VoidCallback onDragStarted;
  final VoidCallback onDragCompleted;

  const OutfitCardDragger({
    super.key,
    required this.outfit,
    required this.onDragStarted,
    required this.onDragCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: LongPressDraggable<Outfit>(
        data: outfit,
        onDragStarted: onDragStarted,
        onDragCompleted: onDragCompleted,
        feedback: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 100,
            height: 90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: _buildOutfitContent(context, isDragging: true),
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.5,
          child: _buildOutfitCard(context),
        ),
        child: _buildOutfitCard(context),
      ),
    );
  }

  Widget _buildOutfitCard(BuildContext context) {
    return Container(
      width: 100,
      height: 90,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surfaceVariant,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: _buildOutfitContent(context),
    );
  }

  Widget _buildOutfitContent(BuildContext context, {bool isDragging = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Outfit image or icon
        if (outfit.imageUrl != null && outfit.imageUrl!.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              outfit.imageUrl!,
              width: 50,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 50,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.checkroom,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),
            ),
          )
        else
          Container(
            width: 50,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.checkroom,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
        
        const SizedBox(height: 8),
        
        // Outfit name
        Text(
          outfit.name,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: isDragging 
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
