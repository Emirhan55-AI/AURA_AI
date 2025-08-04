import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart' hide FailureMapper;
import '../../../../core/error/failure_mapper.dart';
import '../../domain/entities/swap_listing.dart';
import '../../domain/repositories/swap_market_repository.dart';
import '../services/swap_market_api_service.dart';

/// Implementation of SwapMarketRepository
class SwapMarketRepositoryImpl implements SwapMarketRepository {
  final SwapMarketApiService apiService;

  const SwapMarketRepositoryImpl(this.apiService);

  @override
  Future<Either<Failure, List<SwapListing>>> getListings(
    SwapFilterOptions filters,
  ) async {
    try {
      final models = await apiService.fetchListings(filters);
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, SwapListing?>> getListingById(String id) async {
    try {
      final model = await apiService.fetchListingById(id);
      final entity = model?.toEntity();
      return Right(entity);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, String>> createListing(
    CreateListingParams params,
  ) async {
    try {
      final listingId = await apiService.createListing(params);
      return Right(listingId);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, bool>> updateListing(
    String id,
    UpdateListingParams params,
  ) async {
    try {
      final success = await apiService.updateListing(id, params);
      return Right(success);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteListing(String id) async {
    try {
      final success = await apiService.deleteListing(id);
      return Right(success);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, bool>> saveListing(String id) async {
    try {
      final success = await apiService.saveListing(id);
      return Right(success);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, bool>> unsaveListing(String id) async {
    try {
      final success = await apiService.unsaveListing(id);
      return Right(success);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<SwapListing>>> getSavedListings() async {
    try {
      final models = await apiService.fetchSavedListings();
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, String>> uploadImage(File imageFile) async {
    try {
      final imageUrl = await apiService.uploadImage(imageFile);
      return Right(imageUrl);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<SwapListing>>> getListingsBySeller(
    String sellerId,
  ) async {
    try {
      final models = await apiService.fetchListingsBySeller(sellerId);
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<SwapListing>>> searchListings(
    String query,
    SwapFilterOptions? filters,
  ) async {
    try {
      final models = await apiService.searchListings(query, filters);
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getUserSwapStats(
    String userId,
  ) async {
    try {
      final stats = await apiService.fetchUserSwapStats(userId);
      return Right(stats);
    } catch (e) {
      return Left(FailureMapper.fromException(e));
    }
  }
}
