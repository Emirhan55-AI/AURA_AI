import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/swap_listing.dart';
import '../repositories/swap_market_repository.dart';

/// Use case for getting swap listings with filters
class GetSwapListingsUseCase {
  final SwapMarketRepository repository;

  const GetSwapListingsUseCase(this.repository);

  Future<Either<Failure, List<SwapListing>>> call(
    SwapFilterOptions filters,
  ) async {
    return await repository.getListings(filters);
  }
}
