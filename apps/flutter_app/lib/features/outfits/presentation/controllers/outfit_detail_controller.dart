import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/outfit.dart';
import '../../domain/repositories/outfit_repository.dart';
import '../../../wardrobe/domain/entities/clothing_item.dart';
import '../../../social/domain/entities/comment.dart';
import '../../../social/domain/repositories/comment_repository.dart';

part 'outfit_detail_controller.g.dart';

/// State for outfit detail screen
class OutfitDetailState {
  final Outfit? outfit;
  final List<ClothingItem> items;
  final List<Comment> comments;
  final bool isLoading;
  final bool isLoadingItems;
  final bool isLoadingComments;
  final bool isSavingComment;
  final bool isPerformingAction;
  final String? error;

  const OutfitDetailState({
    this.outfit,
    this.items = const [],
    this.comments = const [],
    this.isLoading = false,
    this.isLoadingItems = false,
    this.isLoadingComments = false,
    this.isSavingComment = false,
    this.isPerformingAction = false,
    this.error,
  });

  OutfitDetailState copyWith({
    Outfit? outfit,
    List<ClothingItem>? items,
    List<Comment>? comments,
    bool? isLoading,
    bool? isLoadingItems,
    bool? isLoadingComments,
    bool? isSavingComment,
    bool? isPerformingAction,
    String? error,
  }) {
    return OutfitDetailState(
      outfit: outfit ?? this.outfit,
      items: items ?? this.items,
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      isLoadingItems: isLoadingItems ?? this.isLoadingItems,
      isLoadingComments: isLoadingComments ?? this.isLoadingComments,
      isSavingComment: isSavingComment ?? this.isSavingComment,
      isPerformingAction: isPerformingAction ?? this.isPerformingAction,
      error: error ?? this.error,
    );
  }
}

/// Controller for outfit detail screen with full functionality
@riverpod
class OutfitDetailController extends _$OutfitDetailController {
  @override
  Future<OutfitDetailState> build(String outfitId) async {
    // Load outfit data
    final outfitResult = await ref.read(outfitRepositoryProvider).getOutfitById(outfitId);
    
    return outfitResult.fold(
      (failure) => OutfitDetailState(error: failure.message),
      (outfit) async {
        // Load related data in parallel
        await Future.wait([
          _loadOutfitItems(outfit.clothingItemIds),
          _loadOutfitComments(outfitId),
        ]);
        
        return OutfitDetailState(
          outfit: outfit,
          isLoading: false,
        );
      },
    );
  }

  /// Load clothing items for the outfit
  Future<void> _loadOutfitItems(List<String> itemIds) async {
    if (itemIds.isEmpty) return;

    state = AsyncValue.data(state.value!.copyWith(isLoadingItems: true));

    try {
      final items = <ClothingItem>[];
      for (final itemId in itemIds) {
        final result = await ref.read(outfitRepositoryProvider).getClothingItemById(itemId);
        result.fold(
          (failure) => {}, // Skip failed items
          (item) => items.add(item),
        );
      }

      state = AsyncValue.data(state.value!.copyWith(
        items: items,
        isLoadingItems: false,
      ));
    } catch (e) {
      state = AsyncValue.data(state.value!.copyWith(
        isLoadingItems: false,
        error: 'Failed to load outfit items',
      ));
    }
  }

  /// Load comments for the outfit
  Future<void> _loadOutfitComments(String outfitId) async {
    state = AsyncValue.data(state.value!.copyWith(isLoadingComments: true));

    final result = await ref.read(commentRepositoryProvider).getCommentsForOutfit(outfitId);
    
    result.fold(
      (failure) => state = AsyncValue.data(state.value!.copyWith(
        isLoadingComments: false,
        error: failure.message,
      )),
      (comments) => state = AsyncValue.data(state.value!.copyWith(
        comments: comments,
        isLoadingComments: false,
      )),
    );
  }

  /// Toggle outfit favorite status
  Future<void> toggleFavorite() async {
    final currentState = state.value;
    if (currentState?.outfit == null) return;

    state = AsyncValue.data(currentState!.copyWith(isPerformingAction: true));

    final outfit = currentState.outfit!;
    final newFavoriteStatus = !outfit.isFavorite;

    final updatedOutfit = outfit.copyWith(isFavorite: newFavoriteStatus);
    final result = await ref.read(outfitRepositoryProvider).updateOutfit(updatedOutfit);

    result.fold(
      (failure) => state = AsyncValue.data(currentState.copyWith(
        isPerformingAction: false,
        error: failure.message,
      )),
      (savedOutfit) => state = AsyncValue.data(currentState.copyWith(
        outfit: savedOutfit,
        isPerformingAction: false,
      )),
    );
  }

  /// Share outfit
  Future<void> shareOutfit() async {
    final currentState = state.value;
    if (currentState?.outfit == null) return;

    state = AsyncValue.data(currentState!.copyWith(isPerformingAction: true));

    try {
      final outfit = currentState.outfit!;
      // Implement sharing logic here
      // This could involve creating a share link, opening share dialog, etc.
      
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate sharing
      
      state = AsyncValue.data(currentState.copyWith(
        isPerformingAction: false,
      ));
    } catch (e) {
      state = AsyncValue.data(currentState.copyWith(
        isPerformingAction: false,
        error: 'Failed to share outfit',
      ));
    }
  }

  /// Add comment to outfit
  Future<void> addComment(String commentText) async {
    if (commentText.trim().isEmpty) return;

    final currentState = state.value;
    if (currentState?.outfit == null) return;

    state = AsyncValue.data(currentState!.copyWith(isSavingComment: true));

    final result = await ref.read(commentRepositoryProvider).addComment(
      entityId: currentState.outfit!.id,
      entityType: 'outfit',
      content: commentText.trim(),
    );

    result.fold(
      (failure) => state = AsyncValue.data(currentState.copyWith(
        isSavingComment: false,
        error: failure.message,
      )),
      (comment) {
        final updatedComments = [...currentState.comments, comment];
        state = AsyncValue.data(currentState.copyWith(
          comments: updatedComments,
          isSavingComment: false,
        ));
      },
    );
  }

  /// Delete comment
  Future<void> deleteComment(String commentId) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(isPerformingAction: true));

    final result = await ref.read(commentRepositoryProvider).deleteComment(commentId);

    result.fold(
      (failure) => state = AsyncValue.data(currentState.copyWith(
        isPerformingAction: false,
        error: failure.message,
      )),
      (_) {
        final updatedComments = currentState.comments
            .where((comment) => comment.id != commentId)
            .toList();
        state = AsyncValue.data(currentState.copyWith(
          comments: updatedComments,
          isPerformingAction: false,
        ));
      },
    );
  }

  /// Delete outfit
  Future<void> deleteOutfit() async {
    final currentState = state.value;
    if (currentState?.outfit == null) return;

    state = AsyncValue.data(currentState!.copyWith(isPerformingAction: true));

    final result = await ref.read(outfitRepositoryProvider).deleteOutfit(
      currentState.outfit!.id,
    );

    result.fold(
      (failure) => state = AsyncValue.data(currentState.copyWith(
        isPerformingAction: false,
        error: failure.message,
      )),
      (_) {
        // Outfit deleted successfully
        // The UI should handle navigation back
      },
    );
  }

  /// Refresh outfit data
  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}
