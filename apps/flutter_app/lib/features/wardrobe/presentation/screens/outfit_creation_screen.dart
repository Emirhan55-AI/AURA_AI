import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ui/system_state_widget.dart';
import '../controllers/outfit_creation_controller.dart';
import '../widgets/outfit_creation/wardrobe_item_selector.dart';
import '../widgets/outfit_creation/selected_items_preview.dart';
import '../widgets/outfit_creation/outfit_details_form.dart';

/// OutfitCreationScreen allows users to create new clothing combinations
/// by selecting items from their wardrobe and adding outfit details.
/// 
/// Features:
/// - Browse and select clothing items from wardrobe
/// - Preview selected items as an outfit
/// - Add outfit details (title, description, tags, occasion, season)
/// - Save the outfit to the user's collection
class OutfitCreationScreen extends ConsumerStatefulWidget {
  /// Optional outfit ID for editing existing outfits
  final String? outfitId;

  const OutfitCreationScreen({
    super.key,
    this.outfitId,
  });

  @override
  ConsumerState<OutfitCreationScreen> createState() => _OutfitCreationScreenState();
}

class _OutfitCreationScreenState extends ConsumerState<OutfitCreationScreen> {
  // Local state for UI management (TextEditingControllers for form inputs)
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _initializeScreen() {
    // If editing an existing outfit, load its data
    if (widget.outfitId != null) {
      // TODO: Load outfit data when edit functionality is implemented
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Watch the controller state
    final outfitCreationState = ref.watch(outfitCreationControllerProvider);
    final controller = ref.read(outfitCreationControllerProvider.notifier);
    
    // Extract state values
    final wardrobeItemsAsync = outfitCreationState.wardrobeItems;
    final draftOutfit = outfitCreationState.draftOutfit;
    final isSaving = outfitCreationState.isSaving;
    final isFormValid = outfitCreationState.isFormValid;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.outfitId != null ? 'Edit Outfit' : 'Create Outfit'),
        actions: [
          TextButton(
            onPressed: isFormValid && !isSaving ? () => _onSave(controller) : null,
            child: isSaving
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isFormValid ? colorScheme.primary : colorScheme.outline,
                      ),
                    ),
                  )
                : Text(
                    'Save',
                    style: TextStyle(
                      color: isFormValid ? colorScheme.primary : colorScheme.outline,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: wardrobeItemsAsync.when(
        loading: () => const SystemStateWidget(
          icon: Icons.hourglass_empty,
          title: 'Loading wardrobe...',
          message: 'Please wait while we load your clothing items.',
        ),
        error: (error, stackTrace) => SystemStateWidget(
          icon: Icons.error_outline,
          iconColor: colorScheme.error,
          title: 'Something went wrong',
          message: 'Failed to load wardrobe items. Please try again.',
          onRetry: () => controller.retryLoadWardrobeItems(),
          retryText: 'Try Again',
        ),
        data: (wardrobeItems) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Wardrobe Item Selector
                WardrobeItemSelector(
                  wardrobeItems: wardrobeItems,
                  selectedItemIds: draftOutfit.clothingItemIds,
                  onItemSelected: (itemId, isSelected) {
                    if (isSelected) {
                      final item = wardrobeItems.firstWhere((item) => item.id == itemId);
                      controller.selectItem(item);
                    } else {
                      controller.deselectItem(itemId);
                    }
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Selected Items Preview
                SelectedItemsPreview(
                  wardrobeItems: wardrobeItems,
                  selectedItemIds: draftOutfit.clothingItemIds,
                  onItemRemoved: (itemId) => controller.deselectItem(itemId),
                ),
                
                const SizedBox(height: 24),
                
                // Outfit Details Form
                OutfitDetailsForm(
                  titleController: _titleController,
                  descriptionController: _descriptionController,
                  tags: draftOutfit.tags ?? [],
                  selectedOccasion: draftOutfit.occasion,
                  selectedSeason: draftOutfit.season,
                  onTitleChanged: (title) => controller.updateTitle(title),
                  onDescriptionChanged: (description) => controller.updateDescription(description),
                  onTagsChanged: (tags) {
                    // Handle tag addition/removal
                    final currentTags = draftOutfit.tags ?? [];
                    final newTags = tags.where((tag) => !currentTags.contains(tag));
                    final removedTags = currentTags.where((tag) => !tags.contains(tag));
                    
                    for (final tag in newTags) {
                      controller.addTag(tag);
                    }
                    for (final tag in removedTags) {
                      controller.removeTag(tag);
                    }
                  },
                  onOccasionChanged: (occasion) => controller.setOccasion(occasion ?? ''),
                  onSeasonChanged: (season) => controller.setSeason(season ?? ''),
                ),
                
                // Add some bottom padding for better scrolling
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Handle save button tap
  void _onSave(OutfitCreationController controller) async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await controller.saveOutfit();
        
        if (mounted) {
          // Show success message and navigate back
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.outfitId != null ? 'Outfit updated!' : 'Outfit created!'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
          
          Navigator.of(context).pop();
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save outfit: $error'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }
}
