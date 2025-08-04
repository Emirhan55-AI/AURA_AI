import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/swap_listing.dart';

/// Repository interface for swap market operations
abstract class SwapMarketRepository {
  /// Get all swap listings with optional filters
  Future<Either<Failure, List<SwapListing>>> getListings(
    SwapFilterOptions filters,
  );

  /// Get a specific listing by ID
  Future<Either<Failure, SwapListing?>> getListingById(String id);

  /// Create a new swap listing
  Future<Either<Failure, String>> createListing(
    CreateListingParams params,
  );

  /// Update an existing listing
  Future<Either<Failure, bool>> updateListing(
    String id,
    UpdateListingParams params,
  );

  /// Delete a listing
  Future<Either<Failure, bool>> deleteListing(String id);

  /// Save/favorite a listing for the current user
  Future<Either<Failure, bool>> saveListing(String id);

  /// Remove listing from saved/favorites
  Future<Either<Failure, bool>> unsaveListing(String id);

  /// Get saved listings for the current user
  Future<Either<Failure, List<SwapListing>>> getSavedListings();

  /// Upload an image for a listing
  Future<Either<Failure, String>> uploadImage(File imageFile);

  /// Get listings by seller ID
  Future<Either<Failure, List<SwapListing>>> getListingsBySeller(
    String sellerId,
  );

  /// Search listings
  Future<Either<Failure, List<SwapListing>>> searchListings(
    String query,
    SwapFilterOptions? filters,
  );

  /// Get swap statistics for a user (for swap score calculation)
  Future<Either<Failure, Map<String, dynamic>>> getUserSwapStats(
    String userId,
  );
}
