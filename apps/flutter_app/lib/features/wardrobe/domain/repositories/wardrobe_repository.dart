import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/clothing_item.dart';

/// Repository interface for wardrobe-related data operations
/// Defines the contract for wardrobe data access layer
abstract class WardrobeRepository {
  /// Gets all clothing items for the current user
  Future<Either<Failure, List<ClothingItem>>> getClothingItems();

  /// Gets a specific clothing item by its ID
  Future<Either<Failure, ClothingItem>> getClothingItemById(String id);

  /// Adds a new clothing item to the wardrobe
  Future<Either<Failure, ClothingItem>> addClothingItem(ClothingItem item);

  /// Updates an existing clothing item
  Future<Either<Failure, ClothingItem>> updateClothingItem(ClothingItem item);

  /// Soft deletes a clothing item
  Future<Either<Failure, void>> deleteClothingItem(String id);

  /// Gets clothing items filtered by category
  Future<Either<Failure, List<ClothingItem>>> getClothingItemsByCategory(String category);

  /// Searches clothing items by name, brand, or category
  Future<Either<Failure, List<ClothingItem>>> searchClothingItems(String query);

  /// Gets clothing items filtered by color
  Future<Either<Failure, List<ClothingItem>>> getClothingItemsByColor(String color);

  /// Gets clothing items filtered by brand
  Future<Either<Failure, List<ClothingItem>>> getClothingItemsByBrand(String brand);

  /// Gets wardrobe statistics (item counts, categories, etc.)
  Future<Either<Failure, Map<String, int>>> getWardrobeStats();

  /// Batch deletes multiple clothing items
  Future<Either<Failure, void>> batchDeleteClothingItems(List<String> ids);

  /// Gets recently added items
  Future<Either<Failure, List<ClothingItem>>> getRecentlyAddedItems({int limit = 10});

  /// Checks if the current user owns a specific clothing item
  Future<Either<Failure, bool>> isClothingItemOwner(String itemId);
}
