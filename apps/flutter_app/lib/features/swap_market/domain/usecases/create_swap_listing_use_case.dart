import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/swap_listing.dart';
import '../repositories/swap_market_repository.dart';

/// Use case for creating a new swap listing
class CreateSwapListingUseCase {
  final SwapMarketRepository repository;

  const CreateSwapListingUseCase(this.repository);

  Future<Either<Failure, String>> call(CreateListingParams params) async {
    return await repository.createListing(params);
  }
}
