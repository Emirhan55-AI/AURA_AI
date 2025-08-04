import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Widget for editing the clothing item's image
/// Handles image display, replacement, and cropping operations
class ItemImagePicker extends StatefulWidget {
  final String? initialImageUrl;
  final XFile? selectedImage;
  final bool isLoading;
  final String? error;
  final VoidCallback? onPickImage;
  final VoidCallback? onCropImage;
  final VoidCallback? onRemoveImage;

  const ItemImagePicker({
    super.key,
    this.initialImageUrl,
    this.selectedImage,
    this.isLoading = false,
    this.error,
    this.onPickImage,
    this.onCropImage,
    this.onRemoveImage,
  });

  @override
  State<ItemImagePicker> createState() => _ItemImagePickerState();
}

class _ItemImagePickerState extends State<ItemImagePicker> {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.photo_camera_outlined,
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Item Image',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (widget.error != null)
              _buildErrorState(theme, colorScheme)
            else if (widget.isLoading)
              _buildLoadingState(theme, colorScheme)
            else
              _buildImageState(theme, colorScheme),

            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: widget.onPickImage,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text(_hasImage ? 'Replace' : 'Select'),
                  ),
                ),
                if (_hasImage) ...[
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: widget.onCropImage,
                    icon: const Icon(Icons.crop_outlined),
                    label: const Text('Crop'),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: widget.onRemoveImage,
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Remove Image',
                    color: colorScheme.error,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool get _hasImage => widget.selectedImage != null || widget.initialImageUrl != null;

  Widget _buildErrorState(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: colorScheme.onErrorContainer,
            ),
            const SizedBox(height: 8),
            Text(
              'Image Error',
              style: theme.textTheme.titleSmall?.copyWith(
                color: colorScheme.onErrorContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                widget.error!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onErrorContainer,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Processing image...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageState(ThemeData theme, ColorScheme colorScheme) {
    if (!_hasImage) {
      return _buildPlaceholder(theme, colorScheme);
    }

    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: widget.selectedImage != null
            ? Image.network(
                widget.selectedImage!.path, // In real implementation, this would be a file path
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) => _buildImageError(theme, colorScheme),
              )
            : widget.initialImageUrl != null
                ? Image.network(
                    widget.initialImageUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) => _buildImageError(theme, colorScheme),
                  )
                : _buildPlaceholder(theme, colorScheme),
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.3),
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 48,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              'Select an image',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageError(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      height: 200,
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image_outlined,
              size: 48,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              'Failed to load image',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
