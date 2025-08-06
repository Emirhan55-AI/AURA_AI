import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entities/clothing_item.dart';
import '../../domain/repositories/i_user_wardrobe_repository.dart';
import '../../data/providers/wardrobe_providers.dart';
import '../../../../core/providers/service_providers.dart';

part 'clothing_item_edit_controller.g.dart';

/// State class for managing clothing item edit screen state
class ClothingItemEditState {
  final AsyncValue<ClothingItem?> originalItem;
  final ClothingItem? draftItem;
  final AsyncValue<void> saveState;
  final AsyncValue<void> deleteState;
  final AsyncValue<void> imageState;
  final String itemId;
  final bool isDirty;
  final bool isValid;

  const ClothingItemEditState({
    required this.originalItem,
    this.draftItem,
    required this.saveState,
    required this.deleteState,
    required this.imageState,
    required this.itemId,
    required this.isDirty,
    required this.isValid,
  });

  /// Initial state with loading original item
  factory ClothingItemEditState.initial(String itemId) {
    return ClothingItemEditState(
      originalItem: const AsyncValue<ClothingItem?>.loading(),
      draftItem: null,
      saveState: const AsyncValue<void>.data(null),
      deleteState: const AsyncValue<void>.data(null),
      imageState: const AsyncValue<void>.data(null),
      itemId: itemId,
      isDirty: false,
      isValid: false,
    );
  }

  /// Copy with method for state updates
  ClothingItemEditState copyWith({
    AsyncValue<ClothingItem?>? originalItem,
    ClothingItem? draftItem,
    AsyncValue<void>? saveState,
    AsyncValue<void>? deleteState,
    AsyncValue<void>? imageState,
    String? itemId,
    bool? isDirty,
    bool? isValid,
  }) {
    return ClothingItemEditState(
      originalItem: originalItem ?? this.originalItem,
      draftItem: draftItem ?? this.draftItem,
      saveState: saveState ?? this.saveState,
      deleteState: deleteState ?? this.deleteState,
      imageState: imageState ?? this.imageState,
      itemId: itemId ?? this.itemId,
      isDirty: isDirty ?? this.isDirty,
      isValid: isValid ?? this.isValid,
    );
  }
}

@riverpod
class ClothingItemEditController extends _$ClothingItemEditController {
  @override
  ClothingItemEditState build(String itemId) {
    // Initialize with loading state and trigger initial load
    final initialState = ClothingItemEditState.initial(itemId);
    
    // Start loading the item for editing asynchronously
    Future.microtask(() => loadItemForEditing());
    
    return initialState;
  }

  /// Repository instance
  IUserWardrobeRepository get _repository => ref.read(userWardrobeRepositoryProvider);

  /// Load the original item for editing
  Future<void> loadItemForEditing() async {
    try {
      state = state.copyWith(
        originalItem: const AsyncValue<ClothingItem?>.loading(),
      );

      final result = await _repository.getItemById(state.itemId);
      
      result.fold(
        (failure) {
          state = state.copyWith(
            originalItem: AsyncValue<ClothingItem?>.error(failure, StackTrace.current),
          );
        },
        (item) {
          state = state.copyWith(
            originalItem: AsyncValue<ClothingItem?>.data(item),
            draftItem: item, // Initialize draft with original item
            isDirty: false,
            isValid: _validateItem(item),
          );
        },
      );
    } catch (e, stackTrace) {
      state = state.copyWith(
        originalItem: AsyncValue<ClothingItem?>.error(e, stackTrace),
      );
    }
  }

  /// Retry loading the item if it failed
  Future<void> retryLoadItem() async {
    await loadItemForEditing();
  }

  /// Generic method to update fields in the draft item
  void updateItemField(ClothingItem Function(ClothingItem) updater) {
    if (state.draftItem == null) return;

    final updatedItem = updater(state.draftItem!);
    final isDirty = _isItemDirty(updatedItem);
    final isValid = _validateItem(updatedItem);

    state = state.copyWith(
      draftItem: updatedItem,
      isDirty: isDirty,
      isValid: isValid,
    );
  }

  /// Update item name
  void updateItemName(String name) {
    updateItemField((item) => item.copyWith(name: name));
  }

  /// Update item category
  void updateItemCategory(String category) {
    updateItemField((item) => item.copyWith(category: category));
  }

  /// Update item description
  void updateItemDescription(String description) {
    updateItemField((item) => item.copyWith(notes: description.isEmpty ? null : description));
  }

  /// Update item brand
  void updateItemBrand(String brand) {
    updateItemField((item) => item.copyWith(brand: brand.isEmpty ? null : brand));
  }

  /// Update item size
  void updateItemSize(String size) {
    updateItemField((item) => item.copyWith(size: size.isEmpty ? null : size));
  }

  /// Update item color
  void updateItemColor(String color) {
    updateItemField((item) => item.copyWith(color: color));
  }

  /// Update item tags
  void updateItemTags(List<String> tags) {
    updateItemField((item) => item.copyWith(tags: tags));
  }

  /// Update item seasons (stored in tags for now)
  void updateItemSeasons(Set<String> seasons) {
    if (state.draftItem == null) return;

    final currentTags = List<String>.from(state.draftItem!.tags ?? []);
    final seasonTags = ['Spring', 'Summer', 'Autumn', 'Winter'];
    
    // Remove existing season tags
    currentTags.removeWhere((tag) => seasonTags.contains(tag));
    
    // Add selected seasons
    currentTags.addAll(seasons);
    
    updateItemTags(currentTags);
  }

  /// Update item image
  void updateItemImage(String imageUrl) {
    updateItemField((item) => item.copyWith(imageUrl: imageUrl));
  }

  /// Pick a new image for the item
  Future<void> pickNewImage() async {
    try {
      state = state.copyWith(
        imageState: const AsyncValue<void>.loading(),
      );

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        // Read image bytes
        final bytes = await pickedFile.readAsBytes();
        
        // Upload image to Supabase
        final imageUploadService = ref.read(imageUploadServiceProvider);
        final imageUrl = await imageUploadService.uploadClothingItemImageFromBytes(bytes);
        
        updateItemImage(imageUrl);
        state = state.copyWith(
          imageState: const AsyncValue<void>.data(null),
        );
      } else {
        state = state.copyWith(
          imageState: const AsyncValue<void>.data(null),
        );
      }
    } catch (e, stackTrace) {
      state = state.copyWith(
        imageState: AsyncValue<void>.error(e, stackTrace),
      );
    }
  }

  /// Crop the current image
  Future<void> cropCurrentImage() async {
    try {
      state = state.copyWith(
        imageState: const AsyncValue<void>.loading(),
      );

      // Simulate image cropping - in real implementation, use ImageCropper
      await Future<void>.delayed(const Duration(seconds: 1));
      
      state = state.copyWith(
        imageState: const AsyncValue<void>.data(null),
      );
    } catch (e, stackTrace) {
      state = state.copyWith(
        imageState: AsyncValue<void>.error(e, stackTrace),
      );
    }
  }

  /// Remove the item image
  void removeItemImage() {
    updateItemImage('');
  }

  /// Re-analyze current image with AI to suggest tags and properties
  Future<void> reAnalyzeWithAI() async {
    if (state.draftItem == null || state.draftItem!.imageUrl == null || state.draftItem!.imageUrl!.isEmpty) {
      return;
    }

    try {
      state = state.copyWith(
        imageState: const AsyncValue<void>.loading(),
      );

      final aiTaggingService = ref.read(aiTaggingServiceProvider);
      final analysis = await aiTaggingService.analyzeClothingImage(state.draftItem!.imageUrl!);
      
      // Update item with AI analysis results
      if (state.draftItem != null) {
        final currentTags = List<String>.from(state.draftItem!.tags ?? []);
        final aiTagsList = analysis['tags'] as List<String>? ?? [];
        
        // Merge current tags with AI tags (avoid duplicates)
        final allTags = <String>{...currentTags, ...aiTagsList}.toList();
        
        updateItemField((item) => item.copyWith(
          category: analysis['category'] as String? ?? item.category,
          color: analysis['color'] as String? ?? item.color,
          tags: allTags,
          aiTags: analysis, // Store full AI analysis results
        ));
      }
      
      state = state.copyWith(
        imageState: const AsyncValue<void>.data(null),
      );
    } catch (e, stackTrace) {
      state = state.copyWith(
        imageState: AsyncValue<void>.error(e, stackTrace),
      );
    }
  }

  /// Save the edited item
  Future<void> saveItem() async {
    if (state.draftItem == null || !state.isValid || !state.isDirty) return;

    try {
      state = state.copyWith(
        saveState: const AsyncValue<void>.loading(),
      );

      final result = await _repository.updateItem(state.draftItem!);
      
      result.fold(
        (failure) {
          state = state.copyWith(
            saveState: AsyncValue<void>.error(failure, StackTrace.current),
          );
        },
        (updatedItem) {
          state = state.copyWith(
            saveState: const AsyncValue<void>.data(null),
            originalItem: AsyncValue<ClothingItem?>.data(updatedItem),
            draftItem: updatedItem,
            isDirty: false,
          );
        },
      );
    } catch (e, stackTrace) {
      state = state.copyWith(
        saveState: AsyncValue<void>.error(e, stackTrace),
      );
    }
  }

  /// Delete the item
  Future<void> deleteItem() async {
    try {
      state = state.copyWith(
        deleteState: const AsyncValue<void>.loading(),
      );

      final result = await _repository.deleteItem(state.itemId);
      
      result.fold(
        (failure) {
          state = state.copyWith(
            deleteState: AsyncValue<void>.error(failure, StackTrace.current),
          );
        },
        (_) {
          state = state.copyWith(
            deleteState: const AsyncValue<void>.data(null),
          );
        },
      );
    } catch (e, stackTrace) {
      state = state.copyWith(
        deleteState: AsyncValue<void>.error(e, stackTrace),
      );
    }
  }

  /// Reset save state (for clearing success/error states)
  void resetSaveState() {
    state = state.copyWith(
      saveState: const AsyncValue<void>.data(null),
    );
  }

  /// Reset delete state (for clearing success/error states)
  void resetDeleteState() {
    state = state.copyWith(
      deleteState: const AsyncValue<void>.data(null),
    );
  }

  /// Reset image state (for clearing success/error states)
  void resetImageState() {
    state = state.copyWith(
      imageState: const AsyncValue<void>.data(null),
    );
  }

  /// Check if the draft item is different from the original
  bool _isItemDirty(ClothingItem draftItem) {
    final original = state.originalItem.value;
    if (original == null) return false;

    return draftItem.name != original.name ||
           draftItem.category != original.category ||
           draftItem.color != original.color ||
           draftItem.brand != original.brand ||
           draftItem.size != original.size ||
           draftItem.notes != original.notes ||
           draftItem.imageUrl != original.imageUrl ||
           !_areTagsEqual(draftItem.tags, original.tags);
  }

  /// Compare tag lists for equality
  bool _areTagsEqual(List<String>? tags1, List<String>? tags2) {
    if (tags1 == null && tags2 == null) return true;
    if (tags1 == null || tags2 == null) return false;
    if (tags1.length != tags2.length) return false;
    
    final sortedTags1 = List<String>.from(tags1)..sort();
    final sortedTags2 = List<String>.from(tags2)..sort();
    
    for (int i = 0; i < sortedTags1.length; i++) {
      if (sortedTags1[i] != sortedTags2[i]) return false;
    }
    
    return true;
  }

  /// Validate the item
  bool _validateItem(ClothingItem item) {
    return item.name.trim().isNotEmpty &&
           item.category != null &&
           item.category!.isNotEmpty;
  }
}
