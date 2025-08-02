import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/outfit.dart';

abstract class OutfitRepository {
  /// Get all outfits for the current user
  Future<Either<Failure, List<Outfit>>> getOutfits();
  
  /// Get outfit by ID
  Future<Either<Failure, Outfit>> getOutfit(String outfitId);
  
  /// Create a new outfit
  Future<Either<Failure, Outfit>> createOutfit(Outfit outfit);
  
  /// Update existing outfit
  Future<Either<Failure, Outfit>> updateOutfit(Outfit outfit);
  
  /// Delete outfit (soft delete)
  Future<Either<Failure, void>> deleteOutfit(String outfitId);
  
  /// Get outfits by occasion
  Future<Either<Failure, List<Outfit>>> getOutfitsByOccasion(String occasion);
  
  /// Get outfits by season
  Future<Either<Failure, List<Outfit>>> getOutfitsBySeason(String season);
  
  /// Get favorite outfits
  Future<Either<Failure, List<Outfit>>> getFavoriteOutfits();
  
  /// Get recently worn outfits
  Future<Either<Failure, List<Outfit>>> getRecentlyWornOutfits({int limit = 10});
  
  /// Get least worn outfits
  Future<Either<Failure, List<Outfit>>> getLeastWornOutfits({int limit = 10});
  
  /// Search outfits by name or tags
  Future<Either<Failure, List<Outfit>>> searchOutfits(String query);
  
  /// Mark outfit as worn
  Future<Either<Failure, Outfit>> markOutfitAsWorn(String outfitId);
  
  /// Toggle favorite status
  Future<Either<Failure, Outfit>> toggleFavorite(String outfitId);
  
  /// Rate outfit
  Future<Either<Failure, Outfit>> rateOutfit(String outfitId, double rating);
  
  /// Get outfit statistics
  Future<Either<Failure, Map<String, dynamic>>> getOutfitStatistics();
  
  /// Get outfits containing specific clothing item
  Future<Either<Failure, List<Outfit>>> getOutfitsWithClothingItem(String clothingItemId);
  
  /// Get public outfits for social feed
  Future<Either<Failure, List<Outfit>>> getPublicOutfits({int page = 1, int limit = 20});
  
  /// Get outfits by style
  Future<Either<Failure, List<Outfit>>> getOutfitsByStyle(String style);
}
