import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/swap_listing.dart';

part 'swap_listing_model.g.dart';

/// Data model for SwapListing with JSON serialization
@JsonSerializable()
class SwapListingModel {
  final String id;
  final String clothingItemId;
  final String sellerId;
  final String sellerName;
  final String? sellerAvatarUrl;
  final String description;
  final SwapListingType type;
  final double? price;
  final String? currency;
  final String? swapWantedFor;
  final List<String> imageUrls;
  final SwapListingStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int viewCount;
  final int saveCount;
  final bool isSavedByCurrentUser;
  final double sellerSwapScore;
  final Map<String, dynamic>? metadata;

  const SwapListingModel({
    required this.id,
    required this.clothingItemId,
    required this.sellerId,
    required this.sellerName,
    this.sellerAvatarUrl,
    required this.description,
    required this.type,
    this.price,
    this.currency,
    this.swapWantedFor,
    required this.imageUrls,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.viewCount = 0,
    this.saveCount = 0,
    this.isSavedByCurrentUser = false,
    this.sellerSwapScore = 0.0,
    this.metadata,
  });

  factory SwapListingModel.fromJson(Map<String, dynamic> json) =>
      _$SwapListingModelFromJson(json);

  Map<String, dynamic> toJson() => _$SwapListingModelToJson(this);

  /// Convert to domain entity
  SwapListing toEntity() {
    return SwapListing(
      id: id,
      clothingItemId: clothingItemId,
      sellerId: sellerId,
      sellerName: sellerName,
      sellerAvatarUrl: sellerAvatarUrl,
      description: description,
      type: type,
      price: price,
      currency: currency,
      swapWantedFor: swapWantedFor,
      imageUrls: imageUrls,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      viewCount: viewCount,
      saveCount: saveCount,
      isSavedByCurrentUser: isSavedByCurrentUser,
      sellerSwapScore: sellerSwapScore,
      metadata: metadata,
    );
  }

  /// Create from domain entity
  factory SwapListingModel.fromEntity(SwapListing entity) {
    return SwapListingModel(
      id: entity.id,
      clothingItemId: entity.clothingItemId,
      sellerId: entity.sellerId,
      sellerName: entity.sellerName,
      sellerAvatarUrl: entity.sellerAvatarUrl,
      description: entity.description,
      type: entity.type,
      price: entity.price,
      currency: entity.currency,
      swapWantedFor: entity.swapWantedFor,
      imageUrls: entity.imageUrls,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      deletedAt: entity.deletedAt,
      viewCount: entity.viewCount,
      saveCount: entity.saveCount,
      isSavedByCurrentUser: entity.isSavedByCurrentUser,
      sellerSwapScore: entity.sellerSwapScore,
      metadata: entity.metadata,
    );
  }
}
