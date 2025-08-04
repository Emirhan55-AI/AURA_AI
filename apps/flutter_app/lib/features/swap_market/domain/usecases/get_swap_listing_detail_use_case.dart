import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/swap_listing.dart';
import '../repositories/swap_market_repository.dart';

/// Use case for getting a specific swap listing detail
class GetSwapListingDetailUseCase {
  final SwapMarketRepository repository;

  const GetSwapListingDetailUseCase(this.repository);

  Future<Either<Failure, SwapListing?>> call(String listingId) async {
    return await repository.getListingById(listingId);
  }
}
