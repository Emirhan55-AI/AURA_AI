import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/clothing_item.dart';

/// Repository interface for user-specific wardrobe data operations
/// Defines the contract for wardrobe data access layer following Clean Architecture principles
/// This interface abstracts the data source details and provides a clean API for the domain layer
abstract class IUserWardrobeRepository {
  /// Fetches clothing items for the current user with advanced filtering and pagination
  /// 
  /// Parameters:
  /// - [page]: Page number for pagination (default: 1)
  /// - [limit]: Number of items per page (default: 20)
  /// - [searchTerm]: Optional search term to filter by name, brand, or description
  /// - [categoryIds]: Optional list of category IDs to filter by
  /// - [seasons]: Optional list of seasons to filter by
  /// - [showOnlyFavorites]: When true, only returns favorited items (default: false)
  /// - [sortBy]: Optional sorting criteria (e.g., 'created_at', 'name', 'last_worn_date')
  /// 
  /// Returns: Either a Failure or a List of ClothingItem entities
  Future<Either<Failure, List<ClothingItem>>> fetchItems({
    int page = 1,
    int limit = 20,
    String? searchTerm,
    List<String>? categoryIds,
    List<String>? seasons,
    bool showOnlyFavorites = false,
    String? sortBy,
  });

  /// Adds a new clothing item to the user's wardrobe
  /// 
  /// Parameters:
  /// - [newItem]: The ClothingItem entity to be added
  /// 
  /// Returns: Either a Failure or the created ClothingItem entity with server-generated data
  Future<Either<Failure, ClothingItem>> addItem(ClothingItem newItem);

  /// Gets a specific clothing item by its ID
  /// 
  /// Parameters:
  /// - [itemId]: The unique identifier of the clothing item
  /// 
  /// Returns: Either a Failure or the ClothingItem entity
  Future<Either<Failure, ClothingItem>> getItemById(String itemId);

  /// Updates an existing clothing item
  /// 
  /// Parameters:
  /// - [item]: The ClothingItem entity with updated data
  /// 
  /// Returns: Either a Failure or the updated ClothingItem entity
  Future<Either<Failure, ClothingItem>> updateItem(ClothingItem item);

  /// Soft deletes a clothing item by setting the deleted_at timestamp
  /// 
  /// Parameters:
  /// - [itemId]: The unique identifier of the clothing item to delete
  /// 
  /// Returns: Either a Failure or void on successful deletion
  Future<Either<Failure, void>> deleteItem(String itemId);

  /// Toggles the favorite status of a clothing item
  /// 
  /// Parameters:
  /// - [itemId]: The unique identifier of the clothing item
  /// - [isFavorite]: The new favorite status
  /// 
  /// Returns: Either a Failure or the updated ClothingItem entity
  Future<Either<Failure, ClothingItem>> toggleFavorite(String itemId, bool isFavorite);
}
