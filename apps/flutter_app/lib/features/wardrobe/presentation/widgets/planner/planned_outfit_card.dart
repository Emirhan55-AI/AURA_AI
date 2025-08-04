import 'package:flutter/material.dart';
import '../../../../outfits/domain/entities/outfit.dart';

/// A card widget representing an outfit that has been planned for a specific date
/// Displays the outfit's image and name, with options to remove the plan
class PlannedOutfitCard extends StatelessWidget {
  final Outfit outfit;
  final DateTime plannedDate;
  final VoidCallback? onRemove;
  final VoidCallback? onTap;

  const PlannedOutfitCard({
    super.key,
    required this.outfit,
    required this.plannedDate,
    this.onRemove,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          width: 80,
          height: 100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Remove button
              if (onRemove != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: onRemove,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        child: Icon(
                          Icons.close,
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              
              // Outfit image
              Expanded(
                child: Container(
                  width: 50,
                  height: 50,
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
                          size: 24,
                        )
                      : null,
                ),
              ),
              
              const SizedBox(height: 4),
              
              // Outfit name
              Text(
                outfit.name,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
