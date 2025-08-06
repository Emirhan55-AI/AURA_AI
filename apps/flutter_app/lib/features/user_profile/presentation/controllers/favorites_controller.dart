import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/favorite.dart';
import '../../domain/repositories/favorite_repository.dart';
import '../providers/favorite_providers.dart';

part 'favorites_controller.g.dart';

/// Controller for managing favorites with real backend integration
/// 
/// This controller provides:
/// - Loading favorites by type
/// - Adding/removing favorites
/// - Bulk operations
/// - Real-time state management
@riverpod
class FavoritesController extends _$FavoritesController {
  late FavoriteRepository _favoriteRepository;

  @override
  Future<List<Favorite>> build() async {
    _favoriteRepository = ref.read(favoriteRepositoryProvider);
    return await _loadAllFavorites();
  }

  /// Load all favorites for the current user
  Future<List<Favorite>> _loadAllFavorites() async {
    final result = await _favoriteRepository.getFavorites();
    
    return result.fold(
      (failure) {
        // Log the error and return empty list
        // In a production app, you might want to throw or handle this differently
        return <Favorite>[];
      },
      (favorites) => favorites,
    );
  }

  /// Get favorites by specific type
  Future<List<Favorite>> getFavoritesByType(FavoriteType type) async {
    final result = await _favoriteRepository.getFavoritesByType(type);
    
    return result.fold(
      (failure) {
        // Handle error
        return <Favorite>[];
      },
      (favorites) => favorites,
    );
  }

  /// Add an item to favorites
  Future<bool> addFavorite(String itemId, FavoriteType type, {Map<String, dynamic>? metadata}) async {
    final result = await _favoriteRepository.addFavorite(itemId, type, metadata: metadata);
    
    return result.fold(
      (failure) {
        // Handle error - could show snackbar or toast
        return false;
      },
      (favorite) {
        // Refresh the state to include the new favorite
        ref.invalidateSelf();
        return true;
      },
    );
  }

  /// Remove a favorite by favorite ID
  Future<bool> removeFavorite(String favoriteId) async {
    final result = await _favoriteRepository.removeFavorite(favoriteId);
    
    return result.fold(
      (failure) {
        // Handle error
        return false;
      },
      (_) {
        // Refresh the state to remove the favorite
        ref.invalidateSelf();
        return true;
      },
    );
  }

  /// Remove favorite by item ID and type
  Future<bool> removeFavoriteByItem(String itemId, FavoriteType type) async {
    final result = await _favoriteRepository.removeFavoriteByItem(itemId, type);
    
    return result.fold(
      (failure) {
        // Handle error
        return false;
      },
      (_) {
        // Refresh the state to remove the favorite
        ref.invalidateSelf();
        return true;
      },
    );
  }

  /// Check if an item is favorited
  Future<bool> isFavorited(String itemId, FavoriteType type) async {
    final result = await _favoriteRepository.isFavorited(itemId, type);
    
    return result.fold(
      (failure) => false,
      (isFavorited) => isFavorited,
    );
  }

  /// Bulk remove favorites
  Future<bool> removeFavorites(List<String> favoriteIds) async {
    final result = await _favoriteRepository.removeFavorites(favoriteIds);
    
    return result.fold(
      (failure) {
        // Handle error
        return false;
      },
      (_) {
        // Refresh the state to remove the favorites
        ref.invalidateSelf();
        return true;
      },
    );
  }

  /// Get favorite counts by type
  Future<Map<FavoriteType, int>> getFavoriteCounts() async {
    final result = await _favoriteRepository.getFavoriteCounts();
    
    return result.fold(
      (failure) {
        // Return empty counts on error
        return <FavoriteType, int>{};
      },
      (counts) => counts,
    );
  }

  /// Search favorites
  Future<List<Favorite>> searchFavorites(String query, {FavoriteType? type}) async {
    final result = await _favoriteRepository.searchFavorites(query, type: type);
    
    return result.fold(
      (failure) {
        // Handle error
        return <Favorite>[];
      },
      (favorites) => favorites,
    );
  }

  /// Manual refresh method for pull-to-refresh
  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}
