import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/swap_listing.dart';
import '../../domain/repositories/swap_market_repository.dart';
import '../../domain/usecases/get_swap_listings_use_case.dart';
import '../../domain/usecases/get_swap_listing_detail_use_case.dart';
import '../../domain/usecases/create_swap_listing_use_case.dart';
import '../../data/repositories/swap_market_repository_impl.dart';
import '../../data/services/swap_market_api_service.dart';

part 'swap_market_providers.g.dart';

// Core service and repository providers
@riverpod
SwapMarketApiService swapMarketApiService(SwapMarketApiServiceRef ref) {
  return SwapMarketApiService();
}

@riverpod
SwapMarketRepository swapMarketRepository(SwapMarketRepositoryRef ref) {
  final apiService = ref.watch(swapMarketApiServiceProvider);
  return SwapMarketRepositoryImpl(apiService);
}

// Use case providers
@riverpod
GetSwapListingsUseCase getSwapListingsUseCase(GetSwapListingsUseCaseRef ref) {
  final repository = ref.watch(swapMarketRepositoryProvider);
  return GetSwapListingsUseCase(repository);
}

@riverpod
GetSwapListingDetailUseCase getSwapListingDetailUseCase(
  GetSwapListingDetailUseCaseRef ref,
) {
  final repository = ref.watch(swapMarketRepositoryProvider);
  return GetSwapListingDetailUseCase(repository);
}

@riverpod
CreateSwapListingUseCase createSwapListingUseCase(
  CreateSwapListingUseCaseRef ref,
) {
  final repository = ref.watch(swapMarketRepositoryProvider);
  return CreateSwapListingUseCase(repository);
}

// Family provider for specific listing details
@riverpod
Future<SwapListing?> swapListingDetail(
  SwapListingDetailRef ref,
  String listingId,
) async {
  final useCase = ref.watch(getSwapListingDetailUseCaseProvider);
  final result = await useCase.call(listingId);
  
  return result.fold(
    (failure) => throw Exception('Failed to load listing: ${failure.message}'),
    (listing) => listing,
  );
}

// State notifier for swap market screen
@riverpod
class SwapMarketNotifier extends _$SwapMarketNotifier {
  @override
  SwapMarketState build() {
    return const SwapMarketState();
  }

  Future<void> loadListings([SwapFilterOptions? filters]) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final useCase = ref.read(getSwapListingsUseCaseProvider);
    final result = await useCase.call(filters ?? const SwapFilterOptions());
    
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (listings) => state = state.copyWith(
        isLoading: false,
        listings: listings,
        error: null,
      ),
    );
  }

  void updateFilters(SwapFilterOptions filters) {
    state = state.copyWith(filters: filters);
    loadListings(filters);
  }

  void toggleViewMode() {
    state = state.copyWith(
      viewMode: state.viewMode == SwapMarketViewMode.grid 
          ? SwapMarketViewMode.list 
          : SwapMarketViewMode.grid,
    );
  }

  Future<void> saveListing(String listingId) async {
    final repository = ref.read(swapMarketRepositoryProvider);
    await repository.saveListing(listingId);
    // Refresh listings to update saved status
    loadListings(state.filters);
  }

  Future<void> unsaveListing(String listingId) async {
    final repository = ref.read(swapMarketRepositoryProvider);
    await repository.unsaveListing(listingId);
    // Refresh listings to update saved status
    loadListings(state.filters);
  }
}

// State notifier for create listing screen
@riverpod
class CreateSwapListingNotifier extends _$CreateSwapListingNotifier {
  @override
  CreateSwapListingState build() {
    return const CreateSwapListingState();
  }

  void updateDescription(String description) {
    state = state.copyWith(description: description);
  }

  void updateType(SwapListingType type) {
    state = state.copyWith(type: type);
    // Clear the other type's field when switching
    if (type == SwapListingType.sale) {
      state = state.copyWith(swapWantedFor: '');
    } else {
      state = state.copyWith(price: null);
    }
  }

  void updatePrice(double? price) {
    state = state.copyWith(price: price);
  }

  void updateSwapWantedFor(String swapWantedFor) {
    state = state.copyWith(swapWantedFor: swapWantedFor);
  }

  void addImage(File imageFile) {
    final updatedImages = [...state.additionalImages, imageFile];
    state = state.copyWith(additionalImages: updatedImages);
  }

  void removeImage(int index) {
    final updatedImages = [...state.additionalImages];
    updatedImages.removeAt(index);
    state = state.copyWith(additionalImages: updatedImages);
  }

  Future<String?> publishListing(String clothingItemId) async {
    if (!_isFormValid()) {
      state = state.copyWith(
        error: 'Please fill in all required fields',
      );
      return null;
    }

    state = state.copyWith(isPublishing: true, error: null);

    try {
      final repository = ref.read(swapMarketRepositoryProvider);
      
      // Upload additional images first
      final List<String> imageUrls = [];
      for (final imageFile in state.additionalImages) {
        final result = await repository.uploadImage(imageFile);
        result.fold(
          (failure) => throw Exception('Failed to upload image: ${failure.message}'),
          (imageUrl) => imageUrls.add(imageUrl),
        );
      }

      // Create listing parameters
      final params = CreateListingParams(
        clothingItemId: clothingItemId,
        description: state.description,
        type: state.type,
        price: state.price,
        currency: 'USD',
        swapWantedFor: state.swapWantedFor.isNotEmpty ? state.swapWantedFor : null,
        additionalImageUrls: imageUrls,
      );

      final useCase = ref.read(createSwapListingUseCaseProvider);
      final result = await useCase.call(params);

      return result.fold(
        (failure) {
          state = state.copyWith(
            isPublishing: false,
            error: failure.message,
          );
          return null;
        },
        (listingId) {
          state = state.copyWith(isPublishing: false);
          return listingId;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isPublishing: false,
        error: e.toString(),
      );
      return null;
    }
  }

  bool _isFormValid() {
    if (state.description.trim().isEmpty) return false;
    
    if (state.type == SwapListingType.sale) {
      return state.price != null && state.price! > 0;
    } else {
      return state.swapWantedFor.trim().isNotEmpty;
    }
  }

  void resetForm() {
    state = const CreateSwapListingState();
  }
}

// State classes
enum SwapMarketViewMode { grid, list }

class SwapMarketState {
  final List<SwapListing> listings;
  final SwapFilterOptions filters;
  final SwapMarketViewMode viewMode;
  final bool isLoading;
  final String? error;

  const SwapMarketState({
    this.listings = const [],
    this.filters = const SwapFilterOptions(),
    this.viewMode = SwapMarketViewMode.grid,
    this.isLoading = false,
    this.error,
  });

  SwapMarketState copyWith({
    List<SwapListing>? listings,
    SwapFilterOptions? filters,
    SwapMarketViewMode? viewMode,
    bool? isLoading,
    String? error,
  }) {
    return SwapMarketState(
      listings: listings ?? this.listings,
      filters: filters ?? this.filters,
      viewMode: viewMode ?? this.viewMode,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class CreateSwapListingState {
  final String description;
  final SwapListingType type;
  final double? price;
  final String swapWantedFor;
  final List<File> additionalImages;
  final bool isPublishing;
  final String? error;

  const CreateSwapListingState({
    this.description = '',
    this.type = SwapListingType.sale,
    this.price,
    this.swapWantedFor = '',
    this.additionalImages = const [],
    this.isPublishing = false,
    this.error,
  });

  CreateSwapListingState copyWith({
    String? description,
    SwapListingType? type,
    double? price,
    String? swapWantedFor,
    List<File>? additionalImages,
    bool? isPublishing,
    String? error,
  }) {
    return CreateSwapListingState(
      description: description ?? this.description,
      type: type ?? this.type,
      price: price ?? this.price,
      swapWantedFor: swapWantedFor ?? this.swapWantedFor,
      additionalImages: additionalImages ?? this.additionalImages,
      isPublishing: isPublishing ?? this.isPublishing,
      error: error,
    );
  }
}
