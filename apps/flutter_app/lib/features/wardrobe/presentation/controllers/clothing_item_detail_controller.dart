import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/clothing_item.dart';
import '../../../outfits/domain/entities/outfit.dart';
import '../../domain/repositories/i_user_wardrobe_repository.dart';
import '../../data/providers/wardrobe_providers.dart';

part 'clothing_item_detail_controller.g.dart';

/// State class for managing clothing item detail screen state
class ClothingItemDetailState {
  final AsyncValue<ClothingItem?> itemDetail;
  final AsyncValue<List<Outfit>> relatedOutfits;
  final String itemId;

  const ClothingItemDetailState({
    required this.itemDetail,
    required this.relatedOutfits,
    required this.itemId,
  });

  /// Initial state with loading item detail and empty outfits
  factory ClothingItemDetailState.initial(String itemId) {
    return ClothingItemDetailState(
      itemDetail: const AsyncValue<ClothingItem?>.loading(),
      relatedOutfits: const AsyncValue<List<Outfit>>.data([]),
      itemId: itemId,
    );
  }

  /// Copy with method for state updates
  ClothingItemDetailState copyWith({
    AsyncValue<ClothingItem?>? itemDetail,
    AsyncValue<List<Outfit>>? relatedOutfits,
    String? itemId,
  }) {
    return ClothingItemDetailState(
      itemDetail: itemDetail ?? this.itemDetail,
      relatedOutfits: relatedOutfits ?? this.relatedOutfits,
      itemId: itemId ?? this.itemId,
    );
  }
}

@riverpod
class ClothingItemDetailController extends _$ClothingItemDetailController {
  @override
  ClothingItemDetailState build(String itemId) {
    // Initialize with loading state and trigger initial load
    final initialState = ClothingItemDetailState.initial(itemId);
    
    // Start loading the item details asynchronously
    Future.microtask(() => loadItemDetails());
    
    return initialState;
  }

  /// Gets the current repository instance
  IUserWardrobeRepository get _repository => ref.read(userWardrobeRepositoryProvider);

  /// Loads the clothing item details and related outfits
  Future<void> loadItemDetails() async {
    await _loadItemDetails();
  }

  /// Internal method to load item details
  Future<void> _loadItemDetails() async {
    try {
      final currentState = state;
      
      // Update state to loading for item detail
      state = currentState.copyWith(
        itemDetail: const AsyncValue<ClothingItem?>.loading(),
      );

      // Load the specific clothing item
      final itemResult = await _repository.getItemById(currentState.itemId);
      
      itemResult.fold(
        (failure) {
          // Handle failure
          state = currentState.copyWith(
            itemDetail: AsyncValue<ClothingItem?>.error(failure, StackTrace.current),
          );
        },
        (item) async {
          // Successfully loaded item, now load related outfits
          state = currentState.copyWith(
            itemDetail: AsyncValue<ClothingItem?>.data(item),
            relatedOutfits: const AsyncValue<List<Outfit>>.loading(),
          );
          
          // Load related outfits
          await _loadRelatedOutfits();
        },
      );
    } catch (e, stackTrace) {
      final currentState = state;
      state = currentState.copyWith(
        itemDetail: AsyncValue<ClothingItem?>.error(e, stackTrace),
      );
    }
  }

  /// Loads outfits that contain this clothing item
  Future<void> _loadRelatedOutfits() async {
    try {
      final currentState = state;
      
      // Update state to loading for related outfits
      state = currentState.copyWith(
        relatedOutfits: const AsyncValue<List<Outfit>>.loading(),
      );

      // TODO: Implement actual logic to fetch outfits containing this item
      // For now, return empty list as placeholder
      await Future<void>.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      
      final relatedOutfits = <Outfit>[]; // Placeholder - would fetch from repository
      
      state = currentState.copyWith(
        relatedOutfits: AsyncValue<List<Outfit>>.data(relatedOutfits),
      );
    } catch (e, stackTrace) {
      final currentState = state;
      state = currentState.copyWith(
        relatedOutfits: AsyncValue<List<Outfit>>.error(e, stackTrace),
      );
    }
  }

  /// Toggles the favorite status of the current item
  Future<void> toggleFavorite() async {
    try {
      final currentState = state;
      final currentItem = currentState.itemDetail.valueOrNull;
      
      if (currentItem == null) return;

      // Optimistically update the UI
      final updatedItem = currentItem.copyWith(
        isFavorite: !currentItem.isFavorite,
      );
      
      state = currentState.copyWith(
        itemDetail: AsyncValue<ClothingItem?>.data(updatedItem),
      );

      // Persist the change
      final result = await _repository.toggleFavorite(
        currentState.itemId, 
        updatedItem.isFavorite,
      );

      result.fold(
        (failure) {
          // Revert the optimistic update on failure
          state = currentState.copyWith(
            itemDetail: AsyncValue<ClothingItem?>.data(currentItem),
          );
        },
        (persistedItem) {
          // Update with the server response
          state = currentState.copyWith(
            itemDetail: AsyncValue<ClothingItem?>.data(persistedItem),
          );
        },
      );
    } catch (e, stackTrace) {
      // Handle unexpected errors
      final currentState = state;
      state = currentState.copyWith(
        itemDetail: AsyncValue<ClothingItem?>.error(e, stackTrace),
      );
    }
  }

  /// Handles sharing the current item
  Future<void> shareItem() async {
    try {
      final currentState = state;
      final currentItem = currentState.itemDetail.valueOrNull;
      
      if (currentItem == null) return;

      // Create share content with item details
      final shareText = '''
Check out this ${currentItem.category ?? 'clothing item'}: ${currentItem.name}
${currentItem.brand != null ? 'Brand: ${currentItem.brand}' : ''}
${currentItem.color != null ? 'Color: ${currentItem.color}' : ''}
${currentItem.size != null ? 'Size: ${currentItem.size}' : ''}

Shared from Aura Wardrobe App
''';

      // Use platform's native share functionality
      // This would typically use a share plugin like share_plus
      // For now, we'll simulate the sharing action
      await Future<void>.delayed(const Duration(milliseconds: 300));
      
      // In a real implementation, you would use:
      // await Share.share(shareText, subject: 'Check out my ${currentItem.name}');
      
      // Log the share action or show success feedback
      print('Sharing item: ${currentItem.name}');
      print('Share content: $shareText');
    } catch (e) {
      // Handle sharing errors silently or through a callback
    }
  }

  /// Handles deleting the current item
  Future<void> deleteItem() async {
    try {
      final currentState = state;
      final currentItem = currentState.itemDetail.valueOrNull;
      
      if (currentItem == null) return;

      // Call repository to delete the item
      final result = await _repository.deleteItem(currentState.itemId);

      result.fold(
        (failure) {
          // Handle deletion failure - could expose through state
          state = currentState.copyWith(
            itemDetail: AsyncValue<ClothingItem?>.error(failure.toString(), StackTrace.current),
          );
        },
        (_) {
          // Item successfully deleted
          // The UI should handle navigation back after successful deletion
        },
      );
    } catch (e, stackTrace) {
      final currentState = state;
      state = currentState.copyWith(
        itemDetail: AsyncValue<ClothingItem?>.error(e, stackTrace),
      );
    }
  }

  /// Retries loading the item details after a failure
  Future<void> retryLoadItemDetails() async {
    await _loadItemDetails();
  }

  /// Retries loading the related outfits after a failure
  Future<void> retryLoadRelatedOutfits() async {
    await _loadRelatedOutfits();
  }

  /// Prepares data for editing (if needed before navigation)
  Future<void> prepareForEdit() async {
    // TODO: Implement any preparation logic needed before editing
    // This could involve caching current state, preparing form data, etc.
  }
}
