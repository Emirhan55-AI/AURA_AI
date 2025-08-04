import 'package:freezed_annotation/freezed_annotation.dart';

part 'swap_listing.freezed.dart';
part 'swap_listing.g.dart';

/// Types of swap listings
enum SwapListingType {
  @JsonValue('sale')
  sale,
  @JsonValue('swap')
  swap,
}

/// Status of swap listings
enum SwapListingStatus {
  @JsonValue('active')
  active,
  @JsonValue('sold')
  sold,
  @JsonValue('swapped')
  swapped,
  @JsonValue('deleted')
  deleted,
  @JsonValue('pending')
  pending,
}

/// Main swap listing entity
@freezed
class SwapListing with _$SwapListing {
  const factory SwapListing({
    required String id,
    required String clothingItemId,
    required String sellerId,
    required String sellerName,
    String? sellerAvatarUrl,
    required String description,
    required SwapListingType type,
    double? price,
    String? currency,
    String? swapWantedFor,
    required List<String> imageUrls,
    required SwapListingStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
    @Default(0) int viewCount,
    @Default(0) int saveCount,
    @Default(false) bool isSavedByCurrentUser,
    @Default(0.0) double sellerSwapScore,
    Map<String, dynamic>? metadata,
  }) = _SwapListing;

  factory SwapListing.fromJson(Map<String, dynamic> json) =>
      _$SwapListingFromJson(json);
}

/// Filter options for swap market
@freezed
class SwapFilterOptions with _$SwapFilterOptions {
  const factory SwapFilterOptions({
    SwapListingType? type,
    String? category,
    double? minPrice,
    double? maxPrice,
    String? searchQuery,
    String? sortBy, // 'newest', 'oldest', 'price_low_high', 'price_high_low', 'most_saved'
    @Default(false) bool savedOnly,
  }) = _SwapFilterOptions;

  factory SwapFilterOptions.fromJson(Map<String, dynamic> json) =>
      _$SwapFilterOptionsFromJson(json);
}

/// Parameters for creating a new listing
@freezed
class CreateListingParams with _$CreateListingParams {
  const factory CreateListingParams({
    required String clothingItemId,
    required String description,
    required SwapListingType type,
    double? price,
    String? currency,
    String? swapWantedFor,
    @Default([]) List<String> additionalImageUrls,
  }) = _CreateListingParams;

  factory CreateListingParams.fromJson(Map<String, dynamic> json) =>
      _$CreateListingParamsFromJson(json);
}

/// Parameters for updating a listing
@freezed
class UpdateListingParams with _$UpdateListingParams {
  const factory UpdateListingParams({
    String? description,
    SwapListingType? type,
    double? price,
    String? currency,
    String? swapWantedFor,
    List<String>? additionalImageUrls,
    SwapListingStatus? status,
  }) = _UpdateListingParams;

  factory UpdateListingParams.fromJson(Map<String, dynamic> json) =>
      _$UpdateListingParamsFromJson(json);
}
