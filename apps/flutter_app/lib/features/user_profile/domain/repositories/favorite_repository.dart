import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/favorite.dart';

/// Repository interface for managing user favorites
/// 
/// This interface defines all operations for managing favorites including:
/// - Adding/removing favorites
/// - Retrieving favorites by type
/// - Bulk operations
abstract class FavoriteRepository {
  /// Get all favorites for the current user
  Future<Either<Failure, List<Favorite>>> getFavorites();

  /// Get favorites by specific type for the current user
  Future<Either<Failure, List<Favorite>>> getFavoritesByType(FavoriteType type);

  /// Add an item to favorites
  Future<Either<Failure, Favorite>> addFavorite(String itemId, FavoriteType type, {Map<String, dynamic>? metadata});

  /// Remove an item from favorites
  Future<Either<Failure, void>> removeFavorite(String favoriteId);

  /// Remove favorite by item ID and type
  Future<Either<Failure, void>> removeFavoriteByItem(String itemId, FavoriteType type);

  /// Check if an item is favorited
  Future<Either<Failure, bool>> isFavorited(String itemId, FavoriteType type);

  /// Bulk remove favorites
  Future<Either<Failure, void>> removeFavorites(List<String> favoriteIds);

  /// Get favorite count by type
  Future<Either<Failure, Map<FavoriteType, int>>> getFavoriteCounts();

  /// Search favorites by query
  Future<Either<Failure, List<Favorite>>> searchFavorites(String query, {FavoriteType? type});
}
