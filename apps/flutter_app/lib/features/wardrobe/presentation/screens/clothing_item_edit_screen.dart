import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/clothing_item.dart';
import '../widgets/item_edit/item_image_picker.dart';
import '../widgets/item_edit/item_edit_form.dart';
import '../widgets/item_edit/save_delete_buttons.dart';
import '../controllers/clothing_item_edit_controller.dart';
import '../../../../core/ui/system_state_widget.dart';

/// Screen for editing an existing clothing item's details
/// Allows users to modify all aspects of a clothing item including image, name, category, etc.
class ClothingItemEditScreen extends ConsumerWidget {
  final ClothingItem item;

  const ClothingItemEditScreen({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = clothingItemEditControllerProvider(item.id);
    final state = ref.watch(controller);
    final controllerNotifier = ref.read(controller.notifier);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Handle edge case where item might be null (though unlikely in edit context)
    if (item.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Item'),
        ),
        body: SystemStateWidget(
          icon: Icons.error_outline,
          title: 'Item Not Found',
          message: 'The item you\'re trying to edit could not be found.',
          onCTA: () => Navigator.of(context).pop(),
          ctaText: 'Go Back',
          iconColor: colorScheme.error,
        ),
      );
    }

    // Extract values from controller state
    final currentItem = state.draftItem ?? item;
    final isImageLoading = state.imageState.isLoading;
    final imageError = state.imageState.hasError ? state.imageState.error.toString() : null;
    final isSaving = state.saveState.isLoading;
    final isDeleting = state.deleteState.isLoading;
    final isFormDirty = state.isDirty;
    final isFormValid = state.isValid;
    final canSave = isFormDirty && isFormValid && !isSaving && !isDeleting;

    return PopScope(
      canPop: !isFormDirty,
      onPopInvoked: (didPop) {
        if (!didPop && isFormDirty) {
          _showUnsavedChangesDialog(context);
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: _buildAppBar(theme, colorScheme, canSave, () => _handleSave(context, controllerNotifier)),
        body: _buildBody(
          context,
          theme, 
          colorScheme, 
          currentItem, 
          isImageLoading, 
          imageError, 
          canSave, 
          isSaving, 
          isDeleting, 
          controllerNotifier,
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    ThemeData theme, 
    ColorScheme colorScheme, 
    bool canSave, 
    VoidCallback onSave,
  ) {
    return AppBar(
      title: Text(
        'Edit Item',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      elevation: 0,
      scrolledUnderElevation: 1,
      actions: [
        // Quick Save Button in AppBar
        TextButton(
          onPressed: canSave ? onSave : null,
          child: Text(
            'Save',
            style: TextStyle(
              color: canSave ? colorScheme.primary : colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBody(
    BuildContext context,
    ThemeData theme, 
    ColorScheme colorScheme,
    ClothingItem currentItem,
    bool isImageLoading,
    String? imageError,
    bool canSave,
    bool isSaving,
    bool isDeleting,
    ClothingItemEditController controllerNotifier,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Item Image Picker
          ItemImagePicker(
            initialImageUrl: currentItem.imageUrl,
            selectedImage: null, // We'll handle this through controller
            isLoading: isImageLoading,
            error: imageError,
            onPickImage: () => controllerNotifier.pickNewImage(),
            onCropImage: () => controllerNotifier.cropCurrentImage(),
            onRemoveImage: () => controllerNotifier.removeItemImage(),
          ),
          
          const SizedBox(height: 16),
          
          // Item Edit Form
          ItemEditForm(
            item: currentItem,
            nameError: null, // Validation through controller
            categoryError: null, // Validation through controller
            colorError: null, // Validation through controller
            onNameChanged: (value) => controllerNotifier.updateItemName(value),
            onDescriptionChanged: (value) => controllerNotifier.updateItemDescription(value),
            onCategoryChanged: (value) => controllerNotifier.updateItemCategory(value),
            onColorChanged: (value) => controllerNotifier.updateItemColor(value),
            onBrandChanged: (value) => controllerNotifier.updateItemBrand(value),
            onSizeChanged: (value) => controllerNotifier.updateItemSize(value),
            onSeasonsChanged: (seasons) => controllerNotifier.updateItemSeasons(seasons),
            onTagsChanged: (tags) => controllerNotifier.updateItemTags(tags),
          ),
          
          const SizedBox(height: 16),
          
          // Save/Delete Buttons
          SaveDeleteButtons(
            isSaveEnabled: canSave,
            isSaving: isSaving,
            isDeleting: isDeleting,
            onSave: () => _handleSave(context, controllerNotifier),
            onDelete: () => _handleDelete(context, controllerNotifier),
          ),
          
          // Bottom padding for safe area
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // Event Handlers
  void _handleSave(BuildContext context, ClothingItemEditController controllerNotifier) async {
    await controllerNotifier.saveItem();
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  void _handleDelete(BuildContext context, ClothingItemEditController controllerNotifier) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text(
          'Are you sure you want to delete "${item.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await controllerNotifier.deleteItem();
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _showUnsavedChangesDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text(
          'You have unsaved changes. Are you sure you want to leave without saving?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close edit screen
            },
            child: const Text('Discard Changes'),
          ),
        ],
      ),
    );
  }
}

/// Route generator for ClothingItemEditScreen
class ClothingItemEditRoute {
  static const String name = '/clothing-item-edit';

  static Route<void> route({
    required ClothingItem item,
  }) {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: name),
      builder: (context) => ClothingItemEditScreen(
        item: item,
      ),
    );
  }
}

/// Extension for easy navigation
extension ClothingItemEditNavigation on NavigatorState {
  Future<void> pushClothingItemEdit({
    required ClothingItem item,
  }) {
    return push(
      ClothingItemEditRoute.route(
        item: item,
      ),
    );
  }
}
