import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/wardrobe_controller.dart';

class WardrobeMultiSelectToolbar extends ConsumerWidget {
  const WardrobeMultiSelectToolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(wardrobeControllerProvider.notifier);
    final selectedCount = controller.selectedItemsInMultiSelect.length;

    return Container(
      height: 56,
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Row(
        children: [
          // Close button
          IconButton(
            onPressed: () => controller.exitMultiSelectMode(),
            icon: const Icon(Icons.close),
            tooltip: 'Exit selection mode',
          ),
          
          // Selected count
          Expanded(
            child: Text(
              '$selectedCount item${selectedCount == 1 ? '' : 's'} selected',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
          ),
          
          // Action buttons
          if (selectedCount > 0) ...[
            // Delete button
            IconButton(
              onPressed: () => _showDeleteConfirmationDialog(context, ref, selectedCount),
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete selected items',
            ),
            
            // Move/organize button (placeholder for future implementation)
            IconButton(
              onPressed: () => _showMoveDialog(context),
              icon: const Icon(Icons.folder_outlined),
              tooltip: 'Move to category',
            ),
            
            // Favorite toggle button
            IconButton(
              onPressed: () => _toggleFavoriteForSelected(ref, context),
              icon: const Icon(Icons.favorite_border),
              tooltip: 'Toggle favorite for selected',
            ),
          ],
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, WidgetRef ref, int count) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Items'),
        content: Text(
          'Are you sure you want to delete $count item${count == 1 ? '' : 's'}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(wardrobeControllerProvider.notifier).deleteSelectedItems();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showMoveDialog(BuildContext context) {
    // Placeholder for move functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Move to category functionality coming soon!'),
      ),
    );
  }

  void _toggleFavoriteForSelected(WidgetRef ref, BuildContext context) {
    // Placeholder for bulk favorite toggle
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bulk favorite toggle functionality coming soon!'),
      ),
    );
  }
}
