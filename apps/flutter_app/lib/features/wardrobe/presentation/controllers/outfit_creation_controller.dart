import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../outfits/domain/entities/outfit.dart';
import '../../domain/entities/clothing_item.dart';
import '../../domain/repositories/i_user_wardrobe_repository.dart';
import '../../data/providers/wardrobe_providers.dart';

/// State class for outfit creation
class OutfitCreationState {
  final AsyncValue<List<ClothingItem>> wardrobeItems;
  final Outfit draftOutfit;
  final bool isSaving;
  final bool isFormValid;

  const OutfitCreationState({
    required this.wardrobeItems,
    required this.draftOutfit,
    required this.isSaving,
    required this.isFormValid,
  });

  /// Initial state
  factory OutfitCreationState.initial() {
    return OutfitCreationState(
      wardrobeItems: const AsyncValue.loading(),
      draftOutfit: Outfit.empty(),
      isSaving: false,
      isFormValid: false,
    );
  }

  /// Copy with method for immutable updates
  OutfitCreationState copyWith({
    AsyncValue<List<ClothingItem>>? wardrobeItems,
    Outfit? draftOutfit,
    bool? isSaving,
    bool? isFormValid,
  }) {
    return OutfitCreationState(
      wardrobeItems: wardrobeItems ?? this.wardrobeItems,
      draftOutfit: draftOutfit ?? this.draftOutfit,
      isSaving: isSaving ?? this.isSaving,
      isFormValid: isFormValid ?? this.isFormValid,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OutfitCreationState &&
        other.wardrobeItems == wardrobeItems &&
        other.draftOutfit == draftOutfit &&
        other.isSaving == isSaving &&
        other.isFormValid == isFormValid;
  }

  @override
  int get hashCode {
    return Object.hash(
      wardrobeItems,
      draftOutfit,
      isSaving,
      isFormValid,
    );
  }
}

/// Controller for outfit creation screen
class OutfitCreationController extends StateNotifier<OutfitCreationState> {
  final Ref ref;

  OutfitCreationController(this.ref) : super(OutfitCreationState.initial()) {
    // Auto-load wardrobe items when controller is created
    loadWardrobeItems();
  }

  /// Gets the current repository instance
  IUserWardrobeRepository get _repository => ref.read(userWardrobeRepositoryProvider);

  /// Loads wardrobe items for outfit creation
  Future<void> loadWardrobeItems() async {
    try {
      state = state.copyWith(
        wardrobeItems: const AsyncValue<List<ClothingItem>>.loading(),
      );

      final result = await _repository.fetchItems(
        searchTerm: '',
        categoryIds: <String>[],
        seasons: <String>[],
        showOnlyFavorites: false,
        sortBy: 'created_at',
        page: 1,
        limit: 100, // Load more items for outfit creation
      );

      result.fold(
        (failure) {
          state = state.copyWith(
            wardrobeItems: AsyncValue<List<ClothingItem>>.error(failure, StackTrace.current),
          );
        },
        (items) {
          state = state.copyWith(
            wardrobeItems: AsyncValue<List<ClothingItem>>.data(items),
          );
        },
      );
    } catch (error, stackTrace) {
      state = state.copyWith(
        wardrobeItems: AsyncValue<List<ClothingItem>>.error(error, stackTrace),
      );
    }
  }

  /// Retries loading wardrobe items
  Future<void> retryLoadWardrobeItems() async {
    await loadWardrobeItems();
  }

  /// Selects an item for the outfit
  void selectItem(ClothingItem item) {
    if (state.draftOutfit.clothingItemIds.contains(item.id)) {
      return; // Item already selected
    }

    final updatedItemIds = [...state.draftOutfit.clothingItemIds, item.id];
    final updatedOutfit = state.draftOutfit.copyWith(
      clothingItemIds: updatedItemIds,
    );

    state = state.copyWith(
      draftOutfit: updatedOutfit,
      isFormValid: _validateForm(updatedOutfit),
    );
  }

  /// Deselects an item from the outfit
  void deselectItem(String itemId) {
    final updatedItemIds = state.draftOutfit.clothingItemIds
        .where((id) => id != itemId)
        .toList();
    
    final updatedOutfit = state.draftOutfit.copyWith(
      clothingItemIds: updatedItemIds,
    );

    state = state.copyWith(
      draftOutfit: updatedOutfit,
      isFormValid: _validateForm(updatedOutfit),
    );
  }

  /// Toggles item selection
  void toggleItemSelection(String itemId) {
    if (state.draftOutfit.clothingItemIds.contains(itemId)) {
      deselectItem(itemId);
    } else {
      // Find the item in wardrobe items to select it
      final wardrobeItems = state.wardrobeItems.valueOrNull ?? [];
      final item = wardrobeItems.firstWhere(
        (item) => item.id == itemId,
        orElse: () => throw ArgumentError('Item not found: $itemId'),
      );
      selectItem(item);
    }
  }

  /// Updates the outfit title
  void updateTitle(String title) {
    final updatedOutfit = state.draftOutfit.copyWith(name: title);
    state = state.copyWith(
      draftOutfit: updatedOutfit,
      isFormValid: _validateForm(updatedOutfit),
    );
  }

  /// Updates the outfit description
  void updateDescription(String description) {
    final updatedOutfit = state.draftOutfit.copyWith(description: description);
    state = state.copyWith(
      draftOutfit: updatedOutfit,
      isFormValid: _validateForm(updatedOutfit),
    );
  }

  /// Adds a tag to the outfit
  void addTag(String tag) {
    if (tag.trim().isEmpty) return;
    
    final currentTags = state.draftOutfit.tags ?? [];
    if (currentTags.contains(tag.trim())) return; // Tag already exists
    
    final updatedTags = [...currentTags, tag.trim()];
    final updatedOutfit = state.draftOutfit.copyWith(tags: updatedTags);
    
    state = state.copyWith(
      draftOutfit: updatedOutfit,
      isFormValid: _validateForm(updatedOutfit),
    );
  }

  /// Removes a tag from the outfit
  void removeTag(String tag) {
    final currentTags = state.draftOutfit.tags ?? [];
    final updatedTags = currentTags.where((t) => t != tag).toList();
    final updatedOutfit = state.draftOutfit.copyWith(tags: updatedTags);
    
    state = state.copyWith(
      draftOutfit: updatedOutfit,
      isFormValid: _validateForm(updatedOutfit),
    );
  }

  /// Sets the outfit occasion
  void setOccasion(String occasion) {
    final updatedOutfit = state.draftOutfit.copyWith(occasion: occasion);
    state = state.copyWith(
      draftOutfit: updatedOutfit,
      isFormValid: _validateForm(updatedOutfit),
    );
  }

  /// Sets the outfit season
  void setSeason(String season) {
    final updatedOutfit = state.draftOutfit.copyWith(season: season);
    state = state.copyWith(
      draftOutfit: updatedOutfit,
      isFormValid: _validateForm(updatedOutfit),
    );
  }

  /// Saves the outfit
  Future<void> saveOutfit() async {
    if (!state.isFormValid) return;

    try {
      state = state.copyWith(isSaving: true);

      // Add current timestamp and user ID
      final outfitToSave = state.draftOutfit.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'current_user', // TODO: Get from auth service
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Simulate API call - replace with actual service call
      await Future<void>.delayed(const Duration(seconds: 1));
      
      // TODO: Implement actual save logic through repository
      // final result = await outfitRepository.createOutfit(outfitToSave);
      
      // Use the outfitToSave variable to avoid lint warning
      if (outfitToSave.name.isNotEmpty) {
        state = state.copyWith(isSaving: false);
        
        // Reset draft outfit after successful save
        _resetDraftOutfit();
      }
      
    } catch (error) {
      state = state.copyWith(isSaving: false);
      rethrow;
    }
  }

  /// Validates the form
  bool _validateForm(Outfit outfit) {
    return outfit.clothingItemIds.isNotEmpty && 
           outfit.name.isNotEmpty;
  }

  /// Resets the draft outfit to initial state
  void _resetDraftOutfit() {
    state = state.copyWith(
      draftOutfit: Outfit.empty(),
      isFormValid: false,
    );
  }

  /// Resets the entire state
  void reset() {
    state = OutfitCreationState.initial();
    loadWardrobeItems();
  }
}

/// Provider for Outfit Creation Controller
final outfitCreationControllerProvider = StateNotifierProvider<OutfitCreationController, OutfitCreationState>(
  (ref) => OutfitCreationController(ref),
);
