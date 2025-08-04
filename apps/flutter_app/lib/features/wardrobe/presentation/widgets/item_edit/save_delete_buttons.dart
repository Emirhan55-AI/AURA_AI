import 'package:flutter/material.dart';

/// Widget containing the main action buttons for saving and deleting the item
/// Handles the primary user actions in the edit screen
class SaveDeleteButtons extends StatelessWidget {
  final bool isSaveEnabled;
  final bool isSaving;
  final bool isDeleting;
  final VoidCallback? onSave;
  final VoidCallback? onDelete;
  final String saveText;
  final String deleteText;

  const SaveDeleteButtons({
    super.key,
    this.isSaveEnabled = true,
    this.isSaving = false,
    this.isDeleting = false,
    this.onSave,
    this.onDelete,
    this.saveText = 'Save Changes',
    this.deleteText = 'Delete Item',
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
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Save Button
            FilledButton.icon(
              onPressed: isSaveEnabled && !isSaving && !isDeleting ? onSave : null,
              icon: isSaving 
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.onPrimary,
                      ),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(isSaving ? 'Saving...' : saveText),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Delete Button
            OutlinedButton.icon(
              onPressed: !isSaving && !isDeleting ? onDelete : null,
              icon: isDeleting
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.error,
                      ),
                    )
                  : const Icon(Icons.delete_outline),
              label: Text(isDeleting ? 'Deleting...' : deleteText),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.error,
                side: BorderSide(color: colorScheme.error),
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            // Helper text
            const SizedBox(height: 8),
            Text(
              'Changes will be saved to your wardrobe. Deleted items cannot be recovered.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
